import Foundation

public func unexpected(file: String = #file, function: String = #function, line: Int = #line) {
    assertionFailure()
    //TODO: Log
}

public func unexpected<Value>(_ value: Value, file: String = #file, function: String = #function, line: Int = #line) -> Value {
    assertionFailure()
    //TODO: Log
    return value
}

public func logException<Result>(
    _ block: @autoclosure () throws -> Result,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) throws -> Result {
    do {
        return try block()
    } catch {
        //TODO: Log
        throw error
    }
}

