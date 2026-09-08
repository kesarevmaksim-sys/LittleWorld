import SwiftUI

struct CardRow: View {
    let card: GameCard
    let isSelected: Bool
    let toggleSelection: () -> Void

    var body: some View {
        Image(card.imageName)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .topTrailing) {
                Button(action: toggleSelection) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundStyle(isSelected ? .orange : .white)
                        .shadow(color: .black.opacity(0.6), radius: 3)
                }
                .buttonStyle(.borderless)
                .padding(10)
                .accessibilityLabel(isSelected ? "Снять выбор \(card.name)" : "Выбрать \(card.name)")
            }
            .accessibilityLabel(card.name)
    }
}
