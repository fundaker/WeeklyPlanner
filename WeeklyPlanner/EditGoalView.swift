import SwiftUI

struct EditGoalView: View {

    @Environment(\.dismiss) var dismiss

    @State var title: String
    @State var deadline: Date
    @State var type: GoalType

    var goalID: UUID
    var updateGoal: (Goal) -> Void

    init(goal: Goal, updateGoal: @escaping (Goal) -> Void) {
        _title = State(initialValue: goal.title)
        _deadline = State(initialValue: goal.deadline)
        _type = State(initialValue: goal.type)
        goalID = goal.id
        self.updateGoal = updateGoal
    }

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

            .navigationTitle("Hedef Düzenle")

            .toolbar {

                ToolbarItem(placement: .confirmationAction) {

                    Button("Kaydet") {

                        let updatedGoal = Goal(
                            id: goalID,
                            title: title,
                            deadline: deadline,
                            type: type
                        )
                        updateGoal(updatedGoal)
                        dismiss()

                    }

                }

            }

        }

    }

}
