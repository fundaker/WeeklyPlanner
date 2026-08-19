import SwiftUI
import SwiftData

struct ContentView: View {

    var body: some View {

        TabView {

            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Ana Sayfa")
                }

            NavigationStack {
                TasksView()
            }
            .tabItem {
                Image(systemName: "checklist")
                Text("Görevler")
            }

            TodosView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Yapılacaklar")
                }

            GoalsView()
                .tabItem {
                    Label("Hedefler", systemImage: "target")
                }

            HabitsView()
                .tabItem {
                    Label("Alışkanlıklar", systemImage: "checkmark.seal")
                }

            ReportView()
                .tabItem {
                    Image(systemName: "chart.pie")
                    Text("Raporlar")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(Persistence.previewContainer)
}
