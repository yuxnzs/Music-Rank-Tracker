import Foundation

struct DailyStreams: Codable, Identifiable {
    var id = UUID()
    let artistInfo: Artist
    let date: String
    var streamData: [StreamData]
    
    enum CodingKeys: String, CodingKey {
        case artistInfo, date, streamData
    }
}

struct StreamData: Codable, Identifiable {
    let musicName: String
    let albumName: String?
    let albumType: String?
    let totalTracks: Int?
    let trackNumber: Int?
    let duration: String
    let releaseDate: String
    let imageUrl: URL?
    let totalStreams: Int
    let dailyStreams: Int
    let popularity: Int
    let availableMarkets: Int?
    let spotifyUrl: URL?
    let musicId: String
    let isCollaboration: Bool
    
    // Identifiable id using musicId
    var id: String { musicId }
    
    enum CodingKeys: String, CodingKey {
        case musicName, albumName, albumType, totalTracks, trackNumber, duration, releaseDate, imageUrl, totalStreams, dailyStreams, popularity, availableMarkets, spotifyUrl, musicId, isCollaboration
    }
}
