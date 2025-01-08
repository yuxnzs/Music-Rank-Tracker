import Foundation
import Alamofire

class APIService: ObservableObject {
    @Published var dailyStreams: DailyStreams? = nil
    @Published var billboardHistory: BillboardHistory? = nil
    @Published var billboardDataByDate: [BillboardDate]? = nil
    
    @Published var collaborators: [Artist]? = nil
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String? = nil
    
    // Since original data not include release date to sort, need to save a copy of original release date sorted data
    var originalBillboardHistoryData: [BillboardHistoryData] = []
    
    let baseURL: String = Config.baseURL
    
    // For preview to insert dummy data
    init(dailyStreams: DailyStreams? = nil, billboardHistory: BillboardHistory? = nil, billboardDataByDate: [BillboardDate]? = nil) {
        self.dailyStreams = dailyStreams
        self.billboardHistory = billboardHistory
        self.billboardDataByDate = billboardDataByDate
    }
    
    private func fetchData<T: Decodable>(path: String, params: String) async throws -> T {
        let url = URL(string: "\(baseURL)/\(path)\(params)")!
        
        return try await AF.request(url).serializingDecodable(T.self).value
    }
    
    @MainActor
    func getDailyStreams(artist: String, musicType: String, streamType: String) async -> [StreamData] {
        do {
            // Specify the type to let the compiler know what type to pass to the fetchData function
            let dailyStreams: DailyStreams = try await fetchData(path: "daily-streams/", params: "\(artist)/\(musicType.lowercased())")
            
            let sortedData = sortStreams(streamData: dailyStreams.streamData, streamType: streamType, shouldReassignRanks: true)
            
            // Update dailyStreams with API data and sorted data
            self.dailyStreams = DailyStreams(artistInfo: dailyStreams.artistInfo, date: dailyStreams.date, streamData: sortedData)
            
            return sortedData
        } catch {
            print("Error fetching daily streams: \(error)")
            DispatchQueue.main.async {
                self.alertMessage = "No stream data available for \(artist)"
                self.showAlert = true
            }
            return []
        }
    }
    
    // streamData as Optional to avoid TypePicker call the function before dailyStreams is set
    func sortStreams(streamData: [StreamData], streamType: String, shouldReassignRanks: Bool) -> [StreamData] {
        var sortedStreamData = streamData
        
        switch streamType {
        case "Daily":
            sortedStreamData.sort {
                $0.dailyStreams > $1.dailyStreams
            }
        case "Total":
            sortedStreamData.sort {
                $0.totalStreams > $1.totalStreams
            }
        default:
            break
        }
        
        // When is not filtering or fetching new data, reassign ranks based on the new order
        // Make sure when user is filtering, the rank is not reassigned, maintaining the original rank order
        if shouldReassignRanks {
            for (index, var data) in sortedStreamData.enumerated() {
                data.rank = index + 1
                sortedStreamData[index] = data
            }
        }
        
        return sortedStreamData
    }
    
    func filterData<T>(items: [T], searchText: String, exactMatch: Bool = false, keySelectors: [(T) -> String?]) -> [T] {
        guard !searchText.isEmpty else { return [] }
        let lowercasedSearchText = searchText.lowercased()
        
        return items.filter { item in
            // Apply each key selector and check if any of the keys contain the search text
            keySelectors.contains { keySelector in
                // keySelector(item)?.lowercased() invokes the keySelector function which extracts a specific string field (like musicName or albumName) from the item, converts it to lowercase, and returns it
                if let key = keySelector(item)?.lowercased() {
                    // If isHistoryFilteringRanking from BillboardHistoryView is true, only match exact rank
                    if exactMatch {
                        return key == lowercasedSearchText
                    } else {
                        return key.contains(lowercasedSearchText)
                    }
                }
                return false
            }
        }
    }
    
    @MainActor
    func getCollaborators(musicId: String, isSong: Bool) async {
        do {
            let params = "isSong=\(isSong)&musicId=\(musicId)"
            
            let collaborators: [Artist] = try await fetchData(path: "collaborators?", params: params)
            
            self.collaborators = collaborators
        } catch {
            print("Error fetching collaborators: \(error)")
        }
    }
    
    @MainActor
    func getBillboardHistory(artist: String, sortType: String) async -> [BillboardHistoryData] {
        do {
            let billboardHistory: BillboardHistory = try await fetchData(path: "billboard-history/", params: artist)
            
            // Set originalBillboardHistoryData first, so that sortHistoryData won't return empty data
            self.originalBillboardHistoryData = billboardHistory.historyData
            
            let sortedData = sortHistoryData(historyData: billboardHistory.historyData, sortType: sortType)
            
            self.billboardHistory = BillboardHistory(artistInfo: billboardHistory.artistInfo, historyData: sortedData)
            
            return sortedData
        } catch {
            print("Error fetching billboard history: \(error)")
            DispatchQueue.main.async {
                self.alertMessage = "No billboard history available for \(artist)"
                self.showAlert = true
            }
            return []
        }
    }
    
    func sortHistoryData(historyData: [BillboardHistoryData], sortType: String) -> [BillboardHistoryData] {
        var sortedHistoryData = historyData
        
        switch sortType {
        case "Release Date":
            sortedHistoryData = originalBillboardHistoryData // Return original data sorted by release date
        case "Peak Position":
            sortedHistoryData.sort {
                $0.peakPosition < $1.peakPosition
            }
        case "Weeks on Chart":
            sortedHistoryData.sort {
                $0.weeksOnChart > $1.weeksOnChart
            }
        default:
            break
        }
        
        return sortedHistoryData
    }
    
    @MainActor
    func getBillboardDataByDate(date: String) async {
        do {
            let billboardDataByDate: [BillboardDate] = try await fetchData(path: "billboard-date/", params: date)
            
            self.billboardDataByDate = billboardDataByDate
        } catch {
            print("Error fetching billboard data by date: \(error)")
        }
    }
}
