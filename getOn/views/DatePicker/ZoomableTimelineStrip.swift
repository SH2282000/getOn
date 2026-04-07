import SwiftUI

// MARK: - ZoomableTimelineStrip

/// A horizontally zoomable and pannable timeline strip that displays 24 hours.
/// Used by WeekView for both the hour-label axis and each day's time-block row.
struct ZoomableTimelineStrip<Content: View>: View {
    @Binding var zoomScale: CGFloat
    @Binding var scrollOffset: CGFloat

    let rowHeight: CGFloat
    let content: (_ viewportWidth: CGFloat, _ xPosition: @escaping (_ halfHour: Int) -> CGFloat) -> Content

    @State private var pinchStartScale: CGFloat = 1.0
    @State private var pinchStartOffset: CGFloat = 0.0

    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 6.0

    init(
        zoomScale: Binding<CGFloat>,
        scrollOffset: Binding<CGFloat>,
        rowHeight: CGFloat = 40,
        @ViewBuilder content: @escaping (_ viewportWidth: CGFloat, _ xPosition: @escaping (_ halfHour: Int) -> CGFloat) -> Content
    ) {
        self._zoomScale = zoomScale
        self._scrollOffset = scrollOffset
        self.rowHeight = rowHeight
        self.content = content
    }

    var body: some View {
        GeometryReader { geo in
            let vw = geo.size.width

            let xPos: (Int) -> CGFloat = { halfHour in
                CGFloat(halfHour) / 48.0 * (vw * zoomScale) + scrollOffset
            }

            content(vw, xPos)
                .frame(width: vw, height: rowHeight)
                .clipped()
                .contentShape(Rectangle())
                .simultaneousGesture(magnifyGesture(viewportWidth: vw))
        }
        .frame(height: rowHeight)
    }

    private func magnifyGesture(viewportWidth vw: CGFloat) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newScale = clamp(pinchStartScale * value.magnification, minScale, maxScale)

                // Keep the pinch anchor point stationary on screen
                let anchorX = value.startLocation.x
                let oldContentX = anchorX - pinchStartOffset
                let scaleFactor = newScale / pinchStartScale
                let newContentX = oldContentX * scaleFactor
                let newOffset = anchorX - newContentX

                zoomScale = newScale
                scrollOffset = clampOffset(newOffset, viewportWidth: vw, totalWidth: vw * newScale)
            }
            .onEnded { _ in
                pinchStartScale = zoomScale
                pinchStartOffset = scrollOffset
            }
    }

    private func clamp(_ v: CGFloat, _ lo: CGFloat, _ hi: CGFloat) -> CGFloat {
        min(max(v, lo), hi)
    }

    private func clampOffset(_ offset: CGFloat, viewportWidth: CGFloat, totalWidth: CGFloat) -> CGFloat {
        if totalWidth <= viewportWidth { return 0 }
        return min(0, max(viewportWidth - totalWidth, offset))
    }
}

// MARK: - Helpers

/// Converts a screen x-coordinate back to a half-hour index, accounting for zoom & pan.
func halfHourFromX(_ x: CGFloat, scrollOffset: CGFloat, zoomScale: CGFloat, viewportWidth: CGFloat) -> Int {
    let totalWidth = viewportWidth * zoomScale
    let contentX = x - scrollOffset
    let raw = Int((contentX / totalWidth) * 48.0)
    return min(max(raw, 0), 47)
}
