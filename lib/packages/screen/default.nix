{ pkgs }:

let

screenrc = pkgs.writeText "screenrc" ''
  #env
  setenv SCREENRC_NIX_SHELL "$((test -x shell.sh && echo -n ./shell.sh) || (test -f shell.nix && test -z \"$IN_NIX_SHELL\" && echo -n nix-shell))"

  #change command character from C-a to C-f
  escape ^Ff

  #shortcuts
  bind b screen -t shell bash
  bind ^b screen -t shell bash
  bind c screen -t shell bash -c "$SCREENRC_NIX_SHELL || bash"
  bind ^c screen -t shell bash -c "$SCREENRC_NIX_SHELL || bash"
  bind v screen -t vim bash -c "$SCREENRC_NIX_SHELL --command vim || vim"
  bind ^v screen -t vim bash -c "$SCREENRC_NIX_SHELL --command vim || vim"
  bind r screen -t ranger bash -c "$SCREENRC_NIX_SHELL --command 'PYTHONPATH="" ranger' || ranger"
  bind ^r screen -t ranger bash -c "$SCREENRC_NIX_SHELL --command 'PYTHONPATH="" ranger' || ranger"

  #split window
  bind t split -v

  #close window
  bind x remove
  bind ^x remove

  # lock screen
  bind X lockscreen
  bind ^X lockscreen

  # Hide hardstatus
  bind s eval "hardstatus ignore"
  # Show hardstatus
  bind S eval "hardstatus alwayslastline"

  #switch regions
  bindkey ^h prev
  bindkey ^l next

  #switch buffers
  bind h focus left
  bind l focus right

  #footer 
  hardstatus alwayslastline
  hardstatus string "%{= kW}%?   %-w%:  %?%{=b kB}[%{=b kW}%n %t%{=b kB}]%{= kW}%+w %-=%{= ky}%S%{= kg}@%H  %{= kw}%Y.%m.%d %c  %{-}"
  caption always "%?%F%{=b BW}%:%{= KW}%?   %n %t%=%{-}"
  rendition so "=" "KW"

  # Allow bold colors - necessary for some reason
  attrcolor b ".I"

  # Tell screen how to set colors. AB = background, AF=foreground
  termcapinfo xterm 'Co#256:AB=\E[48;5;%dm:AF=\E[38;5;%dm'

  # Enables use of shift-PgUp and shift-PgDn
  termcapinfo xterm|xterms|xs|rxvt ti@:te@

  # Erase background with current bg color
  defbce "on"

  # Enable 256 color term
  term xterm-256color

  # Cache 30000 lines for scroll back
  defscrollback 30000

  #init
  #TODO how to stay DRY in screenrc?
  screen -t ranger bash -c "$SCREENRC_NIX_SHELL --command 'PYTHONPATH="" ranger' || ranger"
  split -v
  focus right
  screen -t shell bash -c "$SCREENRC_NIX_SHELL || bash"
  focus left
'';

in

pkgs.screen.overrideAttrs (oldAttrs: {
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postInstall = ''
    wrapProgram $out/bin/${oldAttrs.pname} --add-flags '-c "${screenrc}"'
  '';
})
