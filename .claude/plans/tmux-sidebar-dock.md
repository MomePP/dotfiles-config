# Docked Sidebar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A sidebar that lives in a real tmux pane, follows you into whatever window you move to, and is driven by mouse clicks — so you pick a target and immediately work in it without closing anything.

**Architecture:** The existing TUI gains a second run mode that renders without the popup's chrome and does not exit on selection. All tmux orchestration (open, follow, close) lives in Rust behind `dock-toggle` / `dock-follow` subcommands, built from pure argument-vector functions so the flag order is pinned by tests rather than by an unreadable shell script. The plugin's `.tmux` only binds a key and installs two hooks.

**Tech Stack:** Rust 2021, ratatui 0.26.3, crossterm 0.27, anyhow. No new dependencies.

## Global Constraints

- Repository: `~/Developer/tmux-plugins/tmux-agent-switcher`, branch from `main` @ `d8958c8`. Push to `origin` only; `upstream` push is disabled.
- **No new crate dependencies.**
- Tests are inline `#[cfg(test)] mod tests` blocks in the module under test. `crate::test_support::test_card(session_name, window_index) -> WindowCard` is available.
- No `unsafe`.
- **The popup must not change.** Every dock path is selected by an explicit `Surface::Dock`; `Surface::Popup` must produce byte-identical behaviour to today.
- Verification, all three required before each commit:
  - `cargo test`
  - `cargo clippy --all-targets 2>&1 | grep '^warning' | grep -vc 'generated'` — must print **1** (the pre-existing `model.rs:107` warning). Counting raw `^warning` lines is wrong; it includes per-target summaries that vary with what recompiles.
  - `cargo build --release`
- Conventional commits, lower-case subject, no trailing period.
- Do NOT claim "no deviations" in a report unless the code matches the plan character for character. Attributes, comments and imports added or omitted ARE deviations.

## File Structure

| File | Responsibility |
|---|---|
| `src/dock.rs` (new) | Everything tmux-layout: pure argv builders, plus `toggle()` and `follow()` that sequence them |
| `src/ui/layout.rs` | Gains `dock_layout` — full-width list, no modal inset |
| `src/ui/render.rs` | Gains `Surface`; `draw` skips preview/border/top-bar for the dock |
| `src/ui/mod.rs` | Dock run mode, in-loop action execution, click→row resolution |
| `src/main.rs` | `dock`, `dock-toggle`, `dock-follow` subcommands |
| `tmux-agent-switcher.tmux` | `prefix + b` binding and two indexed hooks |

---

### Task 1: `Surface` and the dock layout

**Files:**
- Modify: `src/ui/layout.rs` (append `dock_layout` and its tests)
- Modify: `src/ui/render.rs` (add `Surface`)

**Interfaces:**
- Consumes: `SwitcherLayout { list_overlay, search, sessions, help, preview }`, `switcher_layout_for_input(area, show_help, view, line_count, input)`, `SEARCH_BAR_ROWS`, `HELP_LINE_COUNT`, all already in `layout.rs`.
- Produces: `pub(crate) enum Surface { Popup, Dock }` in `render.rs`; `pub(crate) fn dock_layout(area: Rect, show_help: bool, input: InputMode) -> SwitcherLayout` in `layout.rs`.

- [ ] **Step 1: Write the failing tests**

Append inside `mod tests` in `src/ui/layout.rs`:

```rust
    #[test]
    fn dock_layout_uses_the_whole_pane_with_no_modal_inset() {
        let area = Rect {
            x: 0,
            y: 0,
            width: 30,
            height: 40,
        };

        let layout = dock_layout(area, false, InputMode::Keys);

        // No border to inset past: the list starts at the pane's own edge.
        assert_eq!(layout.list_overlay, area);
        assert_eq!(layout.sessions.x, 0);
        assert_eq!(layout.sessions.width, 30);
        // Nothing to preview beside a pane that fills its own width.
        assert_eq!(layout.preview.width, 0);
        assert_eq!(layout.preview.height, 0);
        // Keys mode hides the search bar, so the list takes the full height.
        assert_eq!(layout.sessions.height, 40);
        assert_eq!(layout.help, None);
    }

    #[test]
    fn dock_layout_puts_the_search_bar_at_the_bottom_in_search_mode() {
        let area = Rect {
            x: 0,
            y: 0,
            width: 30,
            height: 40,
        };

        let layout = dock_layout(area, false, InputMode::Search);

        assert_eq!(layout.search.height, SEARCH_BAR_ROWS);
        assert_eq!(layout.search.y, 40 - SEARCH_BAR_ROWS);
        assert_eq!(layout.sessions.height, 40 - SEARCH_BAR_ROWS);
        assert_eq!(layout.sessions.y, 0);
    }

    #[test]
    fn dock_layout_gives_help_the_rows_below_the_list() {
        let area = Rect {
            x: 0,
            y: 0,
            width: 30,
            height: 40,
        };

        let layout = dock_layout(area, true, InputMode::Keys);
        let help = layout.help.expect("help area");

        assert_eq!(help.height, HELP_LINE_COUNT);
        assert_eq!(layout.sessions.height, 40 - HELP_LINE_COUNT);
        assert_eq!(help.y, layout.sessions.height);
    }
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cargo test --lib ui::layout`
Expected: FAIL — `cannot find function dock_layout in this scope`.

- [ ] **Step 3: Write the implementation**

Append to the implementation part of `src/ui/layout.rs`:

```rust
/// Geometry for the docked sidebar: the pane is the list. No modal inset,
/// because there is no border to sit inside, and no preview, because the work
/// pane beside the dock is the thing a preview would have been showing.
///
/// Row order matches the popup so the two surfaces feel the same: list on top,
/// help below it, search prompt on the bottom row.
pub(crate) fn dock_layout(area: Rect, show_help: bool, input: InputMode) -> SwitcherLayout {
    let search_height = if matches!(input, InputMode::Search) {
        area.height.min(SEARCH_BAR_ROWS)
    } else {
        0
    };
    let body_height = area.height.saturating_sub(search_height);
    let help_height = if show_help {
        HELP_LINE_COUNT.min(body_height)
    } else {
        0
    };

    let sessions = Rect {
        height: body_height.saturating_sub(help_height),
        ..area
    };
    let help = (help_height > 0).then_some(Rect {
        y: area.y.saturating_add(sessions.height),
        height: help_height,
        ..area
    });
    let search = Rect {
        y: area.y.saturating_add(body_height),
        height: search_height,
        ..area
    };

    SwitcherLayout {
        list_overlay: area,
        search,
        sessions,
        help,
        preview: Rect {
            x: area.x,
            y: area.y,
            width: 0,
            height: 0,
        },
    }
}
```

Add to `src/ui/render.rs`, above `draw`:

```rust
/// Which host the switcher is rendering into. The popup owns the whole screen
/// and draws a modal frame over it; the dock is one pane beside the work you
/// are doing and draws none of that.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum Surface {
    Popup,
    Dock,
}
```

- [ ] **Step 4: Run tests and clippy**

Run: `cargo test --lib ui::layout && cargo clippy --all-targets 2>&1 | grep '^warning' | grep -vc 'generated'`
Expected: 3 new tests PASS, clippy prints 1.

`Surface` has no consumer until Task 4. If clippy reports it dead, add `#[allow(dead_code)]` with a comment naming Task 4 — that is this file's existing convention — and remove it in Task 4.

- [ ] **Step 5: Commit**

```bash
cd ~/Developer/tmux-plugins/tmux-agent-switcher
git add src/ui/layout.rs src/ui/render.rs
git commit -m "feat(ui): add the dock's chrome-free layout"
```

---

### Task 2: Click-to-row resolution

**Files:**
- Modify: `src/ui/sections.rs` (append `row_at` and its tests)

**Interfaces:**
- Consumes: `section_heights(body: Rect) -> (Rect, Option<Rect>)`, `SectionFocus`, both in `sections.rs`.
- Produces: `pub(crate) enum ClickTarget { Row { section: SectionFocus, index: usize }, Section(SectionFocus), None }` and `pub(crate) fn row_at(body: Rect, click_y: u16, sessions_len: usize, sessions_offset: usize, agents_len: usize, agents_offset: usize) -> ClickTarget`.

The two `offset` arguments are each pane's scroll offset (`Pane::offset`), so a click resolves to the right item in a scrolled section rather than to its screen position.

- [ ] **Step 1: Write the failing tests**

Append inside `mod tests` in `src/ui/sections.rs`:

```rust
    /// body(20) splits into Sessions rows 0..10 and Agents rows 10..20, each
    /// with a title on its first row.
    #[test]
    fn a_click_on_a_row_resolves_to_that_row() {
        let area = body(20);

        // Sessions title is y=0; its first row is y=1.
        assert_eq!(
            row_at(area, 1, 5, 0, 3, 0),
            ClickTarget::Row {
                section: SectionFocus::Sessions,
                index: 0
            }
        );
        assert_eq!(
            row_at(area, 3, 5, 0, 3, 0),
            ClickTarget::Row {
                section: SectionFocus::Sessions,
                index: 2
            }
        );
        // Agents starts at y=10; its title is y=10, first row y=11.
        assert_eq!(
            row_at(area, 11, 5, 0, 3, 0),
            ClickTarget::Row {
                section: SectionFocus::Agents,
                index: 0
            }
        );
    }

    /// Clicking a title focuses that section without moving its cursor —
    /// clicking a heading should not teleport you to a window.
    #[test]
    fn a_click_on_a_title_focuses_without_selecting() {
        let area = body(20);

        assert_eq!(row_at(area, 0, 5, 0, 3, 0), ClickTarget::Section(SectionFocus::Sessions));
        assert_eq!(row_at(area, 10, 5, 0, 3, 0), ClickTarget::Section(SectionFocus::Agents));
    }

    /// Empty space past the last row is still that section, but selects nothing.
    #[test]
    fn a_click_past_the_last_row_focuses_the_section_only() {
        let area = body(20);

        // Sessions holds 2 rows: y=1 and y=2. y=5 is past them.
        assert_eq!(row_at(area, 5, 2, 0, 3, 0), ClickTarget::Section(SectionFocus::Sessions));
        // Agents holds 1 row at y=11. y=15 is past it.
        assert_eq!(row_at(area, 15, 2, 0, 1, 0), ClickTarget::Section(SectionFocus::Agents));
    }

    /// A scrolled section resolves through its offset: the first visible row is
    /// item `offset`, not item 0.
    #[test]
    fn a_click_in_a_scrolled_section_resolves_through_its_offset() {
        let area = body(20);

        assert_eq!(
            row_at(area, 1, 40, 12, 3, 0),
            ClickTarget::Row {
                section: SectionFocus::Sessions,
                index: 12
            }
        );
        assert_eq!(
            row_at(area, 12, 40, 12, 30, 7),
            ClickTarget::Row {
                section: SectionFocus::Agents,
                index: 8
            }
        );
    }

    /// A body too short to split has no Agents section to click into.
    #[test]
    fn a_click_in_an_unsplit_body_can_only_hit_sessions() {
        let area = body(3);

        assert_eq!(
            row_at(area, 1, 5, 0, 3, 0),
            ClickTarget::Row {
                section: SectionFocus::Sessions,
                index: 0
            }
        );
        assert_eq!(row_at(area, 99, 5, 0, 3, 0), ClickTarget::None);
    }
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cargo test --lib ui::sections`
Expected: FAIL — `cannot find function row_at in this scope`.

- [ ] **Step 3: Write the implementation**

Append to the implementation part of `src/ui/sections.rs`:

```rust
/// What a click landed on.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum ClickTarget {
    /// A row: focus that section and select item `index`.
    Row {
        section: SectionFocus,
        index: usize,
    },
    /// A title or the empty space below the last row: focus the section, select
    /// nothing. Clicking a heading or a gap should not move you anywhere.
    Section(SectionFocus),
    /// Outside both sections.
    None,
}

/// Resolves a click's row within the body to a section and item index, using
/// the same split and the same scroll offsets the renderer used to draw it.
pub(crate) fn row_at(
    body: Rect,
    click_y: u16,
    sessions_len: usize,
    sessions_offset: usize,
    agents_len: usize,
    agents_offset: usize,
) -> ClickTarget {
    let (sessions_area, agents_area) = section_heights(body);

    if let Some(target) = hit(sessions_area, click_y, sessions_len, sessions_offset) {
        return match target {
            Some(index) => ClickTarget::Row {
                section: SectionFocus::Sessions,
                index,
            },
            None => ClickTarget::Section(SectionFocus::Sessions),
        };
    }

    let Some(agents_area) = agents_area else {
        return ClickTarget::None;
    };
    match hit(agents_area, click_y, agents_len, agents_offset) {
        Some(Some(index)) => ClickTarget::Row {
            section: SectionFocus::Agents,
            index,
        },
        Some(None) => ClickTarget::Section(SectionFocus::Agents),
        None => ClickTarget::None,
    }
}

/// `None` when the click is outside this section; `Some(None)` when it is on
/// the title or past the last row; `Some(Some(index))` when it is on a row.
fn hit(area: Rect, click_y: u16, len: usize, offset: usize) -> Option<Option<usize>> {
    if area.height == 0 || click_y < area.y || click_y >= area.y.saturating_add(area.height) {
        return None;
    }
    // Row 0 of the section is its title.
    let Some(row) = click_y.checked_sub(area.y).filter(|row| *row > 0) else {
        return Some(None);
    };
    let index = offset.saturating_add(usize::from(row - 1));
    Some((index < len).then_some(index))
}
```

- [ ] **Step 4: Run tests and clippy**

Run: `cargo test --lib ui::sections && cargo clippy --all-targets 2>&1 | grep '^warning' | grep -vc 'generated'`
Expected: 5 new tests PASS, clippy prints 1. Add `#[allow(dead_code)]` with a comment naming Task 3 if clippy reports these unused; remove it in Task 3.

- [ ] **Step 5: Commit**

```bash
git add src/ui/sections.rs
git commit -m "feat(ui): resolve a click's row within the sections"
```

---

### Task 3: Mouse clicks select

**Files:**
- Modify: `src/ui/mod.rs` — `handle_mouse` (currently at line 562) and its call site in `run_tui_loop` (currently line 1182)

**Interfaces:**
- Consumes: `row_at`, `ClickTarget`, `SectionFocus` (Task 2); `keep_sections_visible(ui, terminal_size)` and `switcher_layout_for_input`, both already in `mod.rs`.
- Produces: `handle_mouse(&mut self, mouse: MouseEvent, navigation_height: u16, terminal_size: Rect) -> Option<Option<SwitcherAction>>` — same return contract as `handle_key`: `Some(..)` closes the switcher with that outcome, `None` keeps it open.

- [ ] **Step 1: Write the failing tests**

Append to `mod tests` in `src/ui/mod.rs`:

```rust
    fn click(column: u16, row: u16) -> crossterm::event::MouseEvent {
        crossterm::event::MouseEvent {
            kind: MouseEventKind::Down(crossterm::event::MouseButton::Left),
            column,
            row,
            modifiers: KeyModifiers::empty(),
        }
    }

    #[test]
    fn clicking_a_session_row_selects_that_session() {
        let mut ui = ui_with(three_sessions());
        let body = sections_body(&ui);

        // Sessions title is the section's first row; the first row of content
        // is the one below it.
        let result = ui.handle_mouse(click(2, body.y + 2), 40, size());

        assert_eq!(ui.focus, SectionFocus::Sessions);
        assert_eq!(ui.sessions_pane.cursor, 1);
        assert_eq!(opened(&result), Some("bravo"));
    }

    #[test]
    fn clicking_a_title_focuses_the_section_without_selecting() {
        let mut agent = test_card("dotfiles", "0");
        agent.agent_status = AgentStatus {
            agent: Some(AgentKind::Claude),
            state: AgentState::Working,
            seen: true,
            run_started_at: None,
        };
        let mut ui = ui_with(vec![agent, test_card("gogo", "0")]);
        let body = sections_body(&ui);
        let (_, agents_area) = section_heights(body);
        let agents_area = agents_area.expect("agents section");

        let result = ui.handle_mouse(click(2, agents_area.y), 40, size());

        assert_eq!(ui.focus, SectionFocus::Agents);
        assert!(result.is_none(), "a title click must not select");
    }

    #[test]
    fn the_scroll_wheel_still_moves_the_focused_section() {
        let mut ui = ui_with(three_sessions());

        let mut wheel = click(2, 2);
        wheel.kind = MouseEventKind::ScrollDown;
        let result = ui.handle_mouse(wheel, 40, size());

        assert_eq!(ui.sessions_pane.cursor, 1);
        assert!(result.is_none());
    }
```

Add this helper beside `ui_with` in the same test module:

```rust
    /// The body rect the renderer would hand the sections for this UI.
    fn sections_body(ui: &SwitcherUi) -> Rect {
        switcher_layout_for_input(
            size(),
            ui.show_help,
            ui.view,
            compact_lines(&ui.filtered).len(),
            ui.input,
        )
        .sessions
    }
```

Extend the test module's imports with `use crossterm::event::MouseButton;` if the compiler asks for it, and `use crate::ui::sections::section_heights;`.

- [ ] **Step 2: Run tests to verify they fail**

Run: `cargo test --lib ui::tests`
Expected: FAIL — `handle_mouse` takes 2 arguments but 3 were supplied.

- [ ] **Step 3: Write the implementation**

Replace `handle_mouse` in `src/ui/mod.rs`:

```rust
    /// Feeds one mouse event into the switcher. Same contract as
    /// [`SwitcherUi::handle_key`]: `Some(..)` closes with that outcome, `None`
    /// keeps it open.
    ///
    /// tmux's default `MouseDown1Pane` binding is
    /// `select-pane -t = ; send -M`, so a single click both focuses the pane
    /// and arrives here — clicking a row is one action, not two.
    fn handle_mouse(
        &mut self,
        mouse: MouseEvent,
        navigation_height: u16,
        terminal_size: Rect,
    ) -> Option<Option<SwitcherAction>> {
        self.numbered_input.clear();

        if let Some(direction) = match mouse.kind {
            MouseEventKind::ScrollDown => Some(Direction::Down),
            MouseEventKind::ScrollUp => Some(Direction::Up),
            _ => None,
        } {
            if self.uses_sections() {
                self.move_focused_pane(direction);
            } else {
                move_compact_selection(
                    &mut self.state,
                    &self.filtered,
                    direction,
                    navigation_height,
                );
            }
            return None;
        }

        if !matches!(mouse.kind, MouseEventKind::Down(MouseButton::Left)) || !self.uses_sections() {
            return None;
        }

        let body = switcher_layout_for_input(
            terminal_size,
            self.show_help,
            self.view,
            compact_lines(&self.filtered).len(),
            self.input,
        )
        .sessions;

        match row_at(
            body,
            mouse.row,
            self.sessions_pane.items().len(),
            self.sessions_pane.offset,
            self.agents_pane.items().len(),
            self.agents_pane.offset,
        ) {
            ClickTarget::Row { section, index } => {
                self.focus = section;
                self.focused_pane_mut().cursor = index;
                self.select_target()
            }
            ClickTarget::Section(section) => {
                self.focus = section;
                None
            }
            ClickTarget::None => None,
        }
    }
```

Update the call site in `run_tui_loop`:

```rust
            Event::Mouse(mouse) if ui.prompt.is_none() => {
                let navigation_height = ui.navigation_height(terminal.size()?);
                if let Some(result) = ui.handle_mouse(mouse, navigation_height, terminal.size()?) {
                    return Ok(result);
                }
            }
```

Extend the crossterm import in `src/ui/mod.rs` with `MouseButton` and `MouseEvent` alongside the existing `MouseEventKind`.

- [ ] **Step 4: Run tests and clippy**

Run: `cargo test && cargo clippy --all-targets 2>&1 | grep '^warning' | grep -vc 'generated'`
Expected: all PASS, clippy prints 1. Remove any `#[allow(dead_code)]` Task 2 added to `row_at`/`ClickTarget`.

- [ ] **Step 5: Commit**

```bash
git add src/ui/mod.rs src/ui/sections.rs
git commit -m "feat(ui): select the row under a left click"
```

---

### Task 4: Dock run mode

**Files:**
- Modify: `src/ui/mod.rs` — `run_tui`, `run_tui_loop`, the `Esc` arm (line ~610), the keys-mode `'q'` arm (line ~937)
- Modify: `src/ui/render.rs` — `draw`
- Modify: `src/lib.rs` — export `run_dock`

**Interfaces:**
- Consumes: `Surface` and `dock_layout` (Task 1); `execute_action(action: SwitcherAction) -> Result<()>` from `crate::tmux`.
- Produces: `pub fn run_dock(cards: Vec<WindowCard>) -> Result<()>`; `draw` gains a trailing `surface: Surface` parameter.

- [ ] **Step 1: Write the failing tests**

Append to `mod tests` in `src/ui/mod.rs`:

```rust
    /// The dock is not a modal — nothing typed inside it may tear down the
    /// pane, because that would collapse the window layout. `prefix + b` is
    /// the only way out, and it is a tmux binding, not a key this loop sees.
    #[test]
    fn q_and_esc_do_not_close_the_dock() {
        let mut ui = dock_ui(three_sessions());

        assert!(ui.handle_key(key(KeyCode::Char('q')), size()).is_none());
        assert!(ui.handle_key(key(KeyCode::Esc), size()).is_none());
    }

    /// They keep their useful half: Esc clears the query.
    #[test]
    fn esc_clears_the_query_in_the_dock() {
        let mut ui = dock_ui(three_sessions());
        ui.query = "brav".to_owned();
        ui.refilter(40);

        assert!(ui.handle_key(key(KeyCode::Esc), size()).is_none());

        assert!(ui.query.is_empty());
    }

    /// The popup keeps closing on both, unchanged.
    #[test]
    fn q_and_esc_still_close_the_popup() {
        let mut ui = ui_with(three_sessions());
        assert_eq!(ui.handle_key(key(KeyCode::Char('q')), size()), Some(None));

        let mut ui = ui_with(three_sessions());
        assert_eq!(ui.handle_key(key(KeyCode::Esc), size()), Some(None));
    }
```

Add this helper beside `ui_with`:

```rust
    fn dock_ui(cards: Vec<WindowCard>) -> SwitcherUi {
        let mut ui = SwitcherUi::with_settings(
            cards,
            None,
            size(),
            Some(HashSet::new()),
            ViewMode::Sidebar,
            InputMode::Keys,
        );
        ui.surface = Surface::Dock;
        ui
    }
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cargo test --lib ui::tests`
Expected: FAIL — `no field surface on type SwitcherUi`.

- [ ] **Step 3: Write the implementation**

Add `surface: Surface` to the `SwitcherUi` struct, initialised to `Surface::Popup` in `with_settings`.

Guard the two closing keys. In the `KeyCode::Esc` arm, replace the `return Some(None)` branch:

```rust
                if self.input != InputMode::Search || self.query.is_empty() {
                    // The dock is a pane, not a modal: closing it would kill the
                    // pane and collapse the window layout. `prefix + b` owns
                    // that. Esc keeps its other half — clearing the query — and
                    // otherwise hands focus back to the work pane.
                    if self.surface == Surface::Dock {
                        focus_work_pane();
                        return None;
                    }
                    return Some(None);
                }
```

In the keys-mode `'q'` arm:

```rust
            'q' => {
                if self.surface == Surface::Dock {
                    focus_work_pane();
                    return None;
                }
                return Some(None);
            }
```

Add the free function beside `persist_expanded`:

```rust
/// Hands the keyboard back to the pane the user was working in. `select-pane -l`
/// is the last-active pane, which is where they came from; the `:.+` fallback
/// covers a dock that has no last pane yet (nothing else was focused since it
/// opened). Best-effort — failing to move focus is not worth an error.
fn focus_work_pane() {
    if tmux_status(Command::new("tmux").args(["select-pane", "-l"])).is_err() {
        let _ = tmux_status(Command::new("tmux").args(["select-pane", "-t", ":.+"]));
    }
}
```

Give `run_tui_loop` a `surface: Surface` parameter, set `ui.surface = surface` after constructing it, and execute actions in place when docked. Replace the two `return Ok(result)` sites in the loop with:

```rust
                if let Some(result) = ui.handle_key(key, terminal.size()?) {
                    // The dock performs the switch and keeps running; the popup
                    // returns the action and tears down first.
                    if surface == Surface::Dock {
                        if let Some(action) = result {
                            let _ = execute_action(action);
                        }
                        continue;
                    }
                    return Ok(result);
                }
```

and the same shape for the mouse arm from Task 3.

Add the dock entry point beside `run_tui`:

```rust
/// Runs the switcher as a persistent pane. Unlike [`run_tui`] this never
/// returns an action for the caller to execute — a dock that exited on
/// selection would be the popup.
pub fn run_dock(cards: Vec<WindowCard>) -> Result<()> {
    force_color_output(true);
    let current_window_id = current_window_id();

    let mut stdout = io::stdout();
    enable_raw_mode()?;
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;
    let result = run_tui_loop(
        &mut terminal,
        cards,
        current_window_id.as_deref(),
        Surface::Dock,
    );
    disable_raw_mode()?;
    execute!(
        terminal.backend_mut(),
        DisableMouseCapture,
        LeaveAlternateScreen
    )?;
    terminal.show_cursor()?;
    result.map(|_| ())
}
```

`run_tui` passes `Surface::Popup`.

In `src/ui/render.rs`, give `draw` a trailing `surface: Surface` parameter and branch its chrome:

```rust
    let layout = match surface {
        Surface::Dock => dock_layout(frame.size(), show_help, input),
        Surface::Popup => switcher_layout_for_input(
            frame.size(),
            show_help,
            view,
            compact_lines(sessions).len(),
            input,
        ),
    };

    if surface == Surface::Popup {
        render_selected_preview(frame, layout.preview, preview);
        frame.render_widget(Clear, layout.list_overlay);
        frame.render_widget(
            Block::default()
                .borders(Borders::ALL)
                .style(Style::default().fg(Color::DarkGray)),
            layout.list_overlay,
        );
        render_modal_top_bar(frame, layout.list_overlay);
    }
```

The rest of `draw` is unchanged. Pass `ui.surface` from both `terminal.draw` closures, and `Surface::Popup` from the existing render tests.

**Fix the click geometry.** Task 3 resolved clicks against
`switcher_layout_for_input(...).sessions`, because the dock did not exist yet.
The dock's body comes from `dock_layout`, and the two differ by the modal
inset — leaving this alone makes every click in the dock land two rows off.
In `handle_mouse`, replace the `let body = switcher_layout_for_input(...)`
block with the same branch `draw` now uses:

```rust
        let body = match self.surface {
            Surface::Dock => dock_layout(terminal_size, self.show_help, self.input),
            Surface::Popup => switcher_layout_for_input(
                terminal_size,
                self.show_help,
                self.view,
                compact_lines(&self.filtered).len(),
                self.input,
            ),
        }
        .sessions;
```

Add a test pinning it, so the two surfaces cannot drift apart again:

```rust
    /// The dock has no modal inset, so its rows sit higher than the popup's.
    /// Resolving a dock click against the popup's geometry silently selects the
    /// wrong row.
    #[test]
    fn a_dock_click_resolves_against_the_dock_geometry() {
        let mut ui = dock_ui(three_sessions());
        let body = dock_layout(size(), ui.show_help, ui.input).sessions;

        let result = ui.handle_mouse(click(2, body.y + 1), 40, size());

        assert_eq!(ui.sessions_pane.cursor, 0);
        assert_eq!(opened(&result), Some("alpha"));
    }
```

`keep_sections_visible` has the same split — check whether it derives its body
from `switcher_layout_for_input` and give it the same branch if so, or the
dock's scrolling will disagree with its rendering by the same two rows.

Export from `src/lib.rs`: `pub use ui::run_dock;`.

- [ ] **Step 4: Run tests and clippy**

Run: `cargo test && cargo clippy --all-targets 2>&1 | grep '^warning' | grep -vc 'generated'`
Expected: all PASS, clippy prints 1. Remove the `#[allow(dead_code)]` Task 1 added to `Surface`.

- [ ] **Step 5: Commit**

```bash
git add src/ui/mod.rs src/ui/render.rs src/lib.rs
git commit -m "feat(ui): run the switcher as a persistent dock"
```

---

### Task 5: tmux argument vectors

**Files:**
- Create: `src/dock.rs`
- Modify: `src/lib.rs` (add `mod dock;`)

**Interfaces:**
- Consumes: nothing.
- Produces, all in `dock`:
  - `pub(crate) const DOCK_PANE_OPTION: &str = "@tmux_agent_switcher_dock_pane";`
  - `pub(crate) const DOCK_MOVING_OPTION: &str = "@tmux_agent_switcher_dock_moving";`
  - `pub(crate) const DOCK_LAYOUT_OPTION: &str = "@tmux_agent_switcher_dock_layout";`
  - `pub(crate) const DEFAULT_DOCK_WIDTH: u16 = 30;`
  - `pub(crate) fn split_args(width: u16, exe: &str) -> Vec<String>`
  - `pub(crate) fn move_args(width: u16, dock_pane: &str, target_pane: &str) -> Vec<String>`
  - `pub(crate) fn restore_layout_args(window_id: &str, layout: &str) -> Vec<String>`

- [ ] **Step 1: Write the failing tests**

Create `src/dock.rs` with only the test module:

```rust
//! The docked sidebar's tmux orchestration: opening it, carrying it into
//! whatever window becomes active, and closing it again.
//!
//! The argument vectors are built by pure functions so the flags that matter —
//! the `-d` that stops a move from stealing focus, the `-b -h` that puts the
//! dock on the left — are pinned by tests rather than by a shell script nobody
//! re-reads.

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn split_puts_the_dock_left_without_taking_focus() {
        let args = split_args(30, "/opt/bin/tmux-agent-switcher");

        assert_eq!(
            args,
            vec![
                "split-window",
                "-b",
                "-h",
                "-d",
                "-l",
                "30",
                "-P",
                "-F",
                "#{pane_id}",
                "/opt/bin/tmux-agent-switcher dock",
            ]
        );
    }

    /// `-d` is the whole reason the follow hook does not have to re-select the
    /// pane the user was in: a move without it makes the dock active.
    #[test]
    fn move_keeps_the_dock_left_and_unfocused() {
        let args = move_args(30, "%7", "%12");

        assert_eq!(
            args,
            vec![
                "move-pane", "-b", "-h", "-d", "-l", "30", "-s", "%7", "-t", "%12",
            ]
        );
    }

    #[test]
    fn restore_layout_targets_the_window_it_belongs_to() {
        let args = restore_layout_args("@3", "b5e2,80x24,0,0,1");

        assert_eq!(
            args,
            vec!["select-layout", "-t", "@3", "b5e2,80x24,0,0,1"]
        );
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Add `mod dock;` to `src/lib.rs`, then run: `cargo test --lib dock`
Expected: FAIL — `cannot find function split_args in this scope`.

- [ ] **Step 3: Write the implementation**

Insert above the test module in `src/dock.rs`:

```rust
pub(crate) const DOCK_PANE_OPTION: &str = "@tmux_agent_switcher_dock_pane";
pub(crate) const DOCK_MOVING_OPTION: &str = "@tmux_agent_switcher_dock_moving";
pub(crate) const DOCK_LAYOUT_OPTION: &str = "@tmux_agent_switcher_dock_layout";
pub(crate) const DEFAULT_DOCK_WIDTH: u16 = 30;

/// Creates the dock pane on the left of the current window. `-d` leaves the
/// user in the pane they were working in; `-P -F` prints the new pane's id so
/// the caller can record it.
pub(crate) fn split_args(width: u16, exe: &str) -> Vec<String> {
    vec![
        "split-window".to_owned(),
        "-b".to_owned(),
        "-h".to_owned(),
        "-d".to_owned(),
        "-l".to_owned(),
        width.to_string(),
        "-P".to_owned(),
        "-F".to_owned(),
        "#{pane_id}".to_owned(),
        format!("{exe} dock"),
    ]
}

/// Carries the dock into the window holding `target_pane`. `-d` keeps the
/// moved pane inactive, so the follow hook never steals focus.
pub(crate) fn move_args(width: u16, dock_pane: &str, target_pane: &str) -> Vec<String> {
    vec![
        "move-pane".to_owned(),
        "-b".to_owned(),
        "-h".to_owned(),
        "-d".to_owned(),
        "-l".to_owned(),
        width.to_string(),
        "-s".to_owned(),
        dock_pane.to_owned(),
        "-t".to_owned(),
        target_pane.to_owned(),
    ]
}

/// Puts a window back the way it was before the dock arrived.
pub(crate) fn restore_layout_args(window_id: &str, layout: &str) -> Vec<String> {
    vec![
        "select-layout".to_owned(),
        "-t".to_owned(),
        window_id.to_owned(),
        layout.to_owned(),
    ]
}
```

- [ ] **Step 4: Run tests and clippy**

Run: `cargo test --lib dock && cargo clippy --all-targets 2>&1 | grep '^warning' | grep -vc 'generated'`
Expected: 3 tests PASS, clippy prints 1. Add `#[allow(dead_code)]` naming Task 6 if the constants read as unused; remove it in Task 6.

- [ ] **Step 5: Commit**

```bash
git add src/dock.rs src/lib.rs
git commit -m "feat(dock): build the tmux argument vectors for the dock"
```

---

### Task 6: Toggle and follow

**Files:**
- Modify: `src/dock.rs` (append)
- Modify: `src/lib.rs` (export `toggle` and `follow`)

**Interfaces:**
- Consumes: everything from Task 5; `tmux_output(args: &[&str]) -> Result<String>` and `tmux_status(cmd: &mut Command) -> Result<()>` from `crate::tmux`.
- Produces: `pub fn toggle() -> Result<()>` and `pub fn follow() -> Result<()>`.

- [ ] **Step 1: Write the failing test**

Append inside `mod tests` in `src/dock.rs`:

```rust
    #[test]
    fn a_window_narrower_than_two_docks_has_no_room() {
        // 30 columns of dock needs 30 more to work in.
        assert!(!has_room(59, 30));
        assert!(has_room(60, 30));
        assert!(has_room(200, 30));
    }

    #[test]
    fn the_configured_width_falls_back_to_the_default() {
        assert_eq!(parse_width(""), DEFAULT_DOCK_WIDTH);
        assert_eq!(parse_width("  "), DEFAULT_DOCK_WIDTH);
        assert_eq!(parse_width("not a number"), DEFAULT_DOCK_WIDTH);
        assert_eq!(parse_width("0"), DEFAULT_DOCK_WIDTH);
        assert_eq!(parse_width("42"), 42);
        assert_eq!(parse_width(" 42 "), 42);
    }
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cargo test --lib dock`
Expected: FAIL — `cannot find function has_room in this scope`.

- [ ] **Step 3: Write the implementation**

Append to `src/dock.rs`:

```rust
use std::process::Command;

use anyhow::Result;

use crate::tmux::{tmux_output, tmux_status};

/// A dock needs at least as much room again beside it, or it is a sidebar with
/// nothing to sit next to.
fn has_room(window_width: u16, dock_width: u16) -> bool {
    window_width >= dock_width.saturating_mul(2)
}

fn parse_width(value: &str) -> u16 {
    value
        .trim()
        .parse::<u16>()
        .ok()
        .filter(|width| *width > 0)
        .unwrap_or(DEFAULT_DOCK_WIDTH)
}

fn width() -> u16 {
    parse_width(&tmux_output(&["show-option", "-gqv", "@agent_switcher_dock_width"]).unwrap_or_default())
}

fn run(args: &[String]) -> Result<()> {
    tmux_status(Command::new("tmux").args(args))
}

fn option(args: &[&str]) -> String {
    tmux_output(args).unwrap_or_default().trim().to_owned()
}

/// The dock's pane id, or `None` when it is closed — which includes a recorded
/// pane that no longer exists, so a pane killed by hand does not wedge the
/// toggle.
fn dock_pane() -> Option<String> {
    let pane = option(&["show-option", "-gqv", DOCK_PANE_OPTION]);
    if pane.is_empty() {
        return None;
    }
    let alive = tmux_output(&["list-panes", "-a", "-F", "#{pane_id}"])
        .unwrap_or_default()
        .lines()
        .any(|line| line.trim() == pane);
    alive.then_some(pane)
}

fn save_layout(window_id: &str) {
    let layout = option(&["display-message", "-p", "-t", window_id, "#{window_layout}"]);
    let _ = run(&[
        "set-option".to_owned(),
        "-w".to_owned(),
        "-t".to_owned(),
        window_id.to_owned(),
        DOCK_LAYOUT_OPTION.to_owned(),
        layout,
    ]);
}

/// Puts `window_id` back the way it was and forgets the saved layout. Ignores
/// failure: if panes were created or destroyed while the dock was there the
/// saved string no longer matches the pane set, and tmux's own arrangement is a
/// perfectly good outcome. Restoring geometry is a courtesy, not a guarantee
/// worth erroring over.
fn restore_layout(window_id: &str) {
    let layout = option(&[
        "show-option",
        "-wqv",
        "-t",
        window_id,
        DOCK_LAYOUT_OPTION,
    ]);
    if !layout.is_empty() {
        let _ = run(&restore_layout_args(window_id, &layout));
    }
    let _ = run(&[
        "set-option".to_owned(),
        "-w".to_owned(),
        "-u".to_owned(),
        "-t".to_owned(),
        window_id.to_owned(),
        DOCK_LAYOUT_OPTION.to_owned(),
    ]);
}

fn window_of(pane: &str) -> String {
    option(&["display-message", "-p", "-t", pane, "#{window_id}"])
}

/// `prefix + b`: opens the dock beside the current window, or closes it.
pub fn toggle() -> Result<()> {
    if let Some(pane) = dock_pane() {
        let host = window_of(&pane);
        run(&["kill-pane".to_owned(), "-t".to_owned(), pane])?;
        restore_layout(&host);
        let _ = run(&[
            "set-option".to_owned(),
            "-g".to_owned(),
            "-u".to_owned(),
            DOCK_PANE_OPTION.to_owned(),
        ]);
        return Ok(());
    }

    let dock_width = width();
    let window_width = option(&["display-message", "-p", "#{window_width}"])
        .parse::<u16>()
        .unwrap_or(0);
    if !has_room(window_width, dock_width) {
        let _ = run(&[
            "display-message".to_owned(),
            format!("agent-switcher: need {} columns for the dock", dock_width * 2),
        ]);
        return Ok(());
    }

    let host = option(&["display-message", "-p", "#{window_id}"]);
    save_layout(&host);

    let exe = std::env::current_exe()?.to_string_lossy().into_owned();
    let pane = tmux_output(
        &split_args(dock_width, &exe)
            .iter()
            .map(String::as_str)
            .collect::<Vec<_>>(),
    )?
    .trim()
    .to_owned();

    run(&[
        "set-option".to_owned(),
        "-g".to_owned(),
        DOCK_PANE_OPTION.to_owned(),
        pane,
    ])
}

/// The follow hook: carries the dock into whatever window just became active.
pub fn follow() -> Result<()> {
    let Some(pane) = dock_pane() else {
        // Nothing to follow with. Clear a stale recording so the next toggle
        // opens cleanly rather than trying to kill a pane that is gone.
        let _ = run(&[
            "set-option".to_owned(),
            "-g".to_owned(),
            "-u".to_owned(),
            DOCK_PANE_OPTION.to_owned(),
        ]);
        return Ok(());
    };

    // `move-pane` changes the active window and re-fires the hooks that called
    // us. Without this guard the second call moves the dock back.
    if !option(&["show-option", "-gqv", DOCK_MOVING_OPTION]).is_empty() {
        return Ok(());
    }

    let current = option(&["display-message", "-p", "#{window_id}"]);
    let host = window_of(&pane);
    if current.is_empty() || current == host {
        return Ok(());
    }

    run(&[
        "set-option".to_owned(),
        "-g".to_owned(),
        DOCK_MOVING_OPTION.to_owned(),
        "1".to_owned(),
    ])?;

    save_layout(&current);
    let target = option(&["display-message", "-p", "-t", &current, "#{pane_id}"]);
    let moved = run(&move_args(width(), &pane, &target));
    restore_layout(&host);

    let _ = run(&[
        "set-option".to_owned(),
        "-g".to_owned(),
        "-u".to_owned(),
        DOCK_MOVING_OPTION.to_owned(),
    ]);
    moved
}
```

Export from `src/lib.rs`: `pub use dock::{follow as dock_follow, toggle as dock_toggle};`.

- [ ] **Step 4: Run tests and clippy**

Run: `cargo test && cargo clippy --all-targets 2>&1 | grep '^warning' | grep -vc 'generated'`
Expected: all PASS, clippy prints 1. Remove any `#[allow(dead_code)]` from Task 5.

- [ ] **Step 5: Commit**

```bash
git add src/dock.rs src/lib.rs
git commit -m "feat(dock): open, follow and close the docked sidebar"
```

---

### Task 7: Wire it into tmux

**Files:**
- Modify: `src/main.rs`
- Modify: `tmux-agent-switcher.tmux`

**Interfaces:**
- Consumes: `run_dock`, `dock_toggle`, `dock_follow`, `load_cards`.
- Produces: the `dock`, `dock-toggle` and `dock-follow` subcommands, and the tmux binding plus hooks.

- [ ] **Step 1: Write the implementation**

Replace the dispatch in `src/main.rs`:

```rust
use anyhow::Result;
use tmux_agent_switcher::{
    dock_follow, dock_toggle, execute_action, load_cards, run_dock, run_status_daemon, run_tui,
};

fn main() -> Result<()> {
    match std::env::args().nth(1).as_deref() {
        Some("status-daemon") => return run_status_daemon(),
        Some("dock") => return run_dock(load_cards()?),
        Some("dock-toggle") => return dock_toggle(),
        Some("dock-follow") => return dock_follow(),
        _ => {}
    }

    if let Some(action) = run_tui(load_cards()?)? {
        execute_action(action)?;
    }

    Ok(())
}
```

Append to `tmux-agent-switcher.tmux`, after the existing key binding block:

```bash
# --- docked sidebar -------------------------------------------------------
# A pane, not a popup: it stays while you work and follows you between windows.
dock_key="$(tmux_option @agent_switcher_dock_key b)"
LAUNCHER="$CURRENT_DIR/bin/tmux-agent-switcher"

if [[ -n "$dock_key" ]]; then
  tmux bind-key "$dock_key" run-shell -b "$LAUNCHER dock-toggle"
fi

# Hooks are arrays. Writing at a reserved index is idempotent across the config
# reloads that re-run this file, and leaves any other plugin's entry at another
# index alone — a plain `set-hook -g` would replace it silently.
#
# `session-window-changed` covers prefix+n, select-window and tree mode;
# `client-session-changed` covers session switches. There is no
# `after-switch-client` hook in tmux, so that pair is the whole surface.
tmux set-hook -g "session-window-changed[50]" "run-shell -b '$LAUNCHER dock-follow'"
tmux set-hook -g "client-session-changed[50]" "run-shell -b '$LAUNCHER dock-follow'"
```

- [ ] **Step 2: Verify it builds and the suite still passes**

Run: `bash -n tmux-agent-switcher.tmux && cargo test && cargo clippy --all-targets 2>&1 | grep '^warning' | grep -vc 'generated' && cargo build --release`
Expected: syntax OK, all tests PASS, clippy prints 1, release builds.

- [ ] **Step 3: Commit**

```bash
git add src/main.rs tmux-agent-switcher.tmux
git commit -m "feat(dock): bind prefix+b and install the follow hooks"
```

- [ ] **Step 4: Manual verification**

The hook behaviour is tmux orchestration and cannot be unit-tested. Install the branch into the live TPM clone and work this checklist, recording the result of each line:

```bash
cd ~/.config/tmux/plugins/tmux-agent-switcher
git fetch origin && git checkout <branch> && cargo build --release
tmux source-file ~/.config/tmux/tmux.conf
```

1. `prefix + b` in a single-pane window — dock appears on the left, focus stays in the work pane.
2. `prefix + b` again — dock closes, window returns to one full-width pane.
3. Open it in a window that already has two panes, close it — the original split geometry comes back.
4. With the dock open, `prefix + n` — the dock arrives in the next window and focus is still in the work pane, not the dock.
5. `C-j` to another session — the dock follows across the session boundary.
6. Click a session row — it expands. Click a window row — that window is selected and focus is in it.
7. Click a section title — focus moves to that section, nothing is selected.
8. Hold `prefix + n` through several windows quickly — no doubled dock, no flicker that outlasts the switch, no window left with a stray empty pane.
9. Press `q` and `Esc` in the dock — it stays open and focus returns to the work pane.
10. `kill-pane` the dock directly, then `prefix + b` — a fresh dock opens rather than an error.
11. Detach and reattach with the dock open — it is still there and still follows.
12. Open the `C-n` popup while the dock is open — the popup behaves exactly as before.

- [ ] **Step 5: Commit any fixes the checklist turns up**

Each fix gets its own commit describing the checklist line that caught it.

---

## Self-review

**Spec coverage.** §4 layout → Task 1. §5 mechanism (options, open/follow/close, the three hazards) → Tasks 5, 6. §6 run modes (no exit on selection, no preview, `Esc`/`q` semantics) → Task 4. §7 mouse → Tasks 2, 3. §8 selecting → Task 3 via the existing `select_target`/`execute_action`. §9 testing, including the manual checklist → every task's Step 4, plus Task 7 Step 4. §10 risks → the follow rule is confined to `dock::follow`, so the fallback to sidebar-initiated moves is a change in one function. §11 out of scope → no tasks, correctly.

**Placeholders.** None.

**Type consistency.** `Surface` (Task 1) is used in Tasks 3 and 4. `ClickTarget`/`row_at` (Task 2) are consumed in Task 3 with the same six-argument signature. `split_args`/`move_args`/`restore_layout_args` and the four constants (Task 5) are consumed in Task 6 unchanged. `run_dock`/`dock_toggle`/`dock_follow` (Tasks 4, 6) are consumed in Task 7 under those exact names.

**Known gap, deliberate.** `handle_mouse` resolves clicks against `switcher_layout_for_input(...).sessions`, which is the popup's geometry. In the dock the body comes from `dock_layout`. Task 3 lands before the dock exists, so it uses the popup's layout; **Task 4 must switch that call to the same `match surface` used in `draw`**, or clicks in the dock will resolve two rows off. This is called out again in Task 4's Step 3.
