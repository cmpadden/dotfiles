import AppKit

private func fail(_ message: String) -> Never {
  FileHandle.standardError.write(Data("glass-toast: \(message)\n".utf8))
  exit(EXIT_FAILURE)
}

// A short-lived accessory process: no Dock icon, focus change, or notification history.
final class ToastPanel: NSPanel {
  override var canBecomeKey: Bool { false }
  override var canBecomeMain: Bool { false }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
  private var panel: ToastPanel?

  func applicationDidFinishLaunching(_ notification: Notification) {
    let args = Array(CommandLine.arguments.dropFirst())
    guard args.count <= 3 else {
      fail("usage: glass-toast [enabled|disabled|reload] [title] [seconds]")
    }
    let kind = args.first ?? "enabled"
    let symbol: String
    let defaultTitle: String
    let message: String
    let tint: NSColor
    switch kind {
    case "reload":
      symbol = "arrow.clockwise"
      defaultTitle = "Hammerspoon Reloaded"
      message = "Your configuration is ready."
      tint = .systemBlue
    case "disabled":
      symbol = "moon.zzz.fill"
      defaultTitle = "Caffeine Disabled"
      message = "Normal display sleep restored."
      tint = .secondaryLabelColor
    case "enabled":
      symbol = "cup.and.saucer.fill"
      defaultTitle = "Caffeine Enabled"
      message = "Your display will stay awake."
      tint = .systemGreen
    default:
      fail("unknown kind: \(kind)")
    }
    let title = args.count > 1 ? args[1] : defaultTitle
    let duration = args.count > 2 ? Double(args[2]) ?? .nan : 2
    guard duration.isFinite, (0.2...30).contains(duration) else {
      fail("duration must be between 0.2 and 30 seconds")
    }
    guard let screen = NSScreen.main else {
      fail("no screen available")
    }

    let size = NSSize(width: 360, height: 76)
    let frame = screen.visibleFrame
    let rect = NSRect(
      x: frame.midX - size.width / 2,
      y: frame.midY - size.height / 2,
      width: size.width,
      height: size.height
    )
    let panel = ToastPanel(
      contentRect: rect,
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )
    panel.isOpaque = false
    panel.backgroundColor = .clear
    panel.hasShadow = true
    panel.level = .statusBar
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
    panel.ignoresMouseEvents = true
    panel.hidesOnDeactivate = false
    panel.isReleasedWhenClosed = false

    let content = NSView(frame: NSRect(origin: .zero, size: size))
    if #available(macOS 26.0, *) {
      let glass = NSGlassEffectView(frame: content.bounds)
      glass.style = .regular
      glass.cornerRadius = 22
      glass.contentView = content
      panel.contentView = glass
    } else {
      let blur = NSVisualEffectView(frame: content.bounds)
      blur.material = .hudWindow
      blur.blendingMode = .behindWindow
      blur.state = .active
      blur.wantsLayer = true
      blur.layer?.cornerRadius = 22
      blur.layer?.masksToBounds = true
      blur.addSubview(content)
      panel.contentView = blur
    }

    let icon = NSImageView()
    icon.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)?
      .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 24, weight: .medium))
    icon.contentTintColor = tint
    icon.translatesAutoresizingMaskIntoConstraints = false

    let heading = NSTextField(labelWithString: title)
    heading.font = .systemFont(ofSize: 14, weight: .semibold)
    heading.textColor = .labelColor
    let detail = NSTextField(labelWithString: message)
    detail.font = .systemFont(ofSize: 12)
    detail.textColor = .secondaryLabelColor
    let labels = NSStackView(views: [heading, detail])
    labels.orientation = .vertical
    labels.alignment = .leading
    labels.spacing = 4
    labels.translatesAutoresizingMaskIntoConstraints = false
    content.addSubview(icon)
    content.addSubview(labels)
    NSLayoutConstraint.activate([
      icon.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 22),
      icon.centerYAnchor.constraint(equalTo: content.centerYAnchor),
      icon.widthAnchor.constraint(equalToConstant: 30),
      icon.heightAnchor.constraint(equalToConstant: 30),
      labels.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 14),
      labels.centerYAnchor.constraint(equalTo: content.centerYAnchor),
      labels.trailingAnchor.constraint(lessThanOrEqualTo: content.trailingAnchor, constant: -22),
    ])

    self.panel = panel
    panel.alphaValue = 0
    panel.orderFrontRegardless()
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.15
      panel.animator().alphaValue = 1
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
      NSAnimationContext.runAnimationGroup(
        { context in
          context.duration = 0.18
          panel.animator().alphaValue = 0
        },
        completionHandler: {
          NSApp.terminate(nil)
        })
    }
  }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
