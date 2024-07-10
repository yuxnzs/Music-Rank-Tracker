import SwiftUI

struct SearchBar: View {
    @Binding var isLoading: Bool
    @Binding var artistName: String
    
    // To avoid multiple taps on the search button
    @State private var isButtonDisabled = false
    
    // Pass in function for Button action
    var onSearch: () async -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            TextField("Enter artist name", text: $artistName)
                .padding(.leading, 10)
                .padding(.vertical, 5)
                .frame(height: 50)
            
            Button {
                UIApplication.shared.endEditing() // Close keyboard when button is tapped
                isLoading = true
                Task {
                    await onSearch()
                    isLoading = false
                }
                disableButtonTemporarily()
            } label: {
                Text("Serach")
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
    
    // Disable button for 5 seconds
    func disableButtonTemporarily() {
        isButtonDisabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            isButtonDisabled = false
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SearchBar(isLoading: .constant(false), artistName: .constant(""), onSearch: { print("Search button tapped")}
    )
}
