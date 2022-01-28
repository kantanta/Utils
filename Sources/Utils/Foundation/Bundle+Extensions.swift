import Foundation

public extension Bundle {
    var displayName: String? {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
    
    var releaseVersionNumber: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    var buildVersionNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}

public extension Bundle {
    enum Configuration: String {
        case debug = "Debug"
        case production = "Release"
    }

    var configuration: Configuration? {
        guard let configuration = infoDictionary?["Configuration"] as? String else {
            assertionFailure("Info.plist does not contain \"Configuration\". Add key \"Configuration\", value $(CONFIGURATION)")
            return unexpected(nil)
        }

        return Configuration(rawValue: configuration)
    }
}
