import Foundation

extension TimeInterval {
    public static var minute: TimeInterval {
        60
    }

    public static var hour: TimeInterval {
        60 * .minute
    }

    public static var day: TimeInterval {
        24 * .hour
    }
    
    public var milliseconds: TimeInterval {
        self / 1000.0
    }

    public var seconds: TimeInterval {
        self
    }

    public var minutes: TimeInterval {
        self * TimeInterval.minute
    }

    public var hours: TimeInterval {
        self * TimeInterval.hour
    }

    public var days: TimeInterval {
        self * TimeInterval.day
    }
}
