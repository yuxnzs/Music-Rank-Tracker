import SwiftUI

struct ToolBarTextField: View {
    @Binding var searchText: String
    @FocusState.Binding var isFocused: Bool
    
    let placeholderText: String
    var onChange: (Binding<String>) -> Void
    
    var body: some View {
        TextField(placeholderText, text: $searchText)
            .focused($isFocused)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 30, alignment: .leading)
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .font(.system(size: 16))
            .onChange(of: searchText) {
                withAnimation(.linear) {
                    onChange($searchText)
                }
            }
    }
}

#Preview {
    ToolBarTextField(
        searchText: .constant(""),
        isFocused: FocusState<Bool>().projectedValue,
        placeholderText: "Enter song or album name",
        onChange: { _ in }
    )
}
