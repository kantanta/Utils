import Foundation

public protocol URLCompatible {
    var url: URL { get }
}

public class TemporaryURL: URLCompatible {
    public private(set) var url: URL
    private var shouldRemove = true
    
    public init(url: URL) {
        self.url = url
    }
    
    public init?(name: String, directory: FileManager.SearchPathDirectory) {
        guard let directoryUrl = FileManager.default.urls(for: directory, in: .userDomainMask).first else { return nil }
        
        url = directoryUrl.appendingPathComponent(name)
    }
    
    public init?(withExtension fileExtension: String? = nil) {
        let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory())
        
        url = tempUrl.appendingPathComponent(UUID().uuidString)
        
        if let fileExtension = fileExtension {
            url = url.appendingPathExtension(fileExtension)
        }
    }
    
    public func detach() -> URL {
        shouldRemove = false
        return url
    }
    
    deinit {
        guard shouldRemove else { return }
        
        try? FileManager.default.removeItem(at: url)
    }
}

extension URL: URLCompatible {
    public var url: URL {
        self
    }
}
