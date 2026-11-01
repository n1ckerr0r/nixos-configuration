{ ... }:

{
  # Allow real-time scheduling, which PipeWire needs for low-latency audio.
  security.rtkit.enable = true;

  # Enable PipeWire as the primary audio server.
  services.pipewire = {
    # Start PipeWire.
    enable = true;

    # Enable ALSA compatibility.
    alsa.enable = true;

    # Enable 32-bit ALSA support for older or proprietary applications.
    alsa.support32Bit = true;

    # Enable a PulseAudio-compatible server on top of PipeWire.
    pulse.enable = true;

    wireplumber = {
      enable = true;

      # Favor high-quality A2DP on connect. This avoids the common Bluetooth
      # startup path where headphones briefly come up in a low-quality headset
      # profile before audio stabilizes.
      extraConfig."10-bluetooth-quality" = {
        "wireplumber.settings" = {
          "bluetooth.autoswitch-to-headset-profile" = false;
        };

        "monitor.bluez.properties" = {
          "bluez5.roles" = [
            "a2dp_sink"
            "a2dp_source"
            "bap_sink"
            "bap_source"
          ];
          "bluez5.codecs" = [
            "sbc"
            "sbc_xq"
            "aac"
            "ldac"
          ];
          "bluez5.enable-sbc-xq" = true;
          "bluez5.a2dp.ldac.quality" = "hq";
        };
      };
    };
  };
}
