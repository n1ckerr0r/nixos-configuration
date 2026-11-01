{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gcc
    clang
    clang-tools
    gnumake
    cmake
    ninja
    bear
    gdb
    lldb
    vscode-extensions.vadimcn.vscode-lldb
    cppcheck
  ];

  environment.sessionVariables.NVIM_CODELLDB = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
}
