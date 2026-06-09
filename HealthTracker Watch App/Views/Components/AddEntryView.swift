import SwiftUI
import WatchKit

struct AddEntryView: View {
    @ObservedObject var healthViewModel: HealthViewModel
    let entryType: EntryType

    @State private var selectedAmount: Double = 100.0
    @Environment(\.dismiss) private var dismiss

    let presets: [Double] = [200, 300, 500]
    let stepsForFineAdjust: Double = 10.0
    let crownSensitivity: Double = 1.0

    var body: some View {
        ScrollView {
            VStack(spacing: 4) {
                Image(systemName: entryType.icon)
                    .font(.system(size: 24))
                    .foregroundColor(entryType.color)

                Text("Add \(entryType.rawValue)")
                    .font(.system(size: 12, weight: .medium))

                Text("\(Int(selectedAmount))")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(entryType.color)

                HStack(spacing: 8) {
                    ForEach(presets, id: \.self) { preset in
                        Button {
                            WKInterfaceDevice.current().play(.click)
                            selectedAmount = preset
                        } label: {
                            Text("+\(Int(preset))")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(selectedAmount == preset ? entryType.color : Color.gray.opacity(0.3))
                                .foregroundColor(selectedAmount == preset ? .black : .white)
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                HStack {
                    Button {
                        WKInterfaceDevice.current().play(.click)
                        selectedAmount = max(0, selectedAmount - stepsForFineAdjust)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()
                    Text("Adjust")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Spacer()

                    Button {
                        WKInterfaceDevice.current().play(.click)
                        selectedAmount += stepsForFineAdjust
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 8)

                Button {
                    if entryType == .calories {
                        healthViewModel.addCalories(selectedAmount)
                    } else {
                        healthViewModel.addWater(selectedAmount)
                    }
                    healthViewModel.refreshDailyTotals()
                    dismiss()
                } label: {
                    Text("Add")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedAmount > 0 ? entryType.color : Color.gray.opacity(0.3))
                        .foregroundColor(selectedAmount > 0 ? .black : .white)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(selectedAmount == 0)
            }
        }
        .focusable()
        .digitalCrownRotation(
            $selectedAmount,
            from: 0,
            through: 10000,
            by: crownSensitivity,
            sensitivity: .low,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
    }
}

#Preview {
    NavigationStack {
        AddEntryView(healthViewModel: HealthViewModel(), entryType: .calories)
    }
}
