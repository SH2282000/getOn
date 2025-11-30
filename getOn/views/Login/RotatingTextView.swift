import SwiftUI
import Combine

struct RotatingTextView: View {
    let prefix: String
    let words: [String]
    let suffix: String
    
    @State private var currentIndex = 0
    @State private var contentSize: CGSize = .zero
    
    let timer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 4) {
            Text(prefix)
                .foregroundColor(.primary)
            
            ZStack(alignment: .leading) {
                // Invisible text for sizing
                ForEach(words, id: \.self) { word in
                    Text(word)
                        .fontWeight(.bold)
                        .opacity(0)
                }
                
                // Visible animating text
                Text(words[currentIndex])
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .id(words[currentIndex])
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.8)).combined(with: .offset(y: 10)),
                        removal: .opacity.combined(with: .scale(scale: 1.2)).combined(with: .offset(y: -10))
                    ))
            }
            // Apply a "Liquid" feel using a blur that animates
            // Note: True "Gooey" effect requires blur+contrast which destroys text anti-aliasing.
            // This combination of spring + scale + opacity gives a smooth "fluid" feel.
            
            Text(suffix)
                .foregroundColor(.primary)
        }
        .onReceive(timer) { _ in
            // Use a spring animation for the "liquid" bounce
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.5)) {
                currentIndex = (currentIndex + 1) % words.count
            }
        }
    }
}

#Preview {
    RotatingTextView(
        prefix: "Discover",
        words: ["people", "events", "places", "activities", "businesses", "everything"],
        suffix: "around you"
    )
}
