import SwiftUI

struct HomeView: View {
    @StateObject private var table = TableStore()

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let isLandscape = proxy.size.width > proxy.size.height

                ZStack {
                    if isLandscape {
                        Image("home-background-landscape")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                    } else {
                        Image("home-background-portrait")
                            .resizable()
                            .scaledToFill()
                            .offset(x: -55)
                            .ignoresSafeArea()
                    }

                    LinearGradient(
                        colors: [.clear, .black.opacity(0.72)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    VStack(spacing: 14) {
                        Spacer()

                        NavigationLink {
                            TableView()
                                .environmentObject(table)
                        } label: {
                            HomeMenuButton(title: "Стол", symbol: "square.grid.2x2.fill")
                        }

                        NavigationLink {
                            CatalogView()
                                .environmentObject(table)
                        } label: {
                            HomeMenuButton(title: "Каталог", symbol: "rectangle.stack.fill")
                        }
                    }
                    .frame(width: min(proxy.size.width - 48, isLandscape ? 420 : 320))
                    .frame(width: proxy.size.width, alignment: .center)
                    .offset(x: isLandscape ? 0 : -20)
                    .padding(.bottom, max(proxy.safeAreaInsets.bottom + 16, 32))
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(.orange)
    }
}
