import AppKit

// App-specific dimensions, not Apple-mandated radii. Nested rounded surfaces
// share a corner center: inner radius + visible inset = outer radius.
enum GlassGeometry {
  static let shadowInset: CGFloat = 24
  static let toastRadius: CGFloat = 16
  static let launcherRadius: CGFloat = 16
  static let selectionMargin: CGFloat = 14
  static let rowInsetX: CGFloat = 4
  static let rowInsetY: CGFloat = 3
  static let searchTopInset: CGFloat = 18
  static let searchHeight: CGFloat = 34
  static let separatorTopInset: CGFloat = 16
  static let separatorHeight: CGFloat = 1
  static let resultsTopInset: CGFloat = 8
  static var launcherChromeHeight: CGFloat {
    searchTopInset + searchHeight + separatorTopInset + separatorHeight + resultsTopInset
      + resultsBottomInset
  }
  static var selectionRadius: CGFloat { max(0, launcherRadius - selectionMargin) }
  static var resultsSideInset: CGFloat { selectionMargin - rowInsetX }
  static var resultsBottomInset: CGFloat { selectionMargin - rowInsetY }
}

// Shared by the non-activating toast and the focusable launcher. Containing
// windows must be transparent and disable NSWindow's additional shadow.
func glassBackground(for content: NSView, cornerRadius: CGFloat) -> NSView {
  let material: NSView
  if #available(macOS 26.0, *) {
    let glass = NSGlassEffectView(frame: content.frame)
    glass.style = .regular
    glass.cornerRadius = cornerRadius
    glass.contentView = content
    material = glass
  } else {
    let blur = NSVisualEffectView(frame: content.frame)
    blur.material = .hudWindow
    blur.blendingMode = .behindWindow
    blur.state = .active
    blur.wantsLayer = true
    blur.layer?.cornerRadius = cornerRadius
    blur.layer?.cornerCurve = .continuous
    blur.layer?.masksToBounds = true
    blur.addSubview(content)
    content.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      content.leadingAnchor.constraint(equalTo: blur.leadingAnchor),
      content.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
      content.topAnchor.constraint(equalTo: blur.topAnchor),
      content.bottomAnchor.constraint(equalTo: blur.bottomAnchor),
    ])
    material = blur
  }

  // Leave room for the material's own soft shading so the rectangular window
  // boundary does not crop it into square corners.
  let backing = NSView(
    frame: NSRect(
      origin: .zero,
      size: NSSize(
        width: content.frame.width + GlassGeometry.shadowInset * 2,
        height: content.frame.height + GlassGeometry.shadowInset * 2)
    ))
  backing.wantsLayer = true
  backing.layer?.backgroundColor = NSColor.clear.cgColor
  material.translatesAutoresizingMaskIntoConstraints = false
  backing.addSubview(material)
  NSLayoutConstraint.activate([
    material.leadingAnchor.constraint(
      equalTo: backing.leadingAnchor, constant: GlassGeometry.shadowInset),
    material.trailingAnchor.constraint(
      equalTo: backing.trailingAnchor, constant: -GlassGeometry.shadowInset),
    material.topAnchor.constraint(equalTo: backing.topAnchor, constant: GlassGeometry.shadowInset),
    material.bottomAnchor.constraint(
      equalTo: backing.bottomAnchor, constant: -GlassGeometry.shadowInset),
  ])
  return backing
}
