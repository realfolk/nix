{
  description = "Haskell project dependencies and utilities.";

  inputs = {
    project-lib.url = "path:./lib/projects/lib";
  };

  outputs = { self, project-lib, ... }:
    {
      lib = {
        id = "haskell";

        shellHook = ghc: ''
          export NIX_GHC="${ghc}/bin/ghc"
          export NIX_GHCPKG="${ghc}/bin/ghc-pkg"
          export NIX_GHC_DOCDIR="${ghc}/share/doc/ghc/html"
          # Export the GHC lib dir to the environment
          # so ghcide knows how to source package dependencies.
          export NIX_GHC_LIBDIR="$(${ghc}/bin/ghc --print-libdir)"
        '';

        ghcWithPackages = { haskellPackages, haskellDependencies ? (p: []), ... }:
          haskellPackages.ghcWithPackages haskellDependencies;

        defineProject = {
          groupName,
          projectName,
          srcDir,
          buildDir,
          buildArtifactsDir,
          executables ? {},
          haskellDependencies ? (availableDependencies: []),
          localDependencies ? [],
          languageExtensions ? [],
          ...
        }:
          { inherit executables haskellDependencies localDependencies languageExtensions; } // project-lib.lib.defineProject {
            inherit
              groupName
              projectName
              srcDir
              buildDir
              buildArtifactsDir;
          };
      };
    };
}
