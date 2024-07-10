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
    let musicName: String
    let albumName: String?
    let totalTracks: Int?
    let trackNumber: Int?
    let duration: String
    let releaseDate: String
    let imageUrl: URL
    let totalStreams: String
    let dailyStreams: String
    let popularity: Int
    let spotifyUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case musicName, albumName, totalTracks, trackNumber, duration, releaseDate, imageUrl, totalStreams, dailyStreams, popularity, spotifyUrl
    }
}
