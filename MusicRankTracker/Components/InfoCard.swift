import SwiftUI

struct InfoCard: View {
    let data: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Content
            VStack {
                Text(data)
                    .font(.system(size: title == "Total Streams" ? 20 : 22))
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
