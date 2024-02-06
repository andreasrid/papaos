{ config, lib, pkgs, ... }:

{
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    flake = "https://github.com/andreasrid/papaos";
    flags = [
      "--update-input" "nixpkgs"
    ];
    # Build  the  new  configuration  and make it the boot default, but do not activate it.
    # That is, the system continues to run the previous configuration until the next reboot.
    operation = "boot";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 120d";
  };
}
