import SwiftUI

struct LoadingPlaceholder: View {
    @State private var isAnimating = false
    
    var body: some View {
        Color.gray
            .opacity(isAnimating ? 0.25 : 0.1)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating.toggle()
                }
            }
    }
}

#Preview {
    LoadingPlaceholder()
}
