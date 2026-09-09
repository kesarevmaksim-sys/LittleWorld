import SwiftUI

struct CatalogView: View {
    @EnvironmentObject private var table: TableStore
    @State private var searchText = ""
    @State private var draftSearchText = ""
    @State private var isSearchPresented = false
    @State private var selectedPower: GameCard?
    @State private var selectedRace: GameCard?
    @State private var isPairAddedToastVisible = false
    @State private var isTablePresented = false

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                Image(proxy.size.width > proxy.size.height ? "table-background-landscape" : "table-background-portrait")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                Color.black.opacity(0.12)
                    .ignoresSafeArea()

                if proxy.size.width > proxy.size.height {
                    HStack(spacing: 14) {
                        CardCatalog(kind: .powers, searchText: $searchText, selectedCard: selectedPower, toggleSelection: togglePower)
                        Divider()
                            .overlay(.orange.opacity(0.55))
                        CardCatalog(kind: .races, searchText: $searchText, selectedCard: selectedRace, toggleSelection: toggleRace)
                    }
                } else {
                    VStack(spacing: 14) {
                        CardCatalog(kind: .powers, searchText: $searchText, selectedCard: selectedPower, toggleSelection: togglePower)
                        Divider()
                            .overlay(.orange.opacity(0.55))
                        CardCatalog(kind: .races, searchText: $searchText, selectedCard: selectedRace, toggleSelection: toggleRace)
                    }
                }

                if selectedPower != nil && selectedRace != nil {
                    let isLandscape = proxy.size.width > proxy.size.height
                    Button("Добавить пару на стол") {
                        table.add(power: selectedPower!, race: selectedRace!)
                        showPairAddedToast()
                    }
                    .font(isLandscape ? .subheadline.weight(.semibold) : .headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, isLandscape ? 15 : 20)
                    .padding(.vertical, isLandscape ? 9 : 13)
                    .background(.orange.opacity(0.5), in: Capsule())
                    .shadow(radius: 5)
                    .padding(.bottom, proxy.safeAreaInsets.bottom + (isLandscape ? 30 : 12))
                }

                if isPairAddedToastVisible {
                    Label("Пара добавлена на Стол", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.black.opacity(0.72), in: Capsule())
                        .shadow(radius: 6)
                        .padding(.bottom, proxy.safeAreaInsets.bottom + (proxy.size.width > proxy.size.height ? 76 : 84))
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        .zIndex(1)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            if !searchText.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.headline)
                    }
                    .accessibilityLabel("Сбросить поиск")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    draftSearchText = searchText
                    isSearchPresented = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.headline)
                }
                .accessibilityLabel("Поиск карточек")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isTablePresented = true
                } label: {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.headline)
                }
                .accessibilityLabel("Перейти на Стол")
            }
        }
        .sheet(isPresented: $isSearchPresented) {
            CatalogSearchSheet(searchText: $draftSearchText) { query in
                searchText = query.trimmingCharacters(in: .whitespacesAndNewlines)
                isSearchPresented = false
            }
            .presentationDetents([.height(210)])
        }
        .navigationDestination(isPresented: $isTablePresented) {
            TableView()
                .environmentObject(table)
        }
        .tint(.orange)
    }

    private func togglePower(_ card: GameCard) {
        selectedPower = selectedPower?.id == card.id ? nil : card
    }

    private func toggleRace(_ card: GameCard) {
        selectedRace = selectedRace?.id == card.id ? nil : card
    }

    private func showPairAddedToast() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            isPairAddedToastVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.2)) {
                isPairAddedToastVisible = false
            }
        }
    }
}
