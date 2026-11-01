{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    texlab
    # Use a cached top-level TeX scheme to avoid local format generation when
    # the store is low on free space.
    texliveMedium
    typst
    tinymist
    typstyle
    marksman
    mdformat
    pandoc
  ];
}
