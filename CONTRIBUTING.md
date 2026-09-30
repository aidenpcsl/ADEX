# Contributing to ADEX

Thank you for helping make Windows administration more transparent and safer.

## Ground rules

- `ADEX.cmd` is the **only** runtime application. Do not add a mandatory executable, DLL, remote script, web API, installer, runtime package, telemetry component, service, scheduled agent, or startup entry.
- Do not copy code, command sequences, branding, UI text, assets, or documentation from another optimizer. Use primary Microsoft documentation and independent testing.
- Do not add tweaks for count. A change must be technically defensible, distinct, and useful.
- Never weaken Defender, SmartScreen, Windows Update, recovery, security mitigations, or boot security for purported performance.
- Do not add undocumented BCD/timer/scheduler folklore, generic service-disable groups, or “guaranteed” FPS/ping/latency claims.

## Development setup

A Windows test host is required to execute the runtime. Clone the repository, edit `ADEX.cmd` with a plain-text editor that preserves CMD syntax, and run the repository validation workflow or its commands locally. PowerShell is allowed only as inline logic embedded in `ADEX.cmd`; no `.ps1` runtime dependency may be introduced.

## Required content for every new operation

Each stable operation ID needs all of the following before review:

1. Unique, permanent ID using the appropriate prefix; do not renumber existing IDs.
2. Name, category, subcategory, purpose, exact change, rationale, risk label, supported Windows versions/builds, and hardware requirement.
3. Detection that reads the actual current state and identifies already-applied/reverted state where meaningful.
4. Compatibility, dependency, and conflict behavior.
5. Backup before mutation, a clear confirmation, apply logic with exit-code checking, and validation that does not claim success on failure.
6. A precise revert path restoring captured previous state whenever possible; explicitly document irreversibility otherwise.
7. Activity-log behavior and non-sensitive report impact.
8. A documentation update in `docs/tweaks.md`, compatibility/test updates, and a changelog entry for the eventual release.

## Batch quality requirements

- Use `set "NAME=value"` form and avoid unquoted paths.
- Account for CMD parsing, delayed expansion, nested parentheses, `ERRORLEVEL`, special characters, localized command output, and 32/64-bit registry implications.
- Prefer focused reusable labels over pasted command blocks.
- Native commands must have result checking. Do not treat mere process launch as success.
- Ensure a failed or unsupported operation logs failure/skipping and does not display validated success.
- Keep emitted diagnostic/report data minimal and avoid credentials or personal files.

## Testing and pull requests

Run through the matrix in [`tests/test-plan.md`](tests/test-plan.md), especially detection → backup → apply → validate → revert → validate for every reversible operation. Test at least supported Windows 10 and Windows 11 builds where feasible, an unelevated relaunch, cancellation, repeated runs, missing keys/services, and a failed native command path.

A pull request should explain the technical justification, OS/hardware scope, user-visible trade-offs, test machines/builds, and any remaining limitations. Small, reviewable changes are preferred. Maintainers may decline changes that are merely preference collections, duplicate current behavior, or reduce safety.
