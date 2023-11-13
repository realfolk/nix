{ lib, ... }:

with lib;

{
  options.webDeploy.user = mkOption {
    type = with types; submodule {
      options = {
        name = mkOption {
          type = str;
          example = literalExpression "ponyo";
        };

        uid = mkOption {
          type = int;
          example = literalExpression "1001";
        };
      };
    };

    example = literalExpression
      ''
      {
        name = "ponyo";
        uid = 1001;
      }
      '';
  };
}
