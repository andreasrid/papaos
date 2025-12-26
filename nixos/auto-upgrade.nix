{ config, lib, pkgs, ... }:

{
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    randomizedDelaySec = "20";
    fixedRandomDelay = true;
    flake = "github:andreasrid/papaos";
    flags = [
      "--recreate-lock-file"
      "--no-write-lock-file"
    ];
    # Build  the  new  configuration  and make it the boot default, but do not activate it.
    # That is, the system continues to run the previous configuration until the next reboot.
    operation = "boot";
    runGarbageCollection = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };
}
