import Foundation

public extension Formatter {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static let iso8601Local: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static let monthFormatter: DateFormatter = {
        $0.dateFormat = "MM/yyyy"
        return $0
    }(DateFormatter())
}

public extension Date {
    var iso8601: String {
        Formatter.iso8601.string(from: self)
    }

    var iso8601Local: String {
        Formatter.iso8601Local.string(from: self)
    }
}

public extension Date {
    var millisecondsSinceReferenceDate: Int64 {
        Int64(timeIntervalSinceReferenceDate * 1000)
    }
    
    var millisecondsSince1970: Int64 {
        Int64(timeIntervalSince1970 * 1000)
    }
}

public extension Date {
    init(millisecondsSinceReferenceDate: Int64) {
        self.init(timeIntervalSinceReferenceDate: TimeInterval(millisecondsSinceReferenceDate) / 1000)
    }
}
