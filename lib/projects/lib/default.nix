{ writeShellScriptBin }:
let
  commandName = { groupName, projectName, ... }: name:
    "${groupName}-${projectName}-${name}";
in
{
  defineProject = { srcDir, buildDir, buildArtifactsDir }: { groupName, projectName, ... }:
    {
      inherit groupName projectName;
      srcPath = "${srcDir}/${groupName}/${projectName}";
      buildPath = "${buildDir}/${groupName}/${projectName}";
      buildArtifactsPath = "${buildArtifactsDir}/${groupName}/${projectName}";
    };

  makeCommand = project: { name, script }:
    let
      fullName = commandName project name;
      package = writeShellScriptBin fullName script;
      bin = "${package}/bin/${fullName}";
    in
    {
      inherit package bin;
      name = fullName;
    };
}
