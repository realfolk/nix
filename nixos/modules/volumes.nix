{ config, lib, pkgs, utils, ... }:

with lib;

{
  imports = [
    ./user.nix
  ];

  options.webDeploy.volumes = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        device = mkOption {
          type = types.str;
          example = literalExpression "/dev/sda1";
        };

        root = mkOption {
          type = types.bool;
          default = false;
        };
      };
    });
    default = {};
    example = literalExpression
      ''
      {
        "/mnt/data" = {
          device = "/dev/sda1";
          root = true;
        };
      }
      '';
  };

  config =
    let
      volumes = config.webDeploy.volumes;
      user = config.webDeploy.user;
    in
    {
      fileSystems = builtins.mapAttrs
        (mountPath: { device, ... }: {
          inherit device;
          label = "data";
          fsType = "ext4";
          autoResize = true;
          autoFormat = false; # Manually create the filesystem before deploying once
        })
        volumes;

      systemd.services = mapAttrs'
        (mountPath: { device, ... }:
          let mountPathSystemd = utils.escapeSystemdPath mountPath; in
          {
            name = "chown-${mountPathSystemd}";
            value = {
              wantedBy = [ "multi-user.target" ];
              after = [ "${mountPathSystemd}.mount" ];
              description = "Change the ownership of ${mountPath} to ${user.name}";
              serviceConfig = {
                Type = "oneshot";
                User = "root";
                ExecStart =
                  let
                    script = pkgs.writeShellScript "chown-${mountPathSystemd}.sh" ''
                      chown -hR ${user.name} ${mountPath}
                    '';
                  in
                  "${script}";
              };
            };
          }
        )
        # Only chown volumes to webDeploy.user if root is false (default)
        (filterAttrs (mountPath: { root, ... }: !root) volumes);
    };
}
