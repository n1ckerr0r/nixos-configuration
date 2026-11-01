{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    swift
    sourcekit-lsp
    swift-format
    swiftlint
    lldb
  ];
}
