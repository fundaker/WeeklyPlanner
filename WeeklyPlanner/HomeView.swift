import SwiftUI
import SwiftData

struct HomeView: View {

    @Query(sort: \WeeklyTask.createdAt) private var tasks: [WeeklyTask]

    var today: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }

    var todayTasks: [WeeklyTask] {
        tasks.filter { $0.day == today }
    }

    var completedTasks: Int {
        tasks.filter { $0.completedHours == $0.totalHours }.count
    }

    var totalTasks: Int {
        tasks.count
    }

    var progress: Double {
        if totalTasks == 0 { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }

    var body: some View {

        NavigationStack {

            VStack(spacing: 30) {

                VStack(alignment: .leading, spacing: 10) {

                    Text("Bugün")
                        .font(.title2)
                        .bold()

                    if todayTasks.isEmpty {

                        Text("Bugün görev yok")
                            .foregroundColor(.gray)

                    } else {

                        ForEach(todayTasks) { task in

                            VStack(alignment: .leading, spacing: 8) {

                                Text(task.title)
                                    .font(.headline)

                                HStack {

                                    ForEach(0..<task.totalHours, id: \.self) { index in

                                        VStack {

                                            Text("\(index + 1)")
                                                .font(.caption)
                                                .foregroundColor(.gray)

                                            Image(systemName: index < task.completedHours ? "checkmark.circle.fill" : "circle")
                                                .font(.title3)
                                                .foregroundColor(index < task.completedHours ? .green : .gray)

                                        }

                                    }

                                }

                            }

                        }

                    }

                }
                .padding()

                VStack(alignment: .leading) {

                    Text("Haftalık İlerleme")
                        .font(.headline)

                    ProgressView(value: progress)

                    Text("\(completedTasks) / \(totalTasks) görev tamamlandı")
                        .font(.caption)
                        .foregroundColor(.gray)

                }
                .padding()

                Spacer()

            }
            .navigationTitle("Ana Sayfa")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ReportView()
                    } label: {
                        Image(systemName: "chart.pie")
                    }
                    .accessibilityLabel("Raporlar")
                }
            }

        }

    }

}
