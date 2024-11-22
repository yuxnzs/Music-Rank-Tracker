import SwiftUI
import SDWebImageSwiftUI

struct ArtistInfo: View {
    let artistImageURL: URL?
    let artistName: String
    let date: String?
    let totalCount: Int
    let isPlaceholder: Bool
    let shorterTotalCountPlaceholder: Bool
    
    init(artistImageURL: URL?, artistName: String, date: String? = nil, totalCount: Int, isPlaceholder: Bool = false, shorterTotalCountPlaceholder: Bool = false) {
        self.artistImageURL = artistImageURL
        self.artistName = artistName
        self.date = date
        self.totalCount = totalCount
        self.isPlaceholder = isPlaceholder
        self.shorterTotalCountPlaceholder = shorterTotalCountPlaceholder
    }
    
    // For loading placeholder in DailyStreamsView and BillboardHistoryView
    init(isPlaceholder: Bool, shorterTotalCountPlaceholder: Bool = false) {
        self.artistImageURL = nil
        self.artistName = "Placeholder"
        self.date = nil
        self.totalCount = 0
        self.isPlaceholder = isPlaceholder
        self.shorterTotalCountPlaceholder = shorterTotalCountPlaceholder
    }
    
    var body: some View {
        VStack {
            HStack {
                if isPlaceholder {
                    // Artist image placeholder
                    LoadingPlaceholder()
                        .clipShape(Circle())
                        .frame(width: 70, height: 70)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        // Artist name placeholder
                        LoadingPlaceholder()
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .frame(width: 150, height: 30)
                        
                        // Date and total count placeholder
                        LoadingPlaceholder()
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        // Shorter placeholder for BillboardHistoryView
                            .frame(width: shorterTotalCountPlaceholder ? 80 : 200, height: 20)
                    }
                } else {
                    // Artist image
                    WebImage(url: artistImageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                    } placeholder: {
                        LoadingPlaceholder()
                            .clipShape(Circle())
                    }
                    .frame(width: 70, height: 70)
                    
                    // Artist name and date
                    VStack(alignment: .leading, spacing: 6) {
                        Text(artistName)
                            .font(.system(size: 24, weight: .bold))
                        
                        Text(date != nil ? "Date: \(date!) • Total: \(totalCount)" : "Total: \(totalCount)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.leading, 3)
                }
            }
            .padding(10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ArtistInfo(
        artistImageURL: URL(string: "https://i.scdn.co/image/ab6761610000e5ebe03a98785f3658f0b6461ec4")!,
        artistName: "Olivia Rodrigo",
        date: "2024-07-10",
        totalCount: 10
    )
    .padding()
}
