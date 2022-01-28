import Foundation
import UIKit
import AdSupport

public typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]?

public enum Environment {
    case production
    case qa
}

public protocol AppConfig {
    var launchOptions: LaunchOptions { get }
    var environment: Environment { get }
    var bundleId: String { get }
    var vendorId: String { get }
    var advertisementId: String? { get }
    var appVersion: String { get }
}

public class SystemAppConfig: AppConfig {
    public let launchOptions: LaunchOptions

    public var environment: Environment {
        guard let configuration = Bundle.main.configuration else { return unexpected(.production) }

        switch configuration {
        case .debug:
            return .qa
        case .production:
            return .production
        }
    }

    public var bundleId: String {
        Bundle.main.bundleIdentifier ?? unexpected("")
    }

    public var vendorId: String {
        UIDevice.current.identifierForVendor?.uuidString ?? unexpected("")
    }

    public var advertisementId: String? {
        let idfaAvailable: Bool
        if #available(iOS 14, *) {
            idfaAvailable = true
        } else {
            idfaAvailable = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        }
        
        guard idfaAvailable else { return nil }

        return ASIdentifierManager.shared().advertisingIdentifier.uuidString.lowercased()
    }

    public var appVersion: String {
        Bundle.main.releaseVersionNumber
    }

    public init(launchOptions: LaunchOptions) {
        self.launchOptions = launchOptions
    }
}

