{ pkgs }:

let

foldr = pkgs.lib.foldr;

commonCommandPrefix = "common";

in

rec {

  defineProject = { groupName, srcDir, buildDir, buildArtifactsDir }: { name }:
    {
      inherit name groupName;
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

  includeInShellHook = command: command // { includeInShellHook = true; };

  excludeFromShellHook = command: command // { includeInShellHook = false; };

  commonCommands = {

    mkdir-src = project: makeCommand {
      inherit project;
      name = "${commonCommandPrefix}-mkdir";
      subName = "src";
      includeInShellHook = true;
      script = ''
        mkdir -p "${project.srcPath}"
      '';
    };

    pwd-src = project: makeCommand {
      inherit project;
      name = "${commonCommandPrefix}-pwd";
      subName = "src";
      script = ''
        echo "${project.srcPath}"
      '';
    };

    pwd-build = project: makeCommand {
      inherit project;
      name = "${commonCommandPrefix}-pwd";
      subName = "build";
      script = ''
        echo "${project.buildPath}"
      '';
    };

    cd-src = project: makeCommand {
      inherit project;
      name = "${commonCommandPrefix}-cd";
      subName = "src";
      script = ''
        cd "${project.srcPath}"
      '';
    };

    cd-build = project: makeCommand {
      inherit project;
      name = "${commonCommandPrefix}-cd";
      subName = "build";
      script = ''
        cd "${project.buildPath}"
      '';
    };

    ls-src = project: makeCommand {
      inherit project;
      name = "${commonCommandPrefix}-ls";
      subName = "src";
      script = ''
        ls "${project.srcPath}" "$@"
      '';
    };

    ls-build = project: makeCommand {
      inherit project;
      name = "${commonCommandPrefix}-ls";
      subName = "build";
      script = ''
        ls "${project.buildPath}" "$@"
      '';
    };

  };

}
