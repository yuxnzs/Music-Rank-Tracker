import SwiftUI

struct LoadingDailyStreamsView: View {
    let bottomSafeArea: CGFloat
    
    var body: some View {
        ArtistInfo(isPlaceholder: true)
            .padding(.bottom, 20)
        
        VStack {
            ForEach(0..<10, id: \.self) { index in
                StreamInfo(isPlaceholder: true, rank: index + 1)
                    .padding(.bottom, 20)
            }
        }
        .padding(.bottom, bottomSafeArea + 20)
    }
}

#Preview {
    LoadingDailyStreamsView(bottomSafeArea: 34)
}
