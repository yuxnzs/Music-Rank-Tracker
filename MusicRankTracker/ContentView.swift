import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .dailyStreams
    @StateObject var apiService = APIService()
    @StateObject var displayManager = DisplayManager()
    
    @State private var isShowingTabBar = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                VStack {
                    switch selectedTab {
                    case .dailyStreams:
                        DailyStreamsView(isShowingTabBar: $isShowingTabBar, bottomSafeArea: geometry.safeAreaInsets.bottom)
                    case .billboardHistory:
                        BillboardHistoryView(bottomSafeArea: geometry.safeAreaInsets.bottom)
                    case .billboardDate:
                        BillboardDateView()
                    }
                }
                .ignoresSafeArea()
                .environmentObject(apiService)
                .environmentObject(displayManager)
                
                VStack {
                    if isShowingTabBar {
                        CurveTabBar(selectedTab: $selectedTab)
                        // Adds padding above the tab bar equal to the bottom safe area height to ensure it remains visible during the downward animation until fully exited
                        // If no padding is added, the tab bar will disappear before the animation completes
                            .padding(.top, geometry.safeAreaInsets.bottom)
                            .transition(.move(edge: .bottom))
                    }
                }
                .animation(.easeInOut, value: isShowingTabBar)
            }
            .onAppear {
                addKeyboardObservers()
            }
            .onDisappear {
                removeKeyboardObservers()
            }
        }
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            withAnimation {
                isShowingTabBar = false
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                isShowingTabBar = true
            }
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
}
