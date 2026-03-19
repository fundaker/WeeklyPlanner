//
//  GoalsView.swift
//  WeeklyPlanner
//
//  Created by Funda Aker on 13.03.2026.
//

import SwiftUI

struct GoalsView: View {

        @State private var goals: [Goal] = GoalStorage.load()
        @State private var selectedType: GoalType = .longTerm
        @State private var showingAddGoal = false
        @State private var goalToDelete: Goal?
        @State private var showDeleteAlert = false
        @State private var goalToEdit: Goal?
    

    func deleteGoal(goal: Goal) {
        goals.removeAll { $0.id == goal.id }
    }
    
    var filteredGoals: [Goal] {
        goals.filter { $0.type == selectedType }
    }

    var body: some View {

        NavigationStack {

            VStack {

                Picker("Hedef Türü", selection: $selectedType) {
                    ForEach(GoalType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                List {

                    ForEach(filteredGoals) { goal in

                        VStack(alignment: .leading) {

                            Text(goal.title)
                                .font(.headline)

                            Text(goal.deadline.formatted(date: .long, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.gray)

                        }

                        .swipeActions {

                            Button(role: .destructive) {

                                goalToDelete = goal
                                showDeleteAlert = true

                            } label: {
                                Label("Sil", systemImage: "trash")
                            }
                            Button {
                                goalToEdit = goal
                            }
                        label: {
                                Label("Düzenle", systemImage: "pencil")
                            }
                            .tint(.blue)

                        }

                    }

                }
                .alert("Hedef Sil", isPresented: $showDeleteAlert) {

                    Button("Sil", role: .destructive) {
                        if let goal = goalToDelete {
                            deleteGoal(goal: goal)
                        }
                    }

                    Button("İptal", role: .cancel) {}

                } message: {

                    Text("Bu hedefi silmek istediğinize emin misiniz?")

                }

            }

            .navigationTitle("Hedefler")
            .toolbar {

                Button {

                    showingAddGoal = true

                } label: {

                    Image(systemName: "plus")

                }

            }

            .sheet(isPresented: $showingAddGoal) {

                AddGoalView { newGoal in
                    goals.append(newGoal)
                }

            }

            .sheet(item: $goalToEdit) { goal in

                EditGoalView(goal: goal) { updatedGoal in
                    
                    if let index = goals.firstIndex(where: { $0.id == updatedGoal.id }) {
                        goals[index] = updatedGoal
                    }
                    
                }

            }
            .onChange(of: goals) {
                GoalStorage.save(goals)
            }

        }

    }

}
