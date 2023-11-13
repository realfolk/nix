{ lib, ... }:

with lib;

{
  options.webDeploy.user = {
    name = mkOption {
      type = types.str;
      example = literalExpression "ponyo";
    };
  };
}
