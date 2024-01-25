{ config, ... }:
{
  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "de_DE.UTF-8";
    #extraLocaleSettings = { LC_MESSAGES = "en_US.UTF-8"; };
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de-latin1-nodeadkeys";
  };
  
  # Configure keymap in X11
  services.xserver.layout = "de";
}
