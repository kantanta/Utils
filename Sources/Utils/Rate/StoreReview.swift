import Foundation
import StoreKit

public class StoreReview {
    public enum RequestType {
        case auto
        case native
        case url
    }
    
    public static var appId: String?
    
    public static func requestReview(with type: RequestType = .auto) {
        switch type {
        case .auto:
            let specificType = specifyAutoRequestType()
            requestReview(with: specificType)
        case .native:
            requestNativeReview()
        case .url:
            guard let url = appReviewUrl() else {
                return
            }
            requestReview(with: url)
        }
    }
    
    private static func specifyAutoRequestType() -> RequestType {
        if #available( iOS 10.3, *) {
            return .native
        }
        
        return .url
    }
    
    private static func appReviewUrl() -> URL? {
        guard let id = appId else {
            return nil
        }
        
        let string = "itms-apps://itunes.apple.com/app/" + id
        return URL(string: string)
    }
    
    private static func requestReview(with url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    private static func requestNativeReview() {
        if #available( iOS 10.3, *){
            SKStoreReviewController.requestReview()
        }
    }
}

