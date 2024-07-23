import Foundation

class DisplayManager: ObservableObject {
    @Published var displayStreamData: [StreamData] = []
    @Published var displayStreamType: String = "daily"
    @Published var dailyStreamsArtistName: String = ""
    @Published var dailySearchText: String = ""
    @Published var isDailySearchTextFieldShowing: Bool = false
    @Published var isFiltering: Bool = false
    @Published var musicType: String = "songs"
    @Published var sortingStreamType: String = "daily"

    // For preview to insert dummy data
    init(displayStreamData: [StreamData] = []) {
        self.displayStreamData = displayStreamData
    }
}
