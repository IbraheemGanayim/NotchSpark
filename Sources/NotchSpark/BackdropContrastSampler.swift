import AppKit
import CoreGraphics
import NotchSparkCore

enum BackdropContrastSampler {
    static func style(behind frame: CGRect) -> BubbleContrastStyle {
        guard CGPreflightScreenCaptureAccess() else {
            return BackdropContrast.fallbackStyle
        }

        guard
            let screen = NSScreen.screens.first(where: { $0.frame.intersects(frame) }),
            let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
        else {
            return BackdropContrast.fallbackStyle
        }

        let sampleFrame = frame.intersection(screen.frame).insetBy(dx: 12, dy: 8)
        guard sampleFrame.width > 2, sampleFrame.height > 2 else {
            return BackdropContrast.fallbackStyle
        }

        let captureRect = displayLocalCaptureRect(for: sampleFrame, on: screen, displayID: displayID)
        guard let image = CGDisplayCreateImage(displayID, rect: captureRect) else {
            return BackdropContrast.fallbackStyle
        }

        return BackdropContrast.style(forAverageLuminance: averageLuminance(of: image))
    }

    private static func displayLocalCaptureRect(
        for frame: CGRect,
        on screen: NSScreen,
        displayID: CGDirectDisplayID
    ) -> CGRect {
        let scaleX = CGFloat(CGDisplayPixelsWide(displayID)) / max(screen.frame.width, 1)
        let scaleY = CGFloat(CGDisplayPixelsHigh(displayID)) / max(screen.frame.height, 1)

        return CGRect(
            x: (frame.minX - screen.frame.minX) * scaleX,
            y: (screen.frame.maxY - frame.maxY) * scaleY,
            width: frame.width * scaleX,
            height: frame.height * scaleY
        ).integral
    }

    private static func averageLuminance(of image: CGImage) -> Double? {
        var pixel = [UInt8](repeating: 0, count: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
            | CGBitmapInfo.byteOrder32Big.rawValue

        return pixel.withUnsafeMutableBytes { bytes -> Double? in
            guard let context = CGContext(
                data: bytes.baseAddress,
                width: 1,
                height: 1,
                bitsPerComponent: 8,
                bytesPerRow: 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo
            ) else {
                return nil
            }

            context.interpolationQuality = .medium
            context.draw(image, in: CGRect(x: 0, y: 0, width: 1, height: 1))

            let red = Double(bytes[0]) / 255
            let green = Double(bytes[1]) / 255
            let blue = Double(bytes[2]) / 255
            return (0.2126 * red) + (0.7152 * green) + (0.0722 * blue)
        }
    }
}
