//
//  ContentView.swift
//  LoanCalculator
//
//  Created by Ivan Tishchenko on 17.12.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = Store()
    @State private var localAmount: Double = 5000
    @State private var localPeriod: Int = 14
    
    private let amountRange: ClosedRange<Double> = 5000...50000
    private let amountStep: Double = 1000
    private let periodOptions = [7, 14, 21, 28]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Amount Slider Section
                    AmountSliderSection(
                        title: "How much?",
                        amount: $localAmount,
                        range: amountRange,
                        step: amountStep,
                        color: .green,
                        onEnd: { store.dispatch(.setAmount(localAmount)) }
                    )
                    
                    // Period Slider Section
                    PeriodSliderSection(
                        title: "How long?",
                        selectedPeriod: $localPeriod,
                        options: periodOptions,
                        color: .orange,
                        onEnd: { store.dispatch(.setPeriod(localPeriod)) }
                    )
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    // Submit Button
                    SubmitButton(
                        isLoading: store.state.isLoading,
                        isEnabled: store.state.isValid && !store.state.isLoading
                    ) {
                        store.dispatch(.submitApplication)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationTitle("Loan Calculator")
            .navigationBarTitleDisplayMode(.large)
            .alert(item: Binding(
                get: { store.state.submissionResult.map { AlertItem(result: $0) } },
                set: { _ in store.dispatch(.dismissResult) }
            )) { item in
                item.alert
            }
            .onAppear {
                store.dispatch(.loadSavedState)
                // Sync local state with store state
                localAmount = store.state.amount
                localPeriod = store.state.periodDays
            }
            .onChange(of: store.state.amount) { newValue in
                localAmount = newValue
            }
            .onChange(of: store.state.periodDays) { newValue in
                localPeriod = newValue
            }
        }
    }
}

// MARK: - Result Row
struct ResultRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Submit Button
struct SubmitButton: View {
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "paperplane.fill")
                }
                Text(isLoading ? "Submitting..." : "Submit Application")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: isEnabled ? [Color.blue, Color.blue.opacity(0.8)] : [Color.gray, Color.gray.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: isEnabled ? Color.blue.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
        }
        .disabled(!isEnabled)
        .scaleEffect(isLoading ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

// MARK: - Alert Item
struct AlertItem: Identifiable {
    let id = UUID()
    let result: SubmissionResult
    
    var alert: Alert {
        switch result {
        case .success(let responseId):
            return Alert(
                title: Text("Success! 🎉"),
                message: Text("Your loan application has been submitted successfully.\n\nReference ID: #\(responseId)"),
                dismissButton: .default(Text("OK"))
            )
        case .failure(let message):
            return Alert(
                title: Text("Error"),
                message: Text(message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Shared Visual Building Blocks
struct DiagonalStripesShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stripeWidth: CGFloat = 8
        let stripeSpacing: CGFloat = 8
        
        let totalWidth = rect.width + rect.height
        var x: CGFloat = -rect.height
        
        while x < totalWidth {
            path.move(to: CGPoint(x: x, y: rect.maxY))
            path.addLine(to: CGPoint(x: x + rect.height, y: 0))
            x += stripeWidth + stripeSpacing
        }
        
        return path
    }
}

struct RoundedTrackShape: Shape {
    var thumbPosition: CGFloat
    var thumbSize: CGFloat
    
    var animatableData: CGFloat {
        get { thumbPosition }
        set { thumbPosition = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = rect.height / 2
        let thumbRadius = thumbSize / 2
        path.addRoundedRect(
            in: CGRect(x: 0, y: 0, width: thumbPosition + thumbRadius * 0.3, height: rect.height),
            cornerSize: CGSize(width: radius, height: radius)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Slider Appearance
struct SliderAppearance {
    let color: Color
    let trackHeight: CGFloat = 20
    let thumbSize: CGFloat = 52
    let unfilledColors: [Color] = [Color.gray.opacity(0.12), Color.gray.opacity(0.18)]
}

// MARK: - Slider Track Background
struct SliderTrackBackground: View {
    let appearance: SliderAppearance
    
    var body: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: appearance.unfilledColors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            DiagonalStripesShape()
                .stroke(Color.gray.opacity(0.15), lineWidth: 3)
                .clipShape(Capsule())
        }
        .frame(height: appearance.trackHeight)
        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Slider Filled Track
struct SliderFilledTrack: View {
    let thumbPosition: CGFloat
    let appearance: SliderAppearance
    
    var body: some View {
        ZStack {
            // Main gradient fill
            RoundedTrackShape(thumbPosition: thumbPosition, thumbSize: appearance.thumbSize)
                .fill(
                    LinearGradient(
                        colors: [
                            appearance.color.opacity(0.75),
                            appearance.color.opacity(0.9),
                            appearance.color,
                            appearance.color.opacity(0.95)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            // Top highlight for 3D effect
            RoundedTrackShape(thumbPosition: thumbPosition, thumbSize: appearance.thumbSize)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
            
            // Bottom shadow for depth
            RoundedTrackShape(thumbPosition: thumbPosition, thumbSize: appearance.thumbSize)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.black.opacity(0.15)
                        ],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
        }
        .frame(height: appearance.trackHeight)
        .shadow(color: appearance.color.opacity(0.4), radius: 3, x: 0, y: 2)
        .shadow(color: appearance.color.opacity(0.2), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Slider Thumb
struct SliderThumb: View {
    let color: Color
    let thumbSize: CGFloat
    let isDragging: Bool
    let thumbPosition: CGFloat
    
    var body: some View {
        ZStack {
            // Outer glow/shadow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.4), color.opacity(0.2), Color.clear],
                        center: .center,
                        startRadius: thumbSize / 2,
                        endRadius: thumbSize / 2 + 12
                    )
                )
                .frame(width: thumbSize + 24, height: thumbSize + 24)
                .blur(radius: isDragging ? 4 : 2)
                .opacity(isDragging ? 1 : 0.6)
            
            // Main sphere with vertical gradient
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            color.opacity(0.6),
                            color.opacity(0.8),
                            color,
                            color.opacity(0.95),
                            color.opacity(0.85)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: thumbSize, height: thumbSize)
                .overlay(
                    // Top highlight (bright spot)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                center: UnitPoint(x: 0.5, y: 0.25),
                                startRadius: 0,
                                endRadius: thumbSize / 3
                            )
                        )
                )
                .overlay(
                    // Inner ring/depression circle
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.35),
                                    Color.black.opacity(0.2),
                                    Color.black.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .frame(width: thumbSize * 0.7, height: thumbSize * 0.7)
                )
                .overlay(
                    // Inner shadow for depression
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.clear,
                                    Color.black.opacity(0.15),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: thumbSize * 0.25,
                                endRadius: thumbSize * 0.4
                            )
                        )
                        .frame(width: thumbSize * 0.7, height: thumbSize * 0.7)
                )
                .shadow(color: Color.black.opacity(0.3), radius: isDragging ? 8 : 4, x: 0, y: isDragging ? 4 : 2)
                .shadow(color: color.opacity(0.6), radius: isDragging ? 10 : 6, x: 0, y: 0)
                .scaleEffect(isDragging ? 1.1 : 1.0)
        }
        .offset(x: thumbPosition - thumbSize / 2 - 10, y: 0)
    }
}

// MARK: - Slider Base
struct SliderBase: View {
    let appearance: SliderAppearance
    let progress: CGFloat     // 0...1
    @Binding var isDragging: Bool
    
    let onDragChanged: (CGFloat) -> Void
    let onDragEnded: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let thumbX = max(appearance.thumbSize / 2,
                             min(width - appearance.thumbSize / 2,
                                 width * progress))
            
            ZStack(alignment: .leading) {
                SliderTrackBackground(appearance: appearance)
                
                SliderFilledTrack(
                    thumbPosition: thumbX,
                    appearance: appearance
                )
                
                SliderThumb(
                    color: appearance.color,
                    thumbSize: appearance.thumbSize,
                    isDragging: isDragging,
                    thumbPosition: thumbX
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            isDragging = true
                            let percent = min(max(0, gesture.location.x / width), 1)
                            onDragChanged(percent)
                        }
                        .onEnded { _ in
                            isDragging = false
                            onDragEnded()
                        }
                )
            }
        }
        .frame(height: appearance.thumbSize)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
    }
}

// MARK: - Amount Slider Section
struct AmountSliderSection: View {
    let title: String
    @Binding var amount: Double
    let range: ClosedRange<Double>
    let step: Double
    let color: Color
    let onEnd: () -> Void
    
    @State private var isDragging = false
    private let appearance: SliderAppearance
    
    init(title: String,
         amount: Binding<Double>,
         range: ClosedRange<Double>,
         step: Double,
         color: Color,
         onEnd: @escaping () -> Void) {
        self.title = title
        self._amount = amount
        self.range = range
        self.step = step
        self.color = color
        self.onEnd = onEnd
        self.appearance = SliderAppearance(color: color)
    }
    
    private var progressBinding: Binding<CGFloat> {
        Binding<CGFloat>(
            get: {
                CGFloat((amount - range.lowerBound) / (range.upperBound - range.lowerBound))
            },
            set: { newProgress in
                let clamped = min(max(0, newProgress), 1)
                let newValue = range.lowerBound + Double(clamped) * (range.upperBound - range.lowerBound)
                let stepped = round(newValue / step) * step
                amount = min(max(stepped, range.lowerBound), range.upperBound)
            }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Header(title: title, valueText: "₦\(amount.formatAsCurrency())")
            
            SliderBase(
                appearance: appearance,
                progress: progressBinding.wrappedValue,
                isDragging: $isDragging,
                onDragChanged: { progressBinding.wrappedValue = $0 },
                onDragEnded: onEnd
            )
            
            Labels(minText: range.lowerBound.formatAsCurrency(),
                   maxText: range.upperBound.formatAsCurrency())
        }
    }
}

// MARK: - Period Slider Section
struct PeriodSliderSection: View {
    let title: String
    @Binding var selectedPeriod: Int
    let options: [Int]
    let color: Color
    let onEnd: () -> Void
    
    @State private var isDragging = false
    private let appearance: SliderAppearance
    
    init(title: String,
         selectedPeriod: Binding<Int>,
         options: [Int],
         color: Color,
         onEnd: @escaping () -> Void) {
        self.title = title
        self._selectedPeriod = selectedPeriod
        self.options = options
        self.color = color
        self.onEnd = onEnd
        self.appearance = SliderAppearance(color: color)
    }
    
    private var progressBinding: Binding<CGFloat> {
        Binding<CGFloat>(
            get: {
                guard let index = options.firstIndex(of: selectedPeriod), options.count > 1 else { return 0 }
                return CGFloat(index) / CGFloat(options.count - 1)
            },
            set: { newProgress in
                guard options.count > 1 else { return }
                let clamped = min(max(0, newProgress), 1)
                let index = Int(round(clamped * CGFloat(options.count - 1)))
                selectedPeriod = options[index]
            }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Header(title: title, valueText: "\(selectedPeriod) days")
            
            SliderBase(
                appearance: appearance,
                progress: progressBinding.wrappedValue,
                isDragging: $isDragging,
                onDragChanged: { progressBinding.wrappedValue = $0 },
                onDragEnded: onEnd
            )
            
            Labels(minText: "7", maxText: "28")
        }
    }
}

// MARK: - Reusable Headers and Labels
struct Header: View {
    let title: String
    let valueText: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Spacer()
            Text(valueText)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }
}

struct Labels: View {
    let minText: String
    let maxText: String
    
    var body: some View {
        HStack {
            Text(minText)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(maxText)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
