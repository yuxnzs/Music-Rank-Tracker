import SwiftUI

struct TypePicker: View {
    @EnvironmentObject var apiService: APIService
    @EnvironmentObject var displayManager: DisplayManager
    
    let text: String
    @Binding var selection: String
    let options: [String]
    let width: CGFloat?
    
    var onChange: ((String) -> Void)?

    init(text: String, selection: Binding<String>, options: [String], width: CGFloat? = nil, isSorting: Bool = false, onChange: ((String) -> Void)? = nil) {
        self.text = text
        self._selection = selection
        self.options = options
        self.width = width
        self.onChange = onChange
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            Text("\(text):")
                .font(.system(size: 18))
                .padding(.vertical, 6)
            
            Picker(text, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .onChange(of: selection) {
                onChange?(selection)
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(.black)
            .padding(.horizontal)
            .padding(.top)
            .frame(width: width, alignment: .leading)
            .offset(x: -20)
        }
    }
}

#Preview {
    TypePicker(
        text: "Type",
        selection: .constant("songs"),
        options: ["songs", "albums"],
        width: 130,
        onChange: { _ in }
    )
    .environmentObject(APIService())
    .environmentObject(DisplayManager())
}
