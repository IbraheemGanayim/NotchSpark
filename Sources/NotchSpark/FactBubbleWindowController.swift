import AppKit
import NotchSparkCore
import SwiftUI

final class FactBubbleWindowController {
    private var panel: NSPanel?
    private var dismissWorkItem: DispatchWorkItem?

    func show(fact: FunFact, metrics: NotchMetrics) {
        let frame = bubbleFrame(for: metrics)
        let contrastStyle = BackdropContrastSampler.style(behind: frame)
        let panel = panel ?? makePanel(frame: frame)
        self.panel = panel

        dismissWorkItem?.cancel()

        panel.contentView = NSHostingView(
            rootView: FactBubbleView(fact: fact, contrastStyle: contrastStyle).id(UUID())
        )
        panel.setFrame(frame.offsetBy(dx: 0, dy: 10), display: false)
        panel.alphaValue = 0
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.18
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
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

        let endFrame = panel.frame.offsetBy(dx: 0, dy: 10)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.22
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            panel.animator().alphaValue = 0
            panel.animator().setFrame(endFrame, display: true)
        } completionHandler: {
            panel.orderOut(nil)
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

    private func bubbleFrame(for metrics: NotchMetrics) -> CGRect {
        let width = min(392, max(292, metrics.screenFrame.width - 52))
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

    private func clamp(_ value: CGFloat, min minimum: CGFloat, max maximum: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, minimum), maximum)
    }
}
