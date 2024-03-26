# Documentation:
# https://dataswamp.org/~solene/2022-01-13-nixos-hardened.html

{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/hardened.nix"
  ];

  ###
  # Overwrite hardened defaults:
  ###
  # Allow broadcast ICMP (mitigate SMURF)
  boot.kernel.sysctl."net.ipv4.icmp_echo_ignore_broadcasts" = false;

  # Undo setting memory allocator to 'scudo'.
  # 'scudo' breaks the usage of firefox.
  environment.memoryAllocator.provider = "libc";

  # Disable kernel module loading once the system is fully initialised. Module
  # loading is disabled until the next reboot. Problems caused by delayed module
  # loading can be fixed by adding the module(s) in question to boot.kernelModules.
  security.lockKernelModules = false;

  # Workaround: Apparmor service fails to start after nixos-rebuild switch
  # https://github.com/NixOS/nixpkgs/issues/273164
  security.apparmor.policies.dummy.profile = ''
      /dummy {
      }
  '';
}
