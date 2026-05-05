# NixOS Development Guidelines for GitHub Copilot

These instructions help GitHub Copilot understand our NixOS configuration preferences and coding standards.

## General Guidelines

- Use declarative configuration with NixOS modules
- Follow the [Nixpkgs contribution guidelines](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md)
- Maintain pure and reproducible builds
- Use flakes for dependency management
- Prefer functional programming patterns

## Important! Configuration Structure
- Host specific configuration, and hardware configuration lives under hosts/
- Custom library functions live under lib/
- Modules live under modules/
    - Home-manager modules and nixos modules are interleaved
    - As all my machines are single-user I have created an alias for home-manager.users.${user} it is simply hm, use it instead
- The entire project is largely in construction
    - Some parts have been only slightly developed or not fully configured
    - For instance, the capabilities system so far hasn't been developed
    - Additionally, some modules live seperately from the other categories
- Sops-nix is used for secret management, however, again it is not used everywhere

## Code Style

### General Style
The general styling convention is enforced by nixfmt-tree which is run as a git-commit hook.

### Nix Expression Format

```nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Use 2 spaces for indentation
  # Place closing braces on their own line for better readability
}
```

### Naming Conventions

- Use camelCase for variable and function names
- Use descriptive names that reflect purpose
- Prefix private functions with underscore
- Use plural forms for lists/sets (e.g., `users`, `services`)

### Module Structure

- Group related options together
- Use type system for option declarations
- Document options with description field
- Include example values in documentation

## Best Practices

### Option Declarations

```nix
options.myModule = {
  enable = lib.mkEnableOption "my module";

  setting = lib.mkOption {
    type = lib.types.str;
    default = "value";
    description = "Clear description of the option";
    example = "example value";
  };
};
```

### Package Verification

- Always verify package names exist before using them in configurations
- Use the nixos-mcp server for package verification when available
- Alternatively, use `nix-env -f '<nixpkgs>' -qaP` to list and verify available packages
- Check packages against the current version of nixpkgs being used
- Prefer using the exact attribute path (e.g., `pkgs.python3Packages.requests` instead of just `requests`)

### Service Configuration

- Use systemd service units when appropriate
- Handle service dependencies explicitly
- Consider resource limits
- Implement proper shutdown behavior

### File Organization

- Separate concerns into distinct modules
- Use `default.nix` for module entry points
- Keep related configurations together
- Follow the standard NixOS module structure

## Common Patterns

### Package Overlays

```nix
final: prev: {
  myPackage = prev.myPackage.overrideAttrs (old: {
    # modifications
  });
}
```

### Service Definitions

```nix
systemd.services.myService = {
  description = "My Service";
  wantedBy = ["multi-user.target"];
  after = ["network.target"];
  serviceConfig = {
    ExecStart = "${package}/bin/service";
    Restart = "always";
  };
};
```

## Host-Specific Configurations

Our configuration manages several distinct hosts, each with unique hardware specifications that require tailored configurations:

### Zephyr
A Huawei NBLB-WAX9N-PCB-B2 laptop
CPU: Intel(R) Core(TM) i5-10210U CPU @ 1.60GHz
GPU: Builtin integrated GPU (iGPU)
RAM: 8GB SODIMM (2x4GB)
Use Case: Everyday workstation for programming, very-light gaming and production

### Hermes
A raspberry pi 3b+
Use Case: Small server running services


## Testing and Validation

- Test configurations with `nixos-rebuild build`
- Verify service functionality
- Check for option type correctness
- Validate dependencies

## Security Considerations

- Avoid hardcoded secrets
- Use proper file permissions
- Implement least privilege principle
- Consider service isolation

## Privacy and Security

- Make your changes safe and secure out-of-the-box while not sacrificing usability
- Learn from resources like
    - https://saylesss88.github.io/nix/hardening_NixOS.html
    - https://chanakar.substack.com/p/linux-security-superpower-auditd-guide
    - https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/security_guide/index
- Analyze the latest CVEs that apply to my nixos configuration and make sure my system is not susceptible

## Performance

- Use binary caches when available
- Optimize build dependencies
- Consider resource usage in services
- Use proper garbage collection settings

## Documentation

### Module Documentation

- Document all custom options
- Include usage examples
- Explain dependencies
- Document any required system configuration

### Comment Style

```nix
# Single-line comments for brief explanations

/* Multi-line comments for
   detailed explanations */

# TODO: Mark todos clearly

# FIXME: Mark issues that need attention
```

## Error Handling

- Use assertions for configuration validation
- Provide helpful error messages
- Handle service failures gracefully
- Log important events

## Version Control

- Use meaningful commit messages
- Tag stable versions
- Document breaking changes
- Keep change history in CHANGELOG.md

## Resource Management

- Clean up temporary files
- Handle service cleanup
- Manage system resources appropriately
- Consider memory and CPU usage

## Integration

- Test with different NixOS versions
- Verify compatibility with common services
- Document integration requirements
- Handle upgrades gracefully

Remember to maintain reproducibility and purity in all configurations. The goal is to create maintainable, reliable, and well-documented NixOS configurations.

