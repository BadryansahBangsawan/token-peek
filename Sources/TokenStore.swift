import AppKit
import Combine
import Foundation

@MainActor
final class TokenStore: ObservableObject {
    @Published var menuTitle = "Token Peek"
    @Published var errorMessage: String?
    @Published var expired = false
    @Published var notValidYet = false
    @Published var hasToken = false
    @Published var headerJSON: String?
    @Published var payloadJSON: String?
    @Published var algTypLine: String?
    @Published var expDisplay: String?
    @Published var nbfDisplay: String?
    @Published var iatDisplay: String?

    private var lastChangeCount = NSPasteboard.general.changeCount
    nonisolated(unsafe) private var clipboardTimer: Timer?
    nonisolated(unsafe) private var remainingTimer: Timer?
    private var exp: TimeInterval?
    private var nbf: TimeInterval?

    init() {
        startClipboardWatch()
    }

    deinit {
        clipboardTimer?.invalidate()
        remainingTimer?.invalidate()
    }

    func startClipboardWatch() {
        clipboardTimer?.invalidate()
        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.pollClipboard()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        clipboardTimer = timer
    }

    func readClipboardNow() {
        let pasteboard = NSPasteboard.general
        lastChangeCount = pasteboard.changeCount
        applyClipboard(pasteboard.string(forType: .string) ?? "")
    }

    func copyPayload() {
        guard let payloadJSON else { return }
        writePasteboard(payloadJSON)
    }

    func copyHeader() {
        guard let headerJSON else { return }
        writePasteboard(headerJSON)
    }

    private func pollClipboard() {
        let pasteboard = NSPasteboard.general
        let changeCount = pasteboard.changeCount
        guard changeCount != lastChangeCount else { return }
        lastChangeCount = changeCount
        applyClipboard(pasteboard.string(forType: .string) ?? "")
    }

    private func applyClipboard(_ string: String) {
        switch JWTDecode.extract(string) {
        case .failure(.regexFailed):
            clearDecode()
            errorMessage = "Internal regex failed."
            menuTitle = "Token Peek"
        case .failure:
            clearDecode()
            menuTitle = "Token Peek"
        case .success(let token):
            switch JWTDecode.decode(token) {
            case .failure(.encoding):
                clearDecode()
                errorMessage = "Invalid JWT encoding."
                menuTitle = "invalid"
            case .failure(.json):
                clearDecode()
                errorMessage = "Invalid JWT JSON."
                menuTitle = "invalid"
            case .failure:
                clearDecode()
                menuTitle = "Token Peek"
            case .success(let decoded):
                applyDecoded(decoded)
            }
        }
    }

    private func applyDecoded(_ decoded: JWTDecode.Decoded) {
        hasToken = true
        errorMessage = nil
        headerJSON = decoded.headerJSON
        payloadJSON = decoded.payloadJSON
        algTypLine = JWTDecode.algTypLine(alg: decoded.alg, typ: decoded.typ)
        exp = decoded.exp
        nbf = decoded.nbf
        if let exp = decoded.exp {
            expDisplay = JWTDecode.formatClaimDate(exp)
        } else {
            expDisplay = nil
        }
        if let nbf = decoded.nbf {
            nbfDisplay = JWTDecode.formatClaimDate(nbf)
        } else {
            nbfDisplay = nil
        }
        if let iat = decoded.iat {
            iatDisplay = JWTDecode.formatClaimDate(iat)
        } else {
            iatDisplay = nil
        }
        refreshRemaining()
        startRemainingTimer()
    }

    private func startRemainingTimer() {
        remainingTimer?.invalidate()
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshRemaining()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        remainingTimer = timer
    }

    private func stopRemainingTimer() {
        remainingTimer?.invalidate()
        remainingTimer = nil
    }

    private func refreshRemaining() {
        guard hasToken else { return }
        let now = Date().timeIntervalSince1970
        expired = false
        notValidYet = false

        if let exp {
            let remaining = exp - now
            if remaining <= 0 {
                expired = true
                menuTitle = "expired"
            } else {
                menuTitle = JWTDecode.remainingLabel(seconds: remaining)
            }
        } else {
            menuTitle = "JWT"
        }

        if let nbf, nbf > now {
            notValidYet = true
        }
    }

    private func clearDecode() {
        hasToken = false
        errorMessage = nil
        expired = false
        notValidYet = false
        headerJSON = nil
        payloadJSON = nil
        algTypLine = nil
        expDisplay = nil
        nbfDisplay = nil
        iatDisplay = nil
        exp = nil
        nbf = nil
        stopRemainingTimer()
    }

    private func writePasteboard(_ string: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
        lastChangeCount = pasteboard.changeCount
    }
}
