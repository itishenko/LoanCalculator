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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Amount Slider Section
                    SliderSection(
                        title: "How much?",
                        value: $localAmount,
                        range: 5000...50000,
                        step: 1000,
                        displayValue: "₦\(localAmount.formatAsCurrency())",
                        color: .green,
                        onChangeEnd: { amount in
                            store.dispatch(.setAmount(amount))
                        }
                    )
                    
                    // Period Slider Section
                    PeriodSliderSection(
                        selectedPeriod: $localPeriod,
                        onChangeEnd: { period in
                            store.dispatch(.setPeriod(period))
                        }
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

// MARK: - Diagonal Stripes Pattern
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

// MARK: - Rounded Track Shape (обтекающий трек)
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
        
        // Если бегунок близко к концу, создаем вырез
//        if thumbPosition > rect.width - thumbRadius {
//            // Левая закругленная часть
//            path.addArc(center: CGPoint(x: radius, y: rect.midY),
//                       radius: radius,
//                       startAngle: .degrees(90),
//                       endAngle: .degrees(270),
//                       clockwise: false)
//            
//            // Верхняя линия до бегунка
//            path.addLine(to: CGPoint(x: thumbPosition - thumbRadius * 0.7, y: 0))
//            
//            // Плавное обтекание вокруг бегунка (верхняя часть)
//            path.addQuadCurve(to: CGPoint(x: thumbPosition, y: rect.midY - thumbRadius * 0.5),
//                            control: CGPoint(x: thumbPosition - thumbRadius * 0.3, y: rect.midY - thumbRadius * 0.7))
//            
//            // Плавное обтекание вокруг бегунка (нижняя часть)
//            path.addQuadCurve(to: CGPoint(x: thumbPosition - thumbRadius * 0.7, y: rect.height),
//                            control: CGPoint(x: thumbPosition - thumbRadius * 0.3, y: rect.midY + thumbRadius * 0.7))
//            
//            // Нижняя линия обратно
//            path.addLine(to: CGPoint(x: radius, y: rect.height))
//        } else {
            // Стандартная капсула
            path.addRoundedRect(in: CGRect(x: 0, y: 15, width: thumbPosition + thumbRadius * 0.3, height: rect.height),
                              cornerSize: CGSize(width: radius, height: radius))
//        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Slider Section
struct SliderSection: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let displayValue: String
    let color: Color
    let onChangeEnd: (Double) -> Void
    
    @State private var isDragging = false
    
    private let trackHeight: CGFloat = 20
    private let thumbSize: CGFloat = 52
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Spacer()
                Text(displayValue)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            ZStack(alignment: .leading) {
                // Track background with diagonal stripes
                ZStack {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.12), Color.gray.opacity(0.18)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    DiagonalStripesShape()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 3)
                        .clipShape(Capsule())
                }
                .frame(height: trackHeight)
                .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                
                // Filled track with flowing effect
                GeometryReader { geometry in
                    let thumbPosition = geometry.size.width * CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
                    
                    ZStack {
                        // Main gradient fill
                        RoundedTrackShape(thumbPosition: thumbPosition, thumbSize: thumbSize)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        color.opacity(0.75),
                                        color.opacity(0.9),
                                        color,
                                        color.opacity(0.95)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        // Top highlight for 3D effect
                        RoundedTrackShape(thumbPosition: thumbPosition, thumbSize: thumbSize)
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
                        RoundedTrackShape(thumbPosition: thumbPosition, thumbSize: thumbSize)
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
                    .frame(height: trackHeight)
                    .shadow(color: color.opacity(0.4), radius: 3, x: 0, y: 2)
                    .shadow(color: color.opacity(0.2), radius: 6, x: 0, y: 3)
                }
                
                // Thumb
                GeometryReader { geometry in
                    let thumbPosition = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width
                    
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
                    .offset(x: thumbPosition - thumbSize / 2, y: -8)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                isDragging = true
                                let percent = min(max(0, gesture.location.x / geometry.size.width), 1)
                                let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(percent)
                                let steppedValue = round(newValue / step) * step
                                value = min(max(steppedValue, range.lowerBound), range.upperBound)
                            }
                            .onEnded { _ in
                                isDragging = false
                                onChangeEnd(value)
                            }
                    )
                }
                .frame(height: thumbSize)
            }
            .frame(height: thumbSize)
            
            // Min/Max labels
            HStack {
                Text(range.lowerBound.formatAsCurrency())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(range.upperBound.formatAsCurrency())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
    }
}

// MARK: - Period Slider Section
struct PeriodSliderSection: View {
    @Binding var selectedPeriod: Int
    let onChangeEnd: (Int) -> Void
    
    let periods = [7, 14, 21, 28]
    @State private var isDragging = false
    
    private let trackHeight: CGFloat = 20
    private let thumbSize: CGFloat = 52
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("How long?")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(selectedPeriod) days")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            ZStack(alignment: .leading) {
                // Track background with diagonal stripes
                ZStack {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.12), Color.gray.opacity(0.18)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    DiagonalStripesShape()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 3)
                        .clipShape(Capsule())
                }
                .frame(height: trackHeight)
                .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                
                // Filled track with flowing effect
                GeometryReader { geometry in
                    let index = periods.firstIndex(of: selectedPeriod) ?? 1
                    let thumbPosition = geometry.size.width * CGFloat(index) / CGFloat(periods.count - 1)
                    
                    ZStack {
                        // Main gradient fill
                        RoundedTrackShape(thumbPosition: thumbPosition, thumbSize: thumbSize)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0.75),
                                        Color.orange.opacity(0.9),
                                        Color.orange,
                                        Color.orange.opacity(0.95)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        // Top highlight for 3D effect
                        RoundedTrackShape(thumbPosition: thumbPosition, thumbSize: thumbSize)
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
                        RoundedTrackShape(thumbPosition: thumbPosition, thumbSize: thumbSize)
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
                    .frame(height: trackHeight)
                    .shadow(color: Color.orange.opacity(0.4), radius: 3, x: 0, y: 2)
                    .shadow(color: Color.orange.opacity(0.2), radius: 6, x: 0, y: 3)
                }
                
                // Thumb
                GeometryReader { geometry in
                    let index = periods.firstIndex(of: selectedPeriod) ?? 1
                    let thumbPosition = geometry.size.width * CGFloat(index) / CGFloat(periods.count - 1)
                    
                    ZStack {
                        // Outer glow/shadow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.orange.opacity(0.4), Color.orange.opacity(0.2), Color.clear],
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
                                        Color.orange.opacity(0.6),
                                        Color.orange.opacity(0.8),
                                        Color.orange,
                                        Color.orange.opacity(0.95),
                                        Color.orange.opacity(0.85)
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
                            .shadow(color: Color.orange.opacity(0.6), radius: isDragging ? 10 : 6, x: 0, y: 0)
                            .scaleEffect(isDragging ? 1.1 : 1.0)
                    }
                    .offset(x: thumbPosition - thumbSize / 2, y: -8)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                isDragging = true
                                let percent = min(max(0, gesture.location.x / geometry.size.width), 1)
                                let index = Int(round(percent * Double(periods.count - 1)))
                                selectedPeriod = periods[index]
                            }
                            .onEnded { _ in
                                isDragging = false
                                onChangeEnd(selectedPeriod)
                            }
                    )
                }
                .frame(height: thumbSize)
            }
            .frame(height: thumbSize)
            
            // Period labels
            HStack {
                ForEach(periods, id: \.self) { period in
                    Text("\(period)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
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
