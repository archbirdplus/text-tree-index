import Foundation

extension UInt64 {
    func toData() -> Data {
        return withUnsafeBytes(of: self.bigEndian, Data.init(_:))
    }
}

extension Data {
    func toUInt64() -> UInt64 {
        return self.withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
    }
    func toInt() -> Int {
        return self.withUnsafeBytes { $0.load(as: Int.self).bigEndian }
    }
}

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

extension FileHandle {
    func read(at offset: UInt64, count: Int) throws -> Data? {
        try self.seek(toOffset: offset)
        return try self.read(upToCount: count)
    }
    func write(at offset: UInt64, _ data: Data) throws {
        try self.seek(toOffset: offset)
        self.write(data)
    }
    func writeToEnd(_ data: Data) throws -> UInt64 {
        try self.seekToEnd()
        let offset = try self.offset()
        self.write(data)
        return offset
    }
}

