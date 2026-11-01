{
  pkgs,
  ...
}:

{
  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9090;

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [ "127.0.0.1:9090" ];
          }
        ];
      }
    ];
  };

  services.grafana = {
    enable = true;

    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "localhost";
      };

      security = {
        # Required by Grafana on recent NixOS releases.
        # Replace with your own stable secret before exposing Grafana anywhere except localhost.
        secret_key = "local-dev-grafana-secret-key-change-me";
      };
    };

    provision = {
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:9090";
            isDefault = true;
          }
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    k6
  ];
}
