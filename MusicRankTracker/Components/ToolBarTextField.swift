import SwiftUI

struct ToolBarTextField: View {
    @Binding var searchText: String
    @FocusState.Binding var isFocused: Bool
    @Binding var isHistoryFilteringRanking: Bool
    
    let placeholderText: String
    var onChange: (Binding<String>) -> Void
    
    // isHistoryFilteringRanking default to false if not provided
    init(searchText: Binding<String>, isFocused: FocusState<Bool>.Binding, isHistoryFilteringRanking: Binding<Bool> = .constant(false), placeholderText: String, onChange: @escaping (Binding<String>) -> Void) {
        self._searchText = searchText
        self._isFocused = isFocused
        self._isHistoryFilteringRanking = isHistoryFilteringRanking
        self.placeholderText = placeholderText
        self.onChange = onChange
    }
    
    var body: some View {
        TextField(placeholderText, text: $searchText)
            .focused($isFocused)
            .padding(.leading, 10)
            .padding(.trailing, 35)
            .frame(maxWidth: .infinity)
            .frame(height: 30, alignment: .leading)
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .font(.system(size: 16))
            .keyboardType(isHistoryFilteringRanking ? .numberPad : .default)
            .onChange(of: searchText) {
                withAnimation(.linear) {
                    onChange($searchText)
                }
            }
            .onChange(of: isHistoryFilteringRanking) {
                // Reopen keyboard to change to numberPad or default
                UIApplication.shared.endEditing()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocused = true
                }
            }
            .overlay {
                HStack {
                    Spacer()
                    // Clear text
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray.opacity(0.5))
                            .font(.system(size: 13))
                            .padding(.trailing, 10)
                    }
                }
            }
    }
}

#Preview {
    ToolBarTextField(
        searchText: .constant(""),
        isFocused: FocusState<Bool>().projectedValue,
        isHistoryFilteringRanking: .constant(false),
        placeholderText: "Enter song or album name",
        onChange: { _ in }
    )
}
