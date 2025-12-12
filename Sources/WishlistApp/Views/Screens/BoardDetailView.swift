import SwiftUI

struct BoardDetailView: View {
    @StateObject private var viewModel: BoardDetailViewModel
    @State private var showingAddItem = false

    init(board: WishlistBoard) {
        _viewModel = StateObject(wrappedValue: BoardDetailViewModel(board: board))
    }

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                ItemRowView(item: item)
                    .listRowBackground(Color.clear)
                    .swipeActions {
                        Button(role: .destructive) { Task { await viewModel.delete(item) } } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            .onMove { indices, offset in
                Task { await viewModel.reorder(from: indices, to: offset) }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle(viewModel.board.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddItem = true }) { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(viewModel: viewModel)
        }
        .task { await viewModel.load() }
    }
}
