{
  pkgs,
  system,
  version,
}:

let
  # Helper function to download npm packages
  fetchNpmPackage =
    {
      pname,
      version,
      hash,
      os ? null,
      cpu ? null,
    }:
    pkgs.fetchurl {
      url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
      inherit hash;
    };

  # Map system to npm package architecture
  getOpencodeArchForSystem =
    system:
    let
      platformMap = {
        "aarch64-darwin" = {
          os = "darwin";
          cpu = "arm64";
        };
        "x86_64-darwin" = {
          os = "darwin";
          cpu = "x64";
        };
        "aarch64-linux" = {
          os = "linux";
          cpu = "arm64";
        };
        "x86_64-linux" = {
          os = "linux";
          cpu = "x64";
        };
      };
    in
    platformMap.${system} or (throw "Unsupported system: ${system}");

  # Get system-specific parameters
  systemInfo = getOpencodeArchForSystem system;
  platformPackageName = "opencode-${systemInfo.os}-${systemInfo.cpu}";

  # Define the hashes for each platform package
  packageHashes = {
    "opencode-ai" = "sha256-x9FBGwHLnU79Pf5G2aw5uq+M5sJugw+RfuFe74dRJq4="; # opencode-ai-0.1.117.tgz
    "opencode-darwin-arm64" = "sha256-9M+Ai1QtnTvBGfjfCVhhKvXD59Kb4SgYNrh1BQxEqP8="; # opencode-darwin-arm64-0.1.117.tgz
    "opencode-darwin-x64" = "sha256-tOvpNnn53DJFGnZlHLnMiYb46BFfNIMCXJFNMJ1dmpA="; # opencode-darwin-x64-0.1.117.tgz
    "opencode-linux-arm64" = "sha256-kYbme+4toFW4JqdLjrj1Xv79JD9OB1MVrfulKI+rYIM="; # opencode-linux-arm64-0.1.117.tgz
    "opencode-linux-x64" = "sha256-u6n9yrebHpisbUJmNFwzYEHTSPCoRrFnlSW/TB6U09Q="; # opencode-linux-x64-0.1.117.tgz
  };

in
pkgs.stdenv.mkDerivation {
  pname = "opencode";
  inherit version;

  # Source tarballs
  src = fetchNpmPackage {
    pname = "opencode-ai";
    inherit version;
    hash = packageHashes."opencode-ai";
  };

  # Platform-specific binary
  platformSrc = fetchNpmPackage {
    pname = platformPackageName;
    inherit version;
    hash =
      packageHashes.${platformPackageName} or (throw "Hash for ${platformPackageName} not defined");
  };

  # Dependencies
  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  # Environment variables
  passthru.exePath = "/bin/opencode";

  # Unpack the sources
  unpackPhase = ''
    tar -xzf $src
    mkdir -p platform
    tar -xzf $platformSrc -C platform
  '';

  # Installation
  installPhase = ''
    # Create directories
    mkdir -p $out/bin
    mkdir -p $out/lib/node_modules/opencode-ai
    mkdir -p $out/lib/node_modules/${platformPackageName}

    # Copy main package
    cp -r package/* $out/lib/node_modules/opencode-ai/

    # Copy platform-specific package
    cp -r platform/package/* $out/lib/node_modules/${platformPackageName}/

    # Create symlink for the binary
    ln -s $out/lib/node_modules/${platformPackageName}/bin/opencode $out/bin/opencode
    chmod +x $out/bin/opencode

    # Create wrapper script
    wrapProgram $out/bin/opencode \
      --set OPENCODE_BIN_PATH $out/lib/node_modules/${platformPackageName}/bin/opencode
  '';

  meta = with pkgs.lib; {
    description = "A powerful terminal-based AI assistant for developers";
    homepage = "https://github.com/sst/opencode";
    license = licenses.mit;
    platforms = [ system ];
    maintainers = [ "aodhan.hayter@gmail.com" ];
    changelog = "https://github.com/sst/opencode/releases";
    longDescription = ''
      OpenCode is an open-source AI developer tool created by SST (Serverless Stack).
      It acts as a terminal-based assistant that helps with coding tasks, debugging,
      and project management directly in your terminal.
    '';
  };
}
