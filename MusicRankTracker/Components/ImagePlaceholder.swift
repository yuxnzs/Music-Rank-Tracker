import SwiftUI

struct ImagePlaceholder: View {
    @State private var isAnimating = false
    
    var body: some View {
        Color.gray
            .opacity(isAnimating ? 0.15 : 0.1)
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    isAnimating.toggle()
                }
            }
    }
}

#Preview {
    ImagePlaceholder()
}
