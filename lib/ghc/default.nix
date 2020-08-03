{ pkgs, selectHaskellPackages, extraHaskellExtensions ? self: super: {} }:

let

projectsLib = import ../projects.nix { inherit pkgs; };

hlib = pkgs.haskell.lib;

rootHaskellPkgs = pkgs.haskell.packages.ghc8101;

haskellSourceOverrides = hlib.packageSourceOverrides {
  th-expand-syns = pkgs.fetchFromGitHub {
    owner = " DanielSchuessler";
    repo = "th-expand-syns";
    rev = "5d41fb524a631fa2c087207701822f4e6313f547";
    sha256 = "0v4dlyxjy7hrcw14hanlgcfyns4wi50lhwzpsjg34pcdzy6g4fh6";
  };
  czipwith = pkgs.fetchFromGitHub {
    owner = "lspitzner";
    repo = "czipwith";
    rev = "b876669e74ce5ca9e183c0bc53b90fc6a946e799";
    sha256 = "0psaydskbkfxyl2466nxw1bm3hx6cbm543xvqrbmhkbprbz2rkxh";
  };
};

hlsSrc = pkgs.fetchFromGitHub {
  owner = "haskell";
  repo = "haskell-language-server";
  rev = "7ad18cfa2d358e9def610dff1c113c87eb0eb19c";
  sha256 = "1j76wgfngil40qji29b76x20m4n6vdkz18i18y5yn71izxna2i8n";
};

dataTreePrintSrc = pkgs.fetchFromGitHub {
  owner = "lspitzner";
  repo = "data-tree-print";
  rev = "c31afbdfab041dce23f696eacdd68b393309ddd5";
  sha256 = "0q4hl6s8fr82m5b7mcwbr18pv9hcyarsbd5y6ik504f5zw8jwld7";
};

haskellExtensions = pkgs.lib.composeExtensions haskellSourceOverrides (self: super: {
  stylish-haskell = hlib.appendPatch super.stylish-haskell ./patches/stylish-haskell-0.11.0.0.patch;
  hindent = hlib.appendPatch super.hindent ./patches/hindent-5.3.1.patch;
  ghc-exactprint = super.ghc-exactprint_0_6_3_1;
  data-tree-print = hlib.appendPatch (super.callCabal2nix "data-tree-print" dataTreePrintSrc {}) ./patches/data-tree-print-0.1.0.2.patch;
  doctest = hlib.dontCheck super.doctest_0_17;
  haskell-language-server_0_2 = hlib.dontCheck (super.callCabal2nixWithOptions "haskell-language-server" hlsSrc "-f -agpl" {
    ormolu = super.ormolu_0_0_5_0;
    ghcide = super.hls-ghcide;
  });
  haddock = hlib.dontHaddock super.haddock;
});

haskellPkgs = rootHaskellPkgs.extend (pkgs.lib.composeExtensions haskellExtensions extraHaskellExtensions);

ghcPkg = haskellPkgs.ghcWithHoogle selectHaskellPackages;

ghcidPkg = pkgs.ghcid;

makeGhcFlags = project: prefix: builtins.concatLists [
  [
    "${prefix}-no-user-package-db" # Only use nix dependencies.
    "${prefix}-i=${project.srcPath}"
  ]
  (map (p: "${prefix}-i=${p.srcPath}") project.dependencies)
];

makeGhcFlagsString = project: prefix: sep: builtins.concatStringsSep sep (makeGhcFlags project prefix);

makeCommandsForExecutables = name: shellHook: makeScript: project:
  pkgs.lib.attrsets.mapAttrsToList
    (execName: mainFile: projectsLib.makeCommand project "${name}-${execName}" (makeScript project execName mainFile) shellHook)
    project.executables;

makeBuildDir = project: execName: "${project.buildPath}/${execName}";
makeBuildTarget = project: execName: "${makeBuildDir project execName}/exe";

commands = rec {

  ghc-flags = project: projectsLib.makeCommand project "ghc-flags" "echo -n \"${makeGhcFlagsString project "" " "}\"" false;

  ghc = project: projectsLib.makeCommand project "ghc" "${ghcPkg}/bin/ghc ${makeGhcFlagsString project "" " "} \"$@\"" false;

  ghci = project: projectsLib.makeCommand project "ghci" "${ghcPkg}/bin/ghci ${makeGhcFlagsString project "" " "} \"$@\"" false;

  hie-yaml = project:
    projectsLib.makeCommand project "hie-yaml" ''
      mkdir -p "${project.srcPath}"
      echo -ne "cradle: {direct: {arguments: [${makeGhcFlagsString project "" ", "}]}}" > "${project.srcPath}/hie.yaml"
    '' true;

  ghcid = makeCommandsForExecutables "ghcid" false (project: execName: mainFile: ''
      ${ghcidPkg}/bin/ghcid --command=${(ghci project).bin} --test=main --reload "${project.srcPath}" "${project.srcPath}/${mainFile}" "$@"
    '');

    docs = makeCommandsForExecutables "docs" false (project: execName: mainFile: let
      buildDir = "${makeBuildDir project execName}/docs";
    in ''
      interface_cmds=$(find -L "${ghcPkg}/share/doc" -iname "*.haddock" | sed -e 's|\(.*\)\(/[^/]\+\)|-i \1,\1\2|')
      test -d "${buildDir}" && rm -rf "${buildDir}"
      mkdir -p ${buildDir}
      ${ghcPkg}/bin/haddock -h ${makeGhcFlagsString project "--optghc=" " "} -o ${buildDir} $interface_cmds "$@" --package-name=${project.name} "${project.srcPath}/${mainFile}"
  '');

  build = makeCommandsForExecutables "build" false (project: execName: mainFile: let
    buildDir = makeBuildDir project execName;
    buildTarget = makeBuildTarget project execName;
  in ''
    mkdir -p "${buildDir}"
    test -f "${buildTarget}" && rm "${buildTarget}"
    ${(ghc project).bin} -O2 -threaded +RTS -N8 -RTS --make -j8 -hidir "${project.buildArtifacts}" -odir "${project.buildArtifacts}" "${project.srcPath}/${mainFile}" -o "${buildTarget}" -prof -fprof-auto -rtsopts "$@" && echo "Successfully built: ${buildTarget}"
    #${(ghc project).bin} -O2 -threaded +RTS -N8 -RTS --make -j8 -hidir "${project.buildArtifacts}" -odir "${project.buildArtifacts}" "${project.srcPath}/${mainFile}" -o "${buildTarget}" -prof -fprof-auto -rtsopts -static -optl-pthread -optl-static "$@" && echo "Successfully built: ${buildTarget}"
  '');

  run = makeCommandsForExecutables "run" false (project: execName: mainFile:
    let
      buildTarget = makeBuildTarget project execName;
      buildCommandName = projectsLib.makeCommandName {
        inherit project execName;
        commandName = "build";
      };
      buildCommand = projectsLib.findCommand buildCommandName (build project);
    in if buildCommand == false then "echo 'Build command not found: ${buildCommandName}'" else ''
      ${buildCommand.bin}
      ${buildTarget} "$@"
    '');

  };

projectConfig = {
  commands = [
    projectsLib.commands.cd
    commands.ghc-flags
    commands.ghc
    commands.ghci
    commands.docs
    commands.hie-yaml
    commands.ghcid
    commands.build
    commands.run
  ];
};

defineProject = { executables ? {}, ... } @ args:
  { inherit executables; } // (projectsLib.defineProject (builtins.removeAttrs args [ "executables" ]));

makeProject = project: projectsLib.makeProject project projectConfig;

makeProjects = projects: projectsLib.makeProjects projects projectConfig;

in

{
  inherit defineProject makeProject makeProjects;

  pkgs = [
    ghcPkg
    ghcidPkg
    #following used for static linking of built binaries
    #pkgs.gmp5.static
    #pkgs.glibc.static
    #pkgs.zlib.static
    #pkgs.zlib.dev
    #pkgs.lmdb.dev
    #(pkgs.libffi.overrideAttrs (old: { dontDisableStatic = true; }))
  ];

  shellHook = ''
    export NIX_GHC="${ghcPkg}/bin/ghc"
    export NIX_GHCPKG="${ghcPkg}/bin/ghc-pkg"
    export NIX_GHC_DOCDIR="${ghcPkg}/share/doc/ghc/html"
    # Export the GHC lib dir to the environment
    # so ghcide knows how to source package dependencies.
    export NIX_GHC_LIBDIR="$(${ghcPkg}/bin/ghc --print-libdir)"
  '';
}
