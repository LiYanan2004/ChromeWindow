#!/bin/bash

set -euo pipefail

fail() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

usage() {
    printf '%s\n' \
        "Usage: $0 [path/to/SwiftUI_WindowPrivate.xcframework]" \
        "" \
        "Rebuilds the macOS re-export framework, preserving its Swift interfaces." \
        "DEVELOPER_DIR selects Xcode; otherwise xcrun uses the active developer directory." \
        "MACOSX_DEPLOYMENT_TARGET defaults to 15.0."
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    exit 0
fi

[[ $# -le 1 ]] || fail "Expected at most one XCFramework path."
[[ "$(uname -s)" == "Darwin" ]] || fail "This script requires macOS."

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
framework_name="SwiftUI_WindowPrivate"
xcframework_directory="${1:-$script_directory/../Sources/DarwinPrivateFrameworkOverlay/$framework_name.xcframework}"
metadata_path="$xcframework_directory/Info.plist"
deployment_target="${MACOSX_DEPLOYMENT_TARGET:-15.0}"

[[ -f "$metadata_path" ]] || fail "Missing XCFramework metadata: $metadata_path"

read_metadata() {
    /usr/bin/plutil -extract "$1" raw -o - "$metadata_path"
}

[[ "$(read_metadata AvailableLibraries)" == "1" ]] ||
    fail "Expected one macOS slice in the XCFramework."
[[ "$(read_metadata AvailableLibraries.0.SupportedPlatform)" == "macos" ]] ||
    fail "The XCFramework slice must target macOS."
[[ "$(read_metadata AvailableLibraries.0.LibraryPath)" == "$framework_name.framework" ]] ||
    fail "Expected $framework_name.framework in the XCFramework."

library_identifier="$(read_metadata AvailableLibraries.0.LibraryIdentifier)"
[[ "$library_identifier" == macos-* && "$library_identifier" != */* ]] ||
    fail "Invalid macOS library identifier: $library_identifier"

framework_directory="$xcframework_directory/$library_identifier/$framework_name.framework"
version_directory="$framework_directory/Versions/A"
framework_metadata_path="$version_directory/Resources/Info.plist"
modules_directory="$version_directory/Modules/$framework_name.swiftmodule"

[[ -f "$framework_metadata_path" ]] || fail "Missing framework metadata: $framework_metadata_path"

for link_path in \
    "$framework_directory/Versions/Current" \
    "$framework_directory/Modules" \
    "$framework_directory/Resources" \
    "$framework_directory/$framework_name"
do
    if [[ -d "$link_path" && ! -L "$link_path" ]]; then
        fail "Expected a symbolic link, found a directory: $link_path"
    fi
done

architecture_count="$(read_metadata AvailableLibraries.0.SupportedArchitectures)"
[[ "$architecture_count" -gt 0 ]] || fail "No architectures are declared in the XCFramework."
architectures=()
architecture_flags=()

for ((architecture_index = 0; architecture_index < architecture_count; architecture_index++)); do
    architecture="$(read_metadata "AvailableLibraries.0.SupportedArchitectures.$architecture_index")"
    [[ -f "$modules_directory/$architecture-apple-macos.swiftinterface" ]] ||
        fail "Missing Swift interface for architecture: $architecture"
    architectures+=("$architecture")
    architecture_flags+=(-arch "$architecture")
done

sdk_path="$(/usr/bin/xcrun --sdk macosx --show-sdk-path)" ||
    fail "Cannot locate the macOS SDK. Select Xcode with DEVELOPER_DIR or xcode-select."
compiler_path="$(/usr/bin/xcrun --sdk macosx --find clang)" ||
    fail "Cannot locate clang in the selected toolchain."
lipo_path="$(/usr/bin/xcrun --sdk macosx --find lipo)" ||
    fail "Cannot locate lipo in the selected toolchain."

printf 'SDK: %s\nArchitectures: %s\nDeployment target: %s\n' \
    "$sdk_path" "${architectures[*]}" "$deployment_target"

temporary_directory="$(mktemp -d "${TMPDIR:-/tmp}/swiftui-window-private.XXXXXX")"
trap 'rm -rf "$temporary_directory"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

temporary_binary="$temporary_directory/$framework_name"
temporary_metadata="$temporary_directory/Info.plist"

# Link an empty object and re-export the system framework's symbols.
"$compiler_path" \
    -dynamiclib \
    "${architecture_flags[@]}" \
    -isysroot "$sdk_path" \
    "-mmacosx-version-min=$deployment_target" \
    -x c /dev/null \
    -Wl,-reexport_framework,SwiftUI \
    "-Wl,-install_name,@rpath/$framework_name.framework/Versions/A/$framework_name" \
    -Wl,-current_version,1.0.0 \
    -Wl,-compatibility_version,1.0.0 \
    -o "$temporary_binary"

"$lipo_path" "$temporary_binary" -verify_arch "${architectures[@]}"

cp "$framework_metadata_path" "$temporary_metadata"
/usr/bin/plutil -replace CFBundleExecutable -string "$framework_name" "$temporary_metadata"
/usr/bin/plutil -replace CFBundleIdentifier -string "com.chromewindow.SwiftUI-WindowPrivate" "$temporary_metadata"
/usr/bin/plutil -replace CFBundleName -string "$framework_name" "$temporary_metadata"
/usr/bin/plutil -replace CFBundleShortVersionString -string "1.0.0" "$temporary_metadata"
/usr/bin/plutil -replace CFBundleVersion -string "1" "$temporary_metadata"
/usr/bin/plutil -lint -s "$temporary_metadata"

# Publish only after compilation and metadata validation have succeeded.
/usr/bin/install -m 755 "$temporary_binary" "$version_directory/$framework_name"
/usr/bin/install -m 644 "$temporary_metadata" "$framework_metadata_path"

# The old SDK stubs carry SwiftUI's install name and conflict with this framework.
rm -f "$framework_directory/$framework_name.tbd" "$version_directory/$framework_name.tbd"
ln -sfn A "$framework_directory/Versions/Current"
ln -sfn Versions/Current/Modules "$framework_directory/Modules"
ln -sfn Versions/Current/Resources "$framework_directory/Resources"
ln -sfn "Versions/Current/$framework_name" "$framework_directory/$framework_name"

printf 'Built: %s\n' "$version_directory/$framework_name"
