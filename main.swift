import Foundation

func prompt(_ str: String) -> String? {
    print(str, terminator: "")
    return readLine()
}

func yesOrNo(_ str: String) -> Bool? {
    while true {
        print(str, terminator: " (y/n)")
        guard let line = readLine() else { return nil }
        if ["y", "yes"].contains(line.lowercased()) { return true }
        if ["n", "no"].contains(line.lowercased()) { return false }
        print("Unrecognized input, enter 'yes' or 'no' or exit with ^D.")
    }
}

extension Array {
    @discardableResult mutating func shift() -> Self.Element? { // js
        return self.count == 0 ? nil : self.removeFirst()
    }
}

var args = CommandLine.arguments
args.shift() // callee

// init, query
guard let mode = args.shift() else {
    print("Usage:")
    print("    ./main init text_path index_path")
    print("    ./main query index_path term1 term2 term3")
    exit(0)
}

switch mode {
case "query":
    guard let path = args.shift() ?? prompt("Path of index file to query: ") else {
        print("nevermind.")
        break
    }
    guard let fh = FileHandle(forReadingAtPath: path) else {
        print("File in path \(path) not found.")
        break
    }
    defer {
        do {
            try fh.close()
        } catch { print("Failed to close handle.") }
    }

    while let line = args.shift() ?? prompt("Query a word? ") {
        let pat = Pattern(from: line)
        let result = query(fh: fh, pat: pat)
        if !result.isEmpty {
            print("String '\(line)' is found in locations \(result)")
        } else {
            print("String '\(line)' was not found")
        }
    }
case "init":
    guard let textPath = args.shift() ?? prompt("Path of text file to index: ") else {
        print("nevermind")
        break
    }

    print("Reading text from '\(textPath)'.")
    guard let textFH = FileHandle(forReadingAtPath: textPath) else {
        print("Could not make file handle for '" + textPath + "'")
        break
    }

    guard let indexLine = args.shift() ?? prompt("Path of destination index file: ") else {
        print("nevermind")
        break
    }
    var indexPath = indexLine
    if(indexLine == "") {
        indexPath = textPath + ".index"
        // print("defaulting to '\(indexPath)'")
    }

    print("Creating index in '\(indexPath)'.")
    guard FileManager.default.createFile(atPath: indexPath, contents: nil) else {
        print("could not find or create index file at path '\(indexPath)'")
        break
    }
    guard let indexFH = FileHandle(forUpdatingAtPath: indexPath) else {
        print("could not make file handle for '\(textPath)'")
        break
    }

    print("both file handles are created")

    createIndex(text: textFH, index: indexFH)

    print("index created in '\(indexPath)'")

    var errors = false
    do {
        try textFH.close()
        try indexFH.close()
    } catch (let e as NSError) {
        errors = true
        print("Error " + e.debugDescription + " while trying to close file handles.")
    }

    if(!errors) {
        print("Closed file handles with no errors.")
    }
default:
    print("Unknown mode (\(mode))- must be one of {init|query}.")
}
print("Exiting.")

