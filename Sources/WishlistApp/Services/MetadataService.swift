import Foundation

struct ProductMetadata {
    var title: String?
    var price: Decimal?
    var currency: String?
    var imageURL: URL?
    var brand: String?
    var description: String?
    var raw: [String: String]
}

protocol MetadataServicing {
    func fetchMetadata(from url: URL) async throws -> ProductMetadata
}

final class MetadataService: MetadataServicing {
    func fetchMetadata(from url: URL) async throws -> ProductMetadata {
        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let html = String(data: data, encoding: .utf8) else {
            return ProductMetadata(title: nil, price: nil, currency: nil, imageURL: nil, brand: nil, description: nil, raw: [:])
        }

        let tags = parseMetaTags(html: html)
        let jsonLD = parseJSONLD(html: html)

        let title = tags["og:title"] ?? jsonLD["name"] ?? tags["title"]
        let description = tags["og:description"] ?? jsonLD["description"] ?? tags["description"]
        let imageURL = URL(string: tags["og:image"] ?? jsonLD["image"] ?? "")
        let price = jsonLD.decimalValue(for: "price") ?? tags.decimalValue(for: "product:price:amount")
        let currency = jsonLD["priceCurrency"] ?? tags["product:price:currency"]
        let brand = jsonLD["brand"] ?? tags["product:brand"]

        var raw = tags
        jsonLD.forEach { raw[$0.key] = $0.value }

        return ProductMetadata(
            title: title,
            price: price,
            currency: currency,
            imageURL: imageURL,
            brand: brand,
            description: description,
            raw: raw
        )
    }

    private func parseMetaTags(html: String) -> [String: String] {
        var tags: [String: String] = [:]
        let pattern = "<meta[^>]+(property|name)=\\\"([^"]+)\\\"[^>]+content=\\\"([^"]*)\\\"[^>]*>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return tags }
        let range = NSRange(location: 0, length: html.utf16.count)
        regex.enumerateMatches(in: html, options: [], range: range) { match, _, _ in
            guard let match = match, match.numberOfRanges == 4 else { return }
            if let keyRange = Range(match.range(at: 2), in: html),
               let valueRange = Range(match.range(at: 3), in: html) {
                let key = String(html[keyRange]).lowercased()
                let value = String(html[valueRange])
                tags[key] = value
            }
        }
        return tags
    }

    private func parseJSONLD(html: String) -> [String: String] {
        guard let range = html.range(of: "<script type=\\\"application/ld+json\\\">", options: [.caseInsensitive]) else { return [:] }
        let suffix = html[range.upperBound...]
        guard let endRange = suffix.range(of: "</script>") else { return [:] }
        let jsonString = suffix[..<endRange.lowerBound]
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [:] }

        var flat: [String: String] = [:]
        json.forEach { key, value in
            if let string = value as? String {
                flat[key] = string
            } else if let number = value as? NSNumber {
                flat[key] = number.stringValue
            }
        }
        return flat
    }
}

private extension Dictionary where Key == String, Value == String {
    func decimalValue(for key: String) -> Decimal? {
        guard let string = self[key] else { return nil }
        return Decimal(string: string)
    }
}
