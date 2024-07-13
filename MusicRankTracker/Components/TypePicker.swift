import SwiftUI

struct TypePicker: View {
    let text: String
    @Binding var selection: String
    let options: [String]
    let width: CGFloat?
    
    let sortStreams: ((_ streamData: DailyStreams, _ streamType: String) -> Void)?
    let streamData: DailyStreams?
    
    init(
        text: String,
        selection: Binding<String>,
        options: [String],
        width: CGFloat? = nil,
        sortStreams: ((_ streamData: DailyStreams, _ streamType: String) -> Void)? = nil,
        streamData: DailyStreams? = nil
    ) {
        self.text = text
        self._selection = selection
        self.options = options
        self.width = width
        self.sortStreams = sortStreams
        self.streamData = streamData
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
            if let streamData = streamData, let sortStreams = sortStreams {
                sortStreams(streamData, selection)
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
        sortStreams: nil,
        streamData: nil
    )
}
