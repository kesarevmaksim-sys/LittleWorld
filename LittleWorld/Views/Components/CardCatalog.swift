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

    private var titleColor: Color {
        kind == .powers
            ? Color(red: 0.96, green: 0.65, blue: 0.14)
            : Color(red: 0.14, green: 0.48, blue: 0.44)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(kind.rawValue)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(titleColor.opacity(0.72), in: Capsule())

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

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
