# Useful for Rust projects.

{ symlinkJoin, writeShellScriptBin, rustc, cargo }:
let
  id = "rust";

  lib = import ../lib { inherit writeShellScriptBin; };

  make = { project }:
    let
      makeCommand = lib.makeCommand project;

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

      combinedCommandsPackage = symlinkJoin {
        name = "${id}-commands-${project.groupName}-${project.projectName}";
        paths = builtins.map ({ package, ... }: package) (builtins.attrValues commands);
      };
    in
    {
      inherit commands combinedCommandsPackage;
    };
in
{
  inherit id make;
  inherit (lib) defineProject;
}
