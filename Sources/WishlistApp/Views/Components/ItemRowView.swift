import SwiftUI

struct ItemRowView: View {
    let item: WishlistItem

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: item.imageURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ZStack {
                    Color.white.opacity(0.05)
                    Image(systemName: "bag").foregroundColor(.white.opacity(0.6))
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.white)
                if let brand = item.brand { Text(brand).font(.caption).foregroundColor(.white.opacity(0.6)) }
                if let price = item.price, let currency = item.currency,
                   let formatted = Formatters.currency.string(from: price as NSNumber) {
                    Text("\(currency) \(formatted)")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.accent)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.4))
        }
        .padding()
        .glassCard()
    }
}
