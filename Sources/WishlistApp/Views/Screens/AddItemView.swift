import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var inputModel = AddItemViewModel()
    let viewModel: BoardDetailViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Product URL")) {
                    TextField("Paste URL", text: $inputModel.urlString)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    Button("Fetch Preview") { Task { await inputModel.fetch() } }
                }

                if let metadata = inputModel.metadata {
                    Section(header: Text("Preview")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(metadata.title ?? "Untitled").font(.headline)
                            if let brand = metadata.brand { Text(brand).font(.subheadline) }
                            if let description = metadata.description { Text(description).font(.footnote) }
                            if let price = metadata.price, let currency = metadata.currency,
                               let formatted = Formatters.currency.string(from: price as NSNumber) {
                                Text("\(currency) \(formatted)").foregroundColor(AppTheme.accent)
                            }
                        }
                    }
                    Section {
                        Button("Add to Board") {
                            Task {
                                guard let url = URL(string: inputModel.urlString) else { return }
                                await viewModel.addItem(from: metadata, url: url)
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close", action: { dismiss() }) }
            }
        }
    }
}
