import SwiftUI

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
