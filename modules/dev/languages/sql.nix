{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    sqls
    sqlfluff
    pgformatter
  ];
}
