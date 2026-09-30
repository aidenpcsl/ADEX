# Changelog

All notable changes to ADEX are documented here. This project follows [Semantic Versioning](https://semver.org/).

## [1.1.0] - 2026-09-30

### Added
- `DIAG-0007` — **Windows Stutter Diagnostics**, a local read-only report covering current CPU/GPU-related indicators, RAM availability, disk activity, power plan, HAGS, gaming settings, GPU/driver details, startup indicators, background processes, and system configuration context.
- A timestamped stutter diagnostics report in `ADEX-data/reports` plus ADEX activity logging for the diagnostic request.

### Safety
- The diagnostic does not change registry values, drivers, services, power settings, startup entries, or gaming configuration. Its findings are indicators to investigate, not claims of an automatic stutter fix or root-cause proof.

## [1.0.0] - 2026-09-29

### Added
- Single-file `ADEX.cmd` runtime with local UAC elevation, system detection, categorized menus, static stable operation IDs, search, metadata display, profiles, custom profiles, logs, reports, integrity hash display, and configurable console color.
- A technically scoped v1 library of Windows settings, maintenance, diagnostics, repair, startup/service/task analysis, cleanup, and privacy operations.
- Registry value-state backups plus exported containing-key copies, power/hibernation/service backup records, Undo Manager, profile restoration attempt, and optional System Restore Point request.
- Preview-first profile application and explicit destructive cleanup confirmations.
- GitHub-ready safety, compatibility, development, test, contribution, and security documentation plus a lightweight Windows CI validation workflow.

### Changed
- Added a minimal official Aiden PC Services creator/community section to the README, documentation, and ADEX About screen. The official creator GitHub identity is `aidenpcsl`; the project contact is `aidenpcservices@gmail.com`.

### Fixed
- Canonicalized Windows and PowerShell path handling, made unknown Windows build detection fail safely, and rejected Windows Server installations from the supported client workflow.
- Reworked native action dispatch to avoid CMD parenthesized-block parsing around PowerShell code; corrected scheduled startup-task trigger inspection.
- Strengthened registry, hibernation, and service undo validation; surfaced cleanup deletion errors; and hardened report output creation.
- Added the transparent source/release audit record at `tests/final-production-audit.md`.

### Safety decisions
- No performance guarantees, no remote scripts or downloads, no telemetry, no installed agent, no BCD/timer changes, no security-product disabling, no blanket service disabling, and no automatic personal-file cleanup.

[1.0.0]: https://github.com/aidenpcsl/ADEX/releases/tag/v1.0.0

[1.1.0]: https://github.com/aidenpcsl/ADEX/releases/tag/v1.1.0
