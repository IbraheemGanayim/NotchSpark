import AppKit
import NotchSparkCore
import SwiftUI

final class FactBubbleWindowController {
    private let reactionCameraManager: ReactionCameraManager
    private var panel: NSPanel?
    private var dismissWorkItem: DispatchWorkItem?
    private var currentMorphFrame: CGRect?

    init(reactionCameraManager: ReactionCameraManager) {
        self.reactionCameraManager = reactionCameraManager
    }

    func show(fact: FunFact, metrics: NotchMetrics, showsReactionCamera: Bool) {
        let shouldShowReactionCamera = showsReactionCamera && reactionCameraManager.canShowPreview
        let frame = bubbleFrame(for: metrics, showsReactionCamera: shouldShowReactionCamera)
        let morphFrame = notchMorphFrame(for: metrics, finalFrame: frame)
        let contrastStyle = BackdropContrastSampler.style(behind: frame)
        let panel = panel ?? makePanel(frame: frame)
        self.panel = panel
        currentMorphFrame = morphFrame

        dismissWorkItem?.cancel()

        if shouldShowReactionCamera {
            reactionCameraManager.startSessionIfNeeded()
        } else {
            reactionCameraManager.stopSession()
        }

        let hostingView = NSHostingView(
            rootView: FactBubbleView(
                fact: fact,
                contrastStyle: contrastStyle,
                reactionCameraSession: shouldShowReactionCamera ? reactionCameraManager.session : nil
            )
            .id(UUID())
        )
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor
        hostingView.layer?.cornerCurve = .continuous
        hostingView.layer?.cornerRadius = 22
        panel.contentView = hostingView
        panel.setFrame(morphFrame, display: false)
        panel.alphaValue = 0.92
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.48
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.16, 0.92, 0.18, 1)
            panel.animator().alphaValue = 1
            panel.animator().setFrame(frame, display: true)
        }

        let dismissWorkItem = DispatchWorkItem { [weak self] in
            self?.dismiss()
        }
        self.dismissWorkItem = dismissWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: dismissWorkItem)
    }

    private func dismiss() {
        dismissWorkItem?.cancel()
        dismissWorkItem = nil

        guard let panel, panel.isVisible else {
            return
        }

        let endFrame = currentMorphFrame ?? panel.frame.offsetBy(dx: 0, dy: 8)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.34
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.46, 0, 0.8, 0.24)
            panel.animator().alphaValue = 0.9
            panel.animator().setFrame(endFrame, display: true)
        } completionHandler: {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.12
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                panel.animator().alphaValue = 0
            } completionHandler: {
                panel.orderOut(nil)
                self.currentMorphFrame = nil
                self.reactionCameraManager.stopSession()
            }
        }
    }

    private func makePanel(frame: CGRect) -> NSPanel {
        let panel = NSPanel(
            contentRect: frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = true
        panel.animationBehavior = .none
        panel.level = .statusBar
        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]
        panel.isReleasedWhenClosed = false
        return panel
    }

    private func bubbleFrame(for metrics: NotchMetrics, showsReactionCamera: Bool) -> CGRect {
        let availableWidth = max(220, metrics.screenFrame.width - 36)
        let preferredWidth: CGFloat = showsReactionCamera ? 468 : 392
        let minimumWidth: CGFloat = showsReactionCamera ? 352 : 292
        let width = min(min(preferredWidth, max(minimumWidth, availableWidth)), availableWidth)
        let height: CGFloat = 66
        let x = clamp(
            metrics.bubbleAnchor.x - (width / 2),
            min: metrics.screenFrame.minX + 18,
            max: metrics.screenFrame.maxX - width - 18
        )
        let y = max(
            metrics.screenFrame.minY + 18,
            metrics.bubbleAnchor.y - height
        )

        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func notchMorphFrame(for metrics: NotchMetrics, finalFrame: CGRect) -> CGRect {
        let width = min(max(metrics.notchWidth * 0.72, 92), 178)
        let height: CGFloat = 16
        let centerX = clamp(
            metrics.bubbleAnchor.x,
            min: metrics.screenFrame.minX + (width / 2) + 12,
            max: metrics.screenFrame.maxX - (width / 2) - 12
        )
        let notchBottom = metrics.screenFrame.maxY - metrics.notchHeight
        let topY = max(finalFrame.maxY, notchBottom + 2)
        return CGRect(
            x: centerX - (width / 2),
            y: topY - height,
            width: width,
            height: height
        )
    }

    private func clamp(_ value: CGFloat, min minimum: CGFloat, max maximum: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, minimum), maximum)
    }
}
