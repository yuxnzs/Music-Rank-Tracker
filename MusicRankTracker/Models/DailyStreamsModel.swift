import Foundation

struct DailyStreams: Codable, Identifiable {
    var id = UUID()
    let artistInfo: Artist
    let date: String
    let streamData: [StreamData]
    
    enum CodingKeys: String, CodingKey {
        case artistInfo, date, streamData
    }
}

struct StreamData: Codable, Identifiable {
    var id = UUID()
    let songTitle: String
    let totalStreams: String
    let dailyStreams: String
    
    enum CodingKeys: String, CodingKey {
        case songTitle, totalStreams, dailyStreams
    }
}
