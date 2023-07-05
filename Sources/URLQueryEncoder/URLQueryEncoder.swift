import Foundation

// MARK: - URLQueryEncoder
public final class URLQueryEncoder {

    // MARK: Lifecycle

    public init(explode: Bool = true, delimiter: String = ",", isDeepObject: Bool = false) {
        self.explode = explode
        _explode = explode
        self.delimiter = delimiter
        _delimiter = delimiter
        self.isDeepObject = isDeepObject
        _isDeepObject = isDeepObject
    }

    // MARK: Public

    /// The strategy to use for encoding `Date` values.
    public enum DateEncodingStrategy {
        /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        case iso8601

        /// Encode the `Date` as a UNIX timestamp (as a JSON number).
        case secondsSince1970

        /// Encode the `Date` as UNIX millisecond timestamp (as a JSON number).
        case millisecondsSince1970

        /// Encode the `Date` as a string formatted by the given formatter.
        case formatted(DateFormatter)

        /// Encode the `Date` as a custom value encoded by the given closure.
        ///
        /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic
        /// container in its place.
        case custom((Date) -> String)
    }

    /// The strategy to use for encoding keys.
    public enum KeyEncodingStrategy {
        /// Use the keys specified by each type. This is the default strategy.
        case useDefaultKeys
        /// Convert from "camelCaseKeys" to "snake_case_keys" before writing a key to JSON payload.
        case convertToSnakeCase
        /// Provide a custom conversion to the key in the encoded JSON from the keys specified by the encoded types.
        /// The full path to the current encoding position is provided for context (in case you need to locate this key
        /// within the payload). The returned key is used in place of the last component in the coding path before
        /// encoding.
        case custom((_ codingPath: [CodingKey]) -> CodingKey)
    }

    public var explode: Bool
    public var delimiter: String
    public var isDeepObject: Bool

    /// By default, `.iso8601`.
    public var dateEncodingStrategy: DateEncodingStrategy = .iso8601
    /// By default, `.useDefaultKeys`.
    public var keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys

    public private(set) var queryItems: [URLQueryItem] = []

    public var items: [(String, String?)] {
        queryItems.map { ($0.name, $0.value) }
    }

    /// Returns the query as a string.
    public var query: String? {
        urlComponents.query
    }

    /// Returns the query as a string with percent-encoded values.
    public var percentEncodedQuery: String? {
        urlComponents.percentEncodedQuery
    }

    public static func encode(_ body: some Encodable) -> URLQueryEncoder {
        let encoder = URLQueryEncoder()
        encoder.encode(["value": body])
        return encoder
    }

    /// Encodes value for the given key.
    @discardableResult
    public func encode(_ value: some Encodable) -> Self {
        encode(value, explode: nil, delimiter: nil, isDeepObject: nil)
    }

    /// Encodes value for the given key.
    @discardableResult
    public func encode(
        _ value: some Encodable,
        explode: Bool? = nil,
        delimiter: String? = nil,
        isDeepObject: Bool? = nil)
        -> Self
    {
        // Temporary override the settings to the duration of the call
        _explode = explode ?? self.explode
        _delimiter = delimiter ?? self.delimiter
        _isDeepObject = isDeepObject ?? self.isDeepObject

        let encoder = _URLQueryEncoder(encoder: self)
        do {
            try value.encode(to: encoder)
        } catch {
            // Assume that encoding to String never fails
            assertionFailure("URL encoding failed with an error: \(error)")
        }
        return self
    }

    // MARK: Private

    private var _explode: Bool
    private var _delimiter: String
    private var _isDeepObject: Bool

    private var urlComponents: URLComponents {
        var components = URLComponents()
        components.queryItems = queryItems
        return components
    }
}

extension URLQueryEncoder {

    // MARK: Fileprivate
    fileprivate func encodeNil(forKey _: [CodingKey]) throws {
        // Do nothing
    }

    fileprivate func encode(_ value: String, forKey codingPath: [CodingKey]) throws {
        append(value, forKey: codingPath)
    }

    fileprivate func encode(_ value: Bool, forKey codingPath: [CodingKey]) throws {
        append(value ? "true" : "false", forKey: codingPath)
    }

    fileprivate func encode(_ value: Int, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }

    fileprivate func encode(_ value: Int8, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }

    fileprivate func encode(_ value: Int16, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }

    fileprivate func encode(_ value: Int32, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }

    fileprivate func encode(_ value: Int64, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }

    fileprivate func encode(_ value: UInt, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }

    fileprivate func encode(_ value: UInt8, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }

    fileprivate func encode(_ value: UInt16, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }

    fileprivate func encode(_ value: UInt32, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }

    fileprivate func encode(_ value: UInt64, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }

    fileprivate func encode(_ value: Double, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }

    fileprivate func encode(_ value: Float, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }

    fileprivate func encode(_ value: URL, forKey codingPath: [CodingKey]) throws {
        append(value.absoluteString, forKey: codingPath)
    }

    fileprivate func encode(_ value: Date, forKey codingPath: [CodingKey]) throws {
        let string: String
        switch dateEncodingStrategy {
        case .iso8601: string = iso8601Formatter.string(from: value)
        case .secondsSince1970: string = String(value.timeIntervalSince1970)
        case .millisecondsSince1970: string = String(Int(value.timeIntervalSince1970 * 1000))
        case .formatted(let formatter): string = formatter.string(from: value)
        case .custom(let closure): string = closure(value)
        }
        append(string, forKey: codingPath)
    }

    fileprivate func encodeEncodable(_ value: some Encodable, forKey codingPath: [CodingKey]) throws {
        switch value {
        case let value as String: try encode(value, forKey: codingPath)
        case let value as Bool: try encode(value, forKey: codingPath)
        case let value as Int: try encode(value, forKey: codingPath)
        case let value as Int8: try encode(value, forKey: codingPath)
        case let value as Int16: try encode(value, forKey: codingPath)
        case let value as Int32: try encode(value, forKey: codingPath)
        case let value as Int64: try encode(value, forKey: codingPath)
        case let value as UInt: try encode(value, forKey: codingPath)
        case let value as UInt8: try encode(value, forKey: codingPath)
        case let value as UInt16: try encode(value, forKey: codingPath)
        case let value as UInt32: try encode(value, forKey: codingPath)
        case let value as UInt64: try encode(value, forKey: codingPath)
        case let value as Double: try encode(value, forKey: codingPath)
        case let value as Float: try encode(value, forKey: codingPath)
        case let value as Date: try encode(value, forKey: codingPath)
        case let value as URL: try encode(value, forKey: codingPath)
        case let value: try value.encode(to: _URLQueryEncoder(encoder: self, codingPath: codingPath))
        }
    }

    // MARK: Private

    // TODO: refactor
    private func append(_ value: String, forKey codingPath: [CodingKey]) {
        guard !codingPath.isEmpty else {
            return // Should never happen
        }

        let key: String
        switch keyEncodingStrategy {
        case .useDefaultKeys:
            key = codingPath[0].stringValue
        case .convertToSnakeCase:
            // TODO: this pattern is flawed so replace it if we ever need it
            // https://gist.github.com/dmsl1805/ad9a14b127d0409cf9621dc13d237457
            if #available(iOS 16.0, *) {
                key = codingPath[0].stringValue.replacing(#/([a-z])([A-Z])/#) {
                    "\($0.output.1)_\($0.output.2.lowercased())"
                }
            } else {
                let regex = try? NSRegularExpression(pattern: "([a-z])([A-Z])", options: [])
                let range = NSRange(location: 0, length: codingPath[0].stringValue.count)
                key = regex?.stringByReplacingMatches(in: codingPath[0].stringValue, options: [],  range: range, withTemplate: "$1_$2") ?? codingPath[0].stringValue
            }
        case .custom(let custom):
            key = custom(codingPath).stringValue
        }

        if _explode {
            if codingPath.count == 2 { // Encoding an object
                if _isDeepObject {
                    queryItems.append(URLQueryItem(name: "\(key)[\(codingPath[1].stringValue)]", value: value))
                } else {
                    queryItems.append(URLQueryItem(name: codingPath[1].stringValue, value: value))
                }
            } else {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        } else {
            if codingPath.count == 2 { // Encoding an object
                let newValue = "\(codingPath[1].stringValue),\(value)"
                if var queryItem = queryItems.last, queryItem.name == key {
                    queryItem.value = [queryItem.value, newValue].compactMap { $0 }.joined(separator: ",")
                    queryItems[queryItems.endIndex - 1] = queryItem
                } else {
                    queryItems.append(URLQueryItem(name: key, value: newValue))
                }
            } else { // Encoding an array or a primitive value
                if var queryItem = queryItems.last, queryItem.name == key {
                    queryItem.value = [queryItem.value, value].compactMap { $0 }.joined(separator: _delimiter)
                    queryItems[queryItems.endIndex - 1] = queryItem
                } else {
                    queryItems.append(URLQueryItem(name: key, value: value))
                }
            }
        }
    }
}

// MARK: - _URLQueryEncoder
private struct _URLQueryEncoder: Encoder {
    let encoder: URLQueryEncoder
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] { [:] }

    func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        KeyedEncodingContainer(KeyedContainer<Key>(encoder: encoder, codingPath: codingPath))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        UnkeyedContanier(encoder: encoder, codingPath: codingPath)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        SingleValueContanier(encoder: encoder, codingPath: codingPath)
    }
}

// MARK: - KeyedContainer
private struct KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    let encoder: URLQueryEncoder
    let codingPath: [CodingKey]

    func encode(_ value: some Encodable, forKey key: Key) throws {
        try encoder.encodeEncodable(value, forKey: codingPath + [key])
    }

    func encodeNil(forKey key: Key) throws {
        try encoder.encodeNil(forKey: codingPath + [key])
    }

    func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey>
        where NestedKey: CodingKey
    {
        assertionFailure("URLQueryEncoder doesn't support nested objects")
        return KeyedEncodingContainer(KeyedContainer<NestedKey>(encoder: encoder, codingPath: codingPath + [key]))
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        assertionFailure("URLQueryEncoder doesn't support nested objects")
        return UnkeyedContanier(encoder: encoder, codingPath: codingPath + [key])
    }

    func superEncoder() -> Encoder {
        assertionFailure("URLQueryEncoder doesn't support nested objects")
        return _URLQueryEncoder(encoder: encoder, codingPath: codingPath)
    }

    func superEncoder(forKey key: Key) -> Encoder {
        assertionFailure("URLQueryEncoder doesn't support nested objects")
        return _URLQueryEncoder(encoder: encoder, codingPath: codingPath + [key])
    }
}

// MARK: - UnkeyedContanier

private final class UnkeyedContanier: UnkeyedEncodingContainer {

    // MARK: Lifecycle

    init(encoder: URLQueryEncoder, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.codingPath = codingPath
    }

    // MARK: Internal
    var encoder: URLQueryEncoder
    var codingPath: [CodingKey]

    private(set) var count = 0

    func encodeNil() throws {
        try encoder.encodeNil(forKey: codingPath)
        count += 1
    }

    func encode(_ value: some Encodable) throws {
        try encoder.encodeEncodable(value, forKey: codingPath)
        count += 1
    }

    func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) -> KeyedEncodingContainer<NestedKey>
        where NestedKey: CodingKey
    {
        assertionFailure("URLQueryEncoder doesn't support nested objects")
        return KeyedEncodingContainer(KeyedContainer<NestedKey>(encoder: encoder, codingPath: codingPath))
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        assertionFailure("URLQueryEncoder doesn't support nested objects")
        return self
    }

    func superEncoder() -> Encoder {
        assertionFailure("URLQueryEncoder doesn't support nested objects")
        return _URLQueryEncoder(encoder: encoder, codingPath: codingPath)
    }
}

// MARK: - SingleValueContanier
private struct SingleValueContanier: SingleValueEncodingContainer {
    let encoder: URLQueryEncoder
    var codingPath: [CodingKey]

    init(encoder: URLQueryEncoder, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.codingPath = codingPath
    }

    mutating func encodeNil() throws {
        try encoder.encodeNil(forKey: codingPath)
    }

    mutating func encode(_ value: some Encodable) throws {
        try encoder.encodeEncodable(value, forKey: codingPath)
    }
}

private let iso8601Formatter = ISO8601DateFormatter()
