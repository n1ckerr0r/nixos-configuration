{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    go
    gopls
    gofumpt
    gotools
    golangci-lint
    delve
  ];
}
