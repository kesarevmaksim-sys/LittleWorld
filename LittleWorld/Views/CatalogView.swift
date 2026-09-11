import SwiftUI

struct CatalogView: View {
    @EnvironmentObject private var table: TableStore
    @State private var searchText = ""
    @State private var draftSearchText = ""
    @State private var isSearchPresented = false
    @State private var selectedPower: GameCard?
    @State private var selectedRace: GameCard?
    @State private var isPairAddedToastVisible = false
    @State private var validationMessage: String?
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
                        addSelectedPair()
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

                if let validationMessage {
                    Label(validationMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.red.opacity(0.85), in: Capsule())
                        .shadow(radius: 6)
                        .padding(.horizontal, 20)
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

    private func addSelectedPair() {
        guard let selectedPower, let selectedRace else { return }

        let hasPower = table.pairs.contains { $0.power.id == selectedPower.id }
        let hasRace = table.pairs.contains { $0.race.id == selectedRace.id }

        if hasPower || hasRace {
            let message: String
            switch (hasPower, hasRace) {
            case (true, true):
                message = "Карточки с этим народом и способностью уже есть на Столе"
            case (true, false):
                message = "Карточка с этой способностью уже есть на Столе"
            case (false, true):
                message = "Карточка с этим народом уже есть на Столе"
            case (false, false):
                return
            }
            showValidation(message)
            return
        }

        table.add(power: selectedPower, race: selectedRace)
        showPairAddedToast()
    }

    private func showPairAddedToast() {
        validationMessage = nil
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            isPairAddedToastVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.2)) {
                isPairAddedToastVisible = false
            }
        }
    }

    private func showValidation(_ message: String) {
        isPairAddedToastVisible = false
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            validationMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeOut(duration: 0.2)) {
                validationMessage = nil
            }
        }
    }
}
