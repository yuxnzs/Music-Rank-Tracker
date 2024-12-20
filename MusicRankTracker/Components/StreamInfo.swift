import SwiftUI
import SDWebImageSwiftUI

struct StreamInfo: View {
    let rank: Int
    let streamData: StreamData
    let streamType: String
    let isPlaceholder: Bool
    
    init(rank: Int, streamData: StreamData, streamType: String, isPlaceholder: Bool = false) {
        self.rank = rank
        self.streamData = streamData
        self.streamType = streamType
        self.isPlaceholder = isPlaceholder
    }
    
    // For LoadingDailyStreamsView
    init(isPlaceholder: Bool, rank: Int) {
        self.rank = rank
        self.streamData = StreamData.placeholder() // Use placeholder() to create a StreamData instance
        self.streamType = "Placeholder"
        self.isPlaceholder = isPlaceholder
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if isPlaceholder {
                // Rank
                Text("\(rank)")
                    .frame(width: rank < 100 ? 25 : 37, alignment: .center)
                    .font(.system(size: 18, weight: .bold))
                    .padding(.trailing)
                
                // Image and song info placeholder
                VStack {
                    HStack(spacing: 0) {
                        // Image placeholder
                        LoadingPlaceholder()
                            .frame(width: 65, height: 65)
                        
                        // Song title and streams placeholder
                        VStack(alignment: .leading, spacing: 5) {
                            LoadingPlaceholder()
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .frame(width: 150, height: 20)
                            
                            LoadingPlaceholder()
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .frame(width: 200, height: 17)
                        }
                        .padding(10)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                // Container style
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                // Rank
                Text("\(rank)")
                    .frame(width: rank < 100 ? 25 : 37, alignment: .center)
                    .font(.system(size: 18, weight: .bold))
                    .padding(.trailing)
                
                VStack {
                    HStack(spacing: 0) {
                        WebImage(url: streamData.imageUrl) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            LoadingPlaceholder()
                        }
                        .frame(width: 65, height: 65)
                        .clipped()
                        
                        // Song title and streams
                        VStack(alignment: .leading, spacing: 5) {
                            Text(streamData.musicName)
                                .font(.system(size: 18, weight: .bold))
                            
                            // Use Group to avoid repeating modifiers
                            Group {
                                if streamType == "Daily" {
                                    Text("Daily Streams: \(streamData.dailyStreams)")
                                } else {
                                    Text("Total Streams: \(streamData.totalStreams)")
                                }
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.secondary)
                        }
                        .padding(10)
                    }
                }
                // Container style
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        // Fixed height for single-line song titles
        .frame(height: 65)
        .padding(.horizontal)
    }
}

#Preview {
    DailyStreamsView(isShowingTabBar: .constant(true), bottomSafeArea: 20)
        .environmentObject(APIService(
            dailyStreams: DailyStreams(
                artistInfo: Artist(
                    name: "Olivia Rodrigo",
                    image: URL(string: "https://i.scdn.co/image/ab6761610000e5ebe03a98785f3658f0b6461ec4")!
                ),
                date: "2024/07/08",
                streamData: [
                    StreamData(rank: 1, musicName: "vampire", albumName: "GUTS", albumType: nil, totalTracks: nil, trackNumber: 3, duration: "3:39", releaseDate: "2023-09-08", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273e85259a1cae29a8d91f2093d")!, totalStreams: 1033456751, dailyStreams: 1220289, popularity: 85, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/1kuGVB7EU95pJObxwvfwKS")!, musicId: "1kuGVB7EU95pJObxwvfwKS", isCollaboration: false),
                    StreamData(rank: 2, musicName: "traitor", albumName: "SOUR", albumType: nil, totalTracks: nil, trackNumber: 2, duration: "3:49", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: 1592608997, dailyStreams: 1061584, popularity: 84, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/5CZ40GBx1sQ9agT82CLQCT")!, musicId: "5CZ40GBx1sQ9agT82CLQCT", isCollaboration: false),
                    StreamData(rank: 3, musicName: "deja vu", albumName: "SOUR", albumType: nil, totalTracks: nil, trackNumber: 5, duration: "3:35", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: 1633758661, dailyStreams: 995883, popularity: 84, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/6HU7h9RYOaPRFeh0R3UeAr")!, musicId: "6HU7h9RYOaPRFeh0R3UeAr", isCollaboration: false),
                    StreamData(rank: 4, musicName: "drivers license", albumName: "SOUR", albumType: nil, totalTracks: nil, trackNumber: 3, duration: "4:02", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: 2209434500, dailyStreams: 972008, popularity: 83, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/5wANPM4fQCJwkGd4rN57mH")!, musicId: "5wANPM4fQCJwkGd4rN57mH", isCollaboration: false),
                    StreamData(rank: 5, musicName: "favorite crime", albumName: "SOUR", albumType: nil, totalTracks: nil, trackNumber: 10, duration: "2:32", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: 1080712099, dailyStreams: 944094, popularity: 82, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/5JCoSi02qi3jJeHdZXMmR8")!, musicId: "5JCoSi02qi3jJeHdZXMmR8", isCollaboration: false),
                    StreamData(rank: 6, musicName: "good 4 u", albumName: "SOUR", albumType: nil, totalTracks: nil, trackNumber: 6, duration: "2:58", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: 2191421930, dailyStreams: 857630, popularity: 83, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/4ZtFanR9U6ndgddUvNcjcG")!, musicId: "4ZtFanR9U6ndgddUvNcjcG", isCollaboration: false),
                    StreamData(rank: 7, musicName: "happier", albumName: "SOUR", albumType: nil, totalTracks: nil, trackNumber: 8, duration: "2:55", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: 1155461099, dailyStreams: 846244, popularity: 82, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/2tGvwE8GcFKwNdAXMnlbfl")!, musicId: "2tGvwE8GcFKwNdAXMnlbfl", isCollaboration: false),
                    StreamData(rank: 8, musicName: "jealousy, jealousy", albumName: "SOUR", albumType: nil, totalTracks: nil, trackNumber: 9, duration: "2:53", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: 903702690, dailyStreams: 693188, popularity: 81, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/0MMyJUC3WNnFS1lit5pTjk")!, musicId: "0MMyJUC3WNnFS1lit5pTjk", isCollaboration: false),
                    StreamData(rank: 9, musicName: "obsessed", albumName: "GUTS (spilled)", albumType: nil, totalTracks: nil, trackNumber: 13, duration: "2:50", releaseDate: "2024-03-22", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b2734063d624ebf8ff67bc3701ee")!, totalStreams: 152793837, dailyStreams: 642435, popularity: 83, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/6tNgRQ0K2NYZ0Rb9l9DzL8")!, musicId: "6tNgRQ0K2NYZ0Rb9l9DzL8", isCollaboration: false),
                    StreamData(rank: 10, musicName: "bad idea right?", albumName: "GUTS", albumType: nil, totalTracks: nil, trackNumber: 2, duration: "3:04", releaseDate: "2023-09-08", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273e85259a1cae29a8d91f2093d")!, totalStreams: 450456901, dailyStreams: 552952, popularity: 80, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/3IX0yuEVvDbnqUwMBB3ouC")!, musicId: "3IX0yuEVvDbnqUwMBB3ouC", isCollaboration: false),
                    StreamData(rank: 11, musicName: "All I Want - From \"High School Musical: The Musical: The Series\"", albumName: "Best of High School Musical: The Musical: The Series", albumType: nil, totalTracks: nil, trackNumber: 1, duration: "2:57", releaseDate: "2021-07-16", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273df69029521d74251c8c4eafa")!, totalStreams: 787944478, dailyStreams: 463036, popularity: 37, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/0qPCCYNKg636mBmz9qOIw2")!, musicId: "0qPCCYNKg636mBmz9qOIw2", isCollaboration: true),
                    StreamData(rank: 12, musicName: "so american", albumName: "GUTS (spilled)", albumType: nil, totalTracks: nil, trackNumber: 17, duration: "2:49", releaseDate: "2024-03-22", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b2734063d624ebf8ff67bc3701ee")!, totalStreams: 92454081, dailyStreams: 456297, popularity: 79, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/5Jh1i0no3vJ9u4deXkb4aV")!, musicId: "5Jh1i0no3vJ9u4deXkb4aV", isCollaboration: false)
                ]
            )
        ))
        .environmentObject(DisplayManager(
            displayStreamData: [
                StreamData(rank: 1, musicName: "vampire", albumName: "GUTS", albumType: nil, totalTracks: nil, trackNumber: 3, duration: "3:39", releaseDate: "2023-09-08", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273e85259a1cae29a8d91f2093d")!, totalStreams: 1033456751, dailyStreams: 1220289, popularity: 85, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/1kuGVB7EU95pJObxwvfwKS")!, musicId: "1kuGVB7EU95pJObxwvfwKS", isCollaboration: false),
                StreamData(rank: 2, musicName: "traitor", albumName: "SOUR", albumType: nil, totalTracks: nil, trackNumber: 2, duration: "3:49", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: 1592608997, dailyStreams: 1061584, popularity: 84, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/5CZ40GBx1sQ9agT82CLQCT")!, musicId: "5CZ40GBx1sQ9agT82CLQCT", isCollaboration: false),
                StreamData(rank: 3, musicName: "deja vu", albumName: "SOUR", albumType: nil, totalTracks: nil, trackNumber: 5, duration: "3:35", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: 1633758661, dailyStreams: 995883, popularity: 84, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/6HU7h9RYOaPRFeh0R3UeAr")!, musicId: "6HU7h9RYOaPRFeh0R3UeAr", isCollaboration: false),
                StreamData(rank: 4, musicName: "drivers license", albumName: "SOUR", albumType: nil, totalTracks: nil, trackNumber: 3, duration: "4:02", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: 2209434500, dailyStreams: 972008, popularity: 83, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/5wANPM4fQCJwkGd4rN57mH")!, musicId: "5wANPM4fQCJwkGd4rN57mH", isCollaboration: false),
                StreamData(rank: 5, musicName: "favorite crime", albumName: "SOUR", albumType: nil, totalTracks: nil, trackNumber: 10, duration: "2:32", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: 1080712099, dailyStreams: 944094, popularity: 82, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/5JCoSi02qi3jJeHdZXMmR8")!, musicId: "5JCoSi02qi3jJeHdZXMmR8", isCollaboration: false),
                StreamData(rank: 6, musicName: "good 4 u", albumName: "SOUR", albumType: nil, totalTracks: nil, trackNumber: 6, duration: "2:58", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: 2191421930, dailyStreams: 857630, popularity: 83, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/4ZtFanR9U6ndgddUvNcjcG")!, musicId: "4ZtFanR9U6ndgddUvNcjcG", isCollaboration: false),
                StreamData(rank: 7, musicName: "happier", albumName: "SOUR", albumType: nil, totalTracks: nil, trackNumber: 8, duration: "2:55", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: 1155461099, dailyStreams: 846244, popularity: 82, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/2tGvwE8GcFKwNdAXMnlbfl")!, musicId: "2tGvwE8GcFKwNdAXMnlbfl", isCollaboration: false),
                StreamData(rank: 8, musicName: "jealousy, jealousy", albumName: "SOUR", albumType: nil, totalTracks: nil, trackNumber: 9, duration: "2:53", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: 903702690, dailyStreams: 693188, popularity: 81, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/0MMyJUC3WNnFS1lit5pTjk")!, musicId: "0MMyJUC3WNnFS1lit5pTjk", isCollaboration: false),
                StreamData(rank: 9, musicName: "obsessed", albumName: "GUTS (spilled)", albumType: nil, totalTracks: nil, trackNumber: 13, duration: "2:50", releaseDate: "2024-03-22", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b2734063d624ebf8ff67bc3701ee")!, totalStreams: 152793837, dailyStreams: 642435, popularity: 83, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/6tNgRQ0K2NYZ0Rb9l9DzL8")!, musicId: "6tNgRQ0K2NYZ0Rb9l9DzL8", isCollaboration: false),
                StreamData(rank: 10, musicName: "bad idea right?", albumName: "GUTS", albumType: nil, totalTracks: nil, trackNumber: 2, duration: "3:04", releaseDate: "2023-09-08", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273e85259a1cae29a8d91f2093d")!, totalStreams: 450456901, dailyStreams: 552952, popularity: 80, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/3IX0yuEVvDbnqUwMBB3ouC")!, musicId: "3IX0yuEVvDbnqUwMBB3ouC", isCollaboration: false),
                StreamData(rank: 11, musicName: "All I Want - From \"High School Musical: The Musical: The Series\"", albumName: "Best of High School Musical: The Musical: The Series", albumType: nil, totalTracks: nil, trackNumber: 1, duration: "2:57", releaseDate: "2021-07-16", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273df69029521d74251c8c4eafa")!, totalStreams: 787944478, dailyStreams: 463036, popularity: 37, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/0qPCCYNKg636mBmz9qOIw2")!, musicId: "0qPCCYNKg636mBmz9qOIw2", isCollaboration: true),
                StreamData(rank: 12, musicName: "so american", albumName: "GUTS (spilled)", albumType: nil, totalTracks: nil, trackNumber: 17, duration: "2:49", releaseDate: "2024-03-22", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b2734063d624ebf8ff67bc3701ee")!, totalStreams: 92454081, dailyStreams: 456297, popularity: 79, availableMarkets: nil, spotifyUrl: URL(string: "https://open.spotify.com/track/5Jh1i0no3vJ9u4deXkb4aV")!, musicId: "5Jh1i0no3vJ9u4deXkb4aV", isCollaboration: false)
            ]
        ))
}
