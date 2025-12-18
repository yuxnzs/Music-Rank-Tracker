import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .dailyStreams
    @StateObject var apiService = APIService()
    @StateObject var displayManager = DisplayManager()
    
    @State private var isShowingTabBar = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Pre-load all views to save the state when switching tabs
                ZStack {
                    DailyStreamsView(isShowingTabBar: $isShowingTabBar, bottomSafeArea: geometry.safeAreaInsets.bottom)
                        .opacity(selectedTab == .dailyStreams ? 1 : 0)
                        .allowsHitTesting(selectedTab == .dailyStreams)
                    
                    BillboardHistoryView(bottomSafeArea: geometry.safeAreaInsets.bottom)
                        .opacity(selectedTab == .billboardHistory ? 1 : 0)
                        .allowsHitTesting(selectedTab == .billboardHistory)
                    
                    BillboardDateView(bottomSafeArea: geometry.safeAreaInsets.bottom)
                        .opacity(selectedTab == .billboardDate ? 1 : 0)
                        .allowsHitTesting(selectedTab == .billboardDate)
                }
                .ignoresSafeArea()
                .environmentObject(apiService)
                .environmentObject(displayManager)
                
                VStack {
                    if isShowingTabBar {
                        CurveTabBar(selectedTab: $selectedTab)
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
