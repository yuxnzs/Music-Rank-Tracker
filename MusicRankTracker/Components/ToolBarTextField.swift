import SwiftUI

struct ToolBarTextField: View {
    @Binding var newText: String
    @Binding var displayStreamData: [StreamData]
    @FocusState.Binding var isFocused: Bool
    
    let placeholderText: String
    var width: CGFloat
    var onChange: (Binding<String>) -> Void
    
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
                withAnimation(.linear) {
                    onChange($newText)
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
        width: 250,
        onChange: { _ in }
    )
}
