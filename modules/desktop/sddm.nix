{ pkgs, ... }:

let
  tokyoNightAstronaut = pkgs.sddm-astronaut.overrideAttrs (old: {
    pname = "sddm-astronaut-tokyo-night";

    installPhase = old.installPhase + ''
      theme_dir=$out/share/sddm/themes/sddm-astronaut-theme

      chmod -R u+w "$theme_dir"
      cp ${../../home/n1ckerr0r/dotfiles/wallpapers/lisau_1.png} \
        "$theme_dir/Backgrounds/lisau_1.png"

      substituteInPlace "$theme_dir/metadata.desktop" \
        --replace-fail "ConfigFile=Themes/astronaut.conf" "ConfigFile=Themes/tokyo-night.conf"

      substituteInPlace "$theme_dir/Main.qml" \
        --replace-fail \
          'source: "Components/VirtualKeyboard.qml"' \
          'source: config.HideVirtualKeyboard == "true" ? "" : "Components/VirtualKeyboard.qml"'

      cat > "$theme_dir/Themes/tokyo-night.conf" <<'EOF'
      [General]

      #################### General ####################

      ScreenWidth="1920"
      ScreenHeight="1080"
      ScreenPadding=""

      Font="JetBrains Mono Nerd Font"
      FontSize="14"

      KeyboardSize="0.4"

      RoundCorners="28"

      Locale=""
      HourFormat="HH:mm"
      DateFormat="dddd d MMMM"

      HeaderText=""

      #################### Background ####################

      BackgroundPlaceholder=""
      Background="Backgrounds/lisau_1.png"

      BackgroundSpeed=""
      PauseBackground=""

      DimBackground="0.25"

      CropBackground="true"

      BackgroundHorizontalAlignment="center"
      BackgroundVerticalAlignment="center"

      #################### Colors ####################

      HeaderTextColor="#c0caf5"
      DateTextColor="#c0caf5"
      TimeTextColor="#7aa2f7"

      FormBackgroundColor="#24283b"
      BackgroundColor="#1f2335"
      DimBackgroundColor="#1f2335"

      LoginFieldBackgroundColor="#292e42"
      PasswordFieldBackgroundColor="#292e42"

      LoginFieldTextColor="#c0caf5"
      PasswordFieldTextColor="#c0caf5"

      UserIconColor="#7aa2f7"
      PasswordIconColor="#7aa2f7"

      PlaceholderTextColor="#565f89"
      WarningColor="#f7768e"

      LoginButtonTextColor="#c0caf5"
      LoginButtonBackgroundColor="#7aa2f7"

      SystemButtonsIconsColor="#c0caf5"
      SessionButtonTextColor="#c0caf5"
      VirtualKeyboardButtonTextColor="#c0caf5"

      DropdownTextColor="#c0caf5"
      DropdownSelectedBackgroundColor="#7aa2f7"
      DropdownBackgroundColor="#24283b"

      HighlightTextColor="#c0caf5"
      HighlightBackgroundColor="#292e42"
      HighlightBorderColor="#7aa2f7"

      HoverUserIconColor="#7dcfff"
      HoverPasswordIconColor="#7dcfff"
      HoverSystemButtonsIconsColor="#7dcfff"
      HoverSessionButtonTextColor="#7dcfff"
      HoverVirtualKeyboardButtonTextColor="#7dcfff"

      #################### Form ####################

      PartialBlur="false"
      FullBlur="false"

      BlurMax="0"
      Blur="0"

      HaveFormBackground="false"

      FormPosition="center"

      #################### Virtual Keyboard ####################

      VirtualKeyboardPosition="center"

      #################### Interface Behavior ####################

      HideVirtualKeyboard="true"
      HideSystemButtons="false"
      HideLoginButton="false"

      ForceLastUser="true"
      PasswordFocus="true"
      HideCompletePassword="true"

      AllowEmptyPassword="false"
      AllowUppercaseLettersInUsernames="false"

      BypassSystemButtonsChecks="false"

      RightToLeftLayout="false"

      #################### Translation ####################

      TranslatePlaceholderUsername=""
      TranslatePlaceholderPassword=""
      TranslateLogin=""
      TranslateLoginFailedWarning=""
      TranslateCapslockWarning=""
      TranslateSuspend=""
      TranslateHibernate=""
      TranslateReboot=""
      TranslateShutdown=""
      TranslateSessionSelection=""
      TranslateVirtualKeyboardButtonOn=""
      TranslateVirtualKeyboardButtonOff=""
      EOF
    '';
  });
in
{
  services.xserver.enable = true;

  services.displayManager = {
    defaultSession = "niri";

    sddm = {
      enable = true;
      autoNumlock = true;
      wayland.enable = false;
      theme = "${tokyoNightAstronaut}/share/sddm/themes/sddm-astronaut-theme";
      package = pkgs.kdePackages.sddm;
      extraPackages = with pkgs.kdePackages; [
        qtmultimedia
        qtsvg
        qtvirtualkeyboard
      ];
    };
  };
}
