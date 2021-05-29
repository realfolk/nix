{
  pkgs
}:

let

projectsLib = import ../default.nix { inherit pkgs; };

# COMMANDS

projectTypeId = "elm";

makeCommandsForEntryPoints = { name, makeScript, includeInShellHook ? false }: project:
  pkgs.lib.attrsets.mapAttrsToList
    (subName: mainFile: projectsLib.makeCommand {
      inherit name subName project includeInShellHook;
      script = (makeScript project subName mainFile);
    })
    project.entryPoints;

makeBuildDir = project: dirName: "${project.buildPath}/${projectTypeId}/${dirName}";
makeBuildTarget = { project, dirName, targetName }: "${makeBuildDir project dirName}/${targetName}";
makeBuildTargetJs = project: dirName: makeBuildTarget { inherit project dirName; targetName = "out.js"; };

elmPkg = pkgs.elmPackages.elm;

commands = rec {
  elm = project: projectsLib.makeCommand {
    inherit project;
    name = "${projectTypeId}-elm";
    script = ''
      cd "${project.srcPath}"
      ${elmPkg}/bin/elm "$@"
    '';
  };
  build = makeCommandsForEntryPoints {
    name = "${projectTypeId}-build";
    makeScript = (project: subName: mainFile:
      let
        buildDir = makeBuildDir project subName;
        buildTarget = makeBuildTargetJs project subName;
      in ''
        echo "Removing old build directory: ${buildDir}"
        mkdir -p "${buildDir}"
        rm -rf "${buildDir}"
        cd "${project.srcPath}"
        ${elmPkg}/bin/elm make src/${mainFile} --output "${buildTarget}" "$@"
        echo "Successfully built entry point ${mainFile}: ${buildTarget}"
    '');
  };
};

# PROJECTS

projectConfig = {
  commands = [
    projectsLib.commonCommands.mkdir-src
    projectsLib.commonCommands.pwd-src
    projectsLib.commonCommands.pwd-build
    projectsLib.commonCommands.cd-src
    projectsLib.commonCommands.cd-build
    projectsLib.commonCommands.ls-src
    projectsLib.commonCommands.ls-build
    commands.elm
    commands.build
  ];
};

defineProject = rootConfig: { entryPoints ? {}, ... }@args:
  { inherit entryPoints; } // (projectsLib.defineProject rootConfig (builtins.removeAttrs args [ "entryPoints" ]));


makeProject = project: projectsLib.makeProject project projectConfig;

makeProjects = projects: projectsLib.makeProjects projects projectConfig;

in

{
  inherit defineProject makeProject makeProjects;

  pkgs = {
    all = [
      elmPkg
      pkgs.elmPackages.elm-language-server
      #elm-format not bundled with elm-language-server
      pkgs.elmPackages.elm-format
      pkgs.elmPackages.elm-test
    ];
    elm = elmPkg;
  };
}
