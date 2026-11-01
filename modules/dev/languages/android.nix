{ pkgs, ... }:

let
  androidPackages = pkgs.androidenv.composeAndroidPackages {
    includeEmulator = true;
    includeSystemImages = true;
    includeNDK = false;
    cmdLineToolsVersion = "latest";
    platformToolsVersion = "latest";
    buildToolsVersions = [ "latest" ];
    platformVersions = [ "latest" ];
    systemImageTypes = [ "google_apis" ];
    abiVersions = [ "x86_64" ];
    extraLicenses = [
      "android-sdk-preview-license"
      "android-googletv-license"
      "android-sdk-arm-dbt-license"
      "google-gdk-license"
      "intel-android-extra-license"
      "intel-android-sysimage-license"
      "mips-android-sysimage-license"
    ];
  };

  androidSdk = androidPackages.androidsdk;

  androidStudioX11 = pkgs.symlinkJoin {
    name = "android-studio-x11";
    paths = [ pkgs.android-studio ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm "$out/bin/android-studio"
      makeWrapper ${pkgs.android-studio}/bin/android-studio "$out/bin/android-studio" \
        --set-default GDK_BACKEND x11 \
        --set-default _JAVA_AWT_WM_NONREPARENTING 1 \
        --unset WAYLAND_DISPLAY
    '';
  };
in

{
  environment.sessionVariables = {
    ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
    ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
    ANDROID_AVD_HOME = "$HOME/.android/avd";
  };

  environment.systemPackages = with pkgs; [
    androidSdk
    androidStudioX11
    android-tools
  ];
}
