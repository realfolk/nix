{
  pkgs,
  selectPackages ? p: [],
  packageExtensions ? self: super: {},
}:

let

projectsLib = import ../default.nix { inherit pkgs; };

hlib = pkgs.haskell.lib;

# GHC

srcs = rec {
  cryptohash-md5 = pkgs.fetchFromGitHub {
    owner = "haskell-hvr";
    repo = "cryptohash-md5";
    rev = "c5531225d9a4fb8a96347e591205ada1d89efb76";
    sha256 = "1mr9qrr6q946xvjs6vx78yp7fh1wansva2gmm49ys4qim85mqqvj";
  };
  cryptohash-sha1 = pkgs.fetchFromGitHub {
    owner = "haskell-hvr";
    repo = "cryptohash-sha1";
    rev = "10bf345b6b003e77fb96f2ff13861a9a3a149290";
    sha256 = "0g8x90sw0lg5iz9xh83i7iknf50k7f7fyx91rvsqns58d385csyf";
  };
  haddock = pkgs.fetchFromGitHub {
    owner = "haskell";
    repo = "haddock";
    rev = "3ddd7825865fd8643394354b259b2285ab3b783e";
    sha256 = "0vwh09iqvr0qprz96fyaiiq9p94sc9ahkm6qv9jg3a7l5hdf7g63";
  };
  haddock-library = "${haddock}/haddock-library";
  haddock-api = "${haddock}/haddock-api";
};

ghcExtensions = (self: super: builtins.mapAttrs (name: value: hlib.dontCheck value) {
  text-trie = hlib.appendPatch super.text-trie ./patches/text-trie-0.2.5.0.patch;
  cryptohash-md5 = hlib.appendPatch (self.callCabal2nix "cryptohash-md5" srcs.cryptohash-md5 {}) ./patches/cryptohash-md5-0.11.101.0.patch;
  cryptohash-sha1 = hlib.appendPatch (self.callCabal2nix "cryptohash-sha1" srcs.cryptohash-sha1 {}) ./patches/cryptohash-sha1-0.11.101.0.patch;
  haddock = self.callCabal2nix "haddock" srcs.haddock {};
  haddock-library = self.callCabal2nix "haddock-library" srcs.haddock-library {};
  haddock-api = self.callCabal2nix "haddock-api" srcs.haddock-api {};
  hls-pragma-plugin = hlib.dontCheck super.hls-pragma-plugin;
  hls-splice-plugin = hlib.dontCheck super.hls-splice-plugin;
  hls-class-plugin = hlib.dontCheck super.hls-class-plugin;
  haskell-language-server =
    let
      hls = pkgs.lib.foldr (flag: pkg: hlib.disableCabalFlag pkg flag) super.haskell-language-server [
        "all-formatters"
        "ormolu"
        "fourmolu"
        "brittany"
        "floskell"
      ];
    in
      hls.override {
        hls-ormolu-plugin = null;
        hls-fourmolu-plugin = null;
        hls-brittany-plugin = null;
        hls-floskell-plugin = null;
      };
});

rootGhcPkgs = pkgs.haskell.packages.ghc8104;

ghcPkgs = rootGhcPkgs.extend (pkgs.lib.composeExtensions ghcExtensions packageExtensions);

ghcPkg = ghcPkgs.ghcWithPackages (p: selectPackages p);

ghcidPkg = pkgs.ghcid;

makeGhcFlags = project: prefix: builtins.concatLists [
  [
    "${prefix}-no-user-package-db" # Only use nix dependencies.
    "${prefix}-i=${project.srcPath}"
  ]
  (map (ext: "${prefix}-X${ext}") project.languageExtensions)
  (map (p: "${prefix}-i=${p.srcPath}") project.dependencies)
];

makeGhcFlagsString =
  project: prefix: sep:
    builtins.concatStringsSep sep (makeGhcFlags project prefix);

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

  hie-bios = project: projectsLib.makeCommand {
    inherit project;
    name = "${projectTypeId}-hie-bios";
    script = ''
      test -z "$HIE_BIOS_OUTPUT" && echo "Invalid HIE_BIOS_OUTPUT environment variable" && exit 1
      test -f "$HIE_BIOS_OUTPUT" && rm "$HIE_BIOS_OUTPUT"
      touch "$HIE_BIOS_OUTPUT"
      echo -e "${makeGhcFlagsString project "" "\\n"}" >> "$HIE_BIOS_OUTPUT"
      for dir in ${builtins.concatStringsSep " " (map (p: p.srcPath) ([project] ++ project.dependencies))}
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
  #The hie-bios command above does this.
  #The below hie-yaml command reconfigures the cradle to be "bios" instead of "direct", calling the
  #above hie-bios command to dynamically generate the list of arguments to pass to ghc.
  hie-yaml = project:
    projectsLib.makeCommand {
      inherit project;
      name = "${projectTypeId}-hie-yaml";
      includeInShellHook = true;
      script = 
      ''
        mkdir -p "${project.srcPath}"
        echo -ne "cradle: {bios: {program: "${(hie-bios project).bin}"}}" > "${project.srcPath}/hie.yaml"
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
        ${(ghc project).bin} -threaded -j4 -hidir "${project.buildArtifacts}" -odir "${project.buildArtifacts}" --make "${project.srcPath}/${mainFile}" -o "${buildTarget}" "$@" && echo "Successfully built: ${buildTarget}"
    '');
  };

  build-optimized = makeCommandsForExecutables {
    name = "${projectTypeId}-build-optimized";
    makeScript = (project: subName: mainFile:
      let
        buildCommandName = projectsLib.makeCommandName {
          inherit project subName;
          name = "${projectTypeId}-build";
        };
        buildCommand = projectsLib.findCommand buildCommandName (build project);
      in "${buildCommand.bin} -O2"
    );
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
        ${buildCommand.bin} -rtsopts #allow use of +RTS...-RTS options
        ${buildTarget} "$@"
    '');
  };
};

# PROJECTS

projectConfig = {
  commands = [
    projectsLib.commonCommands.mkdir-src
    projectsLib.commonCommands.pwd-src
    projectsLib.commonCommands.pwd-build
    projectsLib.commonCommands.cd-src
    projectsLib.commonCommands.cd-build
    projectsLib.commonCommands.ls-src
    projectsLib.commonCommands.ls-build
    commands.ghc-flags
    commands.ghc
    commands.ghci
    commands.docs
    commands.hie-bios
    commands.hie-yaml
    commands.ghcid
    commands.build
    commands.build-optimized
    commands.run
  ];
};

defineProject = rootConfig: { executables ? {}, dependencies ? [], languageExtensions ? [], ... }@args:
  { inherit executables dependencies languageExtensions; } // (projectsLib.defineProject rootConfig (builtins.removeAttrs args [ "executables" "dependencies" ]));

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
      #formatters bundled with haskell-language-server
      #no need to install them separately
      ghcPkgs.haskell-language-server
    ];
    ghc = ghcPkg;
    ghcPkgs = ghcPkgs;
    ghcid = ghcidPkg;
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
