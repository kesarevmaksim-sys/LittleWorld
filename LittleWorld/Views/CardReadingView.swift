import SwiftUI

struct CardReadingView: View {
    let card: GameCard
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                ZoomableCardImage(
                    imageName: card.imageName,
                    allowsDoubleTapZoom: true,
                    keepsZoomAfterGesture: true
                )
                .frame(maxWidth: .infinity)
                .padding(16)
            }
            .background(Color.black.opacity(0.92))
            .navigationTitle(card.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") { dismiss() }
                }
            }
        }
    }
}
