import SwiftUI

struct SearchBar: View {
    @Binding var isLoading: Bool
    @Binding var artistName: String
    
    // To avoid multiple taps on the search button
    @State private var isButtonDisabled = false
    @FocusState private var isFocused: Bool
    
    // Pass in function for Button action
    var onSearch: () async -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            TextField("Enter artist name", text: $artistName)
            // Override parent's onTapGesture to avoid closing keyboard when tapping on TextField
                .onTapGesture {}
                .onSubmit { performSearch() }
                .focused($isFocused)
                .padding(.leading, 10)
                .padding(.trailing, 35)
                .padding(.vertical, 5)
                .frame(height: 50)
                .overlay {
                    HStack {
                        Spacer()
                        // Clear text
                        Button {
                            artistName = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray.opacity(0.5))
                                .font(.system(size: 18))
                        }
                        .padding(.trailing, 10)
                        // Show clear button when keyboard is displayed and artistName is not empty
                        .opacity(isFocused && !artistName.isEmpty ? 1 : 0)
                        .animation(.easeInOut, value: isFocused)
                        .animation(.easeInOut, value: artistName)
                    }
                }
            
            Button {
                performSearch()
            } label: {
                Text("Search")
                    .padding(.horizontal, 20)
                    .frame(height: 50)
                    .background(.black)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(isButtonDisabled) // Disable button when isButtonDisabled is true
        }
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.top)
    }
    
    private func performSearch() {
        UIApplication.shared.endEditing()
        if artistName.isEmpty { return }
        
        isLoading = true
        Task {
            await onSearch()
            DispatchQueue.main.async {
                isLoading = false  // Ensure UI update is performed on the main thread
            }
        }
        disableButtonTemporarily()
    }
    
    // Disable button for 3 seconds
    func disableButtonTemporarily() {
        isButtonDisabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isButtonDisabled = false
        }
    }
}

#Preview {
    SearchBar(isLoading: .constant(false), artistName: .constant(""), onSearch: { print("Search button tapped")}
    )
}
