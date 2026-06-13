import SwiftUI

struct MainDashboardView: View {
    @ObservedObject var healthViewModel: HealthViewModel

    let ringSize = 60.0


    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // MARK: - Header
                Text("Today")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.gray)

                // MARK: - Progress Rings Row
                HStack(spacing: 16) {
                    VStack (spacing: 6) {
                        ProgressRingView(
                            progress: healthViewModel.caloriesProgress,
                            icon: EntryType.calories.icon,
                            color: EntryType.calories.color,
                            size: ringSize
                        )

                        Text("\(Int(healthViewModel.todaysCalories))")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(EntryType.calories.color)

                        Text("/ \(Int(healthViewModel.goals.dailyCaloriesGoal))")
                            .font(.system(size: 9, design: .rounded))
                            .foregroundColor(.gray)
                    }

                    VStack (spacing: 6) {
                        ProgressRingView(
                            progress: healthViewModel.waterProgress,
                            icon: EntryType.water.icon,
                            color: EntryType.water.color,
                            size: ringSize
                        )

                        Text("\(Int(healthViewModel.todaysWater))")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(EntryType.water.color)

                        Text("/ \(Int(healthViewModel.goals.dailyWaterGoal))")
                            .font(.system(size: 9, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }

                HStack(spacing: 12) {
                    NavigationLink(destination: AddEntryView(healthViewModel: healthViewModel, entryType: .calories)) {
                        QuickAddButton(
                            icon: EntryType.calories.icon,
                            label: "Calories",
                            color: EntryType.calories.color
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    NavigationLink(destination: AddEntryView(healthViewModel: healthViewModel, entryType: .water)) {
                        QuickAddButton(
                            icon: EntryType.water.icon,
                            label: "Water",
                            color: EntryType.water.color
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                NavigationLink(destination: GoalsSettingsView(viewModel: healthViewModel)) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 12))
                        Text("Goals")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 4)

                NavigationLink(destination: MotionView()) {
                    HStack {
                        Image(systemName: "gyroscope")
                            .font(.system(size: 12))
                        Text("Motion")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.cyan)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity)
        }
        .overlay {
            if healthViewModel.showQuoteOverlay {
                QuoteOverlayView(
                    quote: healthViewModel.currentQuote,
                    isLoading: healthViewModel.isLoadingQuote
                ) {
                    healthViewModel.showQuoteOverlay = false
                }
            }
        }
    }
}
