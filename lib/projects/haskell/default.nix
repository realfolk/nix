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

projectsLib = import ../default.nix { inherit pkgs; };

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
  text-trie = hlib.dontCheck (hlib.appendPatch super.text-trie ./patches/text-trie-0.2.5.0.patch);
  ghc-exactprint = super.ghc-exactprint_0_6_3_2;
  data-tree-print = hlib.appendPatch (self.callCabal2nix "data-tree-print" dataTreePrintSrc {}) ./patches/data-tree-print-0.1.0.2.patch;
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

ghcPkg = ghcPkgs.ghcWithPackages (p: (selectGhcPackages p) ++ (selectSharedPackages p));

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

projectTypeId = "haskell";

makeCommandsForExecutables = { name, makeScript, includeInShellHook ? false }: project:
  pkgs.lib.attrsets.mapAttrsToList
    (subName: mainFile: projectsLib.makeCommand {
      inherit name subName project includeInShellHook;
      script = (makeScript project subName mainFile);
    })
    project.executables;

makeBuildDir = project: dirName: "${project.buildPath}/${projectTypeId}/${dirName}";
makeBuildTarget = { project, dirName, targetName }: "${makeBuildDir project dirName}/${targetName}";
makeBuildTargetGhc = project: dirName: makeBuildTarget { inherit project dirName; targetName = "out.ghc"; };
makeBuildTargetGhcJs = project: dirName: makeBuildTarget { inherit project dirName; targetName = "out.ghcjs"; };

commands = rec {

  # GHC COMMANDS

  ghc-flags = project: projectsLib.makeCommand {
    inherit project;
    name = "${projectTypeId}-ghc-flags";
    script = "echo -n \"${makeGhcFlagsString project "" " "}\"";
  };

  ghc = project: projectsLib.makeCommand {
    inherit project;
    name = "${projectTypeId}-ghc";
    script = "${ghcPkg}/bin/ghc ${makeGhcFlagsString project "" " "} \"$@\"";
  };

  ghci = project: projectsLib.makeCommand {
    inherit project;
    name = "${projectTypeId}-ghci";
    script = "${ghcPkg}/bin/ghci ${makeGhcFlagsString project "" " "} \"$@\"";
  };

  hie-yaml = project:
    projectsLib.makeCommand {
      inherit project;
      name = "${projectTypeId}-hie-yaml";
      includeInShellHook = true; #TODO haskell-language-server is only supported for ghc
      script = ''
        mkdir -p "${project.srcPath}"
        echo -ne "cradle: {direct: {arguments: [${makeGhcFlagsString project "" ", "}]}}" > "${project.srcPath}/hie.yaml"
        #cat <<EOF > "${project.srcPath}/hie.yaml"
          #cradle:
            #bios:
              #with-ghc: "PATH_TO_GHC"
              #shell: 'echo -ne "${makeGhcFlagsString project "" " "}"'
        #EOF
      '';
    };

    ghcid = makeCommandsForExecutables {
      name = "${projectTypeId}-ghcid";
      makeScript = (project: subName: mainFile: ''
        ${ghcidPkg}/bin/ghcid --command=${(ghci project).bin} --test=main --reload "${project.srcPath}" "${project.srcPath}/${mainFile}" "$@"
      '');
    };

    docs = makeCommandsForExecutables {
      name = "${projectTypeId}-docs";
      makeScript = (project: subName: mainFile:
        let
          buildDir = "${makeBuildDir project subName}/docs";
        in ''
          interface_cmds=$(find -L "${ghcPkg}/share/doc" -iname "*.haddock" | sed -e 's|\(.*\)\(/[^/]\+\)|-i \1,\1\2|')
          test -d "${buildDir}" && rm -rf "${buildDir}"
          mkdir -p ${buildDir}
          ${ghcPkg}/bin/haddock -h ${makeGhcFlagsString project "--optghc=" " "} -o ${buildDir} $interface_cmds "$@" --package-name=${project.name} "${project.srcPath}/${mainFile}"
      '');
    };

    build = makeCommandsForExecutables {
      name = "${projectTypeId}-build";
      makeScript = (project: subName: mainFile:
        let
          buildDir = makeBuildDir project subName;
          buildTarget = makeBuildTargetGhc project subName;
        in ''
          mkdir -p "${buildDir}"
          test -f "${buildTarget}" && rm "${buildTarget}"
          ${(ghc project).bin} -O2 -threaded +RTS -N6 -RTS --make -j6 -hidir "${project.buildArtifacts}" -odir "${project.buildArtifacts}" "${project.srcPath}/${mainFile}" -o "${buildTarget}" -rtsopts "$@" && echo "Successfully built: ${buildTarget}"
      '');
    };

    run = makeCommandsForExecutables {
      name = "${projectTypeId}-run";
      makeScript = (project: subName: mainFile:
        let
          buildTarget = makeBuildTargetGhc project subName;
          buildCommandName = projectsLib.makeCommandName {
            inherit project subName;
            name = "${projectTypeId}-build";
          };
          buildCommand = projectsLib.findCommand buildCommandName (build project);
        in if buildCommand == false then "echo 'Build command not found: ${buildCommandName}'" else ''
          ${buildCommand.bin}
          ${buildTarget} "$@"
      '');
    };

  # GHCJS COMMANDS

  ghcjs = project: projectsLib.makeCommand {
    inherit project;
    name = "${projectTypeId}-ghcjs";
    script = "${ghcjsPkg}/bin/ghcjs ${makeGhcFlagsString project "" " "} \"$@\"";
  };

  buildjs = makeCommandsForExecutables {
    name = "${projectTypeId}-buildjs";
    makeScript = (project: subName: mainFile:
      let
        buildDir = makeBuildDir project subName;
        buildTarget = makeBuildTargetGhcJs project subName;
      in ''
        mkdir -p "${buildDir}"
        test -f "${buildTarget}" && rm "${buildTarget}"
        ${(ghcjs project).bin} -O2 -threaded +RTS -N6 -RTS --make -j6 -hidir "${project.buildArtifacts}" -odir "${project.buildArtifacts}" "${project.srcPath}/${mainFile}" -o "${buildTarget}" "$@" && echo "Successfully built: ${buildTarget}"
    '');
  };

};

# PROJECTS

projectConfig = {
  commands = [
    projectsLib.commonCommands.cd-src
    projectsLib.commonCommands.cd-build
    projectsLib.commonCommands.ls-src
    projectsLib.commonCommands.ls-build
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

defineProject = rootConfig: { executables ? {}, dependencies ? [], ... }@args:
  { inherit executables dependencies; } // (projectsLib.defineProject rootConfig (builtins.removeAttrs args [ "executables" "dependencies" ]));

makeProject = project: projectsLib.makeProject project projectConfig;

makeProjects = projects: projectsLib.makeProjects projects projectConfig;

in

# EXPORTS

{
  inherit defineProject makeProject makeProjects;

  pkgs = {
    all = [
      ghcPkg
      ghcidPkg
      ghcjsPkg
    ];
    ghc = ghcPkg;
    ghcid = ghcidPkg;
    ghcjs = ghcjsPkg;
  };

  shellHook = ''
    export NIX_GHC="${ghcPkg}/bin/ghc"
    export NIX_GHCPKG="${ghcPkg}/bin/ghc-pkg"
    export NIX_GHC_DOCDIR="${ghcPkg}/share/doc/ghc/html"
    # Export the GHC lib dir to the environment
    # so ghcide knows how to source package dependencies.
    export NIX_GHC_LIBDIR="$(${ghcPkg}/bin/ghc --print-libdir)"
  '';
}
