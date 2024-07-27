import Foundation

struct BillboardHistory: Codable, Identifiable {
    var id = UUID()
    let artistInfo: Artist
    var historyData: [BillboardHistoryData]
    
    enum CodingKeys: String, CodingKey {
        case artistInfo, historyData
    }
}

struct BillboardHistoryData: Codable, Identifiable {
    var id = UUID()
    let song: String
    let artist: String
    let firstChartedPosition: Int
    let firstChartedDate: String
    let lastChartedPosition: Int
    let lastChartedDate: String
    let lastWeekPosition: Int?
    let peakPosition: Int
    let weeksOnChart: Int
    
    enum CodingKeys: String, CodingKey {
        case song, artist, firstChartedPosition, firstChartedDate, lastChartedPosition, lastChartedDate, lastWeekPosition, peakPosition, weeksOnChart
    }
}
