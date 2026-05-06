import NotchSparkCore
import AVFoundation
import SwiftUI

struct FactBubbleView: View {
    let fact: FunFact
    let contrastStyle: BubbleContrastStyle
    let reactionCameraSession: AVCaptureSession?

    private let bubbleRadius: CGFloat = 22
    private let iconSize: CGFloat = 32
    private let reactionCameraSize: CGFloat = 42

    @State private var contentOpacity = 0.0
    @State private var contentScale: CGFloat = 0.94
    @State private var contentOffset: CGFloat = 7
    @State private var shimmerOffset: CGFloat = -220
    @State private var sparkOffset: CGFloat = -40
    @State private var sparkOpacity = 0.0
    @State private var notchLipWidth: CGFloat = 108
    @State private var notchLipOpacity = 0.82
    @State private var glowPulse = false
    @State private var iconLift: CGFloat = 5

    var body: some View {
        ZStack {
            bubbleBackground

            content
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .opacity(contentOpacity)
                .scaleEffect(contentScale, anchor: .top)
                .offset(y: contentOffset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(bubbleShape)
        .overlay(border)
        .overlay(shimmer)
        .overlay(notchLip, alignment: .top)
        .overlay(sparkGlide)
        .compositingGroup()
        .shadow(color: shadowColor, radius: glowPulse ? 24 : 13, y: 10)
        .shadow(color: Color.black.opacity(contrastStyle == .paper ? 0.18 : 0.34), radius: 16, y: 10)
        .onAppear(perform: animateIn)
    }

    private var content: some View {
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

            if let reactionCameraSession {
                reactionCamera(session: reactionCameraSession)
            }
        }
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
        .frame(width: iconSize, height: iconSize)
    }

    private func reactionCamera(session: AVCaptureSession) -> some View {
        ReactionCameraPreview(session: session)
            .frame(width: reactionCameraSize, height: reactionCameraSize)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(cameraBorderColor, lineWidth: 1.2)
            )
            .shadow(color: cameraShadowColor, radius: 10, y: 3)
            .accessibilityLabel("Reaction camera preview")
    }

    private var bubbleBackground: some View {
        ZStack {
            bubbleShape
                .fill(.regularMaterial)

            bubbleShape
                .fill(surfaceGradient)
        }
    }

    private var bubbleShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: bubbleRadius, style: .continuous)
    }

    private var border: some View {
        bubbleShape
            .strokeBorder(borderGradient, lineWidth: 1)
            .overlay(
                bubbleShape
                    .inset(by: 1.5)
                    .strokeBorder(innerBorderColor, lineWidth: 0.6)
            )
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
        .clipShape(bubbleShape)
        .allowsHitTesting(false)
    }

    private var sparkGlide: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                Capsule(style: .continuous)
                    .fill(accentColor.opacity(isPaper ? 0.42 : 0.72))
                    .frame(width: 46, height: 2)
                    .blur(radius: 0.6)
                    .offset(x: sparkOffset, y: 1)

                Circle()
                    .fill(accentColor)
                    .frame(width: 5, height: 5)
                    .shadow(color: accentColor.opacity(0.85), radius: 7)
                    .offset(x: sparkOffset + 44, y: -0.5)
            }
            .opacity(sparkOpacity)
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
        .clipShape(bubbleShape)
        .allowsHitTesting(false)
    }

    private var notchLip: some View {
        Capsule(style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        accentColor.opacity(isPaper ? 0.42 : 0.76),
                        Color.white.opacity(isPaper ? 0.36 : 0.28)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: notchLipWidth, height: 3)
            .blur(radius: 0.35)
            .opacity(notchLipOpacity)
            .offset(y: -0.5)
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

    private var cameraBorderColor: Color {
        isPaper ? Color.black.opacity(0.2) : Color.white.opacity(0.26)
    }

    private var cameraShadowColor: Color {
        isPaper ? Color.black.opacity(0.18) : Color.black.opacity(0.32)
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

    private var innerBorderColor: Color {
        isPaper ? Color.white.opacity(0.52) : Color.white.opacity(0.1)
    }

    private var shadowColor: Color {
        isPaper ? Color.black.opacity(0.22) : accentColor.opacity(0.24)
    }

    private var shimmerColor: Color {
        isPaper ? Color.black.opacity(0.08) : Color.white.opacity(0.2)
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.56, dampingFraction: 0.9, blendDuration: 0.12).delay(0.1)) {
            contentOpacity = 1
            contentScale = 1
            contentOffset = 0
            iconLift = 0
            glowPulse = true
        }

        withAnimation(.easeOut(duration: 0.62).delay(0.2)) {
            notchLipWidth = 26
            notchLipOpacity = 0
        }

        withAnimation(.easeInOut(duration: 0.64).delay(0.18)) {
            iconLift = -1
        }

        withAnimation(.easeInOut(duration: 0.62).delay(0.78)) {
            iconLift = 0
        }

        withAnimation(.easeOut(duration: 0.9).delay(0.2)) {
            shimmerOffset = 520
        }

        withAnimation(.easeIn(duration: 0.16).delay(0.24)) {
            sparkOpacity = 1
        }

        withAnimation(.timingCurve(0.2, 0.82, 0.18, 1, duration: 1.05).delay(0.24)) {
            sparkOffset = 430
        }

        withAnimation(.easeOut(duration: 0.32).delay(1.05)) {
            sparkOpacity = 0
        }

        withAnimation(.easeOut(duration: 1.4).delay(0.7)) {
            glowPulse = false
        }
    }
}
