import SwiftUI

// Parent View can pass in both Int and String? data
enum DataItem {
    case intData(Int)
    case stringData(String?)
}

struct InfoRow: View {
    var dataItems: [(data: DataItem, title: String)]
    
    var body: some View {
        HStack {
            Spacer()
            
            // Transform data items into displayable format (String)
            // Handling nil inside the stringData case
            ForEach(dataItems.compactMap { item -> (data: String, title: String)? in
                switch item.data {
                case .intData(let intValue):
                    // thousands separator
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    let formattedNumber = formatter.string(from: NSNumber(value: intValue)) ?? "\(intValue)"
                    return (data: formattedNumber, title: item.title)
                case .stringData(let stringValue):
                    guard let stringValue = stringValue else { return nil }
                    return (data: stringValue, title: item.title)
                }
            }, id: \.title) { item in
                InfoCard(data: item.data, title: item.title)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    InfoRow(
        dataItems: [
            (data: .intData(12), title: "track number"),
            (data: .stringData("2023-09-08"), title: "release date")
        ]
    )
}
