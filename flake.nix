{
  description = "Zig project flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";

    zig2nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Cloudef/zig2nix";
    };
  };

  outputs =
    inputs@{ ... }:

    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devshell.flakeModule ];

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        { system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ inputs.devshell.overlays.default ];
          };

          env = inputs.zig2nix.outputs.zig-env.${system} { };

          rgfwDeps = [
            pkgs.xorg.libX11.dev
            pkgs.xorg.libXi.dev
            pkgs.xorg.libXext.dev
            pkgs.xorg.libXinerama.dev
            pkgs.xorg.libXrandr.dev
            pkgs.xorg.libXcursor.dev
            pkgs.xorg.libXrender.dev
            pkgs.xorg.libXfixes.dev
            pkgs.libGL.dev
            pkgs.wayland.dev
            pkgs.wayland-protocols
            pkgs.libdecor.dev
            pkgs.libxkbcommon.dev
          ];
        in
        {
          _module.args.pkgs = pkgs;

          packages.default = env.package rec {
            src = env.pkgs.lib.cleanSource ./.;

            nativeBuildInputs = [ ];
            buildInputs = [
              pkgs.xorg.libX11
              pkgs.xorg.libXi
              pkgs.xorg.libXext
              pkgs.xorg.libXinerama
              pkgs.xorg.libXrandr
              pkgs.xorg.libXcursor
              pkgs.xorg.libXrender
              pkgs.xorg.libXfixes
              pkgs.libGL
              pkgs.wayland
              pkgs.libdecor
              pkgs.libxkbcommon
            ];

            zigBuildZonLock = ./build.zig.zon2json-lock;
            zigWrapperLibs = buildInputs;

            zigPreferMusl = true;
            zigDisableWrap = false;
          };

          devshells.default = {
            packages = [
              env.pkgs.zls
              pkgs.wgsl-analyzer
              pkgs.claude-code

              pkgs.pkg-config
              pkgs.wayland-scanner
            ]
            ++ rgfwDeps;

            commands = [
              { package = env.pkgs.zig; }
              {
                name = "claude";
                package = pkgs.claude-code;
              }
            ];

            env = [
              {
                name = "LD_LIBRARY_PATH";
                value = "${pkgs.lib.makeLibraryPath [
                  pkgs.xorg.libX11
                  pkgs.xorg.libXi
                  pkgs.xorg.libXext
                  pkgs.xorg.libXinerama
                  pkgs.xorg.libXrandr
                  pkgs.xorg.libXcursor
                  pkgs.xorg.libXrender
                  pkgs.xorg.libXfixes
                  pkgs.libGL
                  pkgs.wayland
                  pkgs.libdecor
                  pkgs.libxkbcommon
                ]}";
              }
              {
                name = "C_INCLUDE_PATH";
                value = "${pkgs.lib.makeSearchPathOutput "dev" "include" [
                  pkgs.xorg.libX11
                  pkgs.xorg.libXi
                  pkgs.xorg.libXext
                  pkgs.xorg.libXinerama
                  pkgs.xorg.libXrandr
                  pkgs.xorg.libXcursor
                  pkgs.xorg.libXrender
                  pkgs.xorg.libXfixes
                  pkgs.libGL
                  pkgs.wayland
                  pkgs.wayland-protocols
                  pkgs.libdecor
                  pkgs.libxkbcommon
                ]}:${pkgs.xorg.xorgproto}/include";
              }
              {
                name = "WAYLAND_PROTOCOLS_DIR";
                value = "${pkgs.wayland-protocols}/share/wayland-protocols";
              }
              {
                name = "WAYLAND_SCANNER";
                value = "${pkgs.wayland-scanner.bin}/bin/wayland-scanner";
              }
            ];
          };
        };
    };
}
