import AppKit

private struct Choice: Decodable {
  let text: String
  let subText: String
  let image: String?
}

private struct Position: Decodable {
  let x: Double
  let y: Double
}

private struct Snapshot: Decodable {
  let session: Int
  let revision: Int
  let input: Int
  let visible: Bool
  let query: String
  let placeholder: String
  let rows: Int
  let width: Double
  let maxWidth: Double?
  let selected: Int
  let choices: [Choice]
  let position: Position?
}

private final class ChooserPanel: NSPanel {
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { false }
}

private final class ChoiceRow: NSTableRowView {
  private let highlight = NSView()

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    configureHighlight()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configureHighlight()
  }

  private func configureHighlight() {
    highlight.wantsLayer = true
    highlight.layer?.cornerRadius = GlassGeometry.selectionRadius
    highlight.layer?.cornerCurve = .continuous
    highlight.translatesAutoresizingMaskIntoConstraints = false
    addSubview(highlight, positioned: .below, relativeTo: nil)
    NSLayoutConstraint.activate([
      highlight.leadingAnchor.constraint(equalTo: leadingAnchor, constant: GlassGeometry.rowInsetX),
      highlight.trailingAnchor.constraint(
        equalTo: trailingAnchor, constant: -GlassGeometry.rowInsetX),
      highlight.topAnchor.constraint(equalTo: topAnchor, constant: GlassGeometry.rowInsetY),
      highlight.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -GlassGeometry.rowInsetY),
    ])
    updateHighlight()
  }

  override var isSelected: Bool { didSet { updateHighlight() } }
  override var selectionHighlightStyle: NSTableView.SelectionHighlightStyle {
    didSet { updateHighlight() }
  }

  override func viewDidChangeEffectiveAppearance() {
    super.viewDidChangeEffectiveAppearance()
    updateHighlight()
  }

  private func updateHighlight() {
    highlight.isHidden = !isSelected || selectionHighlightStyle == .none
    effectiveAppearance.performAsCurrentDrawingAppearance {
      highlight.layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.08).cgColor
    }
  }

  // Draw only the continuous-corner highlight subview, never an opaque row fill.
  override func drawBackground(in dirtyRect: NSRect) {}
  override func drawSelection(in dirtyRect: NSRect) {}
}

// stdout is reserved for newline-delimited JSON; diagnostics belong on stderr.
private func emit(_ event: String, _ values: [String: Any] = [:]) {
  var message = values
  message["event"] = event
  guard let data = try? JSONSerialization.data(withJSONObject: message) else { return }
  FileHandle.standardOutput.write(data + Data([10]))
}

private final class Chooser: NSObject, NSApplicationDelegate, NSWindowDelegate,
  NSSearchFieldDelegate, NSTableViewDataSource, NSTableViewDelegate
{
  private let panel = ChooserPanel(
    contentRect: .zero, styleMask: [.borderless], backing: .buffered, defer: false)
  private let search = NSSearchField()
  private let table = NSTableView()
  private let scroll = NSScrollView()
  private let empty = NSTextField(labelWithString: "Search apps, calculations, and actions")
  private var snapshot: Snapshot?
  private var choices: [Choice] = []
  private var previousApp: NSRunningApplication?
  private var applying = false
  private var inputVersion = 0
  private var images: [String: NSImage] = [:]

  func applicationDidFinishLaunching(_ notification: Notification) {
    // A CLI-hosted AppKit app has no nib-provided Edit menu. Supply the standard
    // responder-chain commands so Cmd+A/C/V/X/Z work in the search field.
    let menu = NSMenu()
    let application = NSMenuItem()
    application.submenu = NSMenu(title: "Launcher")
    application.submenu?.addItem(
      withTitle: "Quit Launcher", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"
    )
    menu.addItem(application)
    let edit = NSMenuItem()
    edit.submenu = NSMenu(title: "Edit")
    for (title, action, key) in [
      ("Undo", Selector(("undo:")), "z"),
      ("Redo", Selector(("redo:")), "Z"),
      ("Cut", #selector(NSText.cut(_:)), "x"),
      ("Copy", #selector(NSText.copy(_:)), "c"),
      ("Paste", #selector(NSText.paste(_:)), "v"),
      ("Select All", #selector(NSText.selectAll(_:)), "a"),
    ] {
      edit.submenu?.addItem(withTitle: title, action: action, keyEquivalent: key)
    }
    menu.addItem(edit)
    NSApp.mainMenu = menu
    panel.delegate = self
    panel.isReleasedWhenClosed = false
    panel.isOpaque = false
    panel.backgroundColor = .clear
    // The glass surface supplies its own edge treatment; an NSWindow shadow
    // adds a dark rectangular outline around the rounded, transparent panel.
    panel.hasShadow = false
    panel.level = .floating
    panel.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary, .ignoresCycle]

    let content = NSView()
    panel.contentView = glassBackground(for: content, cornerRadius: GlassGeometry.launcherRadius)

    let searchIcon = NSImageView()
    searchIcon.image = NSImage(
      systemSymbolName: "magnifyingglass", accessibilityDescription: "Search")?
      .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 20, weight: .medium))
    searchIcon.contentTintColor = .secondaryLabelColor
    // A separate icon avoids NSSearchFieldCell's overlapping bezel-less text rect.
    (search.cell as? NSSearchFieldCell)?.searchButtonCell = nil
    search.delegate = self
    search.font = .systemFont(ofSize: 23)
    search.isBezeled = false
    search.drawsBackground = false
    search.focusRingType = .none
    search.sendsSearchStringImmediately = true
    search.sendsWholeSearchString = false

    table.addTableColumn(NSTableColumn(identifier: NSUserInterfaceItemIdentifier("choice")))
    table.headerView = nil
    table.style = .plain
    table.usesAlternatingRowBackgroundColors = false
    table.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
    table.backgroundColor = .clear
    table.rowHeight = 58
    table.intercellSpacing = .zero
    table.dataSource = self
    table.delegate = self
    table.target = self
    table.doubleAction = #selector(accept)
    table.focusRingType = .none
    scroll.documentView = table
    scroll.drawsBackground = false
    scroll.contentView.drawsBackground = false
    scroll.backgroundColor = .clear
    scroll.hasVerticalScroller = true
    scroll.autohidesScrollers = true
    empty.textColor = .secondaryLabelColor
    empty.font = .systemFont(ofSize: 13)
    let separator = NSBox()
    separator.boxType = .separator
    for view in [searchIcon, search, separator, scroll, empty] {
      view.translatesAutoresizingMaskIntoConstraints = false
      content.addSubview(view)
    }
    NSLayoutConstraint.activate([
      searchIcon.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 22),
      searchIcon.centerYAnchor.constraint(equalTo: search.centerYAnchor),
      searchIcon.widthAnchor.constraint(equalToConstant: 22),
      searchIcon.heightAnchor.constraint(equalToConstant: 22),
      search.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 12),
      search.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -22),
      search.topAnchor.constraint(
        equalTo: content.topAnchor, constant: GlassGeometry.searchTopInset),
      search.heightAnchor.constraint(equalToConstant: GlassGeometry.searchHeight),
      separator.topAnchor.constraint(
        equalTo: search.bottomAnchor, constant: GlassGeometry.separatorTopInset),
      separator.heightAnchor.constraint(equalToConstant: GlassGeometry.separatorHeight),
      separator.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 12),
      separator.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -12),
      scroll.topAnchor.constraint(
        equalTo: separator.bottomAnchor, constant: GlassGeometry.resultsTopInset),
      scroll.leadingAnchor.constraint(
        equalTo: content.leadingAnchor, constant: GlassGeometry.resultsSideInset),
      scroll.trailingAnchor.constraint(
        equalTo: content.trailingAnchor, constant: -GlassGeometry.resultsSideInset),
      scroll.bottomAnchor.constraint(
        equalTo: content.bottomAnchor, constant: -GlassGeometry.resultsBottomInset),
      empty.centerXAnchor.constraint(equalTo: scroll.centerXAnchor),
      empty.centerYAnchor.constraint(equalTo: scroll.centerYAnchor),
    ])

    // EOF shuts down the UI when Hammerspoon exits or reloads its Lua state.
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      while let line = readLine() {
        guard let data = line.data(using: .utf8),
          let state = try? JSONDecoder().decode(Snapshot.self, from: data)
        else {
          FileHandle.standardError.write(Data("native-chooser: invalid snapshot\n".utf8))
          continue
        }
        DispatchQueue.main.async { self?.apply(state) }
      }
      DispatchQueue.main.async { NSApp.terminate(nil) }
    }
    emit("ready")
  }

  private func event(_ name: String, _ extra: [String: Any] = [:]) {
    guard let state = snapshot else { return }
    var values = extra
    values["session"] = state.session
    values["revision"] = state.revision
    values["input"] = inputVersion
    emit(name, values)
  }

  private func apply(_ state: Snapshot) {
    applying = true
    defer {
      applying = false
      emit("ack")
    }
    if let current = snapshot {
      // A snapshot computed before the latest keystroke must not overwrite it.
      if state.session < current.session { return }
      if state.session == current.session && state.visible && state.input < inputVersion { return }
    }
    inputVersion = state.input
    let opening = state.visible && (!panel.isVisible || snapshot?.session != state.session)
    snapshot = state
    guard state.visible else {
      hide()
      event("hidden")
      return
    }
    choices = state.choices
    if images.count > 256 { images.removeAll() }
    search.placeholderString = state.placeholder
    if search.stringValue != state.query { search.stringValue = state.query }
    table.reloadData()
    let selected = state.selected - 1
    if choices.indices.contains(selected) {
      table.selectRowIndexes(IndexSet(integer: selected), byExtendingSelection: false)
      table.scrollRowToVisible(selected)
    } else {
      table.deselectAll(nil)
    }
    empty.stringValue =
      state.query.isEmpty ? "Search apps, calculations, and actions" : "No results"
    empty.isHidden = !choices.isEmpty
    guard let screen = (opening ? NSScreen.main : panel.screen) ?? NSScreen.main else { return }
    let frame = screen.visibleFrame
    let width = min(
      frame.width - 32, state.maxWidth ?? 640, max(360, frame.width * state.width / 100))
    let height = min(
      frame.height - 64,
      GlassGeometry.launcherChromeHeight + CGFloat(max(1, min(state.rows, choices.count)))
        * table.rowHeight)
    // Keep the top edge stable as results change, with room below the search field.
    let top =
      state.position.map { (NSScreen.screens.first?.frame.maxY ?? 0) - $0.y }
      ?? (frame.maxY - frame.height * 0.22)
    let x = state.position?.x ?? (frame.midX - width / 2)
    let surfaceFrame = NSRect(x: x, y: top - height, width: width, height: height)
    panel.setFrame(
      surfaceFrame.insetBy(dx: -GlassGeometry.shadowInset, dy: -GlassGeometry.shadowInset),
      display: true)
    if opening {
      if !panel.isVisible { previousApp = NSWorkspace.shared.frontmostApplication }
      NSApp.activate(ignoringOtherApps: true)
      panel.makeKeyAndOrderFront(nil)
      panel.makeFirstResponder(search)
      search.currentEditor()?.selectedRange = NSRange(
        location: search.stringValue.utf16.count, length: 0)
      event("shown")
    }
  }

  private func hide(restoreFocus: Bool = true) {
    guard panel.isVisible else { return }
    let wasApplying = applying
    applying = true
    panel.orderOut(nil)
    applying = wasApplying
    if restoreFocus && NSApp.isActive { previousApp?.activate(options: []) }
    previousApp = nil
  }

  func windowDidResignKey(_ notification: Notification) {
    if !applying && panel.isVisible {
      event("cancel")
      // A click into another app should keep focus there, not restore the old app.
      hide(restoreFocus: false)
    }
  }

  func controlTextDidChange(_ notification: Notification) {
    guard !applying else { return }
    // Results from the previous query must not be selectable during Lua's debounce.
    choices = []
    inputVersion += 1
    table.reloadData()
    event("query", ["query": search.stringValue])
  }

  func control(_ control: NSControl, textView: NSTextView, doCommandBy command: Selector) -> Bool {
    switch command {
    case #selector(NSResponder.moveDown(_:)):
      moveSelection(1)
    case #selector(NSResponder.moveUp(_:)):
      moveSelection(-1)
    case #selector(NSResponder.insertNewline(_:)):
      accept()
    case #selector(NSResponder.cancelOperation(_:)):
      event("cancel")
      hide()
    default:
      return false
    }
    return true
  }

  private func moveSelection(_ offset: Int) {
    guard !choices.isEmpty else { return }
    let row = min(choices.count - 1, max(0, table.selectedRow + offset))
    table.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
    table.scrollRowToVisible(row)
  }

  @objc private func accept() {
    guard choices.indices.contains(table.selectedRow) else { return }
    event("select", ["row": table.selectedRow + 1, "query": search.stringValue])
  }

  func numberOfRows(in tableView: NSTableView) -> Int { choices.count }

  func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
    ChoiceRow()
  }

  func tableViewSelectionDidChange(_ notification: Notification) {
    if !applying { event("selection", ["row": table.selectedRow + 1]) }
  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
  {
    let choice = choices[row]
    let cell = NSTableCellView()
    let icon = NSImageView()
    if let encoded = choice.image {
      if let cached = images[encoded] {
        icon.image = cached
      } else if let comma = encoded.firstIndex(of: ","), encoded.hasPrefix("data:image/"),
        let data = Data(base64Encoded: String(encoded[encoded.index(after: comma)...])),
        let image = NSImage(data: data)
      {
        images[encoded] = image
        icon.image = image
      }
    }
    let title = NSTextField(labelWithString: choice.text)
    title.font = .systemFont(ofSize: 15, weight: .medium)
    title.lineBreakMode = .byTruncatingTail
    let detail = NSTextField(labelWithString: choice.subText)
    detail.font = .systemFont(ofSize: 12)
    detail.textColor = .secondaryLabelColor
    detail.lineBreakMode = .byTruncatingMiddle
    let labels = NSStackView(views: choice.subText.isEmpty ? [title] : [title, detail])
    labels.orientation = .vertical
    labels.alignment = .leading
    labels.spacing = 3
    for view in [icon, labels] {
      view.translatesAutoresizingMaskIntoConstraints = false
      cell.addSubview(view)
    }
    NSLayoutConstraint.activate([
      icon.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 12),
      icon.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
      icon.widthAnchor.constraint(equalToConstant: 32),
      icon.heightAnchor.constraint(equalToConstant: 32),
      labels.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
      labels.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -12),
      labels.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
    ])
    return cell
  }
}

@main
private enum NativeChooserMain {
  static func main() {
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    let delegate = Chooser()
    app.delegate = delegate
    withExtendedLifetime(delegate) { app.run() }
  }
}
