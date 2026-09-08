import SwiftUI

struct PairView: View {
    let pair: CardPair
    let onOpenPower: () -> Void
    let onOpenRace: () -> Void

    var body: some View {
        GeometryReader { proxy in
            Group {
                if proxy.size.width > proxy.size.height {
                    HStack(spacing: 12) {
                        cardImage(pair.power)
                            .frame(width: proxy.size.width * 0.44, height: proxy.size.height * 0.74)
                            .onTapGesture(perform: onOpenPower)
                        cardImage(pair.race)
                            .frame(width: proxy.size.width * 0.44, height: proxy.size.height * 0.74)
                            .onTapGesture(perform: onOpenRace)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(y: -28)
                } else {
                    VStack(spacing: 8) {
                        cardImage(pair.power)
                            .frame(width: proxy.size.width * 0.92, height: proxy.size.height * 0.18)
                            .onTapGesture(perform: onOpenPower)
                        cardImage(pair.race)
                            .frame(width: proxy.size.width * 0.92, height: proxy.size.height * 0.42)
                            .onTapGesture(perform: onOpenRace)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(y: -16)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private func cardImage(_ card: GameCard) -> some View {
        Image(card.imageName)
            .resizable()
            .scaledToFit()
    }
}
