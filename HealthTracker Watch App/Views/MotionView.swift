import SwiftUI

struct MotionView: View {
    @StateObject private var viewModel = MotionViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Image(systemName: "gyroscope")
                    .font(.system(size: 28))
                    .foregroundStyle(viewModel.isTracking ? .cyan : .gray)
                    .rotationEffect(.degrees(viewModel.isTracking ? 360 : 0))
                    .animation(
                        viewModel.isTracking
                            ? .linear(duration: 2).repeatForever(autoreverses: false)
                            : .default,
                        value: viewModel.isTracking
                    )

                motionSection(
                    title: "Acceleration (g)",
                    values: [
                        ("X", viewModel.accelerationX, .red),
                        ("Y", viewModel.accelerationY, .green),
                        ("Z", viewModel.accelerationZ, .blue)
                    ]
                )

                motionSection(
                    title: "Rotation (rad/s)",
                    values: [
                        ("X", viewModel.rotationRateX, .red),
                        ("Y", viewModel.rotationRateY, .green),
                        ("Z", viewModel.rotationRateZ, .blue)
                    ]
                )

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button(viewModel.isTracking ? "Stop" : "Start") {
                    viewModel.isTracking
                        ? viewModel.stopTracking()
                        : viewModel.startTracking()
                }
                .tint(viewModel.isTracking ? .red : .green)
            }
        }
        .navigationTitle("Motion")
        .onDisappear {
            viewModel.stopTracking()
        }
    }

    private func motionSection(
        title: String,
        values: [(axis: String, value: Double, color: Color)]
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(values, id: \.axis) { item in
                MotionDataRow(
                    axis: item.axis,
                    value: item.value,
                    color: item.color
                )
            }
        }
    }
}

struct MotionDataRow: View {
    let axis: String
    let value: Double
    let color: Color

    private var barValue: Double {
        min(abs(value), 1)
    }

    var body: some View {
        HStack(spacing: 5) {
            Text(axis)
                .font(.caption2.bold())
                .foregroundStyle(color)
                .frame(width: 10)

            GeometryReader { geometry in
                let halfWidth = geometry.size.width / 2

                ZStack {
                    Rectangle()
                        .fill(.secondary.opacity(0.2))
                        .frame(width: 1)

                    Rectangle()
                        .fill(color)
                        .frame(width: halfWidth * barValue, height: 5)
                        .offset(x: value < 0 ? -(halfWidth * barValue / 2) : halfWidth * barValue / 2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 12)

            Text(value.formatted(.number.precision(.fractionLength(2))))
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 38, alignment: .trailing)
        }
    }
}

#Preview {
    NavigationStack {
        MotionView()
    }
}
