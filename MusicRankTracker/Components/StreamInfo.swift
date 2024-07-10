import SwiftUI
import SDWebImageSwiftUI

struct StreamInfo: View {
    let rank: Int
    let streamData: StreamData
    let streamType: String
    
    var body: some View {
        HStack(spacing: 0) {
            // Rank
            Text("\(rank + 1)")
                .frame(width: rank + 1 < 100 ? 25 : 37, alignment: .center)
                .font(.system(size: 18, weight: .bold))
                .padding(.trailing)

            VStack {
                HStack(spacing: 0) {
                    WebImage(url: streamData.imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 65, height: 65)
                    
                    // Song title and streams
                    VStack(alignment: .leading, spacing: 5) {
                        Text(streamData.musicName)
                            .font(.system(size: 18, weight: .bold))
                        
                        // Use Group to avoid repeating modifiers
                        Group {
                            if streamType == "daily" {
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
        // Fixed height for single-line song titles
        .frame(height: 65)
        .padding(.horizontal)
    }
}

#Preview {
    DailyStreamsView()
        .environmentObject(APIService(
            dailyStreams: DailyStreams(
                artistInfo: Artist(
                    name: "Olivia Rodrigo",
                    image: URL(string: "https://i.scdn.co/image/ab6761610000e5ebe03a98785f3658f0b6461ec4")!
                ),
                date: "2024/07/08",
                streamData: [
                    StreamData(musicName: "vampire", albumName: "GUTS", totalTracks: nil, trackNumber: 3, duration: "3:39", releaseDate: "2023-09-08", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273e85259a1cae29a8d91f2093d")!, totalStreams: "1,032,236,462", dailyStreams: "1,187,757", popularity: 85, spotifyUrl: URL(string: "https://open.spotify.com/track/1kuGVB7EU95pJObxwvfwKS")!),
                    StreamData(musicName: "traitor", albumName: "SOUR", totalTracks: nil, trackNumber: 2, duration: "3:49", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: "1,591,547,413", dailyStreams: "1,034,829", popularity: 84, spotifyUrl: URL(string: "https://open.spotify.com/track/5CZ40GBx1sQ9agT82CLQCT")!),
                    StreamData(musicName: "deja vu", albumName: "SOUR", totalTracks: nil, trackNumber: 5, duration: "3:35", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: "1,632,762,778", dailyStreams: "997,879", popularity: 84, spotifyUrl: URL(string: "https://open.spotify.com/track/6HU7h9RYOaPRFeh0R3UeAr")!),
                    StreamData(musicName: "drivers license", albumName: "SOUR", totalTracks: nil, trackNumber: 3, duration: "4:02", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: "2,208,462,492", dailyStreams: "947,586", popularity: 83, spotifyUrl: URL(string: "https://open.spotify.com/track/5wANPM4fQCJwkGd4rN57mH")!),
                    StreamData(musicName: "favorite crime", albumName: "SOUR", totalTracks: nil, trackNumber: 10, duration: "2:32", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: "1,079,768,005", dailyStreams: "873,014", popularity: 82, spotifyUrl: URL(string: "https://open.spotify.com/track/5JCoSi02qi3jJeHdZXMmR8")!),
                    StreamData(musicName: "good 4 u", albumName: "SOUR", totalTracks: nil, trackNumber: 6, duration: "2:58", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: "2,190,564,300", dailyStreams: "866,873", popularity: 83, spotifyUrl: URL(string: "https://open.spotify.com/track/4ZtFanR9U6ndgddUvNcjcG")!),
                    StreamData(musicName: "happier", albumName: "SOUR", totalTracks: nil, trackNumber: 8, duration: "2:55", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: "1,154,614,855", dailyStreams: "823,519", popularity: 82, spotifyUrl: URL(string: "https://open.spotify.com/track/2tGvwE8GcFKwNdAXMnlbfl")!),
                    StreamData(musicName: "jealousy, jealousy", albumName: "SOUR", totalTracks: nil, trackNumber: 9, duration: "2:53", releaseDate: "2021-05-21", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a")!, totalStreams: "903,009,502", dailyStreams: "681,002", popularity: 81, spotifyUrl: URL(string: "https://open.spotify.com/track/0MMyJUC3WNnFS1lit5pTjk")!),
                    StreamData(musicName: "obsessed", albumName: "GUTS (spilled)", totalTracks: nil, trackNumber: 13, duration: "2:50", releaseDate: "2024-03-22", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b2734063d624ebf8ff67bc3701ee")!, totalStreams: "152,151,402", dailyStreams: "650,436", popularity: 83, spotifyUrl: URL(string: "https://open.spotify.com/track/6tNgRQ0K2NYZ0Rb9l9DzL8")!),
                    StreamData(musicName: "bad idea right?", albumName: "GUTS", totalTracks: nil, trackNumber: 2, duration: "3:04", releaseDate: "2023-09-08", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273e85259a1cae29a8d91f2093d")!, totalStreams: "449,903,949", dailyStreams: "556,500", popularity: 80, spotifyUrl: URL(string: "https://open.spotify.com/track/3IX0yuEVvDbnqUwMBB3ouC")!),
                    StreamData(musicName: "All I Want - From \"High School Musical: The Musical: The Series\"", albumName: "Best of High School Musical: The Musical: The Series", totalTracks: nil, trackNumber: 1, duration: "2:57", releaseDate: "2021-07-16", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273df69029521d74251c8c4eafa")!, totalStreams: "787,481,442", dailyStreams: "472,558", popularity: 37, spotifyUrl: URL(string: "https://open.spotify.com/track/0qPCCYNKg636mBmz9qOIw2")!),
                    StreamData(musicName: "so american", albumName: "GUTS (spilled)", totalTracks: nil, trackNumber: 17, duration: "2:49", releaseDate: "2024-03-22", imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b2734063d624ebf8ff67bc3701ee")!, totalStreams: "91,997,784", dailyStreams: "462,149", popularity: 79, spotifyUrl: URL(string: "https://open.spotify.com/track/5Jh1i0no3vJ9u4deXkb4aV")!)
                ]
            )
        ))
}
