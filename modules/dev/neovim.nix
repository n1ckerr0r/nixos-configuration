{ pkgs, ... }:

let
  nvimTreesitterParsers = pkgs.runCommand "nvim-treesitter-parsers" { } ''
    mkdir -p $out/share/nvim-treesitter-parsers/parser

    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-bash}/parser $out/share/nvim-treesitter-parsers/parser/bash.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-c}/parser $out/share/nvim-treesitter-parsers/parser/c.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-cpp}/parser $out/share/nvim-treesitter-parsers/parser/cpp.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-css}/parser $out/share/nvim-treesitter-parsers/parser/css.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-go}/parser $out/share/nvim-treesitter-parsers/parser/go.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-html}/parser $out/share/nvim-treesitter-parsers/parser/html.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-java}/parser $out/share/nvim-treesitter-parsers/parser/java.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-javascript}/parser $out/share/nvim-treesitter-parsers/parser/javascript.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-json}/parser $out/share/nvim-treesitter-parsers/parser/json.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-kotlin}/parser $out/share/nvim-treesitter-parsers/parser/kotlin.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-latex}/parser $out/share/nvim-treesitter-parsers/parser/latex.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-lua}/parser $out/share/nvim-treesitter-parsers/parser/lua.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-markdown}/parser $out/share/nvim-treesitter-parsers/parser/markdown.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-markdown-inline}/parser $out/share/nvim-treesitter-parsers/parser/markdown_inline.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-nix}/parser $out/share/nvim-treesitter-parsers/parser/nix.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-python}/parser $out/share/nvim-treesitter-parsers/parser/python.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-sql}/parser $out/share/nvim-treesitter-parsers/parser/sql.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-swift}/parser $out/share/nvim-treesitter-parsers/parser/swift.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-tsx}/parser $out/share/nvim-treesitter-parsers/parser/tsx.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-typescript}/parser $out/share/nvim-treesitter-parsers/parser/typescript.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-typst}/parser $out/share/nvim-treesitter-parsers/parser/typst.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-vim}/parser $out/share/nvim-treesitter-parsers/parser/vim.so
    ln -s ${pkgs.tree-sitter-grammars.tree-sitter-yaml}/parser $out/share/nvim-treesitter-parsers/parser/yaml.so
  '';
in
{
  environment = {
    sessionVariables = {
      NVIM_TREESITTER_PARSERS = "${nvimTreesitterParsers}/share/nvim-treesitter-parsers";
      NVIM_OSV_PLUGIN = "${pkgs.vimPlugins.one-small-step-for-vimkind}";
    };

    systemPackages = with pkgs; [
      nvimTreesitterParsers
      graphviz
      neovim
      tree-sitter
      vimPlugins.nvim-ts-autotag
      vimPlugins.one-small-step-for-vimkind
    ];
  };
}
