//
//  AddTaskView.swift
//  WeeklyPlanner
//
//  Created by Funda Aker on 10.03.2026.
//

import SwiftUI

struct AddTaskView: View {

    @State private var title = ""
    @State private var selectedDay = "Pazartesi"
    @State private var hours = 1
    let days = ["Pazartesi","Salı","Çarşamba","Perşembe","Cuma","Cumartesi","Pazar"]

    var onAdd: (Task) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {

                Section("Görev") {
                    TextField("Görev adı", text: $title)
                }

                Section("Gün") {
                    Picker("Gün seç", selection: $selectedDay) {
                        ForEach(days, id: \.self) { day in
                            Text(day)
                        }
                    }
                }
                Stepper("Saat: \(hours)", value: $hours, in: 1...8)

            }
            .navigationTitle("Yeni Görev")

            .toolbar {

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let newTask = Task(
                            title: title,
                            day: selectedDay,
                            totalHours: hours
                        )

                        onAdd(newTask)
                        dismiss()
                    }
                }

            }
        }
    }
}
