{
  description = "Real Folk's project utility functions.";
  outputs = { self }:
    {
      lib = rec {
        defineProject = {
          groupName,
          projectName,
          srcDir,
          buildDir,
          buildArtifactsDir,
          ...
        }:
          {
            inherit groupName projectName;
            srcPath = "${srcDir}/${groupName}/${projectName}";
            buildPath = "${buildDir}/${groupName}/${projectName}";
            buildArtifactsPath = "${buildArtifactsDir}/${groupName}/${projectName}";
          };

        commandName = { groupName, projectName, ... }: commandName:
          "${groupName}-${projectName}-${commandName}";

        makeCommand = { project, name, script, writeShellScriptBin }:
          let
            fullName = commandName project name;
            package = writeShellScriptBin fullName script;
            bin = "${package}/bin/${fullName}";
          in
          {
            inherit package bin;
            name = fullName;
          };
      };
    };
}
