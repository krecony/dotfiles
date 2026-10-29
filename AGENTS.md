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
- Only modify files and modules directly required by the current request. Do not include adjacent cleanup, moves, or reorganisations merely because they seem beneficial.
- Leave unrelated configuration in place even when editing the file containing it. For example, a storage refactor must not move display-manager configuration into style modules. Suggest unrelated improvements separately.
- Keep validation proportional to the change. For behaviour-preserving refactors, prefer existing checks and temporary before/after evaluations. Do not automatically add permanent tests, new flake checks, or test infrastructure; add them only when requested or necessary to cover a concrete risk, and explain that need.
- Do not commit secrets.
- After changing Nix configuration evaluate the validity of the flake and changes by running:
    - `nix eval`
    - `nix flake check`
- For documentation-only changes, review the edited text and diff; Nix evaluation is not required.
- Never push or rebuild, that is up to the users discretion
- Always ask before modyfing files motivating why your solutions are appropriate

## Nix style
- Format Nix code with `nix fmt .`, using the formatter configured in `flake.nix`. Do not invoke `nixfmt` directly or create ad-hoc `nix-shell`/`nix shell` environments for formatting.
- Inspect `lib/custom.nix` and existing usage before introducing options or helpers. Prefer the repository's custom helpers when they clearly express the intended behaviour.
- Use `imports = mkImports [ ... ];` for module imports in the repository's module tree, accepting `mkImports` as a module argument. This propagates custom arguments such as `user`, `colors`, and `mkImports` itself. Do not bypass the helper with raw import lists or duplicate its argument-forwarding logic.
- Use `lib.custom.mkEnableByDefaultOption` for boolean options enabled by default. Do not recreate it with `mkEnableOption ... // { default = true; }` or a redundant option declaration.
- Use `inherit (cfg.someSection) optionName;` when forwarding values with matching names instead of repeating assignments.
- Prefer `lib.mkIf` for conditional module definitions and `lib.mkMerge` when combining conditional blocks. Avoid `// lib.optionalAttrs ...` when the same configuration can be expressed clearly with module conditionals.
- Avoid `lib.optionalAttrs` unless conditional construction of a plain attribute set actually requires it and there is no clearer alternative. Prefer a normal `if ... then ... else ...` when selecting between different plain values or structures.
- Check the destination option's type before replacing ordinary attribute-set logic with `mkIf`: module conditionals must be consumed by the module system. Preserve option defaults and behaviour when simplifying expressions.

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
