import SwiftUI
import SDWebImageSwiftUI

struct ArtistItem: View {
    let imageUrl: URL?
    let name: String
    @Binding var isTapped: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            WebImage(url: imageUrl) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
            }
            .frame(width: 90, height: 90)
            
            if isTapped {
                Text(name)
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxHeight: 20)
            } else {
                Text(name)
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: 90)
                    .frame(maxHeight: 20)
            }
        }
        .onTapGesture {
            withAnimation {
                isTapped.toggle()
            }
        }
    }
}

#Preview {
    ArtistItem(
        imageUrl: URL(string: "https://i.scdn.co/image/ab6761610000e5ebe03a98785f3658f0b6461ec4"),
        name: "Olivia Rodrigo",
        isTapped: .constant(false)
    )
}
