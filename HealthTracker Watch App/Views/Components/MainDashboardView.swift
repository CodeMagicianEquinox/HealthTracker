import SwiftUI

struct MainDashboardView: View {
    @ObservedObject var healthviewModel: HealthViewModel
    
    
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
                        // Progress Ring Calories
                    }
                        VStack (spacing: 6) {
                            // Progress Ring Water
                    }
                }
            }
        }
    }
}
