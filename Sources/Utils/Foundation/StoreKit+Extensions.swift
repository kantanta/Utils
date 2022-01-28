import Foundation
import StoreKit

extension SKProduct {
    public var priceString: String? {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: self.price)
    }
}

extension Swift.Error {
    private static var SSErrorDomainCode: Int { 110 }
    
    public var isStoreKitNoConnect: Bool {
        guard let storeKitError = self as? SKError else { return false }

        return storeKitError.code == .cloudServiceNetworkConnectionFailed || storeKitError.code == .unknown
    }
    
    public var isStoreKitPaymentCanceled: Bool {
        guard let storeKitError = self as? SKError else { return false }

        return storeKitError.code == .paymentCancelled
    }
    
    public var isNoInternetSSError: Bool {
        return (self as NSError).code == Self.SSErrorDomainCode
    }
}

extension SKProduct.PeriodUnit {
    func toCalendarUnit() -> NSCalendar.Unit {
        switch self {
        case .day:
            return .day
        case .month:
            return .month
        case .week:
            return .weekOfMonth
        case .year:
            return .year
        @unknown default:
            debugPrint("Unknown period unit")
        }
        return .day
    }
}

extension SKProductSubscriptionPeriod {
    open func localizedPeriod() -> String? {
        return PeriodFormatter.format(unit: unit.toCalendarUnit(), numberOfUnits: numberOfUnits)
    }
}
