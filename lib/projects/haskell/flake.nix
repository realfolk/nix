{
  description = "A flake for Haskell projects.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    projectLib.url = "github:realfolk/nix?dir=lib/projects/lib";
  };

  outputs = { self, nixpkgs, projectLib, ... }:
    let
      id = "haskell";

      ghcWithPackages = { haskellPackages, haskellDependencies ? (p: [ ]), ... }:
        haskellPackages.ghcWithPackages haskellDependencies;

      defineProject =
        { groupName
        , projectName
        , srcDir
        , buildDir
        , buildArtifactsDir
        , executables ? { }
        , haskellDependencies ? (availableDependencies: [ ])
        , localDependencies ? [ ]
        , languageExtensions ? [ ]
        , ...
        }:
        { inherit executables haskellDependencies localDependencies languageExtensions; } // projectLib.lib.defineProject {
          inherit
            groupName
            projectName
            srcDir
            buildDir
            buildArtifactsDir;
        };

      make = { system, haskellPackages, project, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          ghcPkg = haskellPackages.ghcWithPackages (availableDependencies:
            builtins.concatLists [
              (project.haskellDependencies availableDependencies)
              # Add the haskell dependencies of all local dependencies.
              (builtins.concatMap (project_: project_.haskellDependencies availableDependencies) project.localDependencies)
            ]);

          makeGhcFlags = prefix: builtins.concatLists [
            [
              "${prefix}-no-user-package-db" # Only use nix dependencies.
              "${prefix}-i=${project.srcPath}"
            ]
            (map (ext: "${prefix}-X${ext}") project.languageExtensions)
            (map (p: "${prefix}-i=${p.srcPath}") project.localDependencies)
          ];

          makeGhcFlagsString =
            prefix: sep:
            builtins.concatStringsSep sep (makeGhcFlags prefix);

          makeCommand = args: projectLib.lib.makeCommand (args // {
            inherit project;
            writeShellScriptBin = pkgs.writeShellScriptBin;
          });

          makeCommandsForExecutables = { name, makeScript }:
            pkgs.lib.attrsets.mapAttrs'
              (executableName: mainFile:
                let
                  scriptName = "${name}-${executableName}";
                in
                pkgs.lib.attrsets.nameValuePair scriptName (makeCommand {
                  name = scriptName;
                  script = makeScript executableName mainFile;
                }))
              project.executables;

          makeBuildDir = dirName: "${project.buildPath}/${id}/${dirName}";
          makeBuildTarget = { dirName, targetName }: "${makeBuildDir dirName}/${targetName}";
          makeBuildTargetGhc = dirName: makeBuildTarget { inherit dirName; targetName = "out.ghc"; };

          # COMMANDS

          ghcFlags = makeCommand {
            name = "${id}-ghc-flags";
            script = "echo -n \"${makeGhcFlagsString "" " "}\"";
          };

          ghc = makeCommand {
            name = "${id}-ghc";
            script = "${ghcPkg}/bin/ghc ${makeGhcFlagsString "" " "} \"$@\"";
          };

          ghcPkgCommand = makeCommand {
            name = "${id}-ghc-pkg";
            script = "${ghcPkg}/bin/ghc-pkg \"$@\"";
          };

          ghci = makeCommand {
            name = "${id}-ghci";
            script = "${ghcPkg}/bin/ghci ${makeGhcFlagsString "" " "} \"$@\"";
          };

          hieBios = makeCommand {
            name = "${id}-hie-bios";
            script = ''
              test -z "$HIE_BIOS_OUTPUT" && echo "Invalid HIE_BIOS_OUTPUT environment variable" && exit 1
              test -f "$HIE_BIOS_OUTPUT" && rm "$HIE_BIOS_OUTPUT"
              touch "$HIE_BIOS_OUTPUT"
              echo -e "${makeGhcFlagsString "" "\\n"}" >> "$HIE_BIOS_OUTPUT"
              for dir in ${builtins.concatStringsSep " " (map (p: p.srcPath) ([project] ++ project.localDependencies))}
              do
                cd "$dir"
                find . -iname '*.hs' -exec bash -c 'echo "$(dirname $1)/$(basename $1 .hs)" | sed "s/^\(\.\/\|\/\)// ; s/\/\+/./g" >> "$HIE_BIOS_OUTPUT"' bash {} \;
              done
            '';
          };

          #See https://github.com/haskell/haskell-language-server/issues/826#issuecomment-708647758
          #We need to explicitly list each module (both in the project.srcPath and all dependency srcPaths)
          #for haskell-language-server to work.
          #Consequently, we cannot use a direct cradle, we need to dynamically generate this list of modules.
          #The hieBios command above does this.
          #The below hieYaml command reconfigures the cradle to be "bios" instead of "direct", calling the
          #above hieBios command to dynamically generate the list of arguments to pass to ghc.
          hieYaml = makeCommand {
            name = "${id}-hie-yaml";
            script =
              ''
                mkdir -p "${project.srcPath}"
                echo -ne "cradle: {bios: {program: "${hieBios.bin}"}}" > "${project.srcPath}/hie.yaml"
              '';
          };

          ghcid = makeCommandsForExecutables {
            name = "${id}-ghcid";
            makeScript = (executableName: mainFile: ''
              ${pkgs.ghcid}/bin/ghcid --command=${ghci.bin} --test=main --reload "${project.srcPath}" "${project.srcPath}/${mainFile}" "$@"
            '');
          };

          docs = makeCommandsForExecutables {
            name = "${id}-docs";
            makeScript = (executableName: mainFile:
              let
                buildDir = "${makeBuildDir executableName}/docs";
              in
              ''
                interface_cmds=$(find -L "${ghcPkg}/share/doc" -iname "*.haddock" | sed -e 's|\(.*\)\(/[^/]\+\)|-i \1,\1\2|')
                test -d "${buildDir}" && rm -rf "${buildDir}"
                mkdir -p ${buildDir}
                ${ghcPkg}/bin/haddock -h ${makeGhcFlagsString "--optghc=" " "} -o ${buildDir} $interface_cmds "$@" --package-name=${project.projectName} "${project.srcPath}/${mainFile}"
              '');
          };

          build = makeCommandsForExecutables {
            name = "${id}-build";
            makeScript = (executableName: mainFile:
              let
                buildDir = makeBuildDir executableName;
                buildTarget = makeBuildTargetGhc executableName;
              in
              ''
                mkdir -p "${buildDir}"
                test -f "${buildTarget}" && rm "${buildTarget}"
                ${ghc.bin} -threaded -j4 -hidir "${project.buildArtifactsPath}" -odir "${project.buildArtifactsPath}" --make "${project.srcPath}/${mainFile}" -o "${buildTarget}" "$@" && echo "Successfully built: ${buildTarget}"
              '');
          };

          buildOptimized = makeCommandsForExecutables {
            name = "${id}-build-optimized";
            makeScript = (executableName: mainFile:
              let
                buildCommandName = "${id}-build-${executableName}";
                buildCommand = build.${buildCommandName};
              in
              "${buildCommand.bin} -O2 \"$@\""
            );
          };

          run = makeCommandsForExecutables {
            name = "${id}-run";
            makeScript = (executableName: mainFile:
              let
                buildTarget = makeBuildTargetGhc executableName;
                buildCommandName = "${id}-build-${executableName}";
                buildCommand = build.${buildCommandName};
              in
              ''
                ${buildCommand.bin} -rtsopts #allow use of +RTS...-RTS options
                ${buildTarget} "$@"
              '');
          };

          commands = {
            inherit ghcFlags ghc ghci hieBios hieYaml;
            ghcPkg = ghcPkgCommand;
          }
          // ghcid
          // docs
          // build
          // buildOptimized
          // run;

          combinedCommandsPackage = pkgs.symlinkJoin {
            name = "${id}-commands-${project.groupName}-${project.projectName}";
            paths = builtins.map ({ package, ... }: package) (builtins.attrValues commands);
          };
        in
        {
          inherit commands combinedCommandsPackage;
          ghc = ghcPkg;
        };
    in
    {
      lib = {
        inherit id defineProject make;
        shellHook = ghc: ''
          export NIX_GHC="${ghc}/bin/ghc"
          export NIX_GHCPKG="${ghc}/bin/ghc-pkg"
          export NIX_GHC_DOCDIR="${ghc}/share/doc/ghc/html"
          # Export the GHC lib dir to the environment
          # so ghcide knows how to source package dependencies.
          export NIX_GHC_LIBDIR="$(${ghc}/bin/ghc --print-libdir)"
        '';
      };
    };
}
