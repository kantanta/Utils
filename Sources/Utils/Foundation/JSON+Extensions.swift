import Foundation
import UIKit

extension JSONEncoder {
    public static var snakeCase: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    public static var iso8601: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

extension JSONDecoder {
    public static var snakeCase: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    public static var iso8601: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

extension Array where Element: Codable {
    public var jsonData: Data? {
        try? JSONEncoder().encode(self)
    }
}

extension Set where Element: Codable {
    public var jsonData: Data? {
        try? JSONEncoder().encode(self)
    }
}

public final class JsonColor: Decodable {
    public let color: UIColor
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hexString = try container.decode(String.self)
        
        guard let color = UIColor(argbHexString: hexString) else { throw JsonColorError.invalidFormat }
        
        self.color = color
    }
}

public enum JsonColorError: Error {
    case invalidFormat
}
