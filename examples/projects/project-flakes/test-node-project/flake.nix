{
  description = "Test Node project";

  inputs = {
    node-lib.url = "github:/realfolk/nix?dir=lib/projects/node/lib";
  };

  outputs = { node-lib, ... }:
    node-lib.lib.defineProject {
      groupName = "group";
      projectName = "testnode";
      srcDir = "$PROJECT/src";
      buildDir = "$PROJECT/build";
      buildArtifactsDir = "$PROJECT/artifacts";
      executables = {
        index = "index.js";
      };
    };
}
