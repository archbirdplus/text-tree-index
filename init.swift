import Foundation

@discardableResult func createBlock(fh: FileHandle) -> UInt64 {
    let offset = try! fh.seekToEnd()
    fh.write(Data(repeating: UInt8(0), count: 8*256)) // 256 null offsets
    return offset
}

func initIndex(fh: FileHandle) {
    createBlock(fh: fh)
}

func insert(fh: FileHandle, word: [UInt8], index: UInt64, depth: Int) {
    var loc: UInt64 = 0 // location of leaf
    for i in 0..<(depth-1) {
        loc += 8*UInt64(word[i])
        var nextLoc = (try! fh.read(at: loc, count: 8)!).toUInt64()
        if nextLoc == 0 {
            // The next node is at nullpointer, so create a new node.
            nextLoc = createBlock(fh: fh)
            try! fh.write(at: loc, nextLoc.toData())
        }
        loc = nextLoc
    }
    loc += 8*UInt64(word[depth-1])
    let oldLeafLoc = (try! fh.read(at: loc, count: 8))!.toUInt64()
    // leafLoc should be zero if there is no leaf at the end
    let newLeafLoc = try! fh.writeToEnd(oldLeafLoc.toData() + index.toData())
    // Let the branch point to this new leaf.
    try! fh.write(at: loc, newLeafLoc.toData())
}

func createIndex(text: FileHandle, index: FileHandle, depth: Int = 3) {
    initIndex(fh: index)
    // for i in 0..<3
    var context: [UInt8] = [UInt8](try! text.read(upToCount: depth)!)
    var i : UInt64 = 0
    while let xs = try! text.read(upToCount: 1) {
        let x = xs[0]
        i += 1
        context.removeFirst()
        context.append(x)
        insert(fh: index, word: context, index: i, depth: depth)
    }
}

