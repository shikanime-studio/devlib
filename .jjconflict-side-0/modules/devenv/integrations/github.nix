{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.github;
  yamlFormat = pkgs.formats.yaml { };

  configFiles = mapAttrs (
    name: workflow: yamlFormat.generate "${name}.yaml" (removeAttrs workflow [ "actions" ])
  ) cfg.settings.workflows;
in
{
  imports = [
    ./github/cleanup.nix
    ./github/commands.nix
    ./github/integration.nix
    ./github/release.nix
    ./github/triage.nix
    ./github/update.nix
  ];

  options.github = {
    enable = mkEnableOption "generation of GitHub Actions workflow files";

    package = mkOption {
      type = types.package;
      default = pkgs.gh;
      description = "Package to use for GitHub Actions";
    };

    settings = {
      global = {
        workflows = mkOption {
          description = "Global configuration merged into all workflows";
          type = types.submodule {
            options.actions = mkOption {
              type = types.attrsOf (
                types.submodule {
                  freeformType = yamlFormat.type;
                }
              );
              default = { };
              description = "Global actions configuration";
            };
          };
          default = { };
        };
      };
      workflows = mkOption {
        description = "Workflows configuration";
        type = types.attrsOf yamlFormat.type;
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    tasks."devlib:github:workflows:install" = {
      before = [ "devenv:enterShell" ] ++ optional config.treefmt.enable "devenv:treefmt:run";
      description = "Install GitHub Actions workflow files";
      exec = concatStringsSep "\n" (
        mapAttrsToList (name: workflow: ''
          mkdir -p "${config.env.DEVENV_ROOT}/.github/workflows"
          cat ${workflow} > "${config.env.DEVENV_ROOT}/.github/workflows/${name}.yaml"
        '') configFiles
      );
    };
  };
}
