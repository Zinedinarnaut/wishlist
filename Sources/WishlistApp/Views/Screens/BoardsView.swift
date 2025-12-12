import SwiftUI

struct BoardsView: View {
    @EnvironmentObject private var session: SessionViewModel
    @StateObject private var viewModel: BoardsViewModel
    @State private var showingNewBoard = false
    @State private var newBoardName = ""
    @State private var renamingBoard: WishlistBoard?
    @State private var renameText = ""

    init() {
        _viewModel = StateObject(wrappedValue: BoardsViewModel(userId: ""))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                        ForEach(viewModel.boards) { board in
                            NavigationLink(value: board) {
                                BoardCardView(board: board)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Rename") {
                                    renamingBoard = board
                                    renameText = board.name
                                }
                                Button(role: .destructive) { Task { await viewModel.deleteBoard(board) } } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        Button(action: { showingNewBoard = true }) {
                            VStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                Text("New Board")
                                    .font(.footnote)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .glassCard()
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)
                }
            }
            .navigationDestination(for: WishlistBoard.self) { board in
                BoardDetailView(board: board)
            }
            .navigationTitle("Boards")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingNewBoard) {
                newBoardSheet
            }
            .alert("Rename Board", isPresented: Binding(get: { renamingBoard != nil }, set: { if !$0 { renamingBoard = nil } })) {
                TextField("Name", text: $renameText)
                Button("Save") {
                    if let board = renamingBoard {
                        Task { await viewModel.renameBoard(board, name: renameText) }
                    }
                }
                Button("Cancel", role: .cancel) { renamingBoard = nil }
            }
            .task {
                guard let userId = session.user?.id else { return }
                if viewModel.boards.isEmpty {
                    viewModel.updateUser(id: userId)
                    await viewModel.load()
                }
            }
            .refreshable {
                await viewModel.load()
            }
        }
    }

    private var newBoardSheet: some View {
        VStack(spacing: 16) {
            Capsule().frame(width: 40, height: 4).foregroundColor(.white.opacity(0.2))
            Text("New Board").font(.title3.bold())
            TextField("Name", text: $newBoardName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            Button("Create") {
                Task {
                    await viewModel.createBoard(name: newBoardName)
                    newBoardName = ""
                    showingNewBoard = false
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(newBoardName.trimmingCharacters(in: .whitespaces).isEmpty)
            Spacer()
        }
        .padding()
        .presentationDetents([.fraction(0.3)])
        .background(AppTheme.background)
    }

}
