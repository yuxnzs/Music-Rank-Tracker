/*
 Copyright © 2023 AppCoda Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import SwiftUI

/// A custom tab bar view that displays an animated bottom curve when selecting a tab item.
///
/// ![](curve-tab-bar.gif)
///
/// You create a `CurveTabBar` view by providing a binding to the selected tab. Optionally, you can pass an array of the tab items.
///
/// Sample usage:
///
/// ```swift
/// struct ExampleTabView: View {
///     @State private var selectedTab: Tab = .fitness
///
///     var body: some View {
///         ZStack(alignment: .bottom) {
///             TabView(selection: $selectedTab) {
///                 .
///                 .
///                 .
///             }
///
///             CurveTabBar(selectedTab: $selectedTab)
///                .padding(.horizontal)
///                .padding(.bottom, 30)
///         }
///         .ignoresSafeArea()
///     }
/// }
/// ```
///
///  ## Topics
///  ### Creating a CurveTabBar view
///  - ``init(tabItems:verticalPadding:activeForegroundColor:activeBackgroundColor:selectedTab:)``
///
/// ### Implementing the view
/// - ``body``
///
@available(iOS 15, macOS 11.0, *)
struct CurveTabBar: View {
    @Namespace private var tabItemTransition
    
    /// The array of tab items for the tab bar. By default, it aggregates all cases of the `Tab` enum.
    var tabItems: [Tab] = Tab.allCases
    /// The vertical padding of the tab bar
    var verticalPadding: Double = 10.0
    /// The foreground color of the active item
    var activeForegroundColor: Color? = nil
    /// The background color of the active item
    var activeBackgroundColor: Color = Color(.systemBackground)
    
    /// The selected tab item
    @Binding var selectedTab: Tab
    
    var body: some View {
        ZStack {
            
            HStack {
                
                ForEach(tabItems) { tabItem in
                    ZStack {
                        if tabItem == selectedTab {
                            Curve()
                                .fill(activeBackgroundColor)
                                .padding(.vertical, -verticalPadding )
                                .matchedGeometryEffect(id: "selectedtab", in: tabItemTransition)
                                .animation(.spring(response: 0.4, dampingFraction: 0.2), value: selectedTab)
                        }
                        
                        Button {
                            withAnimation(.easeInOut) {
                                selectedTab = tabItem
                            }
                        } label: {
                            TabBarItem(tabItem: tabItem, isActive: tabItem == selectedTab, activeColor: activeForegroundColor, namespace: tabItemTransition)
                        }
                        .buttonStyle(.plain)
                        .offset(y: tabItem == selectedTab ? -10 : 0)
                        
                    }

                }
                
            }
            .padding(.vertical, verticalPadding)
            .background(Color(.systemGray6))
            .border(.clear)
        }
        .frame(maxHeight: 50)
        
    }
    
    struct Curve: Shape {
        
        private let offsetX = 0.9
        private let curveOffsetX = 0.1
        
        func path(in rect: CGRect) -> Path {
            let h = rect.maxY * 0.7
            
            var path = Path()
            path.move(to: .zero)
            path.addLine(to: .init(x: rect.midX * (1.0 - offsetX) - 50, y: 0))
            
            path.addCurve(to: CGPoint(x: rect.midX, y: h), control1: CGPoint(x: rect.midX * curveOffsetX, y: rect.minY), control2: CGPoint(x: rect.midX * curveOffsetX, y: h))
            
            path.addCurve(to: CGPoint(x: rect.midX * (1.0 + offsetX) + 50, y: rect.minY), control1: CGPoint(x: rect.midX * (2.0 - curveOffsetX), y: h), control2: CGPoint(x: rect.midX * (2.0 - curveOffsetX), y: rect.minY))
                        
            return path
        }
    }
}

@available(iOS 15, macOS 11.0, *)
fileprivate struct TabBarItem: View {
    var tabItem: Tab
    var isActive: Bool = false
    var activeColor: Color? = nil
    let namespace: Namespace.ID
    
    init(tabItem: Tab, isActive: Bool = false, activeColor: Color? = nil, namespace: Namespace.ID) {
        
        self.tabItem = tabItem
        self.isActive = isActive
        self.activeColor = activeColor == nil ? tabItem.activeColor : activeColor
        self.namespace = namespace
        
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            
            Image(systemName: tabItem.icon)
                .font(.system(size: isActive ? 25 : 22, weight: isActive ? .medium : .regular))
                .foregroundColor(isActive ? activeColor : .gray)
                .animation(.spring(response: 0.4, dampingFraction: 0.2), value: isActive)
                
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity)
        
    }
    

}

@available(iOS 15, macOS 11.0, *)
struct CurveTabBar_Previews: PreviewProvider {
    static var previews: some View {
        
        CurveTabBarDemo()
            .previewDisplayName("CurveTabBar")
        
        CurveTabBarDemo()
            .previewDisplayName("CurveTabBar (Dark)")
            .preferredColorScheme(.dark)
        
        Color.purple
            .overlay {
                CurveTabBarDemo(activeForegroundColor: .yellow, activeBackgroundColor: .purple)
            }
            .previewDisplayName("CurveTabBar (Color BG)")
            .ignoresSafeArea()
        
        TabBarItemDemo()
            .previewDisplayName("TabBarItem")
    }
    
    struct CurveTabBarDemo: View {
        @State private var selectedTab: Tab = .dailyStreams
        
        var activeForegroundColor: Color? = nil
        var activeBackgroundColor: Color = Color(.systemBackground)
        
        var body: some View {
            CurveTabBar(activeForegroundColor: activeForegroundColor, activeBackgroundColor: activeBackgroundColor, selectedTab: $selectedTab)
        }
    }
    
    struct TabBarItemDemo: View {
        
        @Namespace private var tabItemTransition
        
        var body: some View {
            TabBarItem(tabItem: .dailyStreams, isActive: true, namespace: tabItemTransition)
                .frame(width: 100)
        }
    }
}
