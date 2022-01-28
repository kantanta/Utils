import Foundation

public class DispatchSpecificQueue {
    private static let key = DispatchSpecificKey<NSObject>()
    private let specific = NSObject()
    
    public let queue: DispatchQueue

    public var isCurrent: Bool {
        DispatchQueue.getSpecific(key: Self.key) === self.specific
    }
    
    public init(queue: DispatchQueue) {
        assert(queue != DispatchQueue.main)
        
        self.queue = queue
        self.queue.setSpecific(key: Self.key, value: specific)
    }
    
    public func sync<T>(execute work: () throws -> T) rethrows -> T {
        if isCurrent {
            return try work()
        } else {
            return try queue.sync(execute: work)
        }
    }
    
    public func sync<T>(execute work: () -> T) -> T {
        if isCurrent {
            return work()
        } else {
            return queue.sync(execute: work)
        }
    }
    
    public func async(execute work: @escaping () -> Void) {
        if isCurrent {
            work()
        } else {
            queue.async(execute: work)
        }
    }
}
