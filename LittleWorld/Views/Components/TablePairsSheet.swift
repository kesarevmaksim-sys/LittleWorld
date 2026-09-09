import SwiftUI

struct TablePairsSheet: View {
    let pairs: [CardPair]

    var body: some View {
        NavigationStack {
            List(pairs) { pair in
                Text("\(pair.power.name) — \(pair.race.name)")
            }
            .navigationTitle("Пары на Столе")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
