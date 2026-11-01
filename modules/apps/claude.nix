{ inputs, pkgs, ... }:

{
  # Build Claude Desktop against the system nixpkgs instead of the flake's own pin.
  nixpkgs.overlays = [ inputs.claude-desktop.overlays.default ];

  environment.systemPackages = with pkgs; [
    # Claude Code command-line agent.
    claude-code

    # Claude Desktop in an FHS environment so MCP servers launched through
    # npx, uvx or docker find their usual system paths.
    claude-desktop-fhs
  ];
}
