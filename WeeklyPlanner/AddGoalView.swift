//
//  AddGoalView.swift
//  WeeklyPlanner
//
//  Created by Funda Aker on 13.03.2026.
//
import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var deadline = Date()
    @State private var type: GoalType = .longTerm
   

    var addGoal: (Goal) -> Void

    var body: some View {

        NavigationStack {

            Form {

                TextField("Hedef", text: $title)

                Picker("Tür", selection: $type) {
                    ForEach(GoalType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }

                DatePicker("Hedef Tarihi", selection: $deadline, displayedComponents: .date)

            }

            .navigationTitle("Yeni Hedef")

            .toolbar {

                ToolbarItem(placement: .confirmationAction) {

                    Button("Kaydet") {

                        let newGoal = Goal(
                            title: title,
                            deadline: deadline,
                            type: type
                        )

                        addGoal(newGoal)

                        dismiss()

                    }

                }

            }

        }

    }

}
