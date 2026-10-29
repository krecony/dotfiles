# Dotfiles repo

## Scope
Declarative config for:
- NixOS Hosts
    - nyx (thinkpad p14s gen 6)
    - zephyr (huawei laptop)
    - hermes (raspberry pi 3b+)
- HomeManager user environments
- custom packages and overrides
- secrets via `sops-nix`

## Structure
flake.nix — inputs, overlays, packages, NixOS/Home Manager outputs
flake.lock — lock file for flake versioning
hosts/ — per-host configs for NixOS
modules/ — reusable system, home, and service modules
pkgs/ — custom flake packages that overlay nixpkgs
lib/ — custom helpers
secrets.yaml, .sops.yaml — secret management
checks.nix — nix flake checks
devshell.nix — nix devshell

## Direction
This repository tries to create maximally secure configurations while preserving daily-driver level usability.
It makes use of the nix-mineral repository for extra hardening.
The main focus is the nyx host, other hosts should remain fully usable, however, they are not the main focus.
Dependencies should be minimised when possible, adding unnecessary bloat dependencies should be avoided if unused.
You should always verify if new solutions have not arised in the NixOS project as it is constantly evolving.

## Rules
- Prefer declarative setup over manual state.
- Prefer reusable modules over host-local one-off config.
- Keep host-specific exceptions only when truly host-specific.
- Make sure modules are host-agnostic.
- Inspect existing modules before creating new ones.
- Keep changes minimal and targeted.
- Do not commit secrets.
- After making changes evaluate the validity of the flake and changes by running:
    - `nix eval`
    - `nix flake check`
- Never push or rebuild, that is up to the users discretion
- Always ask before modyfing files motivating why your solutions are appropriate

## Running Executables
If a binary does not exist in the system path, e.g. `python`. Run it using a nix shell, for example:
```
nix-shell -p 'python313.withPackages (ps: with ps; [ numpy ])`
```

If a command requires sudo access prompt the user to provide the output of such a command, explaining why sudo is required and giving an explanation of the command.

## NixOS MCP
Use the `nixos` MCP server (`mcp-nixos`) when working with NixOS, nixpkgs, Home Manager, or Nix-related configuration.

- **Always consult the MCP server** when adding or modifying NixOS options, Home Manager options, packages, or Nix functions. Do this proactively without requiring an explicit request.
- Use `nix` with `source="nixos"` for NixOS options and packages, and `source="home-manager"` for Home Manager options.
- Search for relevant options first, then retrieve their details to verify exact names, types, defaults, and descriptions before writing configuration.
- Use `source="noogle"` to look up unfamiliar Nix library functions, and `nix_versions` when package version history matters.
- Never invent option names, package attributes, or configuration values. Prefer verified information over assumptions.
- Treat MCP results as documentation, not proof of compatibility with this repository's pinned dependencies. Check `flake.lock` and existing configuration when version compatibility matters.
- Follow the repository's existing module structure and conventions rather than introducing unnecessary alternatives.
- If the MCP server is unavailable, state what could not be verified and use local Nix sources or official documentation instead.
