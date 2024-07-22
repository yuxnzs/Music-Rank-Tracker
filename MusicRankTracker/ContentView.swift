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
                        DailyStreamsView()
                    case .billboardHistory:
                        BillboardHistoryView()
                    case .billboardDate:
                        BillboardDateView()
                    }
                }
                .ignoresSafeArea()
                .environmentObject(apiService)
                .environmentObject(displayManager)
                
                if isShowingTabBar {
                    VStack {
                        // Custom TabBar
                        CurveTabBar(selectedTab: $selectedTab)
                    }
                    .animation(.easeInOut, value: isShowingTabBar)
                    .transition(.move(edge: .bottom))
                }
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

#Preview {
    ContentView()
}
