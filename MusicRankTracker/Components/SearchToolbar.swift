import SwiftUI

struct SearchToolbar: View {
    @Binding var isSearchTextFieldShowing: Bool
    @Binding var searchText: String
    @FocusState.Binding var isFocused: Bool
    let placeholderText: String
    let handleTextChange: (Binding<String>) -> Void
    let buttonIcon: String
    let filterButtonAction: () -> Void
    let mainButtonAction: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            VStack {
                if isSearchTextFieldShowing {
                    ToolBarTextField(
                        searchText: $searchText,
                        isFocused: $isFocused,
                        placeholderText: placeholderText,
                        onChange: handleTextChange
                    )
                } else {
                    // Same width as TextField to avoid buttons moving when TextField is hidden
                    Spacer().frame(maxWidth: .infinity)
                }
            }
            
            HStack(spacing: 10) {
                Button {
                    filterButtonAction()
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.black)
                }
                
                Button{
                    mainButtonAction()
                } label: {
                    Image(systemName: buttonIcon)
                        .foregroundStyle(.black)
                    // Set fixed size to ensure that all passed-in icons won't affect the layout
                        .frame(width: 11)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    SearchToolbar(
        isSearchTextFieldShowing: .constant(true),
        searchText: .constant(""),
        isFocused: FocusState<Bool>().projectedValue,
        placeholderText: "Enter song or album name",
        handleTextChange: { _ in },
        buttonIcon: "chart.bar",
        filterButtonAction: { },
        mainButtonAction: { }
    )
    .padding()
}
