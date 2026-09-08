//
//  ContentView.swift
//  LittleWorld
//
//  Created by Макс Кесарев on 06.09.2026.
//

import Combine
import Foundation
import SwiftUI

struct ContentView: View {
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
                    .padding(.bottom, max(proxy.safeAreaInsets.bottom + 16, 32))
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(.orange)
    }
}

struct HomeMenuButton: View {
    let title: String
    let symbol: String

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.title3.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.white.opacity(0.35), lineWidth: 1)
            }
    }
}

struct PlaceholderView: View {
    let title: String
    let symbol: String

    var body: some View {
        ContentUnavailableView(title, systemImage: symbol, description: Text("Раздел скоро появится."))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

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
                    .padding(.bottom, proxy.safeAreaInsets.bottom + (isLandscape ? 8 : 12))
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

struct CardPair: Identifiable {
    let id = UUID()
    let power: GameCard
    let race: GameCard
}

final class TableStore: ObservableObject {
    @Published private(set) var pairs: [CardPair] = []

    func add(power: GameCard, race: GameCard) {
        pairs.append(CardPair(power: power, race: race))
    }

    func remove(_ pair: CardPair) {
        pairs.removeAll { $0.id == pair.id }
    }
}

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

struct CardReadingView: View {
    let card: GameCard
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Image(card.imageName)
                    .resizable()
                    .scaledToFit()
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

struct CatalogSearchSheet: View {
    @Binding var searchText: String
    let onSearch: (String) -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Название способности или народа", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.search)
                    .onSubmit { onSearch(searchText) }

                Button("Найти") {
                    onSearch(searchText)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .frame(maxWidth: .infinity)
            }
            .padding(20)
            .navigationTitle("Найти карточку")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { isFocused = true }
        }
    }
}

enum CardKind: String { case races = "Народы", powers = "Способности" }

struct GameCard: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let tokenCount: Int
    let imageName: String
    let symbol: String
    let color: Color
    let description: String
    let rules: String
}

struct CardCatalog: View {
    let kind: CardKind
    @Binding var searchText: String
    let selectedCard: GameCard?
    let toggleSelection: (GameCard) -> Void

    private var cards: [GameCard] { kind == .races ? DemoCards.races : DemoCards.powers }
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
                .background(.clear)

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

struct CardDetail: View {
    let card: GameCard
    let kind: CardKind

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(spacing: 14) {
                    Image(card.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 320, maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    Text(card.name).font(.largeTitle.bold())
                    Label("\(card.tokenCount) жетонов", systemImage: "shield.fill")
                        .font(.headline).foregroundStyle(card.color)
                }
                .frame(maxWidth: .infinity).padding(.top, 20)
                Section("Кратко") { Text(card.description) }
                Section("Правило") { Text(card.rules) }
            }
            .padding()
        }
        .navigationTitle(kind.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

enum DemoCards {
    static let races = makeCards(prefix: "race", names: [
        "Амазонки", "Великаны", "Волшебники", "Дварфы", "Колдуны", "Крысолюды", "Люди", "Орки", "Полурослики", "Скелеты", "Тритоны", "Тролли", "Упыри", "Эльфы",
        "Белые девы", "Гоблины", "Жрицы", "Игори", "Кобольды", "Кочевники", "Кустовики", "Фавны", "Вендиго", "Драгоны", "Падальщики", "Пугала", "Улитки", "Ханы", "Штормовые великаны",
        "Варвары", "Гомункулы", "Лепреконы", "Писки", "Пломбирки", "Рогатчики", "Скаги", "Шаманы"
    ], color: .pink)

    static let powers = makeCards(prefix: "power", names: [
        "Богатые", "Боевые", "Болотные", "Верховые", "Водные", "Героические", "Драконовластные", "Лесные", "Летучие", "Лютые", "Мирные", "Подземные", "Походные", "Призрачные", "Разбойные", "Скаредные", "Стойкие", "Укреплённые", "Учёные", "Холмовые",
        "Гигантские", "Мародёрские", "Миролюбивые", "Начитанные", "Неисчислимые", "Оборотные", "Огнеметательные", "Прибрежные", "Проклятые", "Шмонающие", "Воздушные", "Вымогающие", "Дирижабные", "Золотоносные", "Ищущие", "Сговорчивые", "Стрелковые", "Животворящие", "Имперские", "Лавовые", "Наёмные", "Окопавшиеся", "Осадные", "Подражающие", "Продажные"
    ], color: .orange)

    private static func makeCards(prefix: String, names: [String], color: Color) -> [GameCard] {
        names.enumerated().map { index, name in
            GameCard(
                name: name,
                tokenCount: 0,
                imageName: String(format: "%@-%03d", prefix, index + 1),
                symbol: "rectangle.fill",
                color: color,
                description: "Полная карточка с описанием.",
                rules: "Правило указано на изображении карточки."
            )
        }
    }
}
