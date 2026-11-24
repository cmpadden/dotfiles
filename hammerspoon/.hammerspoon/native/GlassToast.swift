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
    guard (3...6).contains(args.count) else {
      fail("usage: glass-toast <layout> <title> <symbol> [seconds] [detail] [tint]")
    }
    let compact: Bool
    switch args[0] {
    case "compact-bottom": compact = true
    case "centered-card": compact = false
    default: fail("unknown layout: \(args[0])")
    }
    let title = args[1]
    let symbol = args[2]
    let duration = args.count > 3 ? Double(args[3]) ?? .nan : 2
    let detailText = args.count > 4 ? args[4] : ""
    guard !compact || detailText.isEmpty else {
      fail("compact-bottom only supports one line of text")
    }
    let tint: NSColor
    let tintName = args.count > 5 ? args[5] : "label"
    switch tintName {
    case "label": tint = .labelColor
    case "blue": tint = .systemBlue
    default: fail("unknown icon tint: \(tintName)")
    }
    guard duration.isFinite, (0.2...30).contains(duration) else {
      fail("duration must be between 0.2 and 30 seconds")
    }
    guard let screen = NSScreen.main else {
      fail("no screen available")
    }

    let heading = NSTextField(labelWithString: title)
    heading.font = .systemFont(ofSize: 14, weight: .semibold)
    heading.textColor = .labelColor

    let iconSize: CGFloat = compact ? 18 : 30
    let iconGap: CGFloat = compact ? 8 : 14
    let rowWidth = iconSize + iconGap + heading.intrinsicContentSize.width
    let size =
      compact
      ? NSSize(width: max(200, ceil(rowWidth) + 32), height: 40)
      : NSSize(width: 360, height: 64)
    let frame = screen.visibleFrame
    let rect = NSRect(
      x: frame.midX - size.width / 2,
      y: compact ? frame.minY + min(96, frame.height * 0.12) : frame.midY - size.height / 2,
      width: size.width,
      height: size.height
    )
    let panel = ToastPanel(
      contentRect: rect.insetBy(dx: -GlassGeometry.shadowInset, dy: -GlassGeometry.shadowInset),
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )
    panel.isOpaque = false
    panel.backgroundColor = .clear
    // Use only the material's own shadow, with padding from glassBackground.
    panel.hasShadow = false
    panel.level = .statusBar
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
    panel.ignoresMouseEvents = true
    panel.hidesOnDeactivate = false
    panel.isReleasedWhenClosed = false

    let content = NSView(frame: NSRect(origin: .zero, size: size))
    panel.contentView = glassBackground(for: content, cornerRadius: GlassGeometry.toastRadius)

    let icon = NSImageView()
    icon.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)?
      .withSymbolConfiguration(
        NSImage.SymbolConfiguration(pointSize: compact ? 16 : 24, weight: .medium))
    icon.contentTintColor = tint
    icon.translatesAutoresizingMaskIntoConstraints = false

    let labels = NSStackView(views: [heading])
    if !detailText.isEmpty {
      let detail = NSTextField(labelWithString: detailText)
      detail.font = .systemFont(ofSize: 12)
      detail.textColor = .secondaryLabelColor
      labels.addArrangedSubview(detail)
    }
    labels.orientation = .vertical
    labels.alignment = .leading
    labels.spacing = 4
    labels.translatesAutoresizingMaskIntoConstraints = false
    content.addSubview(icon)
    content.addSubview(labels)
    NSLayoutConstraint.activate([
      icon.leadingAnchor.constraint(
        equalTo: content.leadingAnchor, constant: compact ? (size.width - rowWidth) / 2 : 22),
      icon.centerYAnchor.constraint(equalTo: content.centerYAnchor),
      icon.widthAnchor.constraint(equalToConstant: iconSize),
      icon.heightAnchor.constraint(equalToConstant: iconSize),
      labels.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: iconGap),
      labels.centerYAnchor.constraint(equalTo: content.centerYAnchor),
      labels.trailingAnchor.constraint(
        lessThanOrEqualTo: content.trailingAnchor, constant: compact ? -16 : -22),
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

@main
private enum GlassToastMain {
  static func main() {
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    let delegate = AppDelegate()
    app.delegate = delegate
    withExtendedLifetime(delegate) { app.run() }
  }
}
