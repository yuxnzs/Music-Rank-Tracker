import SwiftUI
import SDWebImageSwiftUI

struct ArtistInfo: View {
    let artistImageURL: URL
    let artistName: String
    let date: String?
    
    var body: some View {
        VStack {
            HStack {
                WebImage(url: artistImageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 70, height: 70)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(artistName)
                        .font(.system(size: 24, weight: .bold))
                    
                    if let date = date {
                        Text("Date: \(date)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.leading, 3)
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
        date: "2024-07-10"
    )
    .padding()
}
