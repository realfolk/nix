{ pkgs }:

let

foldr = pkgs.lib.foldr;

in

rec {

  defineProject = { name, dependencies, srcDir, buildDir, buildArtifactsDir }:
    {
      inherit name dependencies;
      srcPath = "${srcDir}/${name}";
      buildPath = "${buildDir}/${name}";
      buildArtifacts = "${buildArtifactsDir}/${name}";
    };

  makeProject = pDefinition: pConfig: let
    commands = builtins.concatMap (c: pkgs.lib.toList (c pDefinition)) pConfig.commands;
  in {
    pkgs = map (c: c.pkg) commands;
    shellHook = foldr (c: acc: if c.shellHook then "${c.bin}\n${acc}" else acc) "" commands;
  };

  makeProjects = pDefinitions: pConfig: let
    projects = map (d: makeProject d pConfig) pDefinitions;
  in {
    pkgs = builtins.concatMap (p: p.pkgs) projects;
    shellHook = foldr (p: acc: "${p.shellHook}\n${acc}") "" projects;
  };

  makeCommandName = { project, commandName, execName ? "" }: "${project.name}-${commandName}${if execName == "" then "" else "-${execName}"}";

  makeCommand = project: commandName: script: shellHook: rec {
    inherit shellHook;
    name = makeCommandName { inherit project commandName; };
    bin = "${pkg}/bin/${name}";
    pkg = pkgs.writeShellScriptBin name script;
  };

  findCommand = name': commands: pkgs.lib.lists.findFirst ({ name, ...}: name == name') false commands;

  commands = {
    cd = project: makeCommand project "cd" ''
        cd ${project.srcPath}
      '' false;
  };

}
