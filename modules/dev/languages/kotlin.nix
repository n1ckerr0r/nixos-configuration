{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    openjdk
    kotlin
    kotlin-language-server
    gradle
    maven
    ktlint
    detekt
  ];
}
