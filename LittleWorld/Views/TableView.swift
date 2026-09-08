import SwiftUI

struct TableView: View {
    @EnvironmentObject private var table: TableStore
    @State private var page = 0
    @State private var dragOffset: CGFloat = 0
    @State private var readingCard: GameCard?
    @State private var isCarouselAnimating = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Image(proxy.size.width > proxy.size.height ? "table-background-landscape" : "table-background-portrait")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                if table.pairs.isEmpty {
                    ContentUnavailableView("Стол пуст", systemImage: "square.grid.2x2", description: Text("Добавьте народ и способность в Каталоге."))
                } else {
                    let pair = table.pairs[page]
                    let previewIndex = neighboringIndex(for: dragOffset)
                    let previewPair = table.pairs[previewIndex]
                    let progress = min(abs(dragOffset) / max(proxy.size.width, 1), 1)

                    ZStack {
                        PairView(
                            pair: previewPair,
                            onOpenPower: { readingCard = previewPair.power },
                            onOpenRace: { readingCard = previewPair.race }
                        )
                        .offset(x: previewOffset(width: proxy.size.width))
                        .scaleEffect(0.94 + progress * 0.06)
                        .opacity(dragOffset == 0 ? 0 : 0.72 + progress * 0.28)
                        .allowsHitTesting(false)

                        PairView(
                            pair: pair,
                            onOpenPower: { readingCard = pair.power },
                            onOpenRace: { readingCard = pair.race }
                        )
                        .offset(x: dragOffset)
                        .scaleEffect(1 - progress * 0.06)
                        .opacity(1 - progress * 0.28)
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged {
                                guard table.pairs.count > 1, !isCarouselAnimating else { return }
                                dragOffset = $0.translation.width
                            }
                            .onEnded { gesture in
                                finishCarouselSwipe(gesture, width: proxy.size.width)
                            }
                    )
                    .overlay(alignment: .topTrailing) {
                        Button(role: .destructive) {
                            table.remove(pair)
                            page = min(page, max(table.pairs.count - 1, 0))
                        } label: {
                            Image(systemName: "trash.circle.fill")
                                .font(.title)
                                .foregroundStyle(.white, .red)
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Стол")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $readingCard) { card in
            CardReadingView(card: card)
        }
    }

    private func neighboringIndex(for offset: CGFloat) -> Int {
        guard table.pairs.count > 1 else { return page }
        return offset < 0
            ? (page + 1) % table.pairs.count
            : (page - 1 + table.pairs.count) % table.pairs.count
    }

    private func previewOffset(width: CGFloat) -> CGFloat {
        dragOffset < 0 ? width + dragOffset : -width + dragOffset
    }

    private func finishCarouselSwipe(_ gesture: DragGesture.Value, width: CGFloat) {
        guard table.pairs.count > 1, !isCarouselAnimating else { return }

        let predictedTranslation = gesture.predictedEndTranslation.width
        let translation = abs(predictedTranslation) > abs(gesture.translation.width)
            ? predictedTranslation
            : gesture.translation.width
        let threshold = max(60, width * 0.18)

        guard abs(translation) > threshold else {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                dragOffset = 0
            }
            return
        }

        let destination = translation < 0
            ? (page + 1) % table.pairs.count
            : (page - 1 + table.pairs.count) % table.pairs.count
        let destinationID = table.pairs[destination].id
        isCarouselAnimating = true

        withAnimation(.easeInOut(duration: 0.28)) {
            dragOffset = translation < 0 ? -width : width
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.29) {
            if let destinationIndex = table.pairs.firstIndex(where: { $0.id == destinationID }) {
                page = destinationIndex
            }
            dragOffset = 0
            isCarouselAnimating = false
        }
    }
}
