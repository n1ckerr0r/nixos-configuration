{ pkgs, ... }:

let
  javaDebugBundle = pkgs.runCommand "vscode-java-debug-bundle" { } ''
    ln -s ${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar $out
  '';
in
{
  environment.sessionVariables.NVIM_JAVA_DEBUG_BUNDLE = "${javaDebugBundle}";

  environment.systemPackages = with pkgs; [
    openjdk
    jdt-language-server
    google-java-format
    maven
    gradle
    checkstyle
    pmd
    vscode-extensions.vscjava.vscode-java-debug
    vscode-extensions.vscjava.vscode-java-test
  ];
}
