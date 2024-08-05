import SwiftUI
import SDWebImageSwiftUI

struct DailyStreamsView: View {
    @EnvironmentObject var apiService: APIService
    @EnvironmentObject var displayManager: DisplayManager
    @Binding var isShowingTabBar: Bool
    let bottomSafeArea: CGFloat
    
    @State private var isStreamTypeSheetPresented: Bool = false
    
    @FocusState private var isFocused: Bool
    
    // Track if click the same view again
    @State private var lastViewedMusicId: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Search options
                    VStack {
                        HStack(alignment: .bottom, spacing: 0) {
                            TypePicker(
                                text: "Type",
                                selection: $displayManager.musicType,
                                options: ["Songs", "Albums"],
                                width: 130
                            )
                            
                            TypePicker(
                                text: "Sort by",
                                selection: $displayManager.sortingStreamType,
                                options: ["Daily", "Total"],
                                onChange: handleTypeChange
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 30)
                    .padding(.horizontal)
                    
                    SearchBar(isLoading: $displayManager.isDailyLoading, artistName: $displayManager.dailyArtistName, onSearch: searchArtist)
                    // Equal bottom padding in this View
                        .padding(.bottom, 20)
                    
                    if displayManager.isDailyLoading {
                        ProgressView()
                    } else {
                        if let dailyStreams = apiService.dailyStreams {
                            // Artist info
                            ArtistInfo(artistImageURL: dailyStreams.artistInfo.image, artistName: dailyStreams.artistInfo.name, date: dailyStreams.date, totalCount: dailyStreams.streamData.count)
                            // Equal bottom padding in this View
                                .padding(.bottom, 20)
                            
                            // Stream info
                            VStack {
                                // Render the first 10 items first to avoid stuttering behavior caused by LazyVStack
                                ForEach(displayManager.displayStreamData.prefix(10), id: \.id) { streamData in
                                    streamInfoLink(for: streamData, dailyStreams: dailyStreams)
                                }
                                
                                // Render the rest of the items using LazyVStack for better performance
                                LazyVStack {
                                    ForEach(displayManager.displayStreamData.dropFirst(10), id: \.id) { streamData in
                                        streamInfoLink(for: streamData, dailyStreams: dailyStreams)
                                    }
                                }
                                .padding(.bottom, bottomSafeArea + 20)
                            }
                        }
                    }
                }
            }
            // Close keyboard in each View instead of in ContentView to avoid components overriding parent's onTapGesture not working
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .navigationTitle("Daily Streams")
            .toolbar {
                // Center the SearchToolbar
                ToolbarItem(placement: .principal) {
                    SearchToolbar(
                        isSearchTextFieldShowing: $displayManager.isDailySearchTextFieldShowing,
                        searchText: $displayManager.dailySearchText,
                        isFocused: $isFocused,
                        placeholderText: "Enter song or album name",
                        handleTextChange: handleTextChange,
                        mainButtonIcon: "chart.bar",
                        filterButtonAction: filterButtonAction,
                        mainButtonAction: {
                            isStreamTypeSheetPresented.toggle()
                        }
                    )
                }
            }
            .sheet(isPresented: $isStreamTypeSheetPresented) {
                VStack(spacing: 20) {
                    Text("Display Stream Type")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("Choose how you want to view the stream counts:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Picker("Stream Type", selection: $displayManager.displayStreamType) {
                        Text("Daily Streams").tag("Daily")
                        Text("Total Streams").tag("Total")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    Text(displayManager.displayStreamType == "daily" ? "Show daily stream counts" : "Show total stream counts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .presentationDetents([.height(250)])
                .presentationDragIndicator(.visible)
            }
            .alert(isPresented: $apiService.showAlert) {
                Alert(
                    title: Text("Artist Not Found"),
                    message: Text(apiService.alertMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .environmentObject(apiService)
            .environmentObject(displayManager)
        }
    }
    
    func searchArtist() async -> Void {
        apiService.dailyStreams = nil // Reset dailyStreams, avoid next search shows previous result before new data loaded
        displayManager.displayStreamData = await apiService.getDailyStreams(artist: displayManager.dailyArtistName, musicType: displayManager.musicType, streamType: displayManager.sortingStreamType)
    }
    
    // Pass to TypePicker's onChange
    func handleTypeChange(_ selection: String) {
        guard let streamData = apiService.dailyStreams?.streamData else { return }
        
        displayManager.displayStreamType = selection // Update displayStreamType when sorting changes
        
        withAnimation(.linear) {
            if displayManager.isDailyFiltering {
                // When Daily switch to Total or vice versa, sort original data first then filter
                // Make sure when is filtering and changing the sorting type, the rank is displayed based on the sorting type
                // And also ensure the the original data sorting order display the same sorting type after stop filtering
                apiService.dailyStreams?.streamData = apiService.sortStreams(streamData: streamData, streamType: selection, shouldReassignRanks: true)
                
                filterAndUpdateDisplayStreamData(keySelectors: [
                    { $0.musicName },
                    { $0.albumName }
                ])
            } else {
                // When is not filtering, sort the original data
                displayManager.displayStreamData = apiService.sortStreams(streamData: streamData, streamType: selection, shouldReassignRanks: true)
                apiService.dailyStreams?.streamData = displayManager.displayStreamData
            }
        }
    }
    
    // Pass to ToolBarTextField's onChange
    func handleTextChange(_ searchText: Binding<String>) {
        // Update UI when searchText changes
        filterAndUpdateDisplayStreamData(keySelectors: [
            { $0.musicName },
            { $0.albumName }
        ])
        
        if searchText.wrappedValue.isEmpty {
            displayManager.displayStreamData = apiService.dailyStreams?.streamData ?? []
            displayManager.isDailyFiltering = false
        } else {
            displayManager.isDailyFiltering = true
        }
    }
    
    func filterButtonAction() {
        // Use DispatchQueue.main.async to make sure display data reset to original after searchText is cleared
        DispatchQueue.main.async {
            withAnimation(.linear) {
                displayManager.isDailySearchTextFieldShowing.toggle()
                displayManager.dailySearchText = ""
                // When searchText is cleard from here, ToolBarTextField's onChange cannot be triggered
                // So need to handle it manually
                if displayManager.dailySearchText.isEmpty {
                    displayManager.displayStreamData = apiService.dailyStreams?.streamData ?? []
                    displayManager.isDailyFiltering = false
                }
            }
        }
        // Pop up keyboard when TextField is shown
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isFocused = true
        }
    }
    
    func filterAndUpdateDisplayStreamData(keySelectors: [(StreamData) -> String?]) {
        displayManager.displayStreamData = apiService.filterData(
            items: apiService.dailyStreams?.streamData ?? [],
            searchText: displayManager.dailySearchText,
            keySelectors: keySelectors
        )
    }
    
    private func streamInfoLink(for streamData: StreamData, dailyStreams: DailyStreams) -> some View {
        NavigationLink {
            MusicDetailView(artistInfo: dailyStreams.artistInfo, streamData: streamData, lastViewedMusicId: $lastViewedMusicId)
                .onAppear {
                    UIApplication.shared.endEditing() // Make sure the keyboard is closed when the view appears
                    withAnimation {
                        isShowingTabBar = false
                    }
                }
                .onDisappear {
                    withAnimation {
                        isShowingTabBar = true
                    }
                }
        } label: {
            StreamInfo(rank: streamData.rank, streamData: streamData, streamType: displayManager.displayStreamType)
            // Equal bottom padding in this View
                .padding(.bottom, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DailyStreamsView(isShowingTabBar: .constant(true), bottomSafeArea: 34)
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
