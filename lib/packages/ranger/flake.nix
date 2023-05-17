{
  description = "Real Folk's custom-configured Ranger.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=22.11";
    flakeUtils.url = "github:numtide/flake-utils";
    ranger-src = { url = "github:ranger/ranger"; flake = false; };
  };

  outputs = { self, nixpkgs, flakeUtils, ranger-src, ... }:
    flakeUtils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python3Packages = pkgs.python3Packages;
        lib = pkgs.lib;
        highlight = pkgs.highlight;
        file = pkgs.file;
        less = pkgs.less;
        w3m = pkgs.w3m;
        imagePreviewSupport = true;

        rifleConf = pkgs.writeText "rifle.conf" (builtins.readFile ./config/rifle.conf);

        ranger = python3Packages.buildPythonApplication rec {
          pname = "ranger";
          version = "master";
          src = ranger-src;
          LC_ALL = "en_US.UTF-8";
          doCheck = false;

          propagatedBuildInputs = [ file python3Packages.astroid python3Packages.pylint ]
            ++ lib.optionals (imagePreviewSupport) [ python3Packages.pillow ];

          preConfigure = ''
                        #UPSTREAM
            						${lib.optionalString (highlight != null) ''
            							sed -i -e 's|^\s*highlight\b|${highlight}/bin/highlight|' \
            								ranger/data/scope.sh
            						''}
            						substituteInPlace ranger/__init__.py \
            							--replace "DEFAULT_PAGER = 'less'" "DEFAULT_PAGER = '${lib.getBin less}/bin/less'"
            						# give file previews out of the box
            						substituteInPlace ranger/config/rc.conf \
            							--replace /usr/share $out/share \
            							--replace "#set preview_script ~/.config/ranger/scope.sh" "set preview_script $out/share/doc/ranger/config/scope.sh"
            					'' + lib.optionalString imagePreviewSupport ''
            						substituteInPlace ranger/ext/img_display.py \
            							--replace /usr/lib/w3m ${w3m}/libexec/w3m
            						# give image previews out of the box when building with w3m
            						substituteInPlace ranger/config/rc.conf \
            							--replace "set preview_images false" "set preview_images true"

                        # CUSTOM
                        # add custom rifle.conf
                        cat "${rifleConf}" > ranger/config/rifle.conf;
            					'';
        };

      in
      {
        overlays.default = final: prev: {
          inherit ranger;
        };

        packages.default = ranger;
      });
}
