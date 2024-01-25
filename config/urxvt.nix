{ config, pkgs, ... }:
{
  services.urxvtd.enable = true;
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrdb}/bin/xrdb -merge /etc/X11/Xressource.d/urxvt
  '';
  environment.etc = {
    "X11/Xressource.d/urxvt".source = pkgs.writeText "Xressource-urxvt" ''
      !URxvt.scrollBar:     true
      !URxvt.font:		       xft:monospace:pixelsize=12
      URxvt.font:          xft:Bitstream Vera Sans Mono:size=12
      URxvt.perl-ext-common: default,matcher,resize-font,-confirm-paste

      !! Fix urxvt font width
      URxvt.letterSpace: -1

      !! Disable printing the terminal contents when pressing PrintScreen.
      URxvt.print-pipe: "cat > /dev/null"

      !URxvt.saveLines:	65535
      !URxvt.jumpScroll:	true
      !URxvt.skipScroll:	true
      !URxvt.pastableTabs:	true

      !! Colorscheme
      ! to match gnome-terminal "Linux console" scheme
      ! foreground/background
      URxvt*background: #000000
      URxvt*foreground: #ffffff
      ! black
      URxvt.color0  : #000000
      URxvt.color8  : #555555
      ! red
      URxvt.color1  : #AA0000
      URxvt.color9  : #FF5555
      ! green
      URxvt.color2  : #00AA00
      URxvt.color10 : #55FF55
      ! yellow
      URxvt.color3  : #AA5500
      URxvt.color11 : #FFFF55
      ! blue
      URxvt.color4  : #0000AA
      URxvt.color12 : #5555FF
      ! magenta
      URxvt.color5  : #AA00AA
      URxvt.color13 : #FF55FF
      ! cyan
      URxvt.color6  : #00AAAA
      URxvt.color14 : #55FFFF
      ! white
      URxvt.color7  : #AAAAAA
      URxvt.color15 : #FFFFFF
    '';
  };
}
