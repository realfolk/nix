{ pkgs }:

let

foldr = pkgs.lib.foldr;

in

rec {

  defineProject = { groupName, srcDir, buildDir, buildArtifactsDir }: { name, dependencies }:
    {
      inherit name groupName dependencies;
      srcPath = "${srcDir}/${groupName}/${name}";
      buildPath = "${buildDir}/${groupName}/${name}";
      buildArtifacts = "${buildArtifactsDir}/${groupName}/${name}";
    };

  makeProject = pDefinition: pConfig: let
    commands = builtins.concatMap (c: pkgs.lib.toList (c pDefinition)) pConfig.commands;
  in {
    pkgs = map (c: c.pkg) commands;
    shellHook = foldr (c: acc: if c.includeInShellHook then "${c.bin}\n${acc}" else acc) "" commands;
  };

  makeProjects = pDefinitions: pConfig: let
    projects = map (d: makeProject d pConfig) pDefinitions;
  in {
    pkgs = builtins.concatMap (p: p.pkgs) projects;
    shellHook = foldr (p: acc: "${p.shellHook}\n${acc}") "" projects;
  };

  makeCommandName = { project, name, subName ? "" }: "${project.groupName}-${project.name}-${name}${if subName == "" then "" else "-${subName}"}";

  makeCommand = { project, name, subName ? "", script, includeInShellHook ? false }:
    let
      commandName = makeCommandName { inherit project name subName; };
      pkg = pkgs.writeShellScriptBin commandName script;
    in
      {
        inherit pkg includeInShellHook;
        name = commandName;
        bin = "${pkg}/bin/${commandName}";
      };

  findCommand = matchName: commands: pkgs.lib.lists.findFirst ({ name, ...}: name == matchName) false commands;

  commands = {
    cd = project: makeCommand {
      inherit project;
      name = "cd";
      script = ''
        cd ${project.srcPath}
      '';
    };
  };

}
