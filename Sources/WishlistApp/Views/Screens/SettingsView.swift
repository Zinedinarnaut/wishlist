import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
        Form {
            Section(header: Text("Account")) {
                Text("Signed in as")
                if let id = session.user?.id {
                    Text(id).font(.footnote).foregroundColor(.secondary)
                }
                Button("Sign Out", role: .destructive) {
                    session.signOut()
                }
            }

            Section(header: Text("Sync")) {
                Label("iCloud Private Database", systemImage: "icloud")
                Label("End-to-end ownership via record references", systemImage: "lock.shield")
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle("Settings")
    }
}
