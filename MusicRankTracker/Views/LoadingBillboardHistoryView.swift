import SwiftUI

struct LoadingBillboardHistoryView: View {
    let bottomSafeArea: CGFloat
    let isDateView: Bool
    
    init(bottomSafeArea: CGFloat, isDateView: Bool = false) {
        self.bottomSafeArea = bottomSafeArea
        self.isDateView = isDateView
    }
    
    var body: some View {
        if !isDateView {
            ArtistInfo(isPlaceholder: true, shorterTotalCountPlaceholder: true)
                .padding(.bottom, 20)
        }
        
        VStack {
            ForEach(0..<10, id: \.self) { index in
                if isDateView {
                    HStack(spacing: 0) {
                        Text("\(index + 1)")
                            .frame(width: 25, alignment: .center)
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal)
                        
                        RankInfo(isPlaceholder: true)
                            .padding(.trailing)
                    }
                    .padding(.bottom, 20)
                } else {
                    RankInfo(isPlaceholder: true)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
        }
        .padding(.bottom, bottomSafeArea + 20)
    }
}

#Preview {
    LoadingBillboardHistoryView(bottomSafeArea: 34, isDateView: true)
}
