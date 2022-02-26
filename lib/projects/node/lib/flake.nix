{
  description = "Node.js project dependencies and utilities.";

  inputs = {
    project-lib.url = "path:./lib/projects/lib";
  };

  outputs = { self, project-lib, ... }:
    {
      lib = {
        id = "node";
        defineProject = {
          groupName,
          projectName,
          srcDir,
          buildDir,
          buildArtifactsDir,
          executables ? {},
          ...
        }:
          { inherit executables; } // project-lib.lib.defineProject {
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
