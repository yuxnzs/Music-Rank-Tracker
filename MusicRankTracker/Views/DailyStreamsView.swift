import SwiftUI
import SDWebImageSwiftUI

struct DailyStreamsView: View {
    @EnvironmentObject var apiService: APIService
    
    @State var isLoading: Bool = false
    @State private var artistName: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Search bar
                    SearchBar(isLoading: $isLoading, artistName: $artistName, onSearch: searchArtist)
                    
                    if isLoading {
                        ProgressView()
                    } else {
                        if let dailyStreams = apiService.dailyStreams {
                            // Artist info
                            VStack {
                                HStack {
                                    WebImage(url: dailyStreams.artistInfo.image) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(Circle())
                                            .frame(width: 70, height: 70)
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 70, height: 70)
                                    }
                                    
                                    Text(dailyStreams.artistInfo.name)
                                        .font(.system(size: 24, weight: .bold))
                                        .padding(.leading, 3)
                                }
                                .padding(.horizontal, 10)
                                .padding([.top, .bottom], 10)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                            .padding(.bottom)
                            
                            // Stream data
                            // Use enmerated() to get the index of the element
                            ForEach(Array(dailyStreams.streamData.enumerated()), id: \.element.id) { index, streamData in
                                VStack {
                                    HStack(spacing: 0) {
                                        // Rank
                                        Text("\(index + 1)")
                                        // Use padding instead of frame for even spacing
                                        // `105` will have the same spacing as `1`
                                            .padding(.horizontal, 20)
                                            .font(.system(size: 18, weight: .bold))
                                        
                                        // Song title and daily streams
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(streamData.songTitle)
                                                .font(.system(size: 18, weight: .bold))
                                            
                                            Text("Daily Streams: \(streamData.dailyStreams)")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    // Content style
                                    // Ensure uniform vertical spacing for multi-line song titles as single-line
                                    .padding(.vertical, 10)
                                }
                                // Container style
                                .frame(maxWidth: .infinity, alignment: .leading)
                                // Fixed height for single-line song titles
                                .frame(minHeight: 63)
                                .background(.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Daily Streams")
        }
    }
    
    func searchArtist() async -> Void {
        await apiService.getDailyStreams(artist: artistName)
        
        if let _ = apiService.dailyStreams {
            print("Successfully fetched daily streams")
        } else {
            print("Failed to fetch daily streams")
        }
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
                streamData: [
                    StreamData(songTitle: "vampire", totalStreams: "1,027,537,652", dailyStreams: "1,221,995"),
                    StreamData(songTitle: "traitor", totalStreams: "1,587,660,527", dailyStreams: "1,073,382"),
                    StreamData(songTitle: "deja vu", totalStreams: "1,629,021,431", dailyStreams: "967,621"),
                    StreamData(songTitle: "drivers license", totalStreams: "2,204,846,637", dailyStreams: "953,931"),
                    StreamData(songTitle: "good 4 u", totalStreams: "2,187,296,852", dailyStreams: "879,613"),
                    StreamData(songTitle: "favorite crime", totalStreams: "1,076,543,930", dailyStreams: "872,234"),
                    StreamData(songTitle: "happier", totalStreams: "1,151,400,599", dailyStreams: "854,890"),
                    StreamData(songTitle: "jealousy, jealousy", totalStreams: "900,353,551", dailyStreams: "686,528"),
                    StreamData(songTitle: "obsessed", totalStreams: "149,672,055", dailyStreams: "636,839"),
                    StreamData(songTitle: "bad idea right?", totalStreams: "447,754,608", dailyStreams: "541,095"),
                    StreamData(songTitle: "so american", totalStreams: "90,204,314", dailyStreams: "489,490"),
                    StreamData(songTitle: "All I Want - From \"High School Musical: The Musical: The Series\"", totalStreams: "785,729,963", dailyStreams: "459,288"),
                    StreamData(songTitle: "get him back!", totalStreams: "298,631,175", dailyStreams: "424,729"),
                    StreamData(songTitle: "all-american bitch", totalStreams: "241,050,162", dailyStreams: "416,479"),
                    StreamData(songTitle: "1 step forward, 3 steps back", totalStreams: "494,964,474", dailyStreams: "410,330"),
                    StreamData(songTitle: "Can’t Catch Me Now - from The Hunger Games: The Ballad of Songbirds & Snakes", totalStreams: "268,445,933", dailyStreams: "365,366"),
                    StreamData(songTitle: "love is embarrassing", totalStreams: "172,428,140", dailyStreams: "332,305"),
                    StreamData(songTitle: "brutal", totalStreams: "647,956,022", dailyStreams: "323,435"),
                    StreamData(songTitle: "lacy", totalStreams: "185,114,134", dailyStreams: "323,063"),
                    StreamData(songTitle: "the grudge", totalStreams: "190,487,258", dailyStreams: "294,696")
                ]
            )
        ))
}
