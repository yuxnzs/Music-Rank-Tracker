import SwiftUI

struct TypePicker: View {
    @EnvironmentObject var apiService: APIService
    @EnvironmentObject var displayManager: DisplayManager
    
    let text: String
    @Binding var selection: String
    let options: [String]
    let width: CGFloat?
    let isSorting: Bool
    
    var onFilter: (([(StreamData) -> String?]) -> Void)?

    init(text: String, selection: Binding<String>, options: [String], width: CGFloat? = nil, isSorting: Bool = false, onFilter: (([(StreamData) -> String?]) -> Void)? = nil) {
        self.text = text
        self._selection = selection
        self.options = options
        self.width = width
        self.isSorting = isSorting
        self.onFilter = onFilter
    }
    
    var body: some View {
        Text("\(text):")
            .font(.system(size: 18))
            .padding(.vertical, 6)
        
        Picker(text, selection: $selection) {
            ForEach(options, id: \.self) { option in
                Text(option.capitalized).tag(option)
            }
        }
        .onChange(of: selection) {
            guard isSorting, let streamData = apiService.dailyStreams?.streamData else { return }
            
            displayManager.displayStreamType = selection // Update displayStreamType when sorting changes
            
            withAnimation(.linear) {
                if displayManager.isFiltering {
                    // When Daily switch to Total or vice versa, sort original data first then filter
                    // Make sure when is filtering and changing the sorting type, the rank is displayed based on the sorting type
                    // And also ensure the the original data sorting order display the same sorting type after stop filtering
                    apiService.dailyStreams?.streamData = apiService.sortStreams(streamData: streamData, streamType: selection, shouldReassignRanks: true)
                    
                    onFilter?([
                        { $0.musicName },
                        { $0.albumName }
                    ])
                    
                    // When is filtering
                    // Sort the filtered data for display
                    displayManager.displayStreamData = apiService.sortStreams(streamData: displayManager.displayStreamData, streamType: selection, shouldReassignRanks: false)
                } else {
                    // When is not filtering, sort the original data
                    displayManager.displayStreamData = apiService.sortStreams(streamData: streamData, streamType: selection, shouldReassignRanks: true)
                    apiService.dailyStreams?.streamData = displayManager.displayStreamData
                }
            }
        }
        .pickerStyle(MenuPickerStyle())
        .accentColor(.black)
        .padding(.horizontal)
        .padding(.top)
        .frame(width: width, alignment: .leading)
        .offset(x: -20)
    }
}

#Preview {
    TypePicker(
        text: "Type",
        selection: .constant("songs"),
        options: ["songs", "albums"],
        width: 130,
        isSorting: true,
        onFilter: { _ in }
    )
    .environmentObject(APIService())
    .environmentObject(DisplayManager())
}
