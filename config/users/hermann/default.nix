{ config, lib, pkgs, ... }:

{
  users.users.hermann = {
    isNormalUser = true;

    # The asterisk in the password hash prevent unix password authentication
    hashedPassword = "*";

    openssh.authorizedKeys.keys = [
      # Yubikey
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4gKiht22Vfw4OoW2V+++GR2OPb0ItOJNM/LTfAYeWdkcAntaPxQXVxsARIFPDAMUXtk9p59sqF1jq1RtVRRdmKR6pPVm0EQcW7/3RahIezIVu6rUHNVwvLvRuyLW93GUCUn51BSPHsNXnLN2snuZruYeyj8OUWXt25niX1/mHcWsOUSnyDkD9i5uhHyz/+oJ/VpjRsRvXPh1iYGWPEpuowPjjncQNu7V2e+LxSI+f2Y8hfdPMc/sYObPhr3zSx+jfINqv6qKBqxXaEiWgf5aOqO2gG5ZtBHSzcZa9Kwx+NCLD+MaLWpP0HOVy4+DO8s3ccFHpKIliBZDQZYb7ORI7 cardno:9 922 765"
    ];
  };

  home-manager.users.hermann = {
    home.stateVersion = "23.11";
    #home.language.base = "de_DE.UTF-8";
    #home.language.messages = "de_DE.UTF-8";

    home.packages = with pkgs; [
      # After installing VideoDownloadHelper you have to run the following otherwise neither chromium nor FF couldn't find it:
      # path/to/net.downloadhelper.coapp install --user
      nur.repos.wolfangaukang.vdhcoapp
    ];

    xfconf.settings = {
      # Configure Xfce
      # 1. Configure Xfce with xfce4-settings-manager
      # 2. Find Properties with xfce-settings-editor or xfconf-query
      xfce4-screensaver = {
        # Disable Lock Screen - user has no authentication method like password
        "lock/enabled" = false;
      };

      xfce4-xsettings = {
        "Net/ThemeName" = "Adwaita-dark";
      };
    };

    programs.thunderbird = {
      enable = true;
    };

    programs.firefox = {
      enable = true;
      profiles.default = {
        id = 0;
        isDefault = true;

        settings = {
          #"browser.startup.homepage" = "https://nixos.org";
          "intl.locale.requested" = "de_DE";

          # Ask to save logins and passwords for websites
          "signon.rememberSignons" = false;
        };

        extensions = with pkgs.nur.repos; [
          # Note that it is necessary to manually enable these extensions
          # inside Firefox after the first installation.
          rycee.firefox-addons.languagetool
          rycee.firefox-addons.i-dont-care-about-cookies
          rycee.firefox-addons.cookie-autodelete
          rycee.firefox-addons.bitwarden
          rycee.firefox-addons.video-downloadhelper

        ];
      };
    };

    programs.chromium = {
      enable = true;
      extensions = [
        #The extension's ID from the Chome Web Store url or the unpacked crx.
        "oldceeleldhonbafppcapldpdifcinji" # Grammar & Spell Checker — LanguageTool
        "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
        "fihnjjcciajhdojfnbdddfaoknhalnja" # I don't care about cookies
        "fhcgjolkccmbidfldomjliifgaodjagh" # Cookie AutoDelete
        "lmjnegcaeklhafolokijcfjliaokphfk" # Video DownloadHelper
        "niloccemoadcdkdjlinkgdfekeahmflj" # Save to Pocket
      ];
    };

  };
}
