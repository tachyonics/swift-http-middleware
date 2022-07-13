// A structure representing a HTTP version.
public struct HTTPVersion: Equatable {
    /// Create a HTTP version.
    ///
    /// - Parameter major: The major version number.
    /// - Parameter minor: The minor version number.
    public init(major: Int, minor: Int) {
        self._major = UInt16(major)
        self._minor = UInt16(minor)
    }

    private var _minor: UInt16
    private var _major: UInt16

    /// The major version number.
    public var major: Int {
        get {
            return Int(self._major)
        }
        set {
            self._major = UInt16(newValue)
        }
    }

    /// The minor version number.
    public var minor: Int {
        get {
            return Int(self._minor)
        }
        set {
            self._minor = UInt16(newValue)
        }
    }

    /// HTTP/3
    public static let http3 = HTTPVersion(major: 3, minor: 0)

    /// HTTP/2
    public static let http2 = HTTPVersion(major: 2, minor: 0)

    /// HTTP/1.1
    public static let http1_1 = HTTPVersion(major: 1, minor: 1)

    /// HTTP/1.0
    public static let http1_0 = HTTPVersion(major: 1, minor: 0)

    /// HTTP/0.9 (not supported by SwiftNIO)
    public static let http0_9 = HTTPVersion(major: 0, minor: 9)
}
