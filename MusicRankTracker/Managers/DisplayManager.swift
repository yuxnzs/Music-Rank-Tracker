import Foundation

class DisplayManager: ObservableObject {
    // For DailyStreamsView
    @Published var displayStreamData: [StreamData] = []
    @Published var displayStreamType: String = "Daily" // Used to only display the stream type, not the sorting type
    @Published var dailyArtistName: String = ""
    @Published var dailySearchText: String = ""
    @Published var isDailySearchTextFieldShowing: Bool = false
    @Published var isDailyFiltering: Bool = false
    @Published var isDailyLoading: Bool = false
    @Published var musicType: String = "Songs"
    @Published var sortingStreamType: String = "Daily"
    
    // For BillboardHistoryView
    @Published var displayHistoryData: [BillboardHistoryData] = []
    @Published var historyArtistName: String = "songs"
    @Published var historySearchText: String = ""
    @Published var isHistorySearchTextFieldShowing: Bool = false
    @Published var isHistoryFiltering: Bool = false
    @Published var isHistoryFilteringRanking: Bool = false
    @Published var isHistoryLoading: Bool = false
    @Published var sortingHistoryType: String = "Release Date"
    
    // For BillboardDateView
    @Published var displayDateData: [BillboardHistoryData] = []
    @Published var isBillboardDateLoading: Bool = false
    
    // For preview to insert dummy data
    init(displayStreamData: [StreamData] = [], displayHistoryData: [BillboardHistoryData] = []) {
        self.displayStreamData = displayStreamData
        self.displayHistoryData = displayHistoryData
    }
}
