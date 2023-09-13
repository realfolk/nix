# Useful for Elm projects.

{ lib, symlinkJoin, writeShellScriptBin, elmPackages }:
let
  id = "elm";

  localLib = import ../lib { inherit writeShellScriptBin; };

  defineProject = dirs:
    { groupName
    , projectName
    , entryPoints ? {}
    , ...
    }@args:
      localLib.defineProject dirs args // { inherit entryPoints; };

  make = { project }:
    let
      makeCommand = localLib.makeCommand project;

      makeCommandsForEntryPoints = { name, makeScript }:
        lib.attrsets.mapAttrs'
          (entryPointName: mainFile:
            let
              scriptName = "${name}-${entryPointName}";
            in
            lib.attrsets.nameValuePair scriptName (makeCommand {
              name = scriptName;
              script = makeScript entryPointName mainFile;
            }))
          project.entryPoints;

      makeBuildDir = dirName: "${project.buildPath}/${id}/${dirName}";
      makeBuildTarget = { dirName, targetName }: "${makeBuildDir dirName}/${targetName}";
      makeBuildTargetJs = dirName: makeBuildTarget { inherit dirName; targetName = "out.js"; };

      elm = makeCommand {
        name = "${id}-elm";
        script = ''
          cd "${project.srcPath}"
          ${elmPackages.elm}/bin/elm "$@"
        '';
      };

      build = makeCommandsForEntryPoints {
        name = "${id}-build";
        makeScript = (entryPointName: mainFile:
          let
            buildDir = makeBuildDir entryPointName;
            buildTarget = makeBuildTargetJs entryPointName;
          in ''
            echo "Removing old build directory: ${buildDir}"
            mkdir -p "${buildDir}"
            rm -rf "${buildDir}"
            ${elm.bin} make src/${mainFile} --output "${buildTarget}" "$@"
            echo "Successfully built entry point ${mainFile}: ${buildTarget}"
        '');
      };

      commands = { inherit elm; } // build;

      combinedCommandsPackage = symlinkJoin {
        name = "${id}-commands-${project.groupName}-${project.projectName}";
        paths = builtins.map ({ package, ... }: package) (builtins.attrValues commands);
      };
    in
    { inherit commands combinedCommandsPackage; };
in
{ inherit id defineProject make; }
