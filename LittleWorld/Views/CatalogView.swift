import SwiftUI

struct CatalogView: View {
    @EnvironmentObject private var table: TableStore
    @State private var searchText = ""
    @State private var draftSearchText = ""
    @State private var isSearchPresented = false
    @State private var selectedPower: GameCard?
    @State private var selectedRace: GameCard?
    @State private var pairWasAdded = false
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
                        pairWasAdded = true
                    }
                    .font(isLandscape ? .subheadline.weight(.semibold) : .headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, isLandscape ? 15 : 20)
                    .padding(.vertical, isLandscape ? 9 : 13)
                    .background(.orange.opacity(0.5), in: Capsule())
                    .shadow(radius: 5)
                    .padding(.bottom, proxy.safeAreaInsets.bottom + (isLandscape ? 30 : 12))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .navigationTitle("Каталог")
        .navigationBarTitleDisplayMode(.inline)
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
        .alert("Пара добавлена на стол", isPresented: $pairWasAdded) {
            Button("Перейти на Стол") {
                isTablePresented = true
            }
            Button("Остаться в Каталоге", role: .cancel) { }
        } message: {
            Text("\(selectedPower?.name ?? "") + \(selectedRace?.name ?? "")")
        }
        .tint(.orange)
    }

    private func togglePower(_ card: GameCard) {
        selectedPower = selectedPower?.id == card.id ? nil : card
    }

    private func toggleRace(_ card: GameCard) {
        selectedRace = selectedRace?.id == card.id ? nil : card
    }
}
