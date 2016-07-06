import Foundation

class Tokenizer {
    private var codeStream: CharStream
    private(set) internal var current: Token = Variable(value: "placeholder")

    var hasMore: Bool { return codeStream.hasMore }

    init(code: CharStream) {
        codeStream = code
        advance()
    }

    func advance() {
        current = takeNext()
    }
}

private extension Tokenizer {
    func takeNext() -> Token {
        switch codeStream.current {
        case isWhitespace:
            return Whitespace(value: take(matching: isWhitespace))
        case isNumber:
            return Integer(value: take(matching: isNumber))
        case isIdent:
            let ident = take(matching: isIdent)
            if let key = Keyword(string: ident) {
                return key
            } else {
                return Variable(value: ident)
            }
        case isOperator:
            let opString = take(matching: isOperator)
            guard let opChar = opString.characters.first, opToken = Operator(char: opChar) where opString.characters.count == 1 else {
                fatalError("Illegal Operator: \(opString)")
            }

            return opToken
        default:
            fatalError("Illegal Character: \"\(codeStream.current)\"")
        }
    }

    func take(matching matches:(Character) -> Bool) -> String {
        var taken = ""

        while matches(codeStream.current) {
            taken += String(codeStream.current)
            codeStream.advance()
        }

        return taken
    }
}

private func isWhitespace(char: Character) -> Bool {
    return char == "\n" || char == "\t" || char == " "
}

private func isNumber(char: Character) -> Bool {
    switch char {
    case "0"..."9":
        return true
    default:
        return false
    }
}

private func isOperator(char: Character) -> Bool {
    return TokenType.operators.map { op in
                return String(char) == op.rawValue
            }.reduce(false) { acc, doesMatch in
                return acc || doesMatch
            }
}

private func isIdent(char: Character) -> Bool {
    switch char {
    case "a"..."z":
        return true
    case "A"..."Z":
        return true
    case "_":
        return true
    default:
        return false
    }
}

private func ~=(pattern: (Character) -> (Bool), value: Character) -> Bool {
    return pattern(value)
}
