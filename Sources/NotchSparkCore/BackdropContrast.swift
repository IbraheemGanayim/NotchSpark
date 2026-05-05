import Foundation

public enum BubbleContrastStyle: String, Equatable, Sendable {
    case ink
    case paper
}

public enum BackdropContrast {
    public static let fallbackStyle: BubbleContrastStyle = .ink

    public static func style(forAverageLuminance luminance: Double?) -> BubbleContrastStyle {
        guard let luminance, luminance.isFinite else {
            return fallbackStyle
        }

        return clamp(luminance) < 0.43 ? .paper : .ink
    }

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}
