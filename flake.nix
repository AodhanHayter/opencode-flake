{
  description = "OpenCode - A powerful terminal-based AI assistant for developers";

  # Define inputs for the flake
  inputs = {
    # Use the nixpkgs unstable channel
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Use flake-utils for multi-system support
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Define outputs function
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Define the package
        packages.default = pkgs.buildGoModule {
          pname = "opencode";
          version = "0.0.34"; # Update version as needed

          # Fetch source from GitHub
          src = pkgs.fetchFromGitHub {
            owner = "opencode-ai";
            repo = "opencode";
            # You'll need to specify a specific commit or tag
            rev = "v0.0.34"; # Replace with specific commit or tag
            # Initially use a fake hash
            hash = "sha256-EaspkL0TEBJEUU3f75EhZ4BOIvbneUKnTNeNGhJdjYE=";
            # After the first build attempt fails, replace with the actual hash:
            # hash = "sha256-actual-hash-will-go-here";
          };

          # Vendor hash - initially use fake hash, then replace with actual hash
          # after first build attempt
          vendorHash = "sha256-cFzkMunPkGQDFhQ4NQZixc5z7JCGNI7eXBn826rWEvk=";
          doCheck = false;

          # If the project has a specific Go subpackage that should be built
          # Uncomment and specify the subpackage:
          # subPackages = [ "cmd/opencode" ];

          # Set up build flags or environment variables if needed
          # Example: ldflags to set version info at build time
          # ldflags = ["-s" "-w" "-X main.Version=${version}"];

          # Define any runtime dependencies that might be needed
          # buildInputs = with pkgs; [
          #   # Add any runtime dependencies here
          # ];

          meta = with pkgs.lib; {
            description = "A powerful terminal-based AI assistant for developers";
            homepage = "https://github.com/opencode-ai/opencode";
            license = licenses.mit;
            maintainers = [];
            mainProgram = "opencode";
          };
        };

        # Make the package available as the default
        defaultPackage = self.packages.${system}.default;

        # For compatibility with 'nix run' and old-style nix commands
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/opencode";
        };
      }
    );
}
