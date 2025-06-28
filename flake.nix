{
  description = "OpenCode - A powerful terminal-based AI assistant for developers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        let
          # Import the OpenCode package definition
          opencode = import ./package.nix {
            inherit pkgs system;
            version = "0.1.158";
          };

          # Script to verify opencode --version works
          versionCheck = pkgs.writeShellApplication {
            name = "opencode-version-check";
            runtimeInputs = [ opencode ];
            text = ''
              echo "Checking OpenCode version..."
              VERSION=$(${opencode}/bin/opencode --version)
              EXPECTED="0.1.117"

              if [[ "$VERSION" == "$EXPECTED" ]]; then
                echo "✅ Version check passed: $VERSION"
                exit 0
              else
                echo "❌ Version check failed: Expected $EXPECTED but got $VERSION"
                exit 1
              fi
            '';
          };

          # Script to verify binary executable
          binaryCheck = pkgs.writeShellApplication {
            name = "opencode-binary-check";
            text = ''
              echo "Checking OpenCode binary..."
              BINARY_PATH="${opencode}/bin/opencode"

              if [[ -f "$BINARY_PATH" && -x "$BINARY_PATH" ]]; then
                echo "✅ Binary check passed: $BINARY_PATH exists and is executable"
                exit 0
              else
                echo "❌ Binary check failed: $BINARY_PATH does not exist or is not executable"
                exit 1
              fi
            '';
          };

          # Script to verify library structure
          libraryCheck = pkgs.writeShellApplication {
            name = "opencode-library-check";
            text = ''
              echo "Checking OpenCode library structure..."

              # Check main package directory
              if [[ -d "${opencode}/lib/node_modules/opencode-ai" ]]; then
                echo "✅ Main package directory check passed"
              else
                echo "❌ Main package directory check failed: ${opencode}/lib/node_modules/opencode-ai not found"
                exit 1
              fi

              # Get platform-specific package name for the current system
              declare -A PLATFORM_MAP
              PLATFORM_MAP["aarch64-darwin"]="opencode-darwin-arm64"
              PLATFORM_MAP["x86_64-darwin"]="opencode-darwin-x64"
              PLATFORM_MAP["aarch64-linux"]="opencode-linux-arm64"
              PLATFORM_MAP["x86_64-linux"]="opencode-linux-x64"

              PLATFORM_PKG="''${PLATFORM_MAP[${system}]}"

              # Check platform-specific package directory
              if [[ -d "${opencode}/lib/node_modules/$PLATFORM_PKG" ]]; then
                echo "✅ Platform package directory check passed for $PLATFORM_PKG"
              else
                echo "❌ Platform package directory check failed: ${opencode}/lib/node_modules/$PLATFORM_PKG not found"
                exit 1
              fi

              # Check symlink
              if [[ -L "${opencode}/bin/opencode" ]]; then
                echo "✅ Binary symlink check passed"
                exit 0
              else
                echo "❌ Binary symlink check failed: ${opencode}/bin/opencode is not a symlink"
                exit 1
              fi
            '';
          };

          # Meta check script that combines all individual checks
          allChecksScript = pkgs.writeShellApplication {
            name = "opencode-all-checks";
            text = ''
              echo "Running all OpenCode checks..."

              echo "Running binary check..."
              ${binaryCheck}/bin/opencode-binary-check

              echo "Running library structure check..."
              ${libraryCheck}/bin/opencode-library-check

              echo "Running version check..."
              ${versionCheck}/bin/opencode-version-check

              echo "✅ All checks passed!"
            '';
          };
        in
        {
          # Define packages
          packages = {
            inherit opencode;
            default = opencode;
          };

          # Define apps with metadata
          apps = {
            opencode = {
              type = "app";
              program = "${opencode}/bin/opencode";
              meta = {
                description = "A powerful terminal-based AI assistant for developers";
              };
            };
            default = {
              type = "app";
              program = "${opencode}/bin/opencode";
              meta = {
                description = "A powerful terminal-based AI assistant for developers";
              };
            };
          };

          # Define development shell
          devShells.default = pkgs.mkShell {
            buildInputs = [
              opencode
            ];
          };

          # Define checks
          checks = {
            # Package check - verifies the package builds
            opencode-package = opencode;

            # Individual checks
            opencode-version = versionCheck;
            opencode-binary = binaryCheck;
            opencode-library = libraryCheck;

            # Meta check to run all checks
            opencode-all-checks = allChecksScript;
          };
        };
    };
}
