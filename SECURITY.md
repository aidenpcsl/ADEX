# Security Policy

## Supported version

Security fixes are considered for the latest released `1.x` version. Because ADEX directly invokes administrative Windows utilities, reports should identify the exact release, Windows version/build, and the affected operation ID.

## Reporting a vulnerability

Please **do not** publish a suspected vulnerability in a public GitHub issue.

Use the repository’s private security-advisory reporting mechanism when available. If the project has published a dedicated security contact, use that channel instead. Include:

- A clear description of the issue and its impact.
- ADEX release/version and the SHA-256 of the local `ADEX.cmd` if practical.
- Windows edition, build, architecture, and whether the process was elevated.
- Exact menu path/operation ID and minimal reproduction steps.
- Relevant ADEX log lines with private paths, host names, adapter details, user names, tokens, keys, and credentials removed.
- Suggested remediation if available.

## Disclosure expectations

Give maintainers a reasonable opportunity to investigate and release a fix before public disclosure. Do not include secrets, personal data, malware, or destructive proof-of-concept payloads. ADEX will never ask reporters for passwords, credentials, or remote access.

## Scope notes

Operations that intentionally call Windows-native repair/reset tools can affect a local machine only after interactive confirmation. A safety concern includes command injection, unintended privilege escalation, unexpected deletion, incorrect restore behavior, unsafe default selection, or a misleading success/validation result.
