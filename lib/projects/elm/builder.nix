# Useful for building Elm projects with elm2nix.

{ lib, stdenv, elmPackages }:
{
  overrideSrcDirs =
    { elmJSON # builtins.readFile ./elm.json
    , overrides # { "../../extra/src" = "/nix/store/xyz-extra-src"; }
    }:
    let
      elmJSON0 = builtins.fromJSON elmJSON;
      elmJSON1 = elmJSON0 // {
        source-directories = map (oldSrcDir: if overrides ? "${oldSrcDir}" then overrides."${oldSrcDir}" else oldSrcDir) elmJSON0.source-directories;
      };
    in
    builtins.toJSON elmJSON1;

  make =
    { name
    , src
    , system
    , elmPackages
    , packageSrcs # elm2nix convert
    , registryData # elm2nix snapshot
    , entryPoints ? { } # { main = "Main.elm"; } # Path relative to "${src}/src" directory
    , extraBuildPhase ? ""
    , extraElmMakeFlags ? ""
    , ...
    }:
    let
      derivation = stdenv.mkDerivation {
        inherit name src;

        buildInputs = [ elmPackages.elm ];

        buildPhase =
          let
            fetchElmDeps = elmPackages.fetchElmDeps {
              elmVersion = elmPackages.elm.version;
              elmPackages = packageSrcs;
              registryDat = registryData;
            };
          in
          lib.concatStrings [ fetchElmDeps "\n" extraBuildPhase ];

        installPhase =
          let
            compileEntryPoint = entryPointName: entryPoint:
              let
                outputFile = "$out/var/${entryPointName}/out.js";
                docFile = "$out/share/doc/${entryPointName}/doc.json";
                entryPointFile = "src/${entryPoint}";
              in
              ''
                echo "Compiling ${entryPointName}: ${entryPointFile}"
                elm make ${entryPointFile} "--output=${outputFile}" "--docs=${docFile}" "${extraElmMakeFlags}"
              '';
          in
          lib.concatStrings (builtins.attrValues (builtins.mapAttrs compileEntryPoint entryPoints));
      };

      buildFiles = builtins.mapAttrs
        (entryPointName: _: {
          output = "${derivation}/var/${entryPointName}/out.js";
          doc = "${derivation}/share/doc/${entryPointName}/doc.json";
        })
        entryPoints;
    in
    {
      inherit derivation buildFiles;
    };
}
