import Foundation
import Alamofire

class APIService: ObservableObject {
    @Published var dailyStreams: DailyStreams? = nil
    @Published var billboardHistory: BillboardHistory? = nil
    @Published var billboardDataByDate: [BillboardDate]? = nil
    
    @Published var collaborators: [Artist]? = nil
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String? = nil
    
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
    
    func getDailyStreams(artist: String, musicType: String, streamType: String) async -> [StreamData] {
        do {
            // Specify the type to let the compiler know what type to pass to the fetchData function
            let dailyStreams: DailyStreams = try await fetchData(path: "daily-streams/", params: "\(artist)/\(musicType)")
            
            let sortedData = sortStreams(streamData: dailyStreams.streamData, streamType: streamType)
            
            // Update dailyStreams with API data and sorted data
            DispatchQueue.main.async {
                self.dailyStreams = DailyStreams(artistInfo: dailyStreams.artistInfo, date: dailyStreams.date, streamData: sortedData)
            }
            
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
    func sortStreams(streamData: [StreamData], streamType: String) -> [StreamData] {
        var sortedStreamData = streamData
        
        switch streamType {
        case "daily":
            sortedStreamData.sort {
                $0.dailyStreams > $1.dailyStreams
            }
        case "total":
            sortedStreamData.sort {
                $0.totalStreams > $1.totalStreams
            }
        default:
            break
        }
        
        return sortedStreamData
    }
    
    func filterData<T>(items: [T], searchText: String, keySelectors: [(T) -> String?]) -> [T] {
        guard !searchText.isEmpty else { return [] }
        let lowercasedSearchText = searchText.lowercased()
        
        return items.filter { item in
            // Apply each key selector and check if any of the keys contain the search text
            keySelectors.contains { keySelector in
                // keySelector(item)?.lowercased() invokes the keySelector function which extracts a specific string field (like musicName or albumName) from the item, converts it to lowercase, and returns it
                if let key = keySelector(item)?.lowercased(), key.contains(lowercasedSearchText) {
                    return true
                }
                return false
            }
        }
    }
    
    func getCollaborators(musicId: String, isSong: Bool) async {
        do {
            let params = "isSong=\(isSong)&musicId=\(musicId)"
            
            let collaborators: [Artist] = try await fetchData(path: "collaborators?", params: params)
            
            DispatchQueue.main.async {
                self.collaborators = collaborators
            }
        } catch {
            print("Error fetching collaborators: \(error)")
        }
    }
    
    func getBillboardHistory(artist: String, song: String?) async {
        do {
            let billboardHistory: BillboardHistory = try await fetchData(path: "billboard-history/", params: artist)
            
            DispatchQueue.main.async {
                if let song = song {
                    // Get specific song from Billboard history
                    let filteredSongs = billboardHistory.historyData.filter {
                        $0.song.lowercased() == song.lowercased()
                    }
                    self.billboardHistory = BillboardHistory(artistInfo: billboardHistory.artistInfo, historyData: filteredSongs)
                } else {
                    self.billboardHistory = billboardHistory
                }
            }
        } catch {
            print("Error fetching billboard history: \(error)")
        }
    }
    
    func getBillboardDataByDate(date: String) async {
        do {
            let billboardDataByDate: [BillboardDate] = try await fetchData(path: "billboard-date/", params: date)
            
            DispatchQueue.main.async {
                self.billboardDataByDate = billboardDataByDate
            }
        } catch {
            print("Error fetching billboard data by date: \(error)")
        }
    }
}
