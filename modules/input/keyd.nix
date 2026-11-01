_:

{
  # Enable keyd for low-level key remapping.
  services.keyd = {
    # Start the keyd systemd service.
    enable = true;

    # Define keyboard sets that receive remapping rules.
    keyboards = {
      # Rule set name; default is only the local block name here.
      default = {
        # Apply the rule to all attached keyboards.
        ids = [ "*" ];

        # Define remaps for the selected keyboards.
        settings = {
          # Main keyboard layer.
          main = {
            # Pressing physical Caps Lock sends Alt+Shift to switch layouts.
            capslock = "macro(leftalt+leftshift)";

            # Make Escape behave as Caps Lock.
            esc = "capslock";

            # Turn the Compose key (code 135 on this keyboard) into Escape.
            compose = "esc";
          };
        };
      };
    };
  };
}
