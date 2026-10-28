import AppKit

@main
private enum GlassGeometryTests {
  static func main() {
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)

    // Adjacent nested corners share a center; the shadow margin is NOT a content inset.
    let sideInset = GlassGeometry.resultsSideInset + GlassGeometry.rowInsetX
    let bottomInset = GlassGeometry.resultsBottomInset + GlassGeometry.rowInsetY
    assert(sideInset == GlassGeometry.selectionMargin)
    assert(bottomInset == sideInset, "Side and bottom selection margins must match")
    assert(
      sideInset + GlassGeometry.selectionRadius == GlassGeometry.launcherRadius,
      "Nested selection and glass corners must share a center")
    assert(GlassGeometry.selectionRadius > 0)

    // The viewport must contain whole rows, not a clipped row or unexplained bottom gap.
    let chromeHeight =
      GlassGeometry.searchTopInset + GlassGeometry.searchHeight
      + GlassGeometry.separatorTopInset + GlassGeometry.separatorHeight
      + GlassGeometry.resultsTopInset + GlassGeometry.resultsBottomInset
    assert(GlassGeometry.launcherChromeHeight == chromeHeight)

    let sizes: [(NSSize, CGFloat)] = [
      (NSSize(width: 360, height: 64), GlassGeometry.toastRadius),
      (NSSize(width: 640, height: chromeHeight + 58), GlassGeometry.launcherRadius),
      (NSSize(width: 640, height: chromeHeight + 58 * 8), GlassGeometry.launcherRadius),
    ]
    for (size, radius) in sizes {
      assert(radius * 2 <= min(size.width, size.height), "Corner radius must fit the surface")
      let surface = NSRect(origin: .zero, size: size)
      let panel = NSPanel(
        contentRect: surface.insetBy(
          dx: -GlassGeometry.shadowInset, dy: -GlassGeometry.shadowInset),
        styleMask: [.borderless], backing: .buffered, defer: false)
      let content = NSView(frame: surface)
      panel.contentView = glassBackground(for: content, cornerRadius: radius)
      panel.contentView!.layoutSubtreeIfNeeded()
      let material = panel.contentView!.subviews[0]
      assert(
        material.frame.origin == NSPoint(x: GlassGeometry.shadowInset, y: GlassGeometry.shadowInset)
      )
      assert(
        material.frame.size == size && content.frame.size == size,
        "Shadow padding must not resize the visible surface or its content")
      if #available(macOS 26.0, *) {
        assert((material as? NSGlassEffectView)?.cornerRadius == radius)
      } else {
        assert(material.layer?.cornerCurve == .continuous)
      }
    }
    print(
      "PASS: concentric selection corners, equal insets, row sizing, and padded native glass layout"
    )
  }
}
