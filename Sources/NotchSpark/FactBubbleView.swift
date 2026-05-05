import NotchSparkCore
import SwiftUI

struct FactBubbleView: View {
    let fact: FunFact
    let contrastStyle: BubbleContrastStyle

    @State private var isVisible = false
    @State private var shimmerOffset: CGFloat = -220
    @State private var iconLift: CGFloat = 5

    var body: some View {
        HStack(spacing: 11) {
            icon

            Text(fact.text)
                .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                .foregroundStyle(primaryText)
                .lineLimit(2)
                .lineSpacing(0)
                .minimumScaleFactor(0.88)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(bubbleBackground)
        .overlay(shimmer)
        .scaleEffect(isVisible ? 1 : 0.82, anchor: .top)
        .offset(y: isVisible ? 0 : -10)
        .opacity(isVisible ? 1 : 0)
        .onAppear(perform: animateIn)
    }

    private var icon: some View {
        ZStack {
            Circle()
                .fill(iconFill)
                .overlay(
                    Circle()
                        .strokeBorder(iconBorder, lineWidth: 1)
                )

            Image(systemName: fact.symbolName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(iconText)
                .shadow(color: iconShadow, radius: 7, y: 2)
                .offset(y: iconLift)
        }
        .frame(width: 32, height: 32)
    }

    private var bubbleBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.regularMaterial)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(surfaceGradient)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(borderGradient, lineWidth: 1)
        }
        .shadow(color: shadowColor, radius: 18, y: 10)
        .shadow(color: Color.black.opacity(contrastStyle == .paper ? 0.18 : 0.34), radius: 16, y: 10)
    }

    private var shimmer: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            shimmerColor,
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 76, height: proxy.size.height * 1.8)
                .rotationEffect(.degrees(18))
                .offset(x: shimmerOffset, y: -proxy.size.height * 0.35)
                .blendMode(contrastStyle == .paper ? .softLight : .plusLighter)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .allowsHitTesting(false)
    }

    private var accentColor: Color {
        let palette: [Color] = [
            Color(red: 0.36, green: 0.75, blue: 1.0),
            Color(red: 0.56, green: 0.92, blue: 0.62),
            Color(red: 1.0, green: 0.66, blue: 0.36),
            Color(red: 0.98, green: 0.48, blue: 0.78),
            Color(red: 0.74, green: 0.62, blue: 1.0),
            Color(red: 1.0, green: 0.86, blue: 0.34)
        ]

        return palette[abs(fact.paletteIndex) % palette.count]
    }

    private var isPaper: Bool {
        contrastStyle == .paper
    }

    private var primaryText: Color {
        isPaper
            ? Color(red: 0.055, green: 0.06, blue: 0.07).opacity(0.96)
            : Color.white.opacity(0.98)
    }

    private var iconFill: Color {
        isPaper
            ? accentColor.opacity(0.18)
            : accentColor.opacity(0.24)
    }

    private var iconBorder: Color {
        isPaper
            ? Color.black.opacity(0.18)
            : Color.white.opacity(0.24)
    }

    private var iconText: Color {
        isPaper
            ? Color(red: 0.055, green: 0.06, blue: 0.07).opacity(0.9)
            : Color.white.opacity(0.98)
    }

    private var iconShadow: Color {
        isPaper ? Color.white.opacity(0.35) : accentColor.opacity(0.58)
    }

    private var surfaceGradient: LinearGradient {
        if isPaper {
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.94),
                    Color(red: 0.94, green: 0.96, blue: 0.98).opacity(0.88),
                    accentColor.opacity(0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        return LinearGradient(
            colors: [
                Color(red: 0.02, green: 0.025, blue: 0.032).opacity(0.92),
                Color(red: 0.06, green: 0.065, blue: 0.08).opacity(0.9),
                accentColor.opacity(0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: isPaper
                ? [
                    Color.white.opacity(0.86),
                    Color.black.opacity(0.15),
                    accentColor.opacity(0.22)
                ]
                : [
                    Color.white.opacity(0.32),
                    accentColor.opacity(0.24),
                    Color.white.opacity(0.09)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var shadowColor: Color {
        isPaper ? Color.black.opacity(0.22) : accentColor.opacity(0.24)
    }

    private var shimmerColor: Color {
        isPaper ? Color.black.opacity(0.08) : Color.white.opacity(0.2)
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
            isVisible = true
            iconLift = 0
        }

        withAnimation(.easeInOut(duration: 0.52).delay(0.12)) {
            iconLift = -1
        }

        withAnimation(.easeInOut(duration: 0.52).delay(0.64)) {
            iconLift = 0
        }

        withAnimation(.linear(duration: 1.1).delay(0.16)) {
            shimmerOffset = 520
        }
    }
}
