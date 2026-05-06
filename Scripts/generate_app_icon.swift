import AppKit

let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconsetURL = rootURL
    .appendingPathComponent("Packaging")
    .appendingPathComponent("NotchSpark.iconset")

try? FileManager.default.removeItem(at: iconsetURL)
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

let sizes: [(name: String, points: CGFloat, scale: CGFloat)] = [
    ("icon_16x16.png", 16, 1),
    ("icon_16x16@2x.png", 16, 2),
    ("icon_32x32.png", 32, 1),
    ("icon_32x32@2x.png", 32, 2),
    ("icon_128x128.png", 128, 1),
    ("icon_128x128@2x.png", 128, 2),
    ("icon_256x256.png", 256, 1),
    ("icon_256x256@2x.png", 256, 2),
    ("icon_512x512.png", 512, 1),
    ("icon_512x512@2x.png", 512, 2)
]

func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size),
        pixelsHigh: Int(size),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    bitmap.size = image.size

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    defer {
        NSGraphicsContext.restoreGraphicsState()
        image.addRepresentation(bitmap)
    }

    NSGraphicsContext.current?.imageInterpolation = .high

    let bounds = NSRect(x: 0, y: 0, width: size, height: size)
    NSColor.clear.setFill()
    bounds.fill()

    let backgroundRect = bounds.insetBy(dx: size * 0.08, dy: size * 0.08)
    let background = NSBezierPath(
        roundedRect: backgroundRect,
        xRadius: size * 0.22,
        yRadius: size * 0.22
    )

    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.04, green: 0.52, blue: 1.0, alpha: 1.0),
        NSColor(calibratedRed: 0.75, green: 0.35, blue: 0.95, alpha: 1.0),
        NSColor(calibratedRed: 0.18, green: 0.82, blue: 0.35, alpha: 1.0)
    ])
    gradient?.draw(in: background, angle: -35)

    NSColor(calibratedWhite: 1.0, alpha: 0.28).setStroke()
    background.lineWidth = max(1, size * 0.012)
    background.stroke()

    func sparkle(center: CGPoint, outer: CGFloat, inner: CGFloat, color: NSColor) {
        let path = NSBezierPath()
        path.move(to: CGPoint(x: center.x, y: center.y + outer))
        path.line(to: CGPoint(x: center.x + inner, y: center.y + inner))
        path.line(to: CGPoint(x: center.x + outer, y: center.y))
        path.line(to: CGPoint(x: center.x + inner, y: center.y - inner))
        path.line(to: CGPoint(x: center.x, y: center.y - outer))
        path.line(to: CGPoint(x: center.x - inner, y: center.y - inner))
        path.line(to: CGPoint(x: center.x - outer, y: center.y))
        path.line(to: CGPoint(x: center.x - inner, y: center.y + inner))
        path.close()

        color.setFill()
        path.fill()
    }

    sparkle(
        center: CGPoint(x: size * 0.5, y: size * 0.53),
        outer: size * 0.25,
        inner: size * 0.07,
        color: .white
    )
    sparkle(
        center: CGPoint(x: size * 0.71, y: size * 0.72),
        outer: size * 0.09,
        inner: size * 0.027,
        color: NSColor(calibratedWhite: 1.0, alpha: 0.92)
    )
    sparkle(
        center: CGPoint(x: size * 0.3, y: size * 0.3),
        outer: size * 0.075,
        inner: size * 0.022,
        color: NSColor(calibratedWhite: 1.0, alpha: 0.86)
    )

    return image
}

for size in sizes {
    let pixels = Int(size.points * size.scale)
    let image = drawIcon(size: CGFloat(pixels))
    guard
        let tiff = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let png = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "NotchSparkIcon", code: 1)
    }

    try png.write(to: iconsetURL.appendingPathComponent(size.name))
}
