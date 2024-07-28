import SwiftUI

struct BillboardHistoryView: View {
    @EnvironmentObject var apiService: APIService
    @EnvironmentObject var displayManager: DisplayManager
    let bottomSafeArea: CGFloat
    
    @State private var artistName: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Search options
                    VStack {
                        TypePicker(
                            text: "Sort by",
                            selection: $displayManager.sortingHistoryType,
                            options: ["Release Date", "Peak Position", "Weeks on Chart"],
                            onChange: handleTypeChange
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 30)
                    .padding(.horizontal)
                    
                    SearchBar(isLoading: $displayManager.isHistoryLoading, artistName: $artistName, onSearch: getBillboardHistory)
                    // Equal bottom padding in this View
                        .padding(.bottom, 20)
                        .environmentObject(apiService)
                    
                    if displayManager.isHistoryLoading {
                        ProgressView()
                    } else {
                        if let billboardHistory = apiService.billboardHistory {
                            // Artist info
                            ArtistInfo(artistImageURL: billboardHistory.artistInfo.image, artistName: billboardHistory.artistInfo.name, totalCount: billboardHistory.historyData.count)
                            // Equal bottom padding in this View
                                .padding(.bottom, 20)
                            
                            VStack {
                                ForEach(displayManager.displayHistoryData) { historyData in
                                    RankInfo(historyData: historyData)
                                    // Equal bottom padding in this View
                                        .padding(.bottom, 20)
                                }
                            }
                            .padding(.bottom, bottomSafeArea + 20)
                        }
                    }
                }
            }
            .navigationBarTitle("Billboard History")
            .toolbar {
                // Center the SearchToolbar
                ToolbarItem(placement: .principal) {
                    SearchToolbar(
                        isSearchTextFieldShowing: $displayManager.isHistorySearchTextFieldShowing,
                        searchText: $displayManager.historySearchText,
                        isFocused: $isFocused,
                        isHistoryFilteringRanking: $displayManager.isHistoryFilteringRanking,
                        placeholderText: displayManager.isHistoryFilteringRanking ? "Enter rank" : "Enter song name",
                        handleTextChange: handleTextChange,
                        mainButtonIcon: "trophy",
                        filterButtonAction: filterButtonAction,
                        mainButtonAction: {
                            displayManager.isHistoryFilteringRanking.toggle()
                        }
                    )
                    
                    Spacer().frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    func getBillboardHistory() async {
        displayManager.displayHistoryData = await apiService.getBillboardHistory(artist: artistName, sortType: displayManager.sortingHistoryType)
    }
    
    // Pass to TypePicker's onChange
    func handleTypeChange(_ selection: String) {
        guard let historyData = apiService.billboardHistory?.historyData else { return }
        
        withAnimation(.linear) {
            if displayManager.isHistoryFiltering {
                apiService.billboardHistory?.historyData = apiService.sortHistoryData(historyData: historyData, sortType: selection)
                
                filterAndUpdateHistoryData(keySelectors: [
                    displayManager.isHistoryFilteringRanking ? { $0.peakPosition.description } : { $0.song }
                ])
            } else {
                // When is not filtering, sort the original data
                displayManager.displayHistoryData = apiService.sortHistoryData(historyData: historyData, sortType: selection)
                apiService.billboardHistory?.historyData = displayManager.displayHistoryData
            }
        }
    }
    
    // Pass to ToolBarTextField's onChange
    func handleTextChange(_ searchText: Binding<String>) {
        // Update UI when searchText changes
        filterAndUpdateHistoryData(keySelectors: [
            displayManager.isHistoryFilteringRanking ? { $0.peakPosition.description } : { $0.song }
        ])
        
        if searchText.wrappedValue.isEmpty {
            displayManager.displayHistoryData = apiService.billboardHistory?.historyData ?? []
            displayManager.isHistoryFiltering = false
        } else {
            displayManager.isHistoryFiltering = true
        }
    }
    
    func filterButtonAction() {
        // Use DispatchQueue.main.async to make sure display data reset to original after searchText is cleared
        DispatchQueue.main.async {
            withAnimation(.linear) {
                displayManager.isHistorySearchTextFieldShowing.toggle()
                displayManager.historySearchText = ""
                // When searchText is cleard from here, ToolBarTextField's onChange cannot be triggered
                // So need to handle it manually
                if displayManager.historySearchText.isEmpty {
                    displayManager.displayHistoryData = apiService.billboardHistory?.historyData ?? []
                    displayManager.isHistoryFiltering = false
                }
            }
        }
        // Pop up keyboard when TextField is shown
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isFocused = true
        }
    }
    
    func filterAndUpdateHistoryData(keySelectors: [(BillboardHistoryData) -> String?]) {
        displayManager.displayHistoryData = apiService.filterData(
            items: apiService.billboardHistory?.historyData ?? [],
            searchText: displayManager.historySearchText,
            exactMatch: displayManager.isHistoryFilteringRanking,
            keySelectors: keySelectors
        )
    }
}

#Preview {
    BillboardHistoryView(bottomSafeArea: 34)
        .environmentObject(APIService(
            billboardHistory: BillboardHistory(
                artistInfo: Artist(
                    name: "Taylor Swift",
                    image: URL(string: "https://i.scdn.co/image/ab67616100005174859e4c14fa59296c8649e0e4")!
                ),
                historyData: [
                    BillboardHistoryData(
                        song: "Is It Over Now? (Taylor's Version) [From The Vault]",
                        artist: "Taylor Swift",
                        firstChartedPosition: 1,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 47,
                        lastChartedDate: "2024-04-02",
                        lastWeekPosition: 31,
                        peakPosition: 1,
                        weeksOnChart: 22
                    ),
                    BillboardHistoryData(
                        song: "Now That We Don't Talk (Taylor's Version) [From The Vault]",
                        artist: "Taylor Swift",
                        firstChartedPosition: 2,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 87,
                        lastChartedDate: "2024-01-16",
                        lastWeekPosition: 87,
                        peakPosition: 2,
                        weeksOnChart: 8
                    ),
                    BillboardHistoryData(
                        song: "Slut! (Taylor's Version) [From The Vault]",
                        artist: "Taylor Swift",
                        firstChartedPosition: 3,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 98,
                        lastChartedDate: "2023-12-05",
                        lastWeekPosition: 76,
                        peakPosition: 3,
                        weeksOnChart: 5
                    ),
                    BillboardHistoryData(
                        song: "Say Don't Go (Taylor's Version) [From The Vault]",
                        artist: "Taylor Swift",
                        firstChartedPosition: 5,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 100,
                        lastChartedDate: "2023-12-05",
                        lastWeekPosition: 81,
                        peakPosition: 5,
                        weeksOnChart: 5
                    ),
                    BillboardHistoryData(
                        song: "Bad Blood (Taylor's Version)",
                        artist: "Taylor Swift",
                        firstChartedPosition: 7,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 80,
                        lastChartedDate: "2023-11-21",
                        lastWeekPosition: 47,
                        peakPosition: 7,
                        weeksOnChart: 3
                    ),
                    BillboardHistoryData(
                        song: "Style (Taylor's Version)",
                        artist: "Taylor Swift",
                        firstChartedPosition: 9,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 91,
                        lastChartedDate: "2023-11-28",
                        lastWeekPosition: 69,
                        peakPosition: 9,
                        weeksOnChart: 4
                    ),
                    BillboardHistoryData(
                        song: "Suburban Legends (Taylor's Version) [From The Vault]",
                        artist: "Taylor Swift",
                        firstChartedPosition: 10,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 92,
                        lastChartedDate: "2023-11-21",
                        lastWeekPosition: 50,
                        peakPosition: 10,
                        weeksOnChart: 3
                    ),
                    BillboardHistoryData(
                        song: "Blank Space (Taylor's Version)",
                        artist: "Taylor Swift",
                        firstChartedPosition: 12,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 93,
                        lastChartedDate: "2023-11-21",
                        lastWeekPosition: 59,
                        peakPosition: 12,
                        weeksOnChart: 3
                    ),
                    BillboardHistoryData(
                        song: "Welcome To New York (Taylor's Version)",
                        artist: "Taylor Swift",
                        firstChartedPosition: 14,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 77,
                        lastChartedDate: "2023-11-14",
                        lastWeekPosition: 14,
                        peakPosition: 14,
                        weeksOnChart: 2
                    ),
                    BillboardHistoryData(
                        song: "Out Of The Woods (Taylor's Version)",
                        artist: "Taylor Swift",
                        firstChartedPosition: 16,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 85,
                        lastChartedDate: "2023-11-21",
                        lastWeekPosition: 73,
                        peakPosition: 16,
                        weeksOnChart: 3
                    ),
                    BillboardHistoryData(
                        song: "All You Had To Do Was Stay (Taylor's Version)",
                        artist: "Taylor Swift",
                        firstChartedPosition: 20,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 89,
                        lastChartedDate: "2023-11-14",
                        lastWeekPosition: 20,
                        peakPosition: 20,
                        weeksOnChart: 2
                    ),
                    BillboardHistoryData(
                        song: "Shake It Off (Taylor's Version)",
                        artist: "Taylor Swift",
                        firstChartedPosition: 28,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 83,
                        lastChartedDate: "2023-11-14",
                        lastWeekPosition: 28,
                        peakPosition: 28,
                        weeksOnChart: 2
                    ),
                    BillboardHistoryData(
                        song: "New Romantics (Taylor's Version)",
                        artist: "Taylor Swift",
                        firstChartedPosition: 29,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 92,
                        lastChartedDate: "2023-11-14",
                        lastWeekPosition: 29,
                        peakPosition: 29,
                        weeksOnChart: 2
                    ),
                    BillboardHistoryData(
                        song: "Clean (Taylor's Version)",
                        artist: "Taylor Swift",
                        firstChartedPosition: 30,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 96,
                        lastChartedDate: "2023-11-14",
                        lastWeekPosition: 30,
                        peakPosition: 30,
                        weeksOnChart: 2
                    ),
                    BillboardHistoryData(
                        song: "I Wish You Would (Taylor's Version)",
                        artist: "Taylor Swift",
                        firstChartedPosition: 31,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 31,
                        lastChartedDate: "2023-11-07",
                        lastWeekPosition: nil,
                        peakPosition: 31,
                        weeksOnChart: 1
                    ),
                    BillboardHistoryData(
                        song: "I Know Places (Taylor's Version)",
                        artist: "Taylor Swift",
                        firstChartedPosition: 36,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 36,
                        lastChartedDate: "2023-11-07",
                        lastWeekPosition: nil,
                        peakPosition: 36,
                        weeksOnChart: 1
                    ),
                    BillboardHistoryData(
                        song: "Wonderland (Taylor's Version)",
                        artist: "Taylor Swift",
                        firstChartedPosition: 39,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 39,
                        lastChartedDate: "2023-11-07",
                        lastWeekPosition: nil,
                        peakPosition: 39,
                        weeksOnChart: 1
                    ),
                    BillboardHistoryData(
                        song: "How You Get The Girl (Taylor's Version)",
                        artist: "Taylor Swift",
                        firstChartedPosition: 40,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 40,
                        lastChartedDate: "2023-11-07",
                        lastWeekPosition: nil,
                        peakPosition: 40,
                        weeksOnChart: 1
                    ),
                    BillboardHistoryData(
                        song: "You Are In Love (Taylor's Version)",
                        artist: "Taylor Swift",
                        firstChartedPosition: 43,
                        firstChartedDate: "2023-11-07",
                        lastChartedPosition: 43,
                        lastChartedDate: "2023-11-07",
                        lastWeekPosition: nil,
                        peakPosition: 43,
                        weeksOnChart: 1
                    )
                ]
            )
        ))
        .environmentObject(DisplayManager(
            displayHistoryData: [
                BillboardHistoryData(
                    song: "Is It Over Now? (Taylor's Version) [From The Vault]",
                    artist: "Taylor Swift",
                    firstChartedPosition: 1,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 47,
                    lastChartedDate: "2024-04-02",
                    lastWeekPosition: 31,
                    peakPosition: 1,
                    weeksOnChart: 22
                ),
                BillboardHistoryData(
                    song: "Now That We Don't Talk (Taylor's Version) [From The Vault]",
                    artist: "Taylor Swift",
                    firstChartedPosition: 2,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 87,
                    lastChartedDate: "2024-01-16",
                    lastWeekPosition: 87,
                    peakPosition: 2,
                    weeksOnChart: 8
                ),
                BillboardHistoryData(
                    song: "Slut! (Taylor's Version) [From The Vault]",
                    artist: "Taylor Swift",
                    firstChartedPosition: 3,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 98,
                    lastChartedDate: "2023-12-05",
                    lastWeekPosition: 76,
                    peakPosition: 3,
                    weeksOnChart: 5
                ),
                BillboardHistoryData(
                    song: "Say Don't Go (Taylor's Version) [From The Vault]",
                    artist: "Taylor Swift",
                    firstChartedPosition: 5,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 100,
                    lastChartedDate: "2023-12-05",
                    lastWeekPosition: 81,
                    peakPosition: 5,
                    weeksOnChart: 5
                ),
                BillboardHistoryData(
                    song: "Bad Blood (Taylor's Version)",
                    artist: "Taylor Swift",
                    firstChartedPosition: 7,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 80,
                    lastChartedDate: "2023-11-21",
                    lastWeekPosition: 47,
                    peakPosition: 7,
                    weeksOnChart: 3
                ),
                BillboardHistoryData(
                    song: "Style (Taylor's Version)",
                    artist: "Taylor Swift",
                    firstChartedPosition: 9,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 91,
                    lastChartedDate: "2023-11-28",
                    lastWeekPosition: 69,
                    peakPosition: 9,
                    weeksOnChart: 4
                ),
                BillboardHistoryData(
                    song: "Suburban Legends (Taylor's Version) [From The Vault]",
                    artist: "Taylor Swift",
                    firstChartedPosition: 10,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 92,
                    lastChartedDate: "2023-11-21",
                    lastWeekPosition: 50,
                    peakPosition: 10,
                    weeksOnChart: 3
                ),
                BillboardHistoryData(
                    song: "Blank Space (Taylor's Version)",
                    artist: "Taylor Swift",
                    firstChartedPosition: 12,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 93,
                    lastChartedDate: "2023-11-21",
                    lastWeekPosition: 59,
                    peakPosition: 12,
                    weeksOnChart: 3
                ),
                BillboardHistoryData(
                    song: "Welcome To New York (Taylor's Version)",
                    artist: "Taylor Swift",
                    firstChartedPosition: 14,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 77,
                    lastChartedDate: "2023-11-14",
                    lastWeekPosition: 14,
                    peakPosition: 14,
                    weeksOnChart: 2
                ),
                BillboardHistoryData(
                    song: "Out Of The Woods (Taylor's Version)",
                    artist: "Taylor Swift",
                    firstChartedPosition: 16,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 85,
                    lastChartedDate: "2023-11-21",
                    lastWeekPosition: 73,
                    peakPosition: 16,
                    weeksOnChart: 3
                ),
                BillboardHistoryData(
                    song: "All You Had To Do Was Stay (Taylor's Version)",
                    artist: "Taylor Swift",
                    firstChartedPosition: 20,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 89,
                    lastChartedDate: "2023-11-14",
                    lastWeekPosition: 20,
                    peakPosition: 20,
                    weeksOnChart: 2
                ),
                BillboardHistoryData(
                    song: "Shake It Off (Taylor's Version)",
                    artist: "Taylor Swift",
                    firstChartedPosition: 28,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 83,
                    lastChartedDate: "2023-11-14",
                    lastWeekPosition: 28,
                    peakPosition: 28,
                    weeksOnChart: 2
                ),
                BillboardHistoryData(
                    song: "New Romantics (Taylor's Version)",
                    artist: "Taylor Swift",
                    firstChartedPosition: 29,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 92,
                    lastChartedDate: "2023-11-14",
                    lastWeekPosition: 29,
                    peakPosition: 29,
                    weeksOnChart: 2
                ),
                BillboardHistoryData(
                    song: "Clean (Taylor's Version)",
                    artist: "Taylor Swift",
                    firstChartedPosition: 30,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 96,
                    lastChartedDate: "2023-11-14",
                    lastWeekPosition: 30,
                    peakPosition: 30,
                    weeksOnChart: 2
                ),
                BillboardHistoryData(
                    song: "I Wish You Would (Taylor's Version)",
                    artist: "Taylor Swift",
                    firstChartedPosition: 31,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 31,
                    lastChartedDate: "2023-11-07",
                    lastWeekPosition: nil,
                    peakPosition: 31,
                    weeksOnChart: 1
                ),
                BillboardHistoryData(
                    song: "I Know Places (Taylor's Version)",
                    artist: "Taylor Swift",
                    firstChartedPosition: 36,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 36,
                    lastChartedDate: "2023-11-07",
                    lastWeekPosition: nil,
                    peakPosition: 36,
                    weeksOnChart: 1
                ),
                BillboardHistoryData(
                    song: "Wonderland (Taylor's Version)",
                    artist: "Taylor Swift",
                    firstChartedPosition: 39,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 39,
                    lastChartedDate: "2023-11-07",
                    lastWeekPosition: nil,
                    peakPosition: 39,
                    weeksOnChart: 1
                ),
                BillboardHistoryData(
                    song: "How You Get The Girl (Taylor's Version)",
                    artist: "Taylor Swift",
                    firstChartedPosition: 40,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 40,
                    lastChartedDate: "2023-11-07",
                    lastWeekPosition: nil,
                    peakPosition: 40,
                    weeksOnChart: 1
                ),
                BillboardHistoryData(
                    song: "You Are In Love (Taylor's Version)",
                    artist: "Taylor Swift",
                    firstChartedPosition: 43,
                    firstChartedDate: "2023-11-07",
                    lastChartedPosition: 43,
                    lastChartedDate: "2023-11-07",
                    lastWeekPosition: nil,
                    peakPosition: 43,
                    weeksOnChart: 1
                )
            ]
        ))
}
