{
  description = "Elm project dependencies and utilities.";

  inputs = {
    project-lib.url = "github:realfolk/nix?dir=lib/projects/lib";
  };

  outputs = { self, project-lib, ... }:
    {
      lib = {
        id = "elm";
        defineProject = {
          groupName,
          projectName,
          srcDir,
          buildDir,
          buildArtifactsDir,
          entryPoints ? {},
          ...
        }:
          { inherit entryPoints; } // project-lib.lib.defineProject {
            inherit
              groupName
              projectName
              srcDir
              buildDir
              buildArtifactsDir;
          };
      };
    };
}
