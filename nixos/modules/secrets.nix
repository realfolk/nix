{ config, lib, ... }:

with lib;

let
  secrets = config.webDeploy.secrets;
in
{
  imports = [
    ./user.nix
  ];

  options.webDeploy.secrets = mkOption {
    type = with types; attrsOf path;
    default = {};
    example = literalExpression
      ''
      {
        name = ./path/to/secret.age;
      }
      '';
  };

  config.age.secrets =
    let
      owner = config.webDeploy.user.name;
    in
    builtins.mapAttrs (name: file: { inherit file owner; }) secrets;
}
