import SwiftUI

struct InfoCard: View {
    let data: String
    let title: String
    
    private var dataFontSize: CGFloat {
        // If the data is a long number, reduce the font size to fit in the card
        if let intValue = Int(data.replacingOccurrences(of: ",", with: "")),
           intValue >= 10000000000 {
            return 18
        }
        return 20 // Default font size
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Content
            VStack {
                Text(data)
                    .font(.system(size: dataFontSize))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.themeColor)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            
            // Title
            VStack {
                Text(title)
                    .font(.system(size: 15))
                    .fontWeight(.bold)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .frame(width: 180, height: 75)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    InfoCard(
        data: "8,888,888,888",
        title: "Total Streams"
    )
}
