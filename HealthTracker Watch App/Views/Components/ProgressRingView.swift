import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    let icon: String // "flame.fill or "drop.fill"
    let color: Color
    let size: CGFloat
    
    
    // MARK: - Constants
    private let lineWidth: CGFloat = 8
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 3), value: progress)
            
            Image(systemName: icon)
                .font(.system(size: size * 0.3))
                .foregroundColor(color)
        }
        .frame(width: size, height: size)
        
    }
}

#Preview {
    HStack(spacing: 16) {
        ProgressRingView(
            progress: 0.3, icon: "flame.fill", color: .orange, size: 60
        )
        ProgressRingView(
            progress: 0.6, icon: "drop.fill", color: .cyan, size: 60
        )
    }
}
