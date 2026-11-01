{ ... }:

{
  # Local development services are off by default so they do not start on every boot.
  local.dev.databases = {
    # Enable system PostgreSQL for projects that need a local SQL database.
    postgresql.enable = false;

    # Enable system MongoDB for projects that need a local document database.
    mongodb.enable = false;

    # Enable system Redis for projects.
    redis.enable = false;
  };
}
