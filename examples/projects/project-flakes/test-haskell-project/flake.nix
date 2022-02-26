{
  description = "Test Haskell project";

  inputs = {
    haskell-lib.url = "github:/realfolk/nix?dir=lib/projects/haskell/lib";
  };

  outputs = { haskell-lib, ... }:
    haskell-lib.lib.defineProject {
      groupName = "group";
      projectName = "testhaskell";
      srcDir = "$PROJECT/src";
      buildDir = "$PROJECT/build";
      buildArtifactsDir = "$PROJECT/artifacts";
      executables = {
        main = "Main.hs";
      };
      haskellDependencies = p: with p; [
        aeson
        cryptonite
      ];
    };
}
