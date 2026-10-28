import AppKit

// Shared by the non-activating toast and the focusable launcher.
func glassBackground(for content: NSView, cornerRadius: CGFloat) -> NSView {
  if #available(macOS 26.0, *) {
    let glass = NSGlassEffectView(frame: content.frame)
    glass.style = .regular
    glass.cornerRadius = cornerRadius
    glass.contentView = content
    return glass
  }

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
  return blur
}
