import SwiftUI

struct ToolBarTextField: View {
    @EnvironmentObject var apiService: APIService
    @EnvironmentObject var displayManager: DisplayManager
    
    @Binding var newText: String
    @Binding var displayStreamData: [StreamData]
    @FocusState.Binding var isFocused: Bool
    
    let placeholderText: String
    var width: CGFloat
    
    var body: some View {
        TextField(placeholderText, text: $newText)
            .focused($isFocused)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .frame(width: width, height: 30, alignment: .leading)
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .font(.system(size: 16))
            .offset(x: -6)
            .onChange(of: newText) {
                // Update UI when searchText changes
                displayStreamData = apiService.filterData(
                    items: apiService.dailyStreams?.streamData ?? [],
                    searchText: newText,
                    keySelectors: [
                        { $0.musicName },
                        { $0.albumName }
                    ]
                )
                
                // Reset dailyStreams to show all data
                if newText.isEmpty {
                    displayStreamData = apiService.dailyStreams?.streamData ?? []
                } else {
                    displayManager.isFiltering = true
                }
            }
    }
}

#Preview {
    ToolBarTextField(
        newText: .constant(""),
        displayStreamData: .constant([]),
        isFocused: FocusState<Bool>().projectedValue,
        placeholderText: "Enter song or album name",
        width: 250
    )
    .environmentObject(APIService())
    .environmentObject(DisplayManager())
}
