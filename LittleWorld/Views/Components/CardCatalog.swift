import SwiftUI

struct CardCatalog: View {
    let kind: CardKind
    @Binding var searchText: String
    let selectedCard: GameCard?
    let toggleSelection: (GameCard) -> Void

    private var cards: [GameCard] {
        kind == .races ? CardRepository.races : CardRepository.powers
    }

    private var filteredCards: [GameCard] {
        searchText.isEmpty ? cards : cards.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(kind.rawValue)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            if filteredCards.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                List(filteredCards) { card in
                    CardRow(
                        card: card,
                        isSelected: selectedCard?.id == card.id,
                        toggleSelection: { toggleSelection(card) }
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}
