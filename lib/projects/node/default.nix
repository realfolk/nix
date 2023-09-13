# Useful for Node.js projects.

{ lib, symlinkJoin, writeShellScriptBin }:
let
  id = "node";

  localLib = import ../lib { inherit writeShellScriptBin; };

  defineProject = dirs:
    { groupName
    , projectName
    , executables ? {}
    , ...
    }@args:
      localLib.defineProject dirs args // { inherit executables; };

  make = { project, nodeInterpreter }:
    let
      makeCommand = localLib.makeCommand project;

      makeCommandsForExecutables = { name, makeScript }:
        lib.attrsets.mapAttrs'
          (executableName: mainFile:
            let
              scriptName = "${name}-${executableName}";
            in
            lib.attrsets.nameValuePair scriptName (makeCommand {
              name = scriptName;
              script = makeScript executableName mainFile;
            }))
          project.executables;

      node = makeCommand {
        name = "${id}-node";
        script = ''
          cd "${project.srcPath}"
          ${nodeInterpreter}/bin/node "$@"
        '';
      };

      npm = makeCommand {
        name = "${id}-npm";
        script = ''
          cd "${project.srcPath}"
          ${nodeInterpreter}/bin/npm "$@"
        '';
      };

      npx = makeCommand {
        name = "${id}-npx";
        script = ''
          cd "${project.srcPath}"
          ${nodeInterpreter}/bin/npx "$@"
        '';
      };

      run = makeCommandsForExecutables {
        name = "${id}-run";
        makeScript = executableName: mainFile:
          "${node.bin} ${mainFile}";
      };

      commands = { inherit node npm npx; } // run;

      combinedCommandsPackage = symlinkJoin {
        name = "${id}-commands-${project.groupName}-${project.projectName}";
        paths = builtins.map ({ package, ... }: package) (builtins.attrValues commands);
      };
    in
    { inherit commands combinedCommandsPackage; };
in
{ inherit id defineProject make; }
