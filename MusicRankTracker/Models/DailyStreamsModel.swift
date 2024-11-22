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
    var rank: Int
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
        case rank, musicName, albumName, albumType, totalTracks, trackNumber, duration, releaseDate, imageUrl, totalStreams, dailyStreams, popularity, availableMarkets, spotifyUrl, musicId, isCollaboration
    }
    
    // Placeholder instance for StreamInfo component
    static func placeholder() -> StreamData {
        return StreamData(
            rank: 0,
            musicName: "Placeholder",
            albumName: "Placeholder",
            albumType: "Placeholder",
            totalTracks: 0,
            trackNumber: 0,
            duration: "0:00",
            releaseDate: "Placeholder",
            imageUrl: nil,
            totalStreams: 0,
            dailyStreams: 0,
            popularity: 0,
            availableMarkets: 0,
            spotifyUrl: nil,
            musicId: "Placeholder",
            isCollaboration: false
        )
    }
}
