import AppKit

// Include this margin when sizing the containing window, not the visible surface.
let glassShadowInset: CGFloat = 24

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
        width: content.frame.width + glassShadowInset * 2,
        height: content.frame.height + glassShadowInset * 2)
    ))
  backing.wantsLayer = true
  backing.layer?.backgroundColor = NSColor.clear.cgColor
  material.translatesAutoresizingMaskIntoConstraints = false
  backing.addSubview(material)
  NSLayoutConstraint.activate([
    material.leadingAnchor.constraint(equalTo: backing.leadingAnchor, constant: glassShadowInset),
    material.trailingAnchor.constraint(
      equalTo: backing.trailingAnchor, constant: -glassShadowInset),
    material.topAnchor.constraint(equalTo: backing.topAnchor, constant: glassShadowInset),
    material.bottomAnchor.constraint(equalTo: backing.bottomAnchor, constant: -glassShadowInset),
  ])
  return backing
}
