import AppKit
import ServiceManagement

final class AppMenuController: NSObject {
    private let statusItem: NSStatusItem
    private let onToggleEnabled: (Bool) -> Void
    private let onToggleReactionCamera: (Bool) -> Void
    private let onShowFactNow: () -> Void

    private var isEnabled: Bool
    private var isReactionCameraEnabled: Bool
    private var enabledItem = NSMenuItem()
    private var reactionCameraItem = NSMenuItem()
    private var launchAtLoginItem = NSMenuItem()

    init(
        isEnabled: Bool,
        isReactionCameraEnabled: Bool,
        onToggleEnabled: @escaping (Bool) -> Void,
        onToggleReactionCamera: @escaping (Bool) -> Void,
        onShowFactNow: @escaping () -> Void
    ) {
        self.isEnabled = isEnabled
        self.isReactionCameraEnabled = isReactionCameraEnabled
        self.onToggleEnabled = onToggleEnabled
        self.onToggleReactionCamera = onToggleReactionCamera
        self.onShowFactNow = onShowFactNow
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        configureStatusItem()
        rebuildMenu()
    }

    private func configureStatusItem() {
        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "sparkles", accessibilityDescription: "NotchSpark")
            image?.isTemplate = true
            button.image = image
            button.title = image == nil ? "NS" : ""
            button.toolTip = "NotchSpark"
        }
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        let titleItem = NSMenuItem(title: "NotchSpark", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        menu.addItem(.separator())

        let showItem = NSMenuItem(title: "Show Fact Now", action: #selector(showFactNow), keyEquivalent: "f")
        showItem.target = self
        menu.addItem(showItem)

        enabledItem = NSMenuItem(title: "Enabled", action: #selector(toggleEnabled), keyEquivalent: "")
        enabledItem.target = self
        menu.addItem(enabledItem)

        reactionCameraItem = NSMenuItem(title: "Reaction Camera", action: #selector(toggleReactionCamera), keyEquivalent: "")
        reactionCameraItem.target = self
        menu.addItem(reactionCameraItem)

        launchAtLoginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginItem.target = self
        menu.addItem(launchAtLoginItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit NotchSpark", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        refreshMenuState()
    }

    private func refreshMenuState() {
        enabledItem.state = isEnabled ? .on : .off
        reactionCameraItem.state = isReactionCameraEnabled ? .on : .off

        guard isRunningFromAppBundle else {
            launchAtLoginItem.title = "Launch at Login (bundle required)"
            launchAtLoginItem.isEnabled = false
            launchAtLoginItem.state = .off
            return
        }

        launchAtLoginItem.title = "Launch at Login"
        launchAtLoginItem.isEnabled = true

        switch SMAppService.mainApp.status {
        case .enabled:
            launchAtLoginItem.state = .on
        case .requiresApproval:
            launchAtLoginItem.state = .mixed
        default:
            launchAtLoginItem.state = .off
        }
    }

    private var isRunningFromAppBundle: Bool {
        Bundle.main.bundleURL.pathExtension == "app"
    }

    func setReactionCameraEnabled(_ isEnabled: Bool) {
        isReactionCameraEnabled = isEnabled
        refreshMenuState()
    }

    @objc private func showFactNow() {
        onShowFactNow()
    }

    @objc private func toggleEnabled() {
        isEnabled.toggle()
        onToggleEnabled(isEnabled)
        refreshMenuState()
    }

    @objc private func toggleReactionCamera() {
        let requestedState = !isReactionCameraEnabled
        onToggleReactionCamera(requestedState)

        if !requestedState {
            isReactionCameraEnabled = false
            refreshMenuState()
        }
    }

    @objc private func toggleLaunchAtLogin() {
        guard isRunningFromAppBundle else {
            return
        }

        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            showLaunchAtLoginError(error)
        }

        refreshMenuState()
    }

    private func showLaunchAtLoginError(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = "Launch at Login could not be updated."
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.runModal()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
