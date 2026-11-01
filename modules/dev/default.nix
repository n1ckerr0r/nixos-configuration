_:

{
  imports = [
    ./editors.nix
    ./git.nix
    ./neovim.nix
    ./tools.nix

    ./languages/shell.nix
    ./languages/python.nix
    ./languages/go.nix
    ./languages/cpp.nix
    ./languages/java.nix
    ./languages/kotlin.nix
    ./languages/android.nix
    ./languages/javascript.nix
    ./languages/swift.nix
    ./languages/tex.nix
    ./languages/lua.nix
    ./languages/nix.nix
    ./languages/sql.nix
  ];

  nixpkgs.overlays = [
    (_: prev: {
      avro-cpp = prev.avro-cpp.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          # fmt 12 no longer exposes fmt::format from fmt/core.h.
          substituteInPlace include/avro/Exception.hh \
            --replace-fail '#include <fmt/core.h>' '#include <fmt/format.h>'
        '';
      });
    })
  ];
}
