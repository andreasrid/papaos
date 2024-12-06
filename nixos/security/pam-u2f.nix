{ config, lib, pkgs, ... }:

## Test PAM configuration
# Test user and/or sudo authentication. Replace 'root' or 'conso' by your users account name.
# nix-shell -p pamtester
# [nix-shell] pamtester login root authenticate
# [nix-shell] pamtester sudo conso authenticate

let
  ## Obtaining Key Handles and Public Keys
  ## Extra Options: -N require FIDO PIN during authentication
  # nix-shell -p pam_u2f --command 'pamu2fcfg --origin=pam://rid-net.de'
  u2f_keys = [
    # Yubikey rian (serial: 9922765)
    "root:Y4WVhbq0p5fXKplqHatroTX6q8R0zHPpG9VrUsmBGKgZW/MlW3VnNkI/dJo9U59qOI0fOUcTf5YFbsJPODv20Q==,RQUYKlxOUdC/30Q449wD1z9egv5ufSpjgsFpsZv9uWiB79wP0VYhtgmLw2BJwKLOTdbyWSpaVH3oap9mpqD8nQ==,es256,+presence"
    "hermann:T/9DzTPqYcRbwQ7eG69qRt2ZnmLW4ab22aGTYqQKt5pDCEssrS4oFBV6/ZQlCWf0l+Lv2CPuyIN0E4tJzqgSww==,w1c0OS5YnMlhopEbAFUumg53tyncBGW96XHV6157udde9Vj+MoywFOcgcYY1dXtXlzSZGyqP32f53MPPimAw7Q==,es256,+presence"
  ];
in
{
  ## Logging-in
  ## Use your yubikey as a user login or for sudo access.
  # https://nixos.wiki/wiki/Yubikey#pam_u2f
  security.pam = {
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      lightdm.u2fAuth = true;
      xfce4-screensaver.u2fAuth = true;
    };
    u2f.settings = {
      authFile = pkgs.writeText "u2f_mapping" (lib.concatStringsSep "\n" u2f_keys);
      # By default origin is set to pam://$HOSTNAME
      # We set here someting else to use u2f_keys on all my machines.
      origin = "pam://rid-net.de";
      cue = true;
    };
  };
}
