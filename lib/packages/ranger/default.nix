{ lib, fetchFromGitHub, writeText,
  python3Packages, highlight, file, less, w3m,
  imagePreviewSupport ? true
}:
let
  rifleConf = writeText "rifle.conf" (builtins.readFile ./config/rifle.conf);
in
python3Packages.buildPythonApplication rec {
  pname = "ranger";
  version = "master";
  src = fetchFromGitHub {
    owner = "ranger";
    repo = "ranger";
    rev = "fe7c3b28067a00b0715399d811437545edb83e71";
    hash = "sha256-KPCts1MimDQYljoPR4obkbfFT8gH66c542CMG9UW7O0=";
  };
  LC_ALL = "en_US.UTF-8";
  doCheck = false;

  propagatedBuildInputs = [ file python3Packages.astroid python3Packages.pylint ]
    ++ lib.optionals imagePreviewSupport [ python3Packages.pillow ];

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
}
