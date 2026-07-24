import SwiftUI
import AppKit

@main
struct ZCalendarApp {
    @MainActor
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private var timer: Timer?
    private let settings = Settings.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menubar-only app: no Dock icon.
        NSApp.setActivationPolicy(.accessory)
        applyAppearance()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(handleClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        updateTitle()

        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: CalendarView().environmentObject(settings)
        )

        // Refresh the menubar label periodically so it rolls over at midnight.
        timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.updateTitle() }
        }

        settings.onChange = { [weak self] in
            self?.updateTitle()
            self?.applyAppearance()
        }
    }

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showContextMenu(sender)
        } else {
            togglePopover(sender)
        }
    }

    private func togglePopover(_ sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func showContextMenu(_ sender: NSStatusBarButton) {
        let menu = NSMenu()
        let quit = NSMenuItem(title: settings.t("quit"), action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
        if let event = NSApp.currentEvent {
            NSMenu.popUpContextMenu(menu, with: event, for: sender)
        }
    }

    @objc private func quit() { NSApp.terminate(nil) }

    private func updateTitle() {
        let f = DateFormatter()
        f.locale = settings.locale
        f.dateFormat = settings.isChinese ? "M月d日 EEE" : "MMM d, EEE"
        statusItem?.button?.title = f.string(from: Date())
    }

    private func applyAppearance() {
        switch settings.appearance {
        case .system: NSApp.appearance = nil
        case .light: NSApp.appearance = NSAppearance(named: .aqua)
        case .dark: NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
}
