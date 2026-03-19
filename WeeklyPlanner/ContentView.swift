import SwiftUI

struct ContentView: View {
    
    @State private var tasks: [Task] = TaskStorage.load()
    
    var body: some View {
        
        TabView {
            
            HomeView(tasks: tasks)
                .tabItem {
                    Image(systemName: "house")
                    Text("Ana Sayfa")
                }

            TasksView(tasks: $tasks)
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

            ReportView(tasks: tasks)
                .tabItem {
                    Image(systemName: "chart.pie")
                    Text("Raporlar")
                }
        }
        .onChange(of: tasks) {
            TaskStorage.save(tasks)
        }
      
    }
}

#Preview {
    ContentView()
}
