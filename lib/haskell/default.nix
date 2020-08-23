{
  pkgs,
  selectGhcPackages ? p: [],
  selectGhcjsPackages ? p: [],
  selectSharedPackages ? p: [],
  extraGhcExtensions ? self: super: {},
  extraGhcjsExtensions ? self: super: {},
  extraSharedExtensions ? self: super: {}
}:

let

projectsLib = import ../projects.nix { inherit pkgs; };

hlib = pkgs.haskell.lib;

# GHC

ghcSourceOverrides = hlib.packageSourceOverrides {
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
  http-media = pkgs.fetchFromGitHub {
    owner = "zmthy";
    repo = "http-media";
    rev = "917b58ff5f69f1dc7791c59f6530767d099680bf";
    sha256 = "0j9qwx8h16szj7hwkx8zar7w6b2nsvqqq5fp0aaphjqijl33x9r4";
  };
};

dataTreePrintSrc = pkgs.fetchFromGitHub {
  owner = "lspitzner";
  repo = "data-tree-print";
  rev = "c31afbdfab041dce23f696eacdd68b393309ddd5";
  sha256 = "0q4hl6s8fr82m5b7mcwbr18pv9hcyarsbd5y6ik504f5zw8jwld7";
};

ghcExtensions = pkgs.lib.composeExtensions ghcSourceOverrides (self: super: {
  stylish-haskell = hlib.dontCheck super.stylish-haskell;
  hindent = hlib.appendPatch super.hindent ./patches/hindent-5.3.1.patch;
  ghc-exactprint = super.ghc-exactprint_0_6_3_2;
  data-tree-print = hlib.appendPatch (super.callCabal2nix "data-tree-print" dataTreePrintSrc {}) ./patches/data-tree-print-0.1.0.2.patch;
  doctest = hlib.dontCheck super.doctest_0_17;
  haskell-language-server = (hlib.disableCabalFlag super.haskell-language-server "agpl").override {
    brittany = null;
  };
  haddock = hlib.dontHaddock super.haddock;
  servant = super.servant_0_18;
  servant-server = super.servant-server_0_18;
  servant-lucid = hlib.appendPatch super.servant-lucid_0_9_0_1 ./patches/servant-lucid-0.9.0.1.patch;
  miso = super.miso_1_7_1_0;
});

rootGhcPkgs = pkgs.haskell.packages.ghc8101;

ghcPkgs = rootGhcPkgs.extend (pkgs.lib.composeExtensions (pkgs.lib.composeExtensions ghcExtensions extraGhcExtensions) extraSharedExtensions);

ghcPkg = ghcPkgs.ghcWithHoogle (p: (selectGhcPackages p) ++ (selectSharedPackages p));

ghcidPkg = pkgs.ghcid;

makeGhcFlags = project: prefix: builtins.concatLists [
  [
    "${prefix}-no-user-package-db" # Only use nix dependencies.
    "${prefix}-i=${project.srcPath}"
  ]
  (map (p: "${prefix}-i=${p.srcPath}") project.dependencies)
];

makeGhcFlagsString = project: prefix: sep: builtins.concatStringsSep sep (makeGhcFlags project prefix);

# GHCJS

miso = import (pkgs.fetchFromGitHub {
  owner = "dmjio";
  repo = "miso";
  rev = "b25512dfb0cc316902c33f9825355944312d1e15";
  sha256 = "007cl5125zj0c35xim8935k0pvyd0x4fc0s7jryc3qg3pmjbszc9";
}) {};

ghcjsPkgSet = miso.pkgs;

ghcjsSourceOverrides = hlib.packageSourceOverrides {
};

ghcjsExtensions = pkgs.lib.composeExtensions ghcjsSourceOverrides (self: super: {
});

rootGhcjsPkgs = ghcjsPkgSet.haskell.packages.ghcjs86;

ghcjsPkgs = rootGhcjsPkgs.extend (pkgs.lib.composeExtensions (pkgs.lib.composeExtensions ghcjsExtensions extraGhcjsExtensions) extraSharedExtensions);

ghcjsPkg = ghcjsPkgs.ghcWithPackages (p: (selectGhcjsPackages p) ++ (selectSharedPackages p));

# COMMANDS

makeCommandsForExecutables = name: shellHook: makeScript: project:
  pkgs.lib.attrsets.mapAttrsToList
    (execName: mainFile: projectsLib.makeCommand project "${name}-${execName}" (makeScript project execName mainFile) shellHook)
    project.executables;

makeBuildDir = project: execName: "${project.buildPath}/${execName}";
makeBuildTarget = { project, execName, targetName ? "exe" }: "${makeBuildDir project execName}/${targetName}";
makeBuildTargetExe = project: execName: makeBuildTarget { inherit project execName; targetName = "exe"; };
makeBuildTargetJs = project: execName: makeBuildTarget { inherit project execName; targetName = "js"; };

commands = rec {

  # GHC COMMANDS

  ghc-flags = project: projectsLib.makeCommand project "ghc-flags" "echo -n \"${makeGhcFlagsString project "" " "}\"" false;

  ghc = project: projectsLib.makeCommand project "ghc" "${ghcPkg}/bin/ghc ${makeGhcFlagsString project "" " "} \"$@\"" false;

  ghci = project: projectsLib.makeCommand project "ghci" "${ghcPkg}/bin/ghci ${makeGhcFlagsString project "" " "} \"$@\"" false;

  hie-yaml = project:
    projectsLib.makeCommand project "hie-yaml" ''
      mkdir -p "${project.srcPath}"
      echo -ne "cradle: {direct: {arguments: [${makeGhcFlagsString project "" ", "}]}}" > "${project.srcPath}/hie.yaml"
      #cat <<EOF > "${project.srcPath}/hie.yaml"
        #cradle:
          #bios:
            #with-ghc: "PATH_TO_GHC"
            #shell: 'echo -ne "${makeGhcFlagsString project "" " "}"'
      #EOF
    '' (!project.ghcjs); #haskell-language-server is only supported for ghc

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
    buildTarget = makeBuildTargetExe project execName;
  in ''
    mkdir -p "${buildDir}"
    test -f "${buildTarget}" && rm "${buildTarget}"
    ${(ghc project).bin} -O2 -threaded +RTS -N6 -RTS --make -j6 -hidir "${project.buildArtifacts}" -odir "${project.buildArtifacts}" "${project.srcPath}/${mainFile}" -o "${buildTarget}" -rtsopts "$@" && echo "Successfully built: ${buildTarget}"
  '');

  run = makeCommandsForExecutables "run" false (project: execName: mainFile:
    let
      buildTarget = makeBuildTargetExe project execName;
      buildCommandName = projectsLib.makeCommandName {
        inherit project execName;
        commandName = "build";
      };
      buildCommand = projectsLib.findCommand buildCommandName (build project);
    in if buildCommand == false then "echo 'Build command not found: ${buildCommandName}'" else ''
      ${buildCommand.bin} -prof -fprof-auto
      ${buildTarget} "$@"
    '');

  # GHCJS COMMANDS

  ghcjs = project: projectsLib.makeCommand project "ghcjs" "${ghcjsPkg}/bin/ghcjs ${makeGhcFlagsString project "" " "} \"$@\"" false;

  buildjs = makeCommandsForExecutables "buildjs" false (project: execName: mainFile: let
    buildDir = makeBuildDir project execName;
    buildTarget = makeBuildTargetJs project execName;
  in ''
    mkdir -p "${buildDir}"
    test -f "${buildTarget}" && rm "${buildTarget}"
    ${(ghcjs project).bin} -O2 -threaded +RTS -N6 -RTS --make -j6 -hidir "${project.buildArtifacts}" -odir "${project.buildArtifacts}" "${project.srcPath}/${mainFile}" -o "${buildTarget}" "$@" && echo "Successfully built: ${buildTarget}"
  '');

  };

# PROJECTS

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
    commands.ghcjs
    commands.buildjs
  ];
};

defineProject = { executables ? {}, ghcjs ? false, ... } @ args:
  { inherit executables ghcjs; } // (projectsLib.defineProject (builtins.removeAttrs args [ "executables" "ghcjs" ]));

makeProject = project: projectsLib.makeProject project projectConfig;

makeProjects = projects: projectsLib.makeProjects projects projectConfig;

in

# EXPORTS

{
  inherit defineProject makeProject makeProjects;

  pkgs = [
    ghcPkg
    ghcidPkg
    ghcjsPkg
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
