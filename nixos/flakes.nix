# Create nix flake repo:
# $ nix flake init
# $ git add flake.nix

{ pkgs, ... }: {
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
