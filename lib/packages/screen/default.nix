{ pkgs }:

let

screenrc = builtins.readFile ./screenrc;

in

pkgs.screen.overrideAttrs (oldAttrs: {
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postInstall = ''
    wrapProgram $out/bin/${oldAttrs.pname} --add-flags '-c "${screenrc}"'
  '';
})
