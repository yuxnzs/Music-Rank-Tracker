import SwiftUI
import SDWebImageSwiftUI

struct MusicDetailView: View {
    @EnvironmentObject var apiService: APIService
    let artistInfo: Artist
    let streamData: StreamData
    
    // Use @State to change the value in onDisappear
    @Binding var lastViewedMusicId: String?
    
    // Track if click the same view again
    @State private var isArtistNameTapped = false
    @State private var tappedIndices: [Int: Bool] = [:]
    
    @State private var isCollaboratorsLoading = false
    
    // Trigger when `isTapped: binding(for: index)` is changed
    private func binding(for index: Int) -> Binding<Bool> {
        return Binding<Bool>(
            // Get the current state from tappedIndices using index
            // If tappedIndices[index] is nil (when View is first rendered), return false
            get: { tappedIndices[index, default: false] },
            // $0 is a Bool value, passed by SwiftUI based on the current state
            set: { tappedIndices[index] = $0 }
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack {
                    WebImage(url: streamData.imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ImagePlaceholder()
                        // Approximate height for 640 x 640 image after scaledToFit() on iPhone 15
                            .frame(height: 393)
                    }
                }
                
                // Header
                VStack(spacing: 6) {
                    Button {
                        if let spotifyUrl = streamData.spotifyUrl {
                            UIApplication.shared.open(spotifyUrl)
                        }
                    } label: {
                        Text(streamData.musicName)
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    
                    HStack(alignment: .bottom, spacing: 5) {
                        // If is song, display album name and release year
                        // If is album, check weather it's an album or compilation + release year
                        if let albumName = streamData.albumName { // For song
                            Text("\(albumName) • \(streamData.releaseDate.prefix(4))")
                        } else if let albumType = streamData.albumType { // For album or compilation
                            Text("\(albumType.capitalized) • \(streamData.releaseDate.prefix(4))")
                        } else {
                            Text(streamData.releaseDate.prefix(4))
                        }
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding([.horizontal, .top])
                
                // Music Info
                VStack(alignment: .leading, spacing: 18) {
                    InfoRow(dataItems: [
                        // Use trackNumber.map() to safely convert Int? to String
                        (data: streamData.trackNumber.map(DataItem.intData) ?? DataItem.stringData(nil), title: "Track Number"),
                        (data: streamData.totalTracks.map(DataItem.intData) ?? DataItem.stringData(nil), title: "Total Tracks"),
                        (data: DataItem.stringData(streamData.releaseDate), title: "Release Date")
                    ])
                    
                    InfoRow(dataItems: [
                        (data: DataItem.stringData(streamData.popularity.description), title: "Popularity"),
                        (data: DataItem.stringData(streamData.duration), title: streamData.trackNumber != nil ? "Track Length" : "Album Length")
                    ])
                    
                    InfoRow(dataItems: [
                        (data: DataItem.intData(streamData.totalStreams), title: "Total Streams"),
                        (data: DataItem.intData(streamData.dailyStreams), title: "Daily Streams")
                    ])
                    
                    if let availableCountries = streamData.availableMarkets, let totalTrack = streamData.totalTracks {
                        InfoRow(dataItems: [
                            (data: DataItem.intData(streamData.totalStreams / totalTrack), title: "Avg Track Streams"),
                            (data: DataItem.intData(availableCountries), title: "Available Countries")
                        ])
                    }
                }
                .padding(.vertical, 20)
                
                // Artist Info
                VStack(alignment: .leading) {
                    Text(streamData.isCollaboration ? "Artists" : "Artist")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.leading)
                    
                    // Render ProgressView before collaborators are loaded
                    if isCollaboratorsLoading {
                        ProgressView()
                        // Fixed height matching ArtistItem's height
                            .frame(height: 118)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        if let collaborators = apiService.collaborators {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(collaborators.indices, id: \.self) { index in
                                        let collaborator = collaborators[index]
                                        
                                        ArtistItem(imageUrl: collaborator.image, name: collaborator.name, isTapped: binding(for: index))
                                    }
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            ArtistItem(imageUrl: artistInfo.image, name: artistInfo.name, isTapped: $isArtistNameTapped)
                                .padding(.horizontal)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)
            }
            .onAppear {
                if streamData.isCollaboration {
                    // If is collaboration and was just tapped, don't call API again
                    if streamData.musicId != lastViewedMusicId {
                        Task {
                            apiService.collaborators = nil
                            isCollaboratorsLoading = true
                            // If has albumName, it's a song
                            await apiService.getCollaborators(musicId: streamData.musicId, isSong: streamData.albumName != nil)
                            isCollaboratorsLoading = false
                        }
                    }
                } else {
                    apiService.collaborators = nil
                    // Set to nil for non-collaboration songs. Otherwise, tapping a new collaboration song after tapping a non-collaboration song will still trigger "Tapping the view again"
                    lastViewedMusicId = nil
                }
            }
            .onDisappear {
                if streamData.isCollaboration {
                    lastViewedMusicId = streamData.musicId
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    MusicDetailView(
        artistInfo: Artist(
            name: "Olivia Rodrigo",
            image: URL(string: "https://i.scdn.co/image/ab6761610000e5ebe03a98785f3658f0b6461ec4")!
        ),
        streamData:
            StreamData(
                rank: 1,
                musicName: "vampire",
                albumName: "GUTS",
                albumType: nil,
                totalTracks: nil,
                trackNumber: 3,
                duration: "3:39",
                releaseDate: "2023-09-08",
                imageUrl: URL(string: "https://i.scdn.co/image/ab67616d0000b273e85259a1cae29a8d91f2093d")!,
                totalStreams: 1033456751,
                dailyStreams: 1220289,
                popularity: 85,
                availableMarkets: nil,
                spotifyUrl: URL(string: "https://open.spotify.com/track/1kuGVB7EU95pJObxwvfwKS")!,
                musicId: "1kuGVB7EU95pJObxwvfwKS",
                isCollaboration: false
            ),
        lastViewedMusicId: .constant(nil)
    )
    .environmentObject(APIService())
}
