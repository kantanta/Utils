import Foundation

extension String {
    public var filenameCompatible: String {
        var invalidCharacters = CharacterSet(charactersIn: ":/")
        invalidCharacters.formUnion(.newlines)
        invalidCharacters.formUnion(.illegalCharacters)
        invalidCharacters.formUnion(.controlCharacters)
        
        return components(separatedBy: invalidCharacters)
            .joined(separator: "")
    }
}
