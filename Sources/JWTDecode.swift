import Foundation

enum JWTDecode {
    struct Decoded: Equatable {
        var headerJSON: String
        var payloadJSON: String
        var alg: String?
        var typ: String?
        var exp: TimeInterval?
        var nbf: TimeInterval?
        var iat: TimeInterval?
    }

    enum Failure: Error, Equatable {
        case noMatch
        case regexFailed
        case encoding
        case json
    }

    static func extract(_ raw: String) -> Result<String, Failure> {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let source: String
        if trimmed.lowercased().hasPrefix("bearer ") {
            source = String(trimmed.dropFirst(7))
        } else {
            source = trimmed
        }

        let pattern = #"eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+"#
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern)
        } catch {
            return .failure(.regexFailed)
        }

        let range = NSRange(source.startIndex..., in: source)
        guard let match = regex.firstMatch(in: source, options: [], range: range),
              let swiftRange = Range(match.range, in: source)
        else {
            return .failure(.noMatch)
        }
        return .success(String(source[swiftRange]))
    }

    static func decode(_ token: String) -> Result<Decoded, Failure> {
        let parts = token.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3 else {
            return .failure(.encoding)
        }
        guard let headerData = base64URLDecode(String(parts[0])),
              let payloadData = base64URLDecode(String(parts[1]))
        else {
            return .failure(.encoding)
        }
        guard let headerObject = jsonObject(from: headerData),
              let payloadObject = jsonObject(from: payloadData),
              let headerJSON = prettyPrinted(headerObject),
              let payloadJSON = prettyPrinted(payloadObject)
        else {
            return .failure(.json)
        }

        return .success(
            Decoded(
                headerJSON: headerJSON,
                payloadJSON: payloadJSON,
                alg: headerObject["alg"] as? String,
                typ: headerObject["typ"] as? String,
                exp: unixClaim(payloadObject, "exp"),
                nbf: unixClaim(payloadObject, "nbf"),
                iat: unixClaim(payloadObject, "iat")
            )
        )
    }

    static func remainingLabel(seconds remaining: TimeInterval) -> String {
        if remaining < 60 {
            return "exp \(Int(remaining))s"
        }
        if remaining < 60 * 60 {
            return "exp \(Int(remaining / 60))m"
        }
        if remaining < 48 * 60 * 60 {
            return "exp \(Int(remaining / 3600))h"
        }
        return "exp \(Int(remaining / 86400))d"
    }

    static func formatClaimDate(_ interval: TimeInterval) -> String {
        claimFormatter.string(from: Date(timeIntervalSince1970: interval))
    }

    static func algTypLine(alg: String?, typ: String?) -> String? {
        switch (alg, typ) {
        case let (a?, t?):
            return "\(a) · \(t)"
        case let (a?, nil):
            return a
        case let (nil, t?):
            return t
        case (nil, nil):
            return nil
        }
    }

    private static let claimFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter
    }()

    private static func base64URLDecode(_ string: String) -> Data? {
        var encoded = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let pad = (4 - encoded.count % 4) % 4
        if pad > 0 {
            encoded.append(String(repeating: "=", count: pad))
        }
        return Data(base64Encoded: encoded)
    }

    private static func jsonObject(from data: Data) -> [String: Any]? {
        do {
            let value = try JSONSerialization.jsonObject(with: data, options: [])
            return value as? [String: Any]
        } catch {
            return nil
        }
    }

    private static func prettyPrinted(_ object: [String: Any]) -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }

    private static func unixClaim(_ object: [String: Any], _ key: String) -> TimeInterval? {
        guard let value = object[key] else { return nil }
        if value is Bool {
            return nil
        }
        if let number = value as? NSNumber {
            return number.doubleValue
        }
        return nil
    }
}
