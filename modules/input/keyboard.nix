_:

{
  # Configure keyboard layouts for X11 sessions.
  services.xserver.xkb = {
    # Enable English and Russian layouts.
    layout = "us,ru";

    # Keep variants empty to use the default layout variants.
    variant = "";

    # Switch layouts with Alt+Shift.
    options = "grp:alt_shift_toggle";
  };
}
