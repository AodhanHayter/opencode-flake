# OpenCode Nix Flake

> **⚠️ ARCHIVED**: This repository has been archived as OpenCode is now officially maintained in nixpkgs and is more promptly updated there. Please use the official package instead:
>
> - **Official Package**: https://search.nixos.org/packages?channel=25.05&query=opencode
> - **Quick Install**: `nix profile install nixpkgs#opencode`
> - **NixOS Configuration**: Add `pkgs.opencode` to your `environment.systemPackages`

---

This repository previously packaged [OpenCode](https://github.com/sst/opencode), a terminal-based AI assistant for developers, as a Nix flake. OpenCode is developed by SST (Serverless Stack) and provides powerful AI-powered coding assistance directly in your terminal.

## Migrating to the Official Package

If you're currently using this flake, please migrate to the official nixpkgs package:

### From Profile Installation
```bash
# Remove this flake
nix profile remove opencode-flake

# Install official package
nix profile install nixpkgs#opencode
```

### From NixOS/Home Manager Configuration
Replace:
```nix
inputs.opencode-flake.url = "github:aodhanhayter/opencode-flake";
```

With:
```nix
environment.systemPackages = [ pkgs.opencode ];
# Or in home-manager:
home.packages = [ pkgs.opencode ];
```

## Historical Quick Start

This section is preserved for historical reference:

```bash
# Run directly from the flake
nix run github:aodhanhayter/opencode-flake

# Check the version
nix run github:aodhanhayter/opencode-flake -- --version

# Install to your profile
nix profile install github:aodhanhayter/opencode-flake
```

## Installation

### Profile Installation
```bash
nix profile install github:aodhanhayter/opencode-flake
```

### NixOS/Home Manager Configuration
```nix
{
  inputs.opencode-flake.url = "github:aodhanhayter/opencode-flake";

  # In your configuration:
  environment.systemPackages = [ inputs.opencode-flake.packages.${pkgs.system}.default ];

  # Or in home-manager:
  home.packages = [ inputs.opencode-flake.packages.${pkgs.system}.default ];
}
```

## Packaging

This flake builds OpenCode from source, copying the approach from the official nixpkgs build. If you don't require the latest version of opencode, I recommend using the official nixpkgs version as it will likely be more stable and well tested.

- **Source-based builds**: Fetches source code directly from the [sst/opencode](https://github.com/sst/opencode) repository
- **Multi-component build system**:
  - **Go TUI Component**: Builds the terminal UI (`packages/tui`) using `buildGoModule`
  - **TypeScript Core**: Uses Bun to compile the main application logic
- **Deterministic builds**: Includes a local models patch to avoid network dependencies during build
- **Cross-platform support**: Supports all major platforms with proper platform-specific library linking

## Development

```bash
# Enter development shell with OpenCode available
nix develop github:aodhanhayter/opencode-flake

# Build locally
nix build

# Test the package
nix flake check
```

## Automated Maintenance

This repository features **fully automated maintenance**:

- **Automatic updates**: GitHub Actions workflow runs every 6 hours using `nix-update`
- **Version detection**: Automatically detects new OpenCode releases from upstream
- **Auto-deployment**: Updates are automatically tested, tagged, and released
- **Zero-maintenance**: No manual intervention required for version updates

### Workflow Status

- Check the [workflow runs](https://github.com/AodhanHayter/opencode-flake/actions/workflows/update-opencode-nix.yml) to see recent updates
- **Note**: Scheduled workflows are automatically disabled after 60 days of repository inactivity
- To reactivate: Make any commit or [manually trigger the workflow](https://github.com/AodhanHayter/opencode-flake/actions/workflows/update-opencode-nix.yml)

### Manual Updates (if needed)

```bash
# Force update to latest version
nix-update --flake opencode

# Build and test
nix build && nix flake check
```

**Note**: When OpenCode updates, `nix-update` may fail during the build phase if Go module dependencies have changed. This is normal - check the build logs for the correct `vendorHash` and update `package.nix` manually.

## Supported Systems

- `aarch64-darwin` (macOS on Apple Silicon)
- `x86_64-darwin` (macOS on Intel)
- `aarch64-linux` (Linux on ARM64)
- `x86_64-linux` (Linux on x86_64)

## Repository Structure

- `flake.nix`: Clean, minimal flake following nixpkgs patterns
- `package.nix`: Comprehensive OpenCode package definition with source builds
- `local-models-dev.patch`: Patch for deterministic builds with local models
- `.github/workflows/`: Automated CI/CD workflows

## CI/CD & Automation

### GitHub Actions Workflows

1. **Automated Updates** (`update-opencode-nix.yml`):
   - Runs every 6 hours (00:15, 06:15, 12:15, 18:15 UTC)
   - Uses `nix-update` for reliable version detection
   - Auto-creates releases and tags
   - Handles errors and cleanup automatically
   - Can be manually triggered via GitHub Actions UI

2. **Build Verification**:
   - Ensures packages build correctly across all platforms
   - Validates version reporting and functionality

## License

This project is licensed under the MIT License - see the LICENSE file for details.
