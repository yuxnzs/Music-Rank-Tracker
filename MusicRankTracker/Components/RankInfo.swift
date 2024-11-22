import SwiftUI
import SDWebImageSwiftUI

struct RankInfo: View {
    let historyData: BillboardHistoryData
    let isPlaceholder: Bool
    
    init(historyData: BillboardHistoryData, isPlaceholder: Bool = false) {
        self.historyData = historyData
        self.isPlaceholder = isPlaceholder
    }
    
    init(isPlaceholder: Bool) {
        self.historyData = BillboardHistoryData(
            song: "Placeholder",
            artist: "Placeholder",
            firstChartedPosition: 0,
            firstChartedDate: "Placeholder",
            lastChartedPosition: 0,
            lastChartedDate: "Placeholder",
            lastWeekPosition: nil,
            peakPosition: 0,
            weeksOnChart: 0
        )
        self.isPlaceholder = isPlaceholder
    }
    
    var body: some View {
        DisclosureGroup {
            Spacer().padding(.top, 8)
            
            ChartDetail(label: "Song Title", value: "\(historyData.song)")
            ChartDetail(label: "Peak Position", value: "\(historyData.peakPosition)")
            ChartDetail(label: "First Position", value: "\(historyData.firstChartedPosition)")
            ChartDetail(label: "Last Position", value: "\(historyData.lastChartedPosition)")
            ChartDetail(label: "First Date", value: "\(historyData.firstChartedDate)")
            ChartDetail(label: "Last Date", value: "\(historyData.lastChartedDate)")
            ChartDetail(label: "Months on Chart", value: String(format: "%.1f", Double(historyData.weeksOnChart) / 4.3), isLast: true)
        } label : {
            rankInfoLabel(isPlaceholder: isPlaceholder)
        }
        .disabled(isPlaceholder)
        .tint(.black)
        .padding(.horizontal)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
    
    private func rankInfoLabel(isPlaceholder: Bool) -> some View {
        VStack {
            if isPlaceholder {
                VStack(alignment: .leading, spacing: 6) {
                    LoadingPlaceholder()
                        .frame(width: 200, height: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                    LoadingPlaceholder()
                        .frame(width: 250, height: 17)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .padding(.vertical, 10)
            } else {
                HStack(spacing: 0) {
                    // Song title and ranking info
                    VStack(alignment: .leading, spacing: 5) {
                        Text(historyData.song)
                            .font(.system(size: 18, weight: .bold))
                        
                        Text("Peak Position: \(historyData.peakPosition) • Weeks on Chart: \(historyData.weeksOnChart)")
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .frame(height: 57) // Same visual height as StreamInfo
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ChartDetail: View {
    let label: String
    let value: String
    let isLast: Bool
    
    // Only the last one need to pass-in isLast
    init(label: String, value: String, isLast: Bool = false) {
        self.label = label
        self.value = value
        self.isLast = isLast
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Group {
                    Image(systemName: "info.circle")
                    Text(label)
                }
                .font(.system(size: 16))
                .fontWeight(.bold)
                .foregroundStyle(Color.themeColor)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
        
        // Last one doesn't need Divider, use Spacer instead
        if !isLast {
            Divider().padding(.bottom, 8)
        } else {
            Spacer().padding(.bottom, 8)
        }
    }
}

#Preview {
    RankInfo(
        historyData: BillboardHistoryData(
            song: "We Are Never Ever Getting Back Together (Taylor's Version)",
            artist: "Taylor Swift",
            firstChartedPosition: 55,
            firstChartedDate: "2021-11-23",
            lastChartedPosition: 55,
            lastChartedDate: "2021-11-23",
            lastWeekPosition: nil,
            peakPosition: 55,
            weeksOnChart: 1
        )
    )
}
