# Migration Status

This file tracks the staged AutoHotkey v2 migration for this fork.

## Status summary

| Component | Status | Notes |
|---|---|---|
| `AHK_V2_MIGRATION.md` | Started | Roadmap published. |
| `MIGRATION_STATUS.md` | Started | Status tracker published. |
| `AeroZoom.ahk` root launcher | v2 initial pass | Root launcher now uses AutoHotkey v2 syntax and dispatches to existing compiled engine executables. Needs runtime smoke test on Windows. |
| `Data/AeroZoom_MouseL.ahk` | v1 legacy | Large engine script; do not one-shot convert. |
| `Data/AeroZoom_Ctrl.ahk` | v1 legacy | Similar structure to MouseL; candidate for shared extraction. |
| Other `Data/AeroZoom_*` modifier scripts | v1 legacy | Inventory still required. |
| Tray menu | v1 legacy | Uses legacy `Menu` command style. |
| GUI panel | v1 legacy | Needs object-style v2 conversion later. |
| Registry/settings layer | v1 legacy | Must be wrapped before broad conversion. |
| Magnifier integration | v1 legacy | High-risk behavior; test on current Windows 10/11. |
| ZoomIt integration | v1 legacy | Preserve as optional integration. |
| Packaging / compiled `.exe` layout | Pending | Must determine which executables are compiled AHK scripts versus external tools. |
| `scripts/Inventory-AhkAssets.ps1` | Added | Local inventory helper for listing `.ahk`, `.exe`, `.ini`, icon, and packaging assets. |

## Completed actions

1. Published the migration roadmap in `AHK_V2_MIGRATION.md`.
2. Published this status tracker.
3. Converted the root `AeroZoom.ahk` launcher to AutoHotkey v2 syntax.
4. Left `Data/*.ahk` and compiled `Data/*.exe` engine files untouched during the launcher pass.
5. Added a local inventory helper script to support Phase 1.

## Next actions

1. Runtime smoke-test `AeroZoom.ahk` with AutoHotkey v2 on Windows.
2. Run `scripts/Inventory-AhkAssets.ps1` from the repository root.
3. Commit the generated inventory output if useful.
4. Identify duplicated modifier scripts and shared code extraction candidates.
5. Start refactoring common initialization before full engine conversion.

## Rules for migration commits

- Keep each commit small and reversible.
- Do not delete user registry settings except through explicit reset behavior.
- Do not mark the whole app v2-compatible until the engine scripts are converted and tested.
- Add `#Requires AutoHotkey v2.0` only to files that are actually v2 syntax.
- Preserve working compiled v1 binaries until v2 replacements are compiled and tested.
