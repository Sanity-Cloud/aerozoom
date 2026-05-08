# AeroZoom AutoHotkey v2 Migration

This document is the working roadmap for converting this fork from legacy AutoHotkey v1 syntax to native AutoHotkey v2 syntax.

## Current state

AeroZoom is still primarily an AutoHotkey v1-era codebase. The root `AeroZoom.ahk` launcher is small and dispatches into compiled scripts under `Data/`. The large engine scripts under `Data/`, especially the modifier-specific scripts such as `AeroZoom_MouseL.ahk` and `AeroZoom_Ctrl.ahk`, contain the actual registry setup, tray menu, GUI panel, mouse hotkeys, Magnifier integration, ZoomIt integration, and custom hotkey logic.

The migration must be incremental. Do not convert the entire project in one mechanical pass.

## Strategic goal

Move AeroZoom to a native AutoHotkey v2 codebase while preserving:

- mouse-wheel zoom behavior
- Windows Magnifier integration
- ZoomIt integration
- AeroZoom panel behavior
- tray controls
- registry-backed settings
- custom hotkeys
- existing portable/installer layout where practical

## Branch strategy

Preferred branches:

| Branch | Purpose |
|---|---|
| `main` | Stable existing behavior |
| `ahk-v2-migration` | Long-running migration branch |
| `ahk-v2-launcher` | First small migration branch for the root launcher |

If direct commits to `main` are used, keep each commit small and reversible.

## Phase 1: Inventory and migration map

### Tasks

1. List all `.ahk`, `.ini`, `.exe`, helper, icon, and packaging files.
2. Identify which `.exe` files are compiled AutoHotkey scripts versus external binaries.
3. Map modifier variants:
   - Ctrl
   - Alt
   - Shift
   - Win
   - MouseL
   - MouseR
   - MouseM
   - MouseX1
   - MouseX2
4. Determine whether modifier scripts are duplicated copies or generated variants.
5. Mark shared logic that should be extracted before full v2 conversion.

### Deliverable

Update `MIGRATION_STATUS.md` with a full source inventory.

### Acceptance criteria

- Every `.ahk` file is listed.
- Every compiled `.exe` counterpart is accounted for.
- The root launcher behavior is documented.

## Phase 2: Convert the small root launcher first

### Objective

Convert `AeroZoom.ahk` to AutoHotkey v2 syntax without touching the large engine scripts.

This file is the safest initial conversion because it mainly:

- sets the working directory
- checks for the `Data` folder
- warns about WizMouse / Windows Media Center
- reads the selected modifier from the registry
- launches the selected compiled AeroZoom executable

### Required conversion patterns

| v1 pattern | v2 direction |
|---|---|
| `SetWorkingDir %A_ScriptDir%` | `SetWorkingDir(A_ScriptDir)` |
| `IfNotExist, path` | `if !DirExist(path)` / `if !FileExist(path)` |
| `RegRead,var,root,key,value` | `var := RegRead(key, value, default)` or wrapper |
| `RegWrite, type, root, key, value, data` | `RegWrite(data, type, key, value)` |
| `Process, Exist, name` | `ProcessExist(name)` |
| `MsgBox, options, title, text` | `MsgBox(text, title, options)` |
| `Run,"path",,` | `Run(target)` |
| `goto, x64` | function or structured branch |

### Acceptance criteria

- `AeroZoom.ahk` starts under AutoHotkey v2.
- It still launches the correct existing compiled executable.
- It still handles a missing `Data` folder.
- It still reads `HKCU\Software\WanderSick\AeroZoom\Modifier`.
- It does not require converting `Data/*.ahk` yet.

## Phase 3: Add compatibility guardrails

### Tasks

1. Add `#Requires AutoHotkey v2.0` only to files already converted.
2. Keep legacy `Data/*.ahk` files marked as v1 until converted.
3. Keep README wording clear that the migration is staged, not complete.
4. Maintain `MIGRATION_STATUS.md` as the authoritative status table.

### Acceptance criteria

- No user-facing ambiguity about partial migration.
- `main` remains usable.
- v2 work is traceable.

## Phase 4: Refactor before full conversion

### Objective

Reduce duplication in the large modifier scripts before converting them.

Likely extraction targets:

```text
Data/lib/
  az_registry.ahk
  az_os.ahk
  az_magnifier.ahk
  az_zoomit.ahk
  az_tray.ahk
  az_gui.ahk
  az_hotkeys.ahk
```

### Acceptance criteria

- Common initialization appears once.
- Modifier scripts become thinner.
- Behavior remains unchanged under AutoHotkey v1 during this refactor.
- The diff is mechanical and reviewable.

## Phase 5: Build a compatibility wrapper layer

### Objective

Move repeated command-style calls behind named helper functions before broad v2 conversion.

Example target functions:

```ahk
AZ_RegRead(key, name, default := "")
AZ_RegWrite(type, key, name, value)
AZ_Run(path, args := "", workingDir := "")
AZ_Msg(title, text, options := "")
AZ_ProcessExists(name)
AZ_KillProcess(name)
AZ_ShowPanel()
AZ_HidePanel()
AZ_ResetZoom()
```

### Acceptance criteria

- Registry access starts moving behind wrappers.
- Process calls start moving behind wrappers.
- Magnifier operations start moving behind wrappers.
- No behavior change yet.

## Phase 6: Port registry and settings layer

### Tasks

Convert:

- `RegRead`
- `RegWrite`
- `RegDelete`
- default-value initialization
- profile loading
- backup/export/import helpers

### Acceptance criteria

- Fresh install works.
- Existing registry settings migrate without reset.
- Missing registry keys use sane defaults.
- Profile switching still works.

## Phase 7: Port process/window integration

### Tasks

Convert:

- Magnifier launch/kill/hide/minimize
- ZoomIt launch/kill/hide/show
- Snipping Tool detection
- Paint/Calculator/WordPad launch
- process existence checks
- `WinWait`, `WinHide`, `WinShow`, `WinMinimize`, `WinActivate`

### Acceptance criteria

- Magnifier starts.
- Magnifier hides/minimizes correctly.
- Reset zoom works.
- ZoomIt still launches and exits correctly.
- No stuck hidden panel or orphan helper process.

## Phase 8: Port hotkeys

### Objective

Convert keyboard and mouse hotkeys to AutoHotkey v2 without losing mouse-chord behavior.

Priority tests:

- left + wheel up/down
- left + middle
- left + right
- middle hold
- XButton combinations
- Ctrl/Alt/Shift/Win modifier modes

### Acceptance criteria

- Mouse wheel zoom works.
- Reverse zoom works.
- Reset zoom works.
- Panel toggle works.
- Holding middle does not accidentally fire during normal clicking.
- Suspend/pause behavior works.

## Phase 9: Port GUI and tray menu

### Tasks

1. Convert tray menu to AutoHotkey v2 menu APIs.
2. Convert GUI creation to v2 object-style GUI.
3. Convert `GuiControl` updates.
4. Convert slider callbacks.
5. Convert panel positioning logic.
6. Convert transparency/border handling.

### Acceptance criteria

- Tray menu renders.
- Tray icon loads.
- Tray click / double-click behavior works.
- Panel opens near cursor.
- Sliders update registry and live state.
- Buttons invoke correct functions.

## Phase 10: Packaging and release

### Tasks

1. Identify current build process.
2. Determine whether compiled `Data/AeroZoom_*.exe` files need to be rebuilt from v2 scripts.
3. Add a v2 build script.
4. Package release artifacts.

### Acceptance criteria

- v2 scripts compile.
- Launcher runs compiled v2 files.
- Existing `Data` layout still works or is cleanly replaced.
- Release ZIP contains no obsolete v1 binaries unless intentionally retained.

## Risk register

| Risk | Severity | Mitigation |
|---|---:|---|
| Hotkey regressions | High | Convert one modifier mode first, preferably MouseL |
| GUI breakage | High | Port after hotkeys and registry are stable |
| Registry default mismatch | Medium | Add defaults wrapper and test fresh profile |
| Existing user settings reset accidentally | High | Never delete `HKCU\Software\wandersick\AeroZoom` except through explicit reset |
| Compiled `.exe` mismatch | High | Keep v1 binaries until v2 scripts compile cleanly |
| Windows Magnifier behavior differences | High | Test on current Windows 10/11 first |
| ZoomIt integration breakage | Medium | Gate ZoomIt functions behind explicit checks |
| One-shot migration too large to review | High | Use staged PRs |

## Testing checklist

### Startup

- Launch from root folder.
- Launch from wrong folder.
- Launch with missing `Data`.
- Launch with no registry settings.
- Launch with existing registry settings.
- Launch as standard user.
- Launch as admin.

### Core zoom

- Left + wheel up zooms in.
- Left + wheel down zooms out.
- Reverse zoom flips direction.
- Reset zoom returns to 100%.
- Magnifier starts if not running.
- Magnifier hides/minimizes correctly.

### Panel

- Left + right opens panel.
- Panel follows cursor.
- Buttons work.
- Sliders update values.
- Tray menu works.
- Pause/suspend works.

### Custom hotkeys

- Middle hold action.
- XButton actions.
- Ctrl/Alt/Shift/Win modifier modes.
- Custom command execution.
- PrintScreen enhancement.

### External tools

- ZoomIt present.
- ZoomIt missing.
- NirCmd present.
- NirCmd missing.
- Snipping Tool present.
- Snipping Tool missing.
