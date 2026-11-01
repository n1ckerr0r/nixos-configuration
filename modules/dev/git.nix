{ lib, pkgs, ... }:

let
  globalGitignore = import ./gitignore-global.nix;
  globalGitignoreFile = pkgs.writeText "gitignore_global" (
    lib.concatStringsSep "\n" globalGitignore + "\n"
  );
in
{
  programs.git = {
    enable = true;
    config.core.excludesFile = "${globalGitignoreFile}";
  };

  environment.systemPackages = [
    pkgs.git
  ];
}
