{ fetchFromGitHub, vimUtils, wrapNeovim, neovim-unwrapped }:
let
  plugins = import ./config/plugins.nix { inherit fetchFromGitHub; };

  buildPlugin = name: vimUtils.buildVimPluginFrom2Nix {
    pname = name;
    version = "master";
    src = builtins.getAttr name plugins;
  };
in
wrapNeovim neovim-unwrapped {
  vimAlias = true;
  configure = {
    customRC = ''
      luafile ${./config/lua/global.lua}
      luafile ${./config/lua/lsp.lua}
      colorscheme gruvbox
    '';
    packages.myVimPackage = {
      start = map buildPlugin (builtins.attrNames plugins);
    };
  };
}
