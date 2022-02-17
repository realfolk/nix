{
  description = "Test Elm project";

  inputs = {
    elm-lib.url = "github:realfolk/nix?dir=lib/projects/elm/lib";
  };

  outputs = { elm-lib, ... }:
    elm-lib.lib.defineProject {
      groupName = "group";
      projectName = "testelm";
      srcDir = "$PROJECT/src";
      buildDir = "$PROJECT/build";
      buildArtifactsDir = "$PROJECT/artifacts";
      entryPoints = {
        main = "Main.elm";
      };
    };
}
