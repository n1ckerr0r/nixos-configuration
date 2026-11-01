{ pkgs, ... }:

{
  environment.sessionVariables.NVIM_JS_DEBUG = "${pkgs.vscode-js-debug}/bin/js-debug";

  environment.systemPackages = with pkgs; [
    nodejs_22
    typescript
    typescript-language-server
    vscode-langservers-extracted
    prettier
    prettierd
    eslint
    eslint_d
    tsx
    pnpm
    yarn
    esbuild
    vscode-js-debug
  ];
}
