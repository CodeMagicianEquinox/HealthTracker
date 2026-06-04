import SwiftUI

struct AddEntryView: View {
    @ObservedObject var healthViewModel: HealthViewModel
    let entryType: EntryType
    
    @State private var selectedAmount: Double = 100.0
    @Environment(\.dismiss) private var dismiss
    
    let presets: [Double] = [200, 300, 500]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: entryType.icon)
                    .font(.system(size:24))
                    .foregroundColor(entryType.color)
                
                Text("Add \(entryType.rawValue)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(entryType.color)
                
                HStack(spacing: 8) {
                    ForEach(presets, id: \.self) { amount in
                        Button("\(Int(amount))") {
                            selectedAmount = amount
                        }
                    }
                }
            }
        }
    }
}
