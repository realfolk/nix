{
  description = "Test Static project";

  inputs = {
    static-lib = {
      url = "github:realfolk/nix?dir=lib/projects/static/lib";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { static-lib, ... }:
    static-lib.lib.defineProject {
      groupName = "group";
      projectName = "teststatic";
      srcDir = "$PROJECT/src";
      buildDir = "$PROJECT/build";
      buildArtifactsDir = "$PROJECT/artifacts";
    };
}
