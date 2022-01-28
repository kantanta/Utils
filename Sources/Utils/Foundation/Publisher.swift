import Foundation

open class Publisher<Subscriber> {
    private var subscribers = NSHashTable<AnyObject>.weakObjects()

    public init() {}

    public func subscribe(_ subscriber: Subscriber) {
        subscribers.add(subscriber as AnyObject)
    }

    public func unsubscribe(_ subscriber: Subscriber) {
        subscribers.remove(subscriber as AnyObject)
    }

    public func subscribersInvokeOnCurrentQueue(_ execute: @escaping (Subscriber) -> Void) {
        subscribers.allObjects
            .compactMap { $0 as? Subscriber }
            .forEach(execute)
    }

    public func subscribersInvoke(_ execute: @escaping (Subscriber) -> Void) {
        DispatchQueue.mainOrAsync {
            self.subscribersInvokeOnCurrentQueue(execute)
        }
    }
}
