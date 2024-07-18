import Foundation

struct BillboardHistory: Codable, Identifiable {
    var id = UUID()
    let artistInfo: Artist
    let historyData: [BillboardHistoryData]
    
    enum CodingKeys: String, CodingKey {
        case artistInfo, historyData
    }
}

struct BillboardHistoryData: Codable, Identifiable {
    var id = UUID()
    let song: String
    let artist: String
    let first_week: Int
    let this_week: Int
    let last_week: Int?
    let peak_position: Int
    let weeks_on_chart: Int
    
    enum CodingKeys: String, CodingKey {
        case song, artist, first_week, this_week, last_week, peak_position, weeks_on_chart
    }
}
