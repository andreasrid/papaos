{ config, pkgs, ... }:
{
  imports = [
    ./minimal.nix
    ../urxvt.nix
    ../sound.nix
    ../printing
    ../impermanence.nix
  ];

  config = {

    # Enable NTFS support
    boot.supportedFilesystems = [ "ntfs" ];

    nixpkgs.config = {
      allowUnfree = true;
    };

    services = {
      openssh = {
        enable = true;
        extraConfig = "
          MaxAuthTries=10
        ";
      };
    };

    environment.systemPackages = with pkgs; [
      usbutils
      firefox
      chromium
      thunderbird
      evince
      eog
      gedit
      pavucontrol
      mplayer
      cryfs
      (aspellWithDicts (
        dicts: with dicts; [
          en
          en-computers
          en-science
          de
        ]
      ))
      libreoffice-qt
      hunspell
      hunspellDicts.de_DE
      kdePackages.k3b
    ];

    programs.dconf.enable = true;

    ###
    # K3B
    ###
    # To fix cdrecord error message "permission denied" open
    # k3b settings -> Porgrams -> select cdrecord in /run/wrappers/bin/cdrecord
    # https://github.com/NixOS/nixpkgs/issues/19154#issuecomment-647045107
    #services.udisks2.enable = true; # needed by k3b
    programs.k3b.enable = false;

    systemd.user.services.yubikey-touch-detector = {
      path = with pkgs; [
        gnupg
        yubikey-touch-detector
      ];

      script = ''
        export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
        yubikey-touch-detector
      '';

      wantedBy = [ "graphical-session.target" ];
    };

  };

}
