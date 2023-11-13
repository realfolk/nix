{ lib, ... }:

with lib;

{
  options.webDeploy.user = {
    name = mkOption {
      type = types.str;
      example = literalExpression "ponyo";
    };

    uid = mkOption {
      type = types.int;
      example = literalExpression "1001";
    };
  };
}
