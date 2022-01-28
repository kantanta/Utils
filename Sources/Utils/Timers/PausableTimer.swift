import Foundation

public class PausableTimer {
    public typealias Handler = (PausableTimer) -> Void

    private let timeInterval: TimeInterval
    private var handler: Handler?
    private let repeats: Bool
    private var timeLeft: TimeInterval?
    private var timer: Timer?

    public var isValid: Bool {
        onPause || timer?.isValid == true
    }

    public private(set) var onPause: Bool = false

    public init(timeInterval: TimeInterval, repeats: Bool, _ handler: @escaping Handler) {
        self.timeInterval = timeInterval
        self.repeats = repeats
        self.handler = handler
    }

    public func invalidate() {
        timer?.invalidate()
        timer = nil
        handler = nil
    }

    public func pause() {
        defer {
            timer?.invalidate()
            self.timer = nil
        }

        guard !onPause, let timer = self.timer, timer.isValid else { return }

        onPause = true
        timeLeft = max(0, timer.fireDate.timeIntervalSinceNow)
    }

    public func resume() {
        guard onPause else { return }

        schedule(timeLeft ?? timeInterval)
        timeLeft = nil
    }

    public func start() {
        schedule(timeInterval)
    }
    
    public func instantlyStart() {
        handler?(self)
        schedule(timeInterval)
    }

    private func schedule(_ interval: TimeInterval) {
        guard timer == nil else { return }

        timer = NonBlockingTimer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            // strong self
            self.timer = nil
            guard let handler = self.handler else { return }

            if self.repeats {
                self.schedule(self.timeInterval)
            } else {
                self.handler = nil
            }

            handler(self)
        }
    }
}

extension PausableTimer {
    public class func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, _ handler: @escaping Handler) -> PausableTimer {
        let timer = PausableTimer(timeInterval: interval, repeats: repeats, handler)
        timer.schedule(interval)
        return timer
    }
}
