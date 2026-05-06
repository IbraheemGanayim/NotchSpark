import AppKit
import NotchSparkCore

final class AppCoordinator {
    private enum DefaultsKey {
        static let isEnabled = "isEnabled"
        static let isReactionCameraEnabled = "isReactionCameraEnabled"
    }

    private let factStore = FactStore()
    private let reactionCameraManager = ReactionCameraManager()
    private lazy var bubbleController = FactBubbleWindowController(reactionCameraManager: reactionCameraManager)
    private var cursorController: CursorProximityController?
    private var menuController: AppMenuController?
    private var isReactionCameraEnabled = false

    func start() {
        let enabled = UserDefaults.standard.object(forKey: DefaultsKey.isEnabled) as? Bool ?? true
        let reactionCameraEnabled = (UserDefaults.standard.object(forKey: DefaultsKey.isReactionCameraEnabled) as? Bool ?? false)
            && reactionCameraManager.canShowPreview
        isReactionCameraEnabled = reactionCameraEnabled
        UserDefaults.standard.set(reactionCameraEnabled, forKey: DefaultsKey.isReactionCameraEnabled)

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
            isReactionCameraEnabled: reactionCameraEnabled,
            onToggleEnabled: { [weak self] isEnabled in
                self?.setEnabled(isEnabled)
            },
            onToggleReactionCamera: { [weak self] isEnabled in
                self?.setReactionCameraEnabled(isEnabled)
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

    private func setReactionCameraEnabled(_ isEnabled: Bool) {
        guard isEnabled else {
            isReactionCameraEnabled = false
            reactionCameraManager.stopSession()
            UserDefaults.standard.set(false, forKey: DefaultsKey.isReactionCameraEnabled)
            menuController?.setReactionCameraEnabled(false)
            return
        }

        reactionCameraManager.requestPermission { [weak self] granted in
            guard let self else {
                return
            }

            let canEnable = granted && self.reactionCameraManager.canShowPreview
            self.isReactionCameraEnabled = canEnable
            UserDefaults.standard.set(canEnable, forKey: DefaultsKey.isReactionCameraEnabled)
            self.menuController?.setReactionCameraEnabled(canEnable)
        }
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
        bubbleController.show(
            fact: factStore.nextFact(),
            metrics: metrics,
            showsReactionCamera: isReactionCameraEnabled
        )
    }
}
