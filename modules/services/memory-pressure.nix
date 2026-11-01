_:

{
  # Compressed RAM swap smooths short IDE/browser spikes and gives earlyoom
  # time to terminate the real memory hog before the whole system freezes.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    # The previous 50% limit is exhausted during a normal browser/IDE session.
    # zram only consumes RAM for pages that are actually swapped (and compresses
    # them), so a 100% virtual capacity provides useful headroom without
    # reserving another 7 GiB of memory up front.
    memoryPercent = 100;
    priority = 100;
  };

  boot.kernel.sysctl = {
    # zram benefits from compressing cold pages earlier instead of pushing the
    # system into heavy reclaim against regular RAM.
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
  };

  services.earlyoom = {
    enable = true;
    enableNotifications = true;

    # Be conservative: browser tabs and IDEs can briefly push memory and zram
    # hard during page restores or builds. Only kill after sustained pressure.
    freeMemThreshold = 3;
    freeMemKillThreshold = 1;
    freeSwapThreshold = 8;
    freeSwapKillThreshold = 3;

    # earlyoom still considers the kernel oom_score, but these names steer it
    # toward coursework/stress memory hogs first.
    extraArgs = [
      "--prefer"
      "(^|/)(a\\.out|lab5|memhog|stress|stress-ng)( |$)"
      "--avoid"
      "(^|/)(systemd|niri|gnome-shell|pipewire|wireplumber|dbus-daemon|NetworkManager|ssh|sshd|zsh|foot|kitty|wezterm|alacritty|chromium|chrome|google-chrome|Google Chrome|code|codium|idea|java)( |$)"
    ];
  };
}
