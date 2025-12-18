import SwiftUI

struct BillboardDateView: View {
    @EnvironmentObject var apiService: APIService
    @EnvironmentObject var displayManager: DisplayManager
    @State private var selectedDate: Date = {
        let today = Date()
        return DateHelper.nearestSaturday(from: today)
    }()
    @State private var scrollPosition: ScrollPosition = .init()
    @State private var showToolbarTitle = false
    @State var currentDate = ""
    
    let bottomSafeArea: CGFloat
    let calendar = Calendar.current
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .onChange(of: selectedDate) { _, newDate in
                            selectedDate = startOfSaturday(for: newDate)
                        }
                        .datePickerStyle(.compact)
                    
                    Button {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let formattedDate = formatter.string(from: selectedDate)
                        currentDate = formattedDate
                        
                        displayManager.isBillboardDateLoading = true
                        Task {
                            displayManager.displayDateData = await apiService.getBillboardDataByDate(date: formattedDate)
                            
                            displayManager.isBillboardDateLoading = false
                        }
                    } label: {
                        Text("Search")
                            .padding(.horizontal, 20)
                            .frame(height: 35)
                            .background(.black)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                if displayManager.isBillboardDateLoading {
                    LoadingBillboardHistoryView(bottomSafeArea: bottomSafeArea, isDateView: true)
                } else {
                    if let _ = apiService.billboardDataByDate {
                        VStack {
                            ForEach(Array(displayManager.displayDateData.enumerated()), id: \.element.id) { index, historyData in
                                let rank = index + 1
                                
                                HStack(spacing: 0) {
                                    // Rank
                                    Text("\(rank)")
                                        .frame(width: rank < 100 ? 25 : 37, alignment: .center)
                                        .font(.system(size: 18, weight: .bold))
                                        .padding(.horizontal)
                                    
                                    RankInfo(historyData: historyData, isDateView: true)
                                        .padding(.trailing)
                                }
                                // Equal bottom padding in this View
                                .padding(.bottom, 20)
                            }
                        }
                        .padding(.bottom, bottomSafeArea + 20)
                    }
                }
            }
            .navigationTitle("Billboard Date")
            .scrollPosition($scrollPosition)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y // Listen to vertical scroll offset
            } action: { _, newY in
                withAnimation(.easeInOut(duration: 0.25)) {
                    // Show title when scrolled down
                    showToolbarTitle = newY > -45
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        if showToolbarTitle {
                            Text(currentDate)
                                .frame(width: 150, height: 30)
                                .font(.headline)
                                .transition(
                                    .move(edge: .top)
                                    .combined(with: .opacity)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    func startOfSaturday(for date: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let offset = weekday == 1 ? 6 : (7 - weekday)  // 星期日是 1，要 +6 到週六
        return calendar.date(byAdding: .day, value: offset, to: date)!
    }
}

struct DateHelper {
    static func nearestSaturday(from date: Date) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        // weekday: 1 = 星期日, 2 = 星期一, ..., 7 = 星期六
        if weekday == 7 || weekday == 1 {
            // 今天是星期六或日 → 回到本週六
            let offset = weekday == 7 ? 0 : -1 // 星期日往前一天
            return calendar.date(byAdding: .day, value: offset, to: date)!
        } else {
            // 星期一到五 → 選上週六
            let offset = -(weekday) // 回到上週六
            return calendar.date(byAdding: .day, value: offset, to: date)!
        }
    }
}

#Preview {
    BillboardDateView(bottomSafeArea: 34)
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
                        peakChartedDate: "2024-04-02",
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
                        peakChartedDate: "2024-01-16",
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
                        peakChartedDate: "2024-01-16",
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
                        peakChartedDate: "2024-01-16",
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
                        peakChartedDate: "2024-01-16",
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
                        peakChartedDate: "2024-01-16",
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
                        peakChartedDate: "2024-01-16",
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
                        peakChartedDate: "2024-01-16",
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
                        peakChartedDate: "2024-01-16",
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
                        peakChartedDate: "2024-01-16",
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
                        peakChartedDate: "2023-11-07",
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
                        peakChartedDate: "2023-11-07",
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
                        peakChartedDate: "2023-11-07",
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
                        peakChartedDate: "2023-11-07",
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
                        peakChartedDate: "2023-11-07",
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
                        peakChartedDate: "2023-11-07",
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
                        peakChartedDate: "2023-11-07",
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
                        peakChartedDate: "2023-11-07",
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
                        peakChartedDate: "2023-11-07",
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
                    peakChartedDate: "2024-04-02",
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
                    peakChartedDate: "2024-01-16",
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
                    peakChartedDate: "2024-01-16",
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
                    peakChartedDate: "2024-01-16",
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
                    peakChartedDate: "2023-11-21",
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
                    peakChartedDate: "2023-11-28",
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
                    peakChartedDate: "2023-11-21",
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
                    peakChartedDate: "2023-11-21",
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
                    peakChartedDate: "2023-11-14",
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
                    peakChartedDate: "2023-11-21",
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
                    peakChartedDate: "2023-11-07",
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
                    peakChartedDate: "2023-11-07",
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
                    peakChartedDate: "2023-11-07",
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
                    peakChartedDate: "2023-11-07",
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
                    peakChartedDate: "2023-11-07",
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
                    peakChartedDate: "2023-11-07",
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
                    peakChartedDate: "2023-11-07",
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
                    peakChartedDate: "2023-11-07",
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
                    peakChartedDate: "2023-11-07",
                    weeksOnChart: 1
                )
            ]
        ))
}
