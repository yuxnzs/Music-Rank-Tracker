import Foundation

class DisplayManager: ObservableObject {
    @Published var displayStreamData: [StreamData] = []
    @Published var displayStreamType: String = "Daily"
    @Published var dailyArtistName: String = ""
    @Published var dailySearchText: String = ""
    @Published var isDailySearchTextFieldShowing: Bool = false
    @Published var isDailyFiltering: Bool = false
    @Published var musicType: String = "Songs"
    @Published var sortingStreamType: String = "Daily"

    // For preview to insert dummy data
    init(displayStreamData: [StreamData] = []) {
        self.displayStreamData = displayStreamData
    }
}
