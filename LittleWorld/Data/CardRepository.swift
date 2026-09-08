import Foundation
import SwiftUI

enum CardRepository {
    private struct CardDescription: Decodable {
        let type: String
        let name: String
        let description: String
    }

    private static let cards = loadCards()
    static let races = cards.filter { $0.type == "race" }
    static let powers = cards.filter { $0.type == "power" }

    private static func loadCards() -> [GameCard] {
        guard let url = Bundle.main.url(forResource: "CardDescriptions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let descriptions = try? JSONDecoder().decode([CardDescription].self, from: data) else {
            assertionFailure("Не удалось загрузить CardDescriptions.json")
            return []
        }

        var indexes = ["power": 0, "race": 0]
        return descriptions.compactMap { description in
            guard description.type == "power" || description.type == "race" else { return nil }
            indexes[description.type, default: 0] += 1

            return GameCard(
                type: description.type,
                name: description.name,
                tokenCount: 0,
                imageName: String(format: "%@-%03d", description.type, indexes[description.type, default: 0]),
                symbol: "rectangle.fill",
                color: description.type == "power" ? .orange : .pink,
                description: description.description
            )
        }
    }
}
