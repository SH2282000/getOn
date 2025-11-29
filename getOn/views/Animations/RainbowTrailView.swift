import SwiftUI

struct RainbowTrailView: View {
    // Callbacks to pass gesture data back to the parent (e.g., MapReader)
    var onUpdate: ((CGPoint) -> Void)?
    var onEnd: (() -> Void)?
    
    @State private var points: [TouchPoint] = []
    
    struct TouchPoint {
        let location: CGPoint
        let timestamp: Date
    }
    
    var body: some View {
        TimelineView(.animation) { context in
            Canvas { ctx, size in
                // 1. Clean up old points
                let now = context.date
                let fadingTime: TimeInterval = 0.5
                
                let currentPoints = points.filter { point in
                    now.timeIntervalSince(point.timestamp) < fadingTime
                }
                
                guard currentPoints.count > 1 else { return }
                
                // 2. Create the path
                var path = Path()
                path.move(to: currentPoints[0].location)
                
                for i in 1..<currentPoints.count {
                    let p1 = currentPoints[i-1].location
                    let p2 = currentPoints[i].location
                    let midPoint = CGPoint(
                        x: (p1.x + p2.x) / 2,
                        y: (p1.y + p2.y) / 2
                    )
                    path.addQuadCurve(to: midPoint, control: p1)
                }
                if let last = currentPoints.last {
                    path.addLine(to: last.location)
                }
                
                // 3. Style: Use Normal blend mode for visibility on Maps
                ctx.blendMode = .normal
                
                let timeOffset = now.timeIntervalSinceReferenceDate
                let hue = (timeOffset * 0.3).truncatingRemainder(dividingBy: 1.0)
                let baseColor = Color(hue: hue, saturation: 1, brightness: 1)
                
                // Draw layers
                let layers = 4
                for i in 0..<layers {
                    let progress = Double(i) / Double(layers - 1)
                    let lineWidth = 40.0 * (1.0 - progress * 0.6)
                    let blurRadius = 15.0 * (1.0 - progress)
                    let opacity = 0.2 + (progress * 0.8)
                    
                    var layerCtx = ctx
                    if blurRadius > 0 {
                        layerCtx.addFilter(.blur(radius: blurRadius))
                    }
                    
                    layerCtx.stroke(
                        path,
                        with: .color(baseColor.opacity(opacity)),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                    )
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Update local visual state
                        let newPoint = TouchPoint(location: value.location, timestamp: Date())
                        points.append(newPoint)
                        
                        // Pass location back to parent Map logic
                        onUpdate?(value.location)
                    }
                    .onEnded { _ in
                        onEnd?()
                    }
            )
            .onChange(of: context.date) { _ in
                let now = Date()
                if let first = points.first, now.timeIntervalSince(first.timestamp) > 0.6 {
                    points.removeAll { now.timeIntervalSince($0.timestamp) > 0.6 }
                }
            }
        }
        .allowsHitTesting(true) // Ensures it catches the gestures
    }
}

// MARK: - Preview
struct RainbowTrailView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Simulation of a Map Background
            Color.gray.opacity(0.3).ignoresSafeArea()
            
            RainbowTrailView(
                onUpdate: { print("Coordinates: \($0)") },
                onEnd: { print("Ended") }
            )
        }
    }
}
