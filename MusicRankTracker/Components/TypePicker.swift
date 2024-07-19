import SwiftUI

struct TypePicker: View {
    @EnvironmentObject var apiService: APIService
    @EnvironmentObject var displayManager: DisplayManager
    
    let text: String
    @Binding var selection: String
    let options: [String]
    let width: CGFloat?
    let isSorting: Bool
    
    @Binding var displayStreamData: [StreamData]
    
    // Initializer not include streamData and displayStreamData
    init(text: String, selection: Binding<String>, options: [String], width: CGFloat? = nil, isSorting: Bool = false) {
        self.text = text
        self._selection = selection
        self.options = options
        self.width = width
        self._displayStreamData = .constant([])
        self.isSorting = isSorting
    }
    
    init(
        text: String,
        selection: Binding<String>,
        options: [String],
        width: CGFloat? = nil,
        displayStreamData: Binding<[StreamData]>,
        isSorting: Bool
    ) {
        self.text = text
        self._selection = selection
        self.options = options
        self.width = width
        self._displayStreamData = displayStreamData
        self.isSorting = isSorting
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
            
            if displayManager.isFiltering {
                // When is filtering
                // Sort the filtered data for display
                displayStreamData = apiService.sortStreams(streamData: displayStreamData, streamType: selection)
                // Sort the original data too to ensure the sorting order remains the same
                // after showing the original data when stop filtering
                apiService.dailyStreams?.streamData = apiService.sortStreams(streamData: streamData, streamType: selection)
            } else {
                // When is not filtering, sort the original data
                displayStreamData = apiService.sortStreams(streamData: streamData, streamType: selection)
                apiService.dailyStreams?.streamData = displayStreamData
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
        displayStreamData: .constant([]),
        isSorting: true
    )
    .environmentObject(APIService())
    .environmentObject(DisplayManager())
}
