import Foundation

struct BillboardDate: Codable, Identifiable {
    var id = UUID()
    let rank: Int
    let title: String
    let artist: String
    let cover: URL
    let position: BillboardPosition
    
    enum CodingKeys: String, CodingKey {
        case rank, title, artist, cover, position
    }
}

struct BillboardPosition: Codable {
    let positionLastWeek: Int?
    let peakPosition: Int
    let weeksOnChart: Int
}
