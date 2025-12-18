import SwiftUI
import SDWebImageSwiftUI

struct ArtistItem: View {
    let imageUrl: URL?
    let name: String
    @Binding var isTapped: Bool
    
    // Font size for artist name
    let fontSize: CGFloat = 18
    @State private var isTextTooLong: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            WebImage(url: imageUrl) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } placeholder: {
                LoadingPlaceholder()
                    .clipShape(Circle())
            }
            .frame(width: 90, height: 90)
            
            if isTapped {
                Text(name)
                    .font(.system(size: fontSize, weight: .bold))
                    .frame(maxHeight: 20)
            } else {
                // Write sperately to avoid blurry text bug
                if isTextTooLong {
                    Text(name)
                        .font(.system(size: fontSize, weight: .bold))
                        .fixedSize(horizontal: true, vertical: false) // Expand text and remove `...`
                        .frame(maxWidth: 90, maxHeight: 20, alignment: isTextTooLong ? .leading : .center)
                    // Right side gradient mask
                        .mask(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .black, location: 0),
                                    .init(color: .black, location: 0.7),
                                    .init(color: .clear, location: 1)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                } else {
                    // No mask if text is short
                    Text(name)
                        .font(.system(size: fontSize, weight: .bold))
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(maxWidth: 90, maxHeight: 20, alignment: isTextTooLong ? .leading : .center)
                }
            }
        }
        .onTapGesture {
            withAnimation {
                isTapped.toggle()
            }
        }
        .onAppear {
            // Check if the text is too long
            isTextTooLong = textWidth(name, font: UIFont.systemFont(ofSize: fontSize, weight: .bold)) > 90
        }
    }
    
    // Calculate the width of the text
    func textWidth(_ text: String, font: UIFont) -> CGFloat {
        // Set font attributes for text.size(withAttributes:)
        let attributes = [NSAttributedString.Key.font: font]
        // Return the calculated text width
        return text.size(withAttributes: attributes).width
    }
}

#Preview {
    ArtistItem(
        imageUrl: URL(string: "https://i.scdn.co/image/ab6761610000e5ebe03a98785f3658f0b6461ec4"),
        name: "Olivia Rodrigo",
        isTapped: .constant(false)
    )
}
