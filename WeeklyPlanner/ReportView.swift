
import SwiftUI
import Charts

struct ReportView: View {

    var tasks: [Task]

    @State private var selectedReportType: ReportType = .weekly
    @State private var selectedWeekOffset = 0
    @State private var selectedMonthOffset = 0

    // 📅 HAFTA ARALIĞI
    func weekRange(offset: Int) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()

        let currentWeek = calendar.dateInterval(of: .weekOfYear, for: now)!

        let start = calendar.date(byAdding: .weekOfYear, value: offset, to: currentWeek.start)!
        let end = calendar.date(byAdding: .day, value: 6, to: start)!

        return (start, end)
    }
    func monthRange(offset: Int) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()

        let currentMonth = calendar.dateInterval(of: .month, for: now)!

        let start = calendar.date(byAdding: .month, value: offset, to: currentMonth.start)!
        let end = calendar.date(byAdding: .day, value: -1,
                                to: calendar.date(byAdding: .month, value: 1, to: start)!)!

        return (start, end)
    }

    // 📊 HAFTALIK VERİ
    var weeklyReportData: [String: Int] {

        let range = weekRange(offset: selectedWeekOffset)

        var result: [String: Int] = [:]

        for task in tasks {

            let filteredDates = task.completionDates.filter {
                $0 >= range.start && $0 <= range.end
            }

            let hours = filteredDates.count

            if hours > 0 {
                result[task.title, default: 0] += hours
            }
        }

        return result
    }
    var monthlyReportData: [String: Int] {

        let range = monthRange(offset: selectedMonthOffset)

        var result: [String: Int] = [:]

        for task in tasks {

            let filteredDates = task.completionDates.filter {
                $0 >= range.start && $0 <= range.end
            }

            let hours = filteredDates.count

            if hours > 0 {
                result[task.title, default: 0] += hours
            }
        }

        return result
    }
    func monthTitle() -> String {

        let range = monthRange(offset: selectedMonthOffset)

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        return formatter.string(from: range.start)
    }

    // 🗓 HAFTA BAŞLIĞI
    func weekTitle() -> String {
        let range = weekRange(offset: selectedWeekOffset)

        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"

        return "\(formatter.string(from: range.start)) - \(formatter.string(from: range.end))"
    }

    var body: some View {

        NavigationStack {

            VStack {

                // 🔥 SEGMENTED BAR
                Picker("Rapor Türü", selection: $selectedReportType) {
                    ForEach(ReportType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // 📅 HAFTA SEÇİCİ
                if selectedReportType == .weekly {
                    HStack {

                        Button("◀︎") {
                            selectedWeekOffset -= 1
                        }

                        Spacer()

                        Text(weekTitle())
                            .font(.headline)

                        Spacer()

                        Button("▶︎") {
                            selectedWeekOffset += 1
                        }

                    }
                    .padding(.horizontal)
                }
                
                else {
                    HStack {

                        Button("◀︎") {
                            selectedMonthOffset -= 1
                        }

                        Spacer()

                        Text(monthTitle())
                            .font(.headline)

                        Spacer()

                        Button("▶︎") {
                            selectedMonthOffset += 1
                        }

                    }
                    .padding(.horizontal)
                }
                // 📊 CHART
                if selectedReportType == .weekly {

                    Chart {

                        ForEach(weeklyReportData.keys.sorted(), id: \.self) { key in

                            if let value = weeklyReportData[key] {

                                SectorMark(
                                    angle: .value("Saat", value)
                                )
                                .foregroundStyle(by: .value("Görev", key))

                            }

                        }

                    }
                    .frame(height: 300)

                }
                else {

                    Chart {

                        ForEach(monthlyReportData.keys.sorted(), id: \.self) { key in

                            if let value = monthlyReportData[key] {

                                BarMark(
                                    x: .value("Görev", key),
                                    y: .value("Saat", value)
                                )
                                .foregroundStyle(by: .value("Görev", key))

                            }

                        }

                    }
                    .frame(height: 300)

                }
                List {

                    let sortedData = selectedReportType == .weekly
                        ? weeklyReportData.sorted { $0.value > $1.value }
                        : monthlyReportData.sorted { $0.value > $1.value }

                    ForEach(Array(sortedData.enumerated()), id: \.element.key) { index, item in

                        HStack {

                            if index == 0 {
                                Text("🥇")
                            }

                            Text(item.key)

                            Spacer()

                            Text("\(item.value) saat")
                                .foregroundColor(.gray)

                        }

                    }

                }
           

            }
            .navigationTitle("Raporlar")

        }

    }

}

// ✅ ENUM
enum ReportType: String, CaseIterable {
    case weekly = "Haftalık"
    case monthly = "Aylık"
}
