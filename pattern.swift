// Implements a crude regex-like pattern matching syntax. Metacharacters list:
// . -> any character
// \ -> escape next character...
//      \ -> backslash
//      n -> newline
//      d -> digit
//      D -> non-digit
//      w -> alphanumeric_
//      W -> non-alphanumeric_
//      s -> whitespace
//      S -> non-whitespace

// Pointless wrapper around a set of chars that the regex token matches
struct Token {
    let matching: Set<UInt8>

    // it's literally just the . wildcard
    static let unescapedDeltas: [String: Set<UInt8>] = [
        ".": Set<UInt8>(0...255)
    ]
    static let characterTable: [Set<UInt8>] = unescapedDeltas
        .reduce(into: (0...255).map { Set([$0]) }) { r, x in
        r[Int(x.key.first!.asciiValue!)] = x.value
    }

    static let escapedDeltas: [String: Set<UInt8>] = [
        "\\": Set<UInt8>("\\".map { $0.asciiValue! }),
        "n": Set<UInt8>("\n".map { $0.asciiValue! }),
        "d": Set<UInt8>(48..<58),
        "D": Set<UInt8>(0...255).subtracting(Set(48..<58)),
        "w": Set<UInt8>.union(Set(48..<48), Set(65...90), Set(97...122)),
        "W": Set<UInt8>(0...255).subtracting(Set<UInt8>.union(Set(48..<48), Set(65...90), Set(97...122))),
        "s": Set<UInt8>([9, 32]),
        "S": Set<UInt8>(0...255).subtracting(Set([9, 32]))
    ]
    // I wonder if this bakes into the binary...
    static let escapedCharacterTable: [Set<UInt8>] = escapedDeltas
        .reduce(into: (0...255).map { Set([$0]) }) { r, x in
        r[Int(x.key.first!.asciiValue!)] = x.value
    }

    init(character: UInt8) { 
        matching = Token.characterTable[Int(character)]
    }

    init(metaCharacter: UInt8) {
        matching = Token.escapedCharacterTable[Int(metaCharacter)]
    }
}

struct Pattern {
    let tokens: ArraySlice<Token>
    let done: Bool

    init(following prior: Pattern) {
        tokens = prior.tokens[(prior.tokens.startIndex+1)...]
        done = tokens.isEmpty
    }

    init(from str: String) {
        var tmp: [Token] = []
        var bytes = str.utf8.makeIterator()
        while let x = bytes.next() {
            if x == 92 {
                // I wonder if the compiler will inline this expression...
                bytes.next().map(Token.init(metaCharacter:)).map { tmp.append($0) }
            } else { tmp.append(Token(character: x)) }
        }
        tokens = tmp[...]
        done = tokens.isEmpty
    }

    func match(_ str: [UInt8]) -> Bool {
        var pat = self
        var bytes = str.makeIterator()
        while let byte = bytes.next(), let next = pat.match(byte) {
            if next.done { return true }
            pat = next
        }
        // Either in the case of the string being to short, or
        // the pattern couldn't be matched.
        return false 
    }

    func match(_ x: UInt8) -> Pattern? {
        return tokens[0].matching.contains(x) ? Pattern(following: self) : nil
    }

    func matches() -> (Pattern, Set<UInt8>) {
        return (Pattern(following: self), tokens.first!.matching)
    }

    var length: Int { get { tokens.count } }

}

