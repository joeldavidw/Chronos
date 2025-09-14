import Foundation

final class SecureBytes {
    private var bytes: [UInt8]
    private var length: Int

    init(bytes: [UInt8]) {
        length = bytes.count
        self.bytes = bytes.withUnsafeBufferPointer { [UInt8]($0) }

        _ = self.bytes.withUnsafeBufferPointer { pointer in
            mlock(pointer.baseAddress, pointer.count)
        }
    }

    deinit {
        self.clear()
    }

    func clear() {
        bytes = [UInt8](repeating: 0, count: length)
        length = 0

        _ = bytes.withUnsafeBufferPointer { pointer in
            munlock(pointer.baseAddress, pointer.count)
        }
    }

    private init(copying _: SecureBytes) {
        fatalError("Copying is not allowed for SecureBytes")
    }

    var description: String {
        return "<SecureBytes: length=\(length)>"
    }
}

extension SecureBytes: Collection {
    typealias Index = Int

    var startIndex: Index {
        return bytes.startIndex
    }

    var endIndex: Index {
        return bytes.endIndex
    }

    func index(after i: Index) -> Index {
        bytes.index(after: i)
    }

    subscript(position: Index) -> UInt8 {
        return bytes[position]
    }
}
