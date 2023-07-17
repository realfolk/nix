{
  description = "A flake for Rust projects.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    projectLib.url = "github:realfolk/nix?dir=lib/projects/lib";
  };

  outputs = { self, nixpkgs, projectLib, ... }:
    let
      id = "rust";

      defineProject = args: projectLib.lib.defineProject args;

      make = { system, rustc, cargo, project, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          makeCommand = args: projectLib.lib.makeCommand (args // {
            inherit project;
            writeShellScriptBin = pkgs.writeShellScriptBin;
          });

          # COMMANDS

          rustcCommand = makeCommand {
            name = "${id}-rustc";
            script = ''
              cd "${project.srcPath}"
              ${rustc}/bin/rustc "$@"
            '';
          };

          rustdoc = makeCommand {
            name = "${id}-rustdoc";
            script = ''
              cd "${project.srcPath}"
              ${rustc}/bin/rustdoc "$@"
            '';
          };

          rust-gdb = makeCommand {
            name = "${id}-rust-gdb";
            script = ''
              cd "${project.srcPath}"
              ${rustc}/bin/rust-gdb "$@"
            '';
          };

          rust-lldb = makeCommand {
            name = "${id}-rust-lldb";
            script = ''
              cd "${project.srcPath}"
              ${rustc}/bin/rust-lldb "$@"
            '';
          };

          cargoCommand = makeCommand {
            name = "${id}-cargo";
            script = ''
              cd "${project.srcPath}"
              ${cargo}/bin/cargo "$@"
            '';
          };

          commands = {
            inherit
              rustdoc
              rust-gdb
              rust-lldb;
            rustc = rustcCommand;
            cargo = cargoCommand;
          };

          combinedCommandsPackage = pkgs.symlinkJoin {
            name = "${id}-commands-${project.groupName}-${project.projectName}";
            paths = builtins.map ({ package, ... }: package) (builtins.attrValues commands);
          };
        in
        {
          inherit commands combinedCommandsPackage;
        };
    in
    {
      lib = {
        inherit id defineProject make;
      };
    };
}
