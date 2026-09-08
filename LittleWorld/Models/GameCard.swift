import SwiftUI

struct GameCard: Identifiable, Hashable {
    let id = UUID()
    let type: String
    let name: String
    let tokenCount: Int
    let imageName: String
    let symbol: String
    let color: Color
    let description: String
}
