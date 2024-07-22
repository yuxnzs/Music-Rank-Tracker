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
        VStack(alignment: .trailing) {
            HStack(spacing: 0) {
                if isSearchTextFieldShowing {
                    ToolBarTextField(
                        searchText: $searchText,
                        isFocused: $isFocused,
                        placeholderText: placeholderText,
                        width: 275,
                        onChange: handleTextChange
                    )
                } else {
                    // Same width as TextField to avoid buttons moving when TextField is hidden
                    Spacer().frame(width: 275)
                }
                
                HStack(spacing: 5) {
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
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
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
}
