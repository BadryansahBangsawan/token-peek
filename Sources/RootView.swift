import AppKit
import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: TokenStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: FunTheme.sectionSpacing) {
            Text("Token Peek")
                .font(.headline)

            if let errorMessage = store.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if store.expired {
                Label("Expired.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if store.notValidYet {
                Label("Not valid yet.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if store.hasToken {
                tokenContent
            } else if store.errorMessage == nil {
                ExtraEmptyState(
                    title: "No token",
                    detail: "Copy a JWT or Bearer token.",
                    actionTitle: "Read clipboard",
                    action: { store.readClipboardNow() }
                )
            }

            ExtraSettingsFooter()
        }
        .animation(reduceMotion ? nil : FunTheme.spring, value: store.hasToken)
        .animation(reduceMotion ? nil : FunTheme.spring, value: store.errorMessage)
        .animation(reduceMotion ? nil : FunTheme.spring, value: store.expired)
        .funPanel()
        .onAppear {
            store.readClipboardNow()
        }
    }

    @ViewBuilder
    private var tokenContent: some View {
        if let algTypLine = store.algTypLine {
            Text(algTypLine)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        Text("Signature not verified.")
            .font(.subheadline)
            .foregroundStyle(.secondary)

        if store.expDisplay != nil || store.nbfDisplay != nil || store.iatDisplay != nil {
            VStack(alignment: .leading, spacing: 4) {
                if let expDisplay = store.expDisplay {
                    Text("exp  \(expDisplay)")
                }
                if let nbfDisplay = store.nbfDisplay {
                    Text("nbf  \(nbfDisplay)")
                }
                if let iatDisplay = store.iatDisplay {
                    Text("iat  \(iatDisplay)")
                }
            }
            .extraRowSurface()
        }

        Text("Header")
            .font(.headline)
        TextEditor(text: .constant(store.headerJSON ?? ""))
            .font(.system(.body, design: .monospaced))
            .disabled(true)
            .frame(minHeight: 72, maxHeight: 120)
            .extraRowSurface()

        Text("Payload")
            .font(.headline)
        TextEditor(text: .constant(store.payloadJSON ?? ""))
            .font(.system(.body, design: .monospaced))
            .disabled(true)
            .frame(minHeight: 72, maxHeight: 140)
            .extraRowSurface()

        HStack {
            Button("Copy payload") {
                store.copyPayload()
            }
            .buttonStyle(.borderedProminent)
            Button("Copy header") {
                store.copyHeader()
            }
            .buttonStyle(.bordered)
        }
    }
}
