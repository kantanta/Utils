import Foundation

public struct Identifier<RawIdentifier: Codable & Hashable, Value>: Hashable, RawRepresentable {
    public let rawValue: RawIdentifier
    
    public init(rawValue: RawIdentifier) {
        self.rawValue = rawValue
    }
}

extension Identifier: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(RawIdentifier.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

