import Foundation

struct CardPair: Identifiable {
    let id = UUID()
    let power: GameCard
    let race: GameCard
}
