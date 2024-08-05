import SwiftUI

struct SearchToolbar: View {
    @Binding var isSearchTextFieldShowing: Bool
    @Binding var searchText: String
    @FocusState.Binding var isFocused: Bool
    @Binding var isHistoryFilteringRanking: Bool
    let placeholderText: String
    let handleTextChange: (Binding<String>) -> Void
    let mainButtonIcon: String
    let filterButtonAction: () -> Void
    let mainButtonAction: () -> Void
    
    init(
        isSearchTextFieldShowing: Binding<Bool>,
        searchText: Binding<String>,
        isFocused: FocusState<Bool>.Binding,
        isHistoryFilteringRanking: Binding<Bool> = .constant(false),
        placeholderText: String,
        handleTextChange: @escaping (Binding<String>) -> Void,
        mainButtonIcon: String,
        filterButtonAction: @escaping () -> Void,
        mainButtonAction: @escaping () -> Void
    ) {
        self._isSearchTextFieldShowing = isSearchTextFieldShowing
        self._searchText = searchText
        self._isFocused = isFocused
        self._isHistoryFilteringRanking = isHistoryFilteringRanking
        self.placeholderText = placeholderText
        self.handleTextChange = handleTextChange
        self.mainButtonIcon = mainButtonIcon
        self.filterButtonAction = filterButtonAction
        self.mainButtonAction = mainButtonAction
    }
    
    var body: some View {
        HStack(spacing: 10) {
            VStack {
                if isSearchTextFieldShowing {
                    ToolBarTextField(
                        searchText: $searchText,
                        isFocused: $isFocused,
                        isHistoryFilteringRanking: $isHistoryFilteringRanking,
                        placeholderText: placeholderText,
                        onChange: handleTextChange
                    )
                    // Override parent's onTapGesture to avoid closing keyboard when tapping on TextField
                    .onTapGesture {}
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
                    Image(systemName: mainButtonIcon)
                        .foregroundStyle(isHistoryFilteringRanking ? Color.yellow : Color.black)
                        .shadow(color: isHistoryFilteringRanking ? Color.yellow.opacity(0.5) : Color.clear, radius: 3)
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
        mainButtonIcon: "chart.bar",
        filterButtonAction: { },
        mainButtonAction: { }
    )
    .padding()
}
