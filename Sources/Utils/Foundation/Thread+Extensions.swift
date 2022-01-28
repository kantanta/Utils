import Foundation
import Darwin.os.lock

public class OSUnfairLock: NSLocking {
    private var unfairLock: os_unfair_lock_t
    
    public init() {
        let lock = os_unfair_lock_t.allocate(capacity: 1)
        lock.initialize(repeating: os_unfair_lock_s(), count: 1)
        unfairLock = lock
    }
    
    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }
    
    public func lock() {
        os_unfair_lock_lock(unfairLock)
    }
    
    public func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
    
    public func tryLock() -> Bool {
        os_unfair_lock_trylock(unfairLock)
    }
}

public extension NSLocking {
    func synchronized<T>(block: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try block()
    }
}
