import AppKit
import NotchSparkCore

final class AppCoordinator {
    private enum DefaultsKey {
        static let isEnabled = "isEnabled"
    }

    private let factStore = FactStore()
    private let bubbleController = FactBubbleWindowController()
    private var cursorController: CursorProximityController?
    private var menuController: AppMenuController?

    func start() {
        let enabled = UserDefaults.standard.object(forKey: DefaultsKey.isEnabled) as? Bool ?? true

        let cursorController = CursorProximityController(
            isEnabled: enabled,
            cursorProvider: { NSEvent.mouseLocation },
            screenProvider: { NSScreen.screens.map(ScreenSnapshot.init(screen:)) },
            onTrigger: { [weak self] metrics in
                self?.showFact(metrics: metrics)
            }
        )

        self.cursorController = cursorController
        cursorController.start()

        menuController = AppMenuController(
            isEnabled: enabled,
            onToggleEnabled: { [weak self] isEnabled in
                self?.setEnabled(isEnabled)
            },
            onShowFactNow: { [weak self] in
                self?.showFactNow()
            }
        )
    }

    private func setEnabled(_ isEnabled: Bool) {
        cursorController?.isEnabled = isEnabled
        UserDefaults.standard.set(isEnabled, forKey: DefaultsKey.isEnabled)
    }

    private func showFactNow() {
        cursorController?.noteManualShow()

        let metrics = cursorController?.metrics(for: NSEvent.mouseLocation)
            ?? NSScreen.main.map { NotchGeometry.metrics(for: ScreenSnapshot(screen: $0)) }
            ?? NSScreen.screens.first.map { NotchGeometry.metrics(for: ScreenSnapshot(screen: $0)) }

        guard let metrics else {
            return
        }

        showFact(metrics: metrics)
    }

    private func showFact(metrics: NotchMetrics) {
        bubbleController.show(fact: factStore.nextFact(), metrics: metrics)
    }
}
