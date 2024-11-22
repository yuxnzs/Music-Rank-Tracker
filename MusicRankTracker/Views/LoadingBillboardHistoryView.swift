import SwiftUI

struct LoadingBillboardHistoryView: View {
    let bottomSafeArea: CGFloat
    
    var body: some View {
        ArtistInfo(isPlaceholder: true, shorterTotalCountPlaceholder: true)
            .padding(.bottom, 20)
        
        VStack {
            ForEach(0..<10, id: \.self) { index in
                RankInfo(isPlaceholder: true)
                    .padding(.bottom, 20)
            }
        }
        .padding(.bottom, bottomSafeArea + 20)
    }
}

#Preview {
    LoadingBillboardHistoryView(bottomSafeArea: 34)
}
