import CoreGraphics
import Foundation

public final class CursorProximityController {
    public typealias CursorProvider = () -> CGPoint
    public typealias ScreenProvider = () -> [ScreenSnapshot]
    public typealias TriggerHandler = (NotchMetrics) -> Void

    public var isEnabled: Bool

    private let pollInterval: TimeInterval
    private let cooldown: TimeInterval
    private let cursorProvider: CursorProvider
    private let screenProvider: ScreenProvider
    private let onTrigger: TriggerHandler
    private var timer: Timer?
    private var wasInsideTriggerZone = false
    private var lastTriggeredAt = -TimeInterval.infinity

    public init(
        isEnabled: Bool = true,
        pollInterval: TimeInterval = 0.12,
        cooldown: TimeInterval = 8,
        cursorProvider: @escaping CursorProvider,
        screenProvider: @escaping ScreenProvider,
        onTrigger: @escaping TriggerHandler
    ) {
        self.isEnabled = isEnabled
        self.pollInterval = pollInterval
        self.cooldown = cooldown
        self.cursorProvider = cursorProvider
        self.screenProvider = screenProvider
        self.onTrigger = onTrigger
    }

    deinit {
        stop()
    }

    public func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
    }

    public func noteManualShow(now: TimeInterval = Date.timeIntervalSinceReferenceDate) {
        lastTriggeredAt = now
    }

    public func metrics(for mouseLocation: CGPoint) -> NotchMetrics? {
        let screens = screenProvider()

        if let matchingScreen = screens.first(where: { $0.frame.contains(mouseLocation) }) {
            return NotchGeometry.metrics(for: matchingScreen)
        }

        return screens.first.map(NotchGeometry.metrics)
    }

    @discardableResult
    public func tick(
        mouseLocation explicitMouseLocation: CGPoint? = nil,
        now: TimeInterval = Date.timeIntervalSinceReferenceDate
    ) -> Bool {
        let mouseLocation = explicitMouseLocation ?? cursorProvider()

        guard let metrics = metrics(for: mouseLocation) else {
            wasInsideTriggerZone = false
            return false
        }

        let isInside = metrics.triggerZone.contains(mouseLocation)

        guard isEnabled else {
            wasInsideTriggerZone = isInside
            return false
        }

        let didEnter = isInside && !wasInsideTriggerZone
        wasInsideTriggerZone = isInside

        guard didEnter, now - lastTriggeredAt >= cooldown else {
            return false
        }

        lastTriggeredAt = now
        onTrigger(metrics)
        return true
    }
}
