import SwiftUI

struct QuoteOverlayView: View {
    let quote: MotivationalQuote?
    let isLoading: Bool
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let quote = quote {
                    Image(systemName: "quote.opening")
                        .font(.title3)
                        .foregroundColor(.yellow)

                    Text(quote.quote)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)

                    Text("-- \(quote.author)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                }

                Text("Tap To Dismiss")
                    .font(.system(size: 9))
                    .foregroundColor(.gray.opacity(0.7))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onDismiss)
    }
}
