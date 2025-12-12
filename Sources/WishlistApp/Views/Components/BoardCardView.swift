import SwiftUI

struct BoardCardView: View {
    let board: WishlistBoard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(board.name)
                .font(.headline)
                .foregroundColor(.white)
            Text(board.createdAt, format: .dateTime.month().day().year())
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassCard()
    }
}
