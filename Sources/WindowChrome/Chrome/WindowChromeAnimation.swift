import SwiftUI

enum WindowChromeAnimation {
    static let geometryResponse = 0.28

    static func titlebarOpacityResponse(isPresented: Bool) -> Double {
        isPresented ? 0.7 : 0.14
    }

    static var transaction: Transaction {
        var transaction = Transaction(animation: spring(response: geometryResponse))
        transaction[SpeedKey.self] = 1
        transaction[DelayKey.self] = 0
        return transaction
    }

    // sub_3cfd0 / sub_3d0a8 preserve transactions without an animation.
    static func replaceAnimation(in transaction: inout Transaction, response: Double) {
        guard transaction.animation != nil else { return }
        transaction.animation = spring(response: response)
            .speed(transaction[SpeedKey.self])
            .delay(transaction[DelayKey.self])
    }

    private static func spring(response: Double) -> Animation {
        .spring(response: response, dampingFraction: 1, blendDuration: 0)
    }

    private struct SpeedKey: TransactionKey {
        static let defaultValue = 1.0
    }

    private struct DelayKey: TransactionKey {
        static let defaultValue = 0.0
    }
}
