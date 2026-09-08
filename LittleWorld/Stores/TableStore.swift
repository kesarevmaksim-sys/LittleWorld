import Combine
import Foundation

final class TableStore: ObservableObject {
    @Published private(set) var pairs: [CardPair] = []

    func add(power: GameCard, race: GameCard) {
        pairs.append(CardPair(power: power, race: race))
    }

    func remove(_ pair: CardPair) {
        pairs.removeAll { $0.id == pair.id }
    }
}
