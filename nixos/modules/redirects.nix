{ config, lib, ... }:

with lib;

let
  redirects = config.webDeploy.redirects;
in
{
  options.webDeploy.redirects = mkOption {
    type = with types; attrsOf str;
    default = {};
    example = literalExpression
      ''
      {
        "www.qoda.fi" = "qoda.fi";
      }
      '';
  };

  config.services.nginx = {
    enable = true;
    virtualHosts = mapAttrs'
      (from: to: {
        name = from;
        value = {
          forceSSL = true;
          enableACME = true;
          globalRedirect = to;
        };
      })
      redirects;
  };
}
