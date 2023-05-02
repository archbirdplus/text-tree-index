import Foundation

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

