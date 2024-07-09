/*
 Copyright © 2023 AppCoda Limited.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 Abstract: The model of the tab items
 */

import SwiftUI

protocol TabItem: CaseIterable, Identifiable {
    var id: Int { get }
    var name: String { get }
    var icon: String { get }
    var activeColor: Color { get }
}

/// A model representing the items of the tab view.
///
/// A ``Tab`` enum is used to define the available items in a tab-based UI. Each tab has an associated `id`, `name`,
/// `icon`, and `activeColor` properties. The `id` property is used to uniquely identify each, while the `name`
/// property is used to display the label of the tab item. The `icon` property is used to display a corresponding icon,
/// and the `activeColor` property contains the specify `Color` used for the active tab item.
///
/// The code below shows a sample `Tab` enum which contains five tab items including:
///
/// * Nature
/// * Travel
/// * Fitness
/// * Food
/// * Interior design
///
@available(iOS 15, macOS 11.0, *)
enum Tab: Int, TabItem {
    case dailyStreams
    case billboardHistory
    case billboardDate
    
    /// The unique ID for the tab item
    var id: Int {
        self.rawValue
    }
    
    /// The label of the tab item
    var name: String {
        switch self {
        case .dailyStreams: return "Daily Streams"
        case .billboardHistory: return "Billboard History"
        case .billboardDate: return "Billboard Data by Date"
        }
    }
    
    /// The icon of the tab item
    var icon: String {
        switch self {
        case .dailyStreams: return "chart.bar"
        case .billboardHistory: return "trophy"
        case .billboardDate: return "calendar"
        }
    }
    
    /// The color of the active tab item
    var activeColor: Color {
        Color(red: 0.68, green: 0.85, blue: 0.90)
    }
}


