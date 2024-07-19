import Foundation

class DisplayManager: ObservableObject {
    @Published var displayStreamData: [StreamData] = []
    @Published var artistName: String = ""
    @Published var musicType: String = "songs"
    @Published var sortingStreamType: String = "daily"
    @Published var displayStreamType: String = "daily"
    @Published var searchText: String = ""
    
    // For preview to insert dummy data
    init(displayStreamData: [StreamData] = []) {
        self.displayStreamData = displayStreamData
    }
}
