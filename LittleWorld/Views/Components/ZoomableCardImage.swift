import SwiftUI

struct ZoomableCardImage: View {
    private struct ActiveMagnification {
        let scale: CGFloat
        let anchor: UnitPoint
    }

    let imageName: String
    var allowsDoubleTapZoom = false
    var keepsZoomAfterGesture = false

    @State private var settledScale: CGFloat = 1
    @State private var settledAnchor: UnitPoint = .center
    @State private var settledOffset: CGSize = .zero
    @GestureState private var activeMagnification: ActiveMagnification?
    @GestureState private var dragTranslation: CGSize = .zero

    private var displayedScale: CGFloat {
        let baseScale = keepsZoomAfterGesture ? settledScale : 1
        return min(max(baseScale * (activeMagnification?.scale ?? 1), 1), 4)
    }

    private var displayedAnchor: UnitPoint {
        activeMagnification?.anchor ?? (keepsZoomAfterGesture ? settledAnchor : .center)
    }

    private var displayedOffset: CGSize {
        let baseOffset = keepsZoomAfterGesture ? settledOffset : .zero
        return CGSize(
            width: baseOffset.width + dragTranslation.width,
            height: baseOffset.height + dragTranslation.height
        )
    }

    var body: some View {
        Group {
            if displayedScale > 1 {
                cardImage.simultaneousGesture(moveGesture)
            } else {
                cardImage
            }
        }
        .simultaneousGesture(magnifyGesture)
        .onTapGesture(count: 2) {
            guard allowsDoubleTapZoom else { return }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.82)) {
                settledScale = settledScale > 1 ? 1 : 2
                settledAnchor = .center
                settledOffset = .zero
            }
        }
        .accessibilityHint("Увеличьте изображение жестом двумя пальцами")
    }

    private var cardImage: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .scaleEffect(displayedScale, anchor: displayedAnchor)
            .offset(displayedOffset)
    }

    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .updating($activeMagnification) { value, state, _ in
                state = ActiveMagnification(scale: value.magnification, anchor: value.startAnchor)
            }
            .onEnded { value in
                if keepsZoomAfterGesture {
                    settledAnchor = value.startAnchor
                    settledScale = min(max(settledScale * value.magnification, 1), 4)
                }
            }
    }

    private var moveGesture: some Gesture {
        DragGesture()
            .updating($dragTranslation) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                guard keepsZoomAfterGesture else { return }
                settledOffset.width += value.translation.width
                settledOffset.height += value.translation.height
            }
    }
}
