{
  pkgs
}:

let

projectsLib = import ../default.nix { inherit pkgs; };

# COMMANDS

projectTypeId = "static";

makeBuildDir = project: dirName: "${project.buildPath}/${projectTypeId}/${dirName}";

commands = {
  build = project: projectsLib.makeCommand {
    inherit project;
    name = "${projectTypeId}-build";
    script = ''
      echo "Removing old build directory: ${project.buildPath}"
      mkdir -p "${project.buildPath}"
      rm -rf "${project.buildPath}"
      cp -r "${project.srcPath}" "${project.buildPath}"
      echo "Successfully copied assets to new build directory: ${project.buildPath}"
    '';
  };
};

# PROJECTS

projectConfig = {
  commands = [
    projectsLib.commonCommands.cd-src
    projectsLib.commonCommands.cd-build
    projectsLib.commonCommands.ls-src
    projectsLib.commonCommands.ls-build
    commands.build
  ];
};

defineProject = rootConfig: defineConfig:
  projectsLib.defineProject rootConfig defineConfig;

makeProject = project: projectsLib.makeProject project projectConfig;

makeProjects = projects: projectsLib.makeProjects projects projectConfig;

in

{
  inherit defineProject makeProject makeProjects;
}
