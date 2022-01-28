import Foundation

@propertyWrapper
public struct UserDefaultCodable<T: Codable> {
    public let key: String

    public init(_ key: String) {
      self.key = key
    }
    
    public var wrappedValue: T? {
        get {
            guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
            
            return try? JSONDecoder().decode(T.self, from: data)
        }
        set {
            if let data = newValue.flatMap({ try? JSONEncoder().encode($0) }) {
                UserDefaults.standard.set(data, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
}

public protocol DefaultValue {
    static var defaultValue: Self { get }
}

public protocol UserDefaultsStorable {
    static func retrieveValue(forKey: String) -> Self?
    static func storeValue(_ value: Self, forKey: String)
}

@propertyWrapper
public struct UserDefault<T: DefaultValue & UserDefaultsStorable> {
    public let key: String
    public let defaultValue: T

    public init(_ key: String, defaultValue: T = T.defaultValue) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            T.retrieveValue(forKey: key) ?? defaultValue
        }
        set {
            T.storeValue(newValue, forKey: key)
        }
    }
}

extension UserDefaultsStorable {
    public static func retrieveValue(forKey key: String) -> Self? {
        return UserDefaults.standard.value(forKey: key) as? Self
    }
    public static func storeValue(_ value: Self, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
}

extension Int: DefaultValue, UserDefaultsStorable {
    public static var defaultValue: Int { 0 }
}

extension Double: DefaultValue, UserDefaultsStorable {
    public static var defaultValue: Double { 0 }
}

extension Bool: DefaultValue, UserDefaultsStorable {
    public static var defaultValue: Bool { false }
}

extension String: DefaultValue, UserDefaultsStorable {
    public static var defaultValue: String { "" }
}

extension Date: UserDefaultsStorable {
    public static var defaultValue: Date { Date() }
}

extension Array: DefaultValue, UserDefaultsStorable where Array.Element: UserDefaultsStorable {
    public static var defaultValue: Self { [] }
}

extension Dictionary: DefaultValue, UserDefaultsStorable where Dictionary.Key: UserDefaultsStorable/*, Dictionary.Value: UserDefaultsStorable*/ {
    public static var defaultValue: Self { [:] }
}

extension Optional: DefaultValue {
    public static var defaultValue: Wrapped? { nil }
}

extension Optional: UserDefaultsStorable where Wrapped: UserDefaultsStorable {
    public static func storeValue(_ value: Self, forKey key: String) {
        switch value {
        case .some(let value):
            UserDefaults.standard.set(value, forKey: key)
        case .none:
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}

