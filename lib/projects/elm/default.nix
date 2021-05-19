{
  pkgs
}:

let

projectsLib = import ../default.nix { inherit pkgs; };

# COMMANDS

projectTypeId = "elm";

makeBuildDir = project: "${project.buildPath}/${projectTypeId}";

elmPkg = pkgs.elmPackages.elm;

commands = rec {
  make-src-dir = project: projectsLib.makeCommand {
    inherit project;
    name = "${projectTypeId}-make-src-dir";
    includeInShellHook = true;
    script = ''
      mkdir -p "${project.srcPath}"
    '';
  };
  elm = project: projectsLib.makeCommand {
    inherit project;
    name = "${projectTypeId}-elm";
    script = ''
      cd "${project.srcPath}"
      ${elmPkg}/bin/elm "$@"
    '';
  };
  build = project: projectsLib.makeCommand {
    inherit project;
    name = "${projectTypeId}-build";
    script =
      let buildDir = makeBuildDir project;
      in
        ''
          echo "Removing old build directory: ${project.buildPath}"
          mkdir -p "${buildDir}"
          rm -rf "${buildDir}"
          cd "${project.srcPath}"
          ${elmPkg}/bin/elm make src/Main.elm --output "${buildDir}/out.js" "$@"
          echo "Successfully built project: ${project.buildPath}"
        '';
  };
};

# PROJECTS

projectConfig = {
  commands = [
    projectsLib.commonCommands.pwd-src
    projectsLib.commonCommands.pwd-build
    projectsLib.commonCommands.cd-src
    projectsLib.commonCommands.cd-build
    projectsLib.commonCommands.ls-src
    projectsLib.commonCommands.ls-build
    commands.make-src-dir
    commands.elm
    commands.build
    commands.nix
  ];
};

defineProject = rootConfig: defineConfig:
  projectsLib.defineProject rootConfig defineConfig;

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
