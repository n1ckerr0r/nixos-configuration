{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.dev.databases;
in
{
  options.local.dev.databases = {
    postgresql.enable = lib.mkEnableOption "PostgreSQL service for local development";
    mongodb.enable = lib.mkEnableOption "MongoDB service for local development";
    redis.enable = lib.mkEnableOption "Redis service for local development";
  };

  config = {
    # Enable PostgreSQL as a system service only when local.dev.databases.postgresql.enable = true.
    services.postgresql = lib.mkIf cfg.postgresql.enable {
      # Start the PostgreSQL server.
      enable = true;

      # Allow PostgreSQL to accept TCP connections.
      enableTCPIP = true;

      # Replace default authentication rules with trust for local connections.
      authentication = lib.mkForce ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all ::1/128 trust
      '';
    };

    # Enable MongoDB as a system service only when local.dev.databases.mongodb.enable = true.
    services.mongodb = lib.mkIf cfg.mongodb.enable {
      # Start the MongoDB server.
      enable = true;

      # Use MongoDB Community Edition from nixpkgs.
      package = pkgs.mongodb-ce;
    };

    services.redis.servers."" = lib.mkIf cfg.redis.enable {
      # Start the Redis server.
      enable = true;
    };
  };
}
