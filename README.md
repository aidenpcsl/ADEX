# ADEX

**ADEX** is an original, offline-first Windows optimization, diagnostics, maintenance, and recovery assistant. Its complete runtime is a single file: [`ADEX.cmd`](ADEX.cmd). It invokes only native Windows utilities and inline local PowerShell; it does **not** download tools, run remote scripts, install services, add startup entries, or transmit telemetry.

> **Status: v1.1.0.** ADEX favors a smaller defensible library over a list of registry folklore. It makes no promises about FPS, ping, input latency, or benchmark gains.

## What it does

- Detects Windows edition/build, architecture, CPU, RAM, GPU, and elevation state.
- Provides a metadata-backed local library of **59** Windows operations across Windows, gaming, input, CPU/GPU, memory, storage, power, network, startup, services, scheduled tasks, UI, privacy, cleanup, diagnostics, and repair.
- Uses a consistent lifecycle: detect → compatibility check → describe → backup when meaningful → confirm → apply/run → validate → log.
- Backs up each registry value state and exports its containing key before an ADEX registry change. Power-plan, hibernation, and conservative service changes receive operation-specific backup records.
- Supplies profiles with a mandatory preview, an Undo Manager, local activity logging, system reports, native diagnostics, repair entry points, a read-only Windows Stutter Diagnostics report, and a native `winsat` disk measurement option.
- Avoids dangerous categories on purpose: no Defender/SmartScreen/Windows Update disabling, BCD/timer changes, `numproc`, “magic” memory settings, blanket service disabling, or remote downloads.

## Requirements and support

| Requirement | Detail |
|---|---|
| Operating system | Windows 10 (version 1903 or newer for the supported library) or Windows 11 |
| Privileges | Run as Administrator; ADEX offers a UAC relaunch if needed |
| Runtime dependencies | None beyond Windows built-ins: `reg`, `sc`, `schtasks`, `powercfg`, `DISM`, `SFC`, `netsh`, `ipconfig`, and PowerShell |
| Connectivity | Not required. A few explicit diagnostics/repair paths may use an existing network connection or configured Windows repair source. |
| Architecture | x64 and other Windows architectures supported by the included native operations, subject to individual compatibility checks |

Hardware-dependent settings such as Hardware-accelerated GPU scheduling are guarded by build requirements and described as requests to Windows; a compatible driver and restart remain necessary.

## Install and launch

1. Download a release ZIP and extract it to a user-writable local folder.
2. Right-click `ADEX.cmd` and choose **Run as administrator**, or launch it normally and accept the UAC relaunch.
3. Review each operation’s description, risk, current state, proposed state, backup method, validation method, dependencies, and conflicts before confirming.
4. Keep the generated `ADEX-data` folder beside `ADEX.cmd`; it contains logs, reversible-state records, registry exports, reports, and saved custom profiles.

No installer is necessary. Delete ADEX only after retaining any backups/reports you may need.

## Main experience

```text
ADEX 1.1.0 | Windows Optimization and Diagnostics
Windows : Windows 11 Pro [build 26100]
System  : AMD64 | CPU: ...
Memory  : 32 GB | GPU: ...
Admin   : YES | Data: ADEX-data next to this script

[1] Windows settings     [8] Network       [15] Diagnostics
[2] Gaming               [9] Startup       [16] Repair
[3] Input               [10] Services      [17] Backup and Restore Point
[4] CPU and GPU         [11] Scheduled tasks [18] Undo Manager
...                      [19] Profiles     [20] Search library
```

The dashboard values shown above are illustrative. ADEX always reads the actual local system and does not fabricate results.

## Library at a glance

The full stable ID list, current v1.1.0 metadata, expected behavior, and reversibility notes are in [docs/tweaks.md](docs/tweaks.md).

| Area | Purpose |
|---|---|
| Windows and UI | Conservative visual/background/activity preferences and Explorer usability |
| Gaming, input, CPU/GPU | Windows Game Mode/capture preferences, mouse/keyboard preference, graphics scheduling compatibility, and power-policy inspection |
| Memory and storage | Inspect memory/page file state, invoke Windows Memory Diagnostic, inspect TRIM/SMART/file system, and run native volume optimization |
| Power and network | Power-plan/hibernation management with backup, DNS/adapter/reachability diagnostics |
| Startup, services, tasks | Inventory startup/task sources; inspect services; only choose Manual or Automatic service startup after dependency review—never generic disable |
| Privacy and cleanup | Local privacy preferences and confirmed preview-based disposable-cache cleanup |
| Diagnostics and repair | Native integrity, events, drivers, battery, read-only stutter indicators, DISM, SFC, Winsock/TCP-IP, and explicitly confirmed firewall-policy repair |

## Safety model

ADEX labels each operation **SAFE**, **ADVANCED**, or **EXPERIMENTAL**. Labels communicate scope and reversibility, not a promise of a performance outcome.

- **SAFE** — read-only, information, or narrowly scoped user preference.
- **ADVANCED** — a meaningful preference/maintenance/repair action with a clear trade-off, extra confirmation, or altered feature behavior.
- **EXPERIMENTAL** — high-impact recovery action requiring explicit in-flow confirmation.

Registry operations preserve the original value’s existence, type, and value in `ADEX-data/undo-records.log`, while an exported `.reg` copy of the containing key is retained when that key already exists. If an ADEX-created key was absent, a transparent backup marker records that no export was possible. The Undo Manager restores *your captured value*, not an arbitrary Windows default. Cache cleanup and native diagnostics are intentionally not “undoable”; each is previewed and acknowledged as such.

A Windows restore point can be requested from **Backup and Restore Point**. It can help restore system settings, registry state, and drivers, but does not replace data backups and cannot guarantee recovery. Read [docs/safety.md](docs/safety.md) before making changes.

## Profiles

Profiles are curated and previewed before application:

- **SAFE** — selected UI/privacy/Game Mode preferences.
- **GAMING** — Game Mode plus capture/startup-panel preferences.
- **PERFORMANCE** — visual preference set plus High performance plan.
- **PRIVACY** — advertising, tailored-experience, suggested-content, feedback, and app-launch tracking preferences.
- **CLEANUP** — temp and shader-cache previews; each location retains its own destructive confirmation.
- **CUSTOM** — add/remove known IDs, save the list locally, preview, and apply.

There is deliberately no “apply every tweak” button.

## Backup, revert, and recovery

1. Prefer a Windows restore point before multiple advanced changes.
2. Use **Undo Manager** → **Undo one operation by ID** to restore the latest captured state for a reversible operation.
3. Use **Restore most recently applied profile** to attempt its captured operations in order.
4. Review `ADEX-data/logs/adex.log` and `ADEX-data/undo-records.log` if something fails.
5. Registry exports and task XML exports remain in `ADEX-data/backups` for manual inspection.

ADEX does not auto-delete original backup records. See [docs/troubleshooting.md](docs/troubleshooting.md).

## Reports, privacy, and measurements

Reports are stored locally under `ADEX-data/reports`. The system report intentionally contains the displayed OS/hardware summary and ADEX operation/log history, not a full `systeminfo` dump, passwords, credentials, or personal files. The network report can contain local network configuration; inspect it before sharing.

The optional `winsat disk -drive C` action captures Windows’ own output under present conditions. It does not claim that an ADEX setting caused a result or compare unlike runs.

## Aiden PC Services

> ADEX is an original Windows optimization project founded and developed by Aiden.

The Aiden PC Services community ecosystem is available for project updates, discussion, and support. These links are informational only; ADEX remains an offline-first standalone utility.

- **Website:** https://aidenpcsl.netlify.app
- **Creator GitHub:** https://github.com/aidenpcsl
- **YouTube:** https://youtube.com/@aidenpcsl
- **Instagram:** https://instagram.com/aidenpcsl
- **TikTok:** https://tiktok.com/@aidenpcsl
- **Facebook:** https://facebook.com/aidenpcsl
- **Discord:** `@aidenpcsl` — server: https://discord.gg/8WNCmAqXg
- **Project contact:** [aidenpcservices@gmail.com](mailto:aidenpcservices@gmail.com)

More detail is available in [Aiden PC Services](docs/community.md).

## Development

This repository is intentionally batch-first. `ADEX.cmd` is the **only** runtime file. Documentation, tests, and CI do not become runtime dependencies. See:

- [Architecture](docs/architecture.md)
- [Compatibility](docs/compatibility.md)
- [Development guide](docs/development.md)
- [Test plan](tests/test-plan.md)
- [Contributing guide](CONTRIBUTING.md)

## Contributing and security

Contributions require technical justification, version/build and hardware scope, risk classification, detection, backup, apply, validation, revert behavior where possible, and documentation. Read [CONTRIBUTING.md](CONTRIBUTING.md).

Do **not** open public issues for suspected vulnerabilities. See [SECURITY.md](SECURITY.md).

## License

ADEX is released under the [MIT License](LICENSE). No third-party runtime component is bundled.
