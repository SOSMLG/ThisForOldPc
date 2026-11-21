# ThisForOldPc - project instructions

Small, distro-agnostic i3 setup for old PCs and low-resource X11 desktops.
The default palette is Graphite Amber: graphite `#16181D`, surface `#202329`,
and amber `#E8A33D`.

## Entry points

- `install-i3.sh` detects the package manager, installs the package set and
  deploys configs from `configs/`.
- `verify.sh` is a read-only end-state check for deployed configs and commands.

## Conventions

- Run as a normal user. Privilege escalation lives in `install-i3.sh`:
  explicit `TFOP_PRIV`, then sudo, then doas. Do not add bare sudo calls.
- Keep `configs/` portable. No hard-coded usernames or home directories.
- Back up any existing config before replacing it. Re-running the installer
  must be safe.
- Optional tools (picom, zram-generator, TLP) may be absent on a release;
  warn and continue rather than failing the install.
- No systemd units or service calls.
