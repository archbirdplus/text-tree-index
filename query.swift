import Foundation

func query(fh: FileHandle, pat: Pattern, depth: Int = 3) -> [Int] {
    var tmp: [Int] = []
    walkTree(fh: fh, accumulator: &tmp, depth: depth, loc: 0, pat: pat)
    return tmp
}

// TODO: let it check the original text file to match longer patterns
func walkList(fh: FileHandle, accumulator tmp: inout [Int], loc start: UInt64, pat: Pattern) {
    print("\u{001B}[31mWarning\u{001B}[0m: regexes longer than the tree depth are not supported")
    var loc = start
    if loc == 0 { return }
    while let dat = (try! fh.read(at: loc, count: 8*2)) {
        loc = dat.prefix(8).toUInt64()
        let ind = dat.suffix(8).toUInt64()
        // let bytes = try! textFH.read(at: ind, count: pat.length)
        // if pat.match(bytes) {
        tmp.append(Int(ind))
        // }
        if loc == 0 { break }
    }
}

func walkList(fh: FileHandle, accumulator tmp: inout [Int], loc start: UInt64) {
    //
    var loc = start
    while let dat = (try! fh.read(at: loc, count: 8*2)), loc != 0 {
        loc = dat.prefix(8).toUInt64()
        let ind = dat.suffix(8).toUInt64()
        tmp.append(Int(ind))
    }
}

func walkTree(fh: FileHandle, accumulator tmp: inout [Int], depth: Int = 3, loc: UInt64 = 0) {
    guard depth > 0 else {
        walkList(fh: fh, accumulator: &tmp, loc: loc)
        return
    }
    for c in 0...256 {
        let nextLoc = (try! fh.read(at: loc + 8*UInt64(c), count: 8))!.toUInt64()
        if nextLoc != 0 {
            walkTree(fh: fh, accumulator: &tmp, depth: depth-1, loc: nextLoc)
        }
    }
}

func walkTree(fh: FileHandle, accumulator tmp: inout [Int], depth: Int = 3, loc: UInt64 = 0, pat: Pattern) {
    guard depth > 0 else {
        if pat.done {
            walkList(fh: fh, accumulator: &tmp, loc: loc)
        } else {
            walkList(fh: fh, accumulator: &tmp, loc: loc, pat: pat)
        }
        return
    }
    let (next, chars) = pat.matches()
    if !pat.done {
        for c in chars {
            let nextLoc = (try! fh.read(at: loc + 8*UInt64(c), count: 8))!.toUInt64()
            if nextLoc != 0 {
                walkTree(fh: fh, accumulator: &tmp, depth: depth-1, loc: nextLoc, pat: next)
            }
        }
    } else {
        for c in 0...256 {
            let nextLoc = (try! fh.read(at: loc + 8*UInt64(c), count: 8))!.toUInt64()
            if nextLoc != 0 {
                walkTree(fh: fh, accumulator: &tmp, depth: depth-1, loc: nextLoc)
            }
        }
    }
}

func query(fh: FileHandle, str: String, depth: Int = 3) -> [Int] {
    let word = [UInt8](str.utf8)
    var loc: UInt64 = 0
    for i in 0..<depth {
        loc += 8*UInt64(word[i])
        loc = (try! fh.read(at: loc, count: 8))!.toUInt64()
        if loc == 0 {
            return []
        }
    }
    var tmp: [Int] = []
    while let dat = (try! fh.read(at: loc, count: 8*2)) {
        if loc == 0 { break }
        loc = dat.prefix(8).toUInt64()
        tmp.append(Int(dat.suffix(8).toUInt64()))
    }
    return tmp
}

