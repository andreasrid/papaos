{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users.hermann = {
    isNormalUser = true;

    # The asterisk in the password hash prevent unix password authentication
    hashedPassword = "*";

    extraGroups = [
      "wheel"
      "audio"
    ];
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
      vdhcoapp
    ];

    xfconf.settings = {
      # Configure Xfce
      # 1. Configure Xfce with xfce4-settings-manager
      # 2. Find Properties with xfce-settings-editor or xfconf-query
      xfce4-screensaver = {
        # Disable Lock Screen - user has no authentication method like password
        "lock/enabled" = false;
      };
      xfce4-power-manager = {
        # set power button action to 4:=shutdown
        "xfce4-power-manager/power-button-action" = 4;
      };

      xfce4-xsettings = {
        "Net/ThemeName" = "Adwaita-dark";
      };
    };

    programs.thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
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

        extensions.packages = with pkgs.nur.repos; [
          # Note that it is necessary to manually enable these extensions
          # inside Firefox after the first installation.
          rycee.firefox-addons.languagetool
          rycee.firefox-addons.i-dont-care-about-cookies
          rycee.firefox-addons.cookie-autodelete
          rycee.firefox-addons.bitwarden
          rycee.firefox-addons.video-downloadhelper

          (rycee.firefox-addons.buildFirefoxXpiAddon rec {
            pname = "YT Ad Speedup - Skip Video Ads Faster";
            version = "1.0.5";
            addonId = "{8f5ec562-8beb-11ee-b9d1-0242ac120002}";
            url = "https://addons.mozilla.org/firefox/downloads/file/4207941/yt_ad_speedup_skip_ads_faster-${version}.xpi";
            sha256 = "90916e35902aae93125afd0292816dd8cd948467de5c1f7669b5fbf3bf14da79";
            meta = { };
          })

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
