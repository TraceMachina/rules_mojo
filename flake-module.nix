{ lib, self, flake-parts-lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  options = {
    perSystem = flake-parts-lib.mkPerSystemOption ({ config, options, pkgs, ... }:
      let cfg = config.rules_mojo;
      in
      {
        options = {
          rules_mojo = {
            pkgs = mkOption {
              type = types.uniq (types.lazyAttrsOf (types.raw or types.unspecified));
              description = lib.mdDoc ''
                Nixpkgs to use in the rules_mojo [`settings`](#opt-perSystem.rules_mojo.settings).
              '';
              default = pkgs;
              defaultText = lib.literalMD "`pkgs` (module argument)";
            };
            settings = mkOption {
              type = types.submoduleWith {
                modules = [ ./modules/rules_mojo.nix ];
                specialArgs = { inherit (cfg) pkgs; };
              };
              default = { };
              description = lib.mdDoc ''
                The rules_mojo configuration.
              '';
            };
            installationScript = mkOption {
              type = types.str;
              description = lib.mdDoc "A .bazelrc.mojo generator for rules_mojo.";
              default = cfg.settings.installationScript;
              defaultText = lib.literalMD "bazelrc contents";
              readOnly = true;
            };
          };
        };
      }
    );
  };
}
