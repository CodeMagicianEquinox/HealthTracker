import SwiftUI

struct MainDashboardView: View {
    @ObservedObject var healthviewModel: HealthViewModel
    
    let ringSize = 60
    
    
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
                            progress: healthviewModel.caloriesProgress,
                            icon: "flame.fill",
                            color: .orange,
                            size: 60
                        )
                    }
                        VStack (spacing: 6) {
                            ProgressRingView(
                                progress: healthviewModel.waterProgress,
                                icon: EntryType.water.icon,
                                color: EntryType.water.color,
                                size: 60
                        )
                    }
                }
            }
        }
    }
}
