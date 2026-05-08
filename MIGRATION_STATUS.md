# Migration Status

This file tracks the staged AutoHotkey v2 migration for this fork.

## Status summary

| Component | Status | Notes |
|---|---|---|
| `AHK_V2_MIGRATION.md` | Started | Roadmap published. |
| `MIGRATION_STATUS.md` | Started | Status tracker published. |
| `AeroZoom.ahk` root launcher | Pending | First executable migration target. Convert to v2 before engine scripts. |
| `Data/AeroZoom_MouseL.ahk` | v1 legacy | Large engine script; do not one-shot convert. |
| `Data/AeroZoom_Ctrl.ahk` | v1 legacy | Similar structure to MouseL; candidate for shared extraction. |
| Other `Data/AeroZoom_*` modifier scripts | v1 legacy | Inventory still required. |
| Tray menu | v1 legacy | Uses legacy `Menu` command style. |
| GUI panel | v1 legacy | Needs object-style v2 conversion later. |
| Registry/settings layer | v1 legacy | Must be wrapped before broad conversion. |
| Magnifier integration | v1 legacy | High-risk behavior; test on current Windows 10/11. |
| ZoomIt integration | v1 legacy | Preserve as optional integration. |
| Packaging / compiled `.exe` layout | Pending | Must determine which executables are compiled AHK scripts versus external tools. |

## Next actions

1. Convert only the root `AeroZoom.ahk` launcher to AutoHotkey v2.
2. Keep `Data/*.ahk` and compiled `Data/*.exe` files untouched during the launcher pass.
3. Inventory every `.ahk` and `.exe` file under the repo.
4. Identify duplicated modifier scripts and shared code extraction candidates.
5. Start refactoring common initialization before full engine conversion.

## Rules for migration commits

- Keep each commit small and reversible.
- Do not delete user registry settings except through explicit reset behavior.
- Do not mark the whole app v2-compatible until the engine scripts are converted and tested.
- Add `#Requires AutoHotkey v2.0` only to files that are actually v2 syntax.
- Preserve working compiled v1 binaries until v2 replacements are compiled and tested.
