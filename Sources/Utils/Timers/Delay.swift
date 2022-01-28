import Foundation
import UIKit

public class Delay {
    private var callback: SimpleHandler?
    private var timer: PausableTimer?

    public init(_ delay: TimeInterval, callback: @escaping SimpleHandler) {
        self.callback = callback
        
        timer = PausableTimer(timeInterval: delay, repeats: false) { _ in
            self.timer = nil
            self.callback?()
        }

        timer?.start()
        if UIApplication.shared.applicationState != .active {
            timer?.pause()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    public func invalidate() {
        timer?.invalidate()
        timer = nil

        callback = nil
    }

    @objc private func willResignActive() {
        timer?.pause()
    }

    @objc private func didBecomeActive() {
        timer?.start()
    }
}

public func delay(_ delay: TimeInterval, callback: @escaping SimpleHandler) {
    _ = Delay(delay, callback: callback)
}
