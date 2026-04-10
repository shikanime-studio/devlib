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

  zizmorConfigFile = yamlFormat.generate "zizmor.yml" {
    # TODO: Refactor file generation pipeline to avoid GitHub rate limit using
    # zizmor with pinact
    rules = {
      artipacked.disable = true;
      secrets-outside-env.disable = true;
      unpinned-uses.disable = true;
    };
  };
in
{
  imports = [
    ./github/cleanup.nix
    ./github/commands.nix
    ./github/fluxcd.nix
    ./github/javascript.nix
    ./github/integration.nix
    ./github/nix.nix
    ./github/release.nix
    ./github/skaffold.nix
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
    packages = [ cfg.package ];

    git-hooks.hooks.action-validator.enable = true;

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

    treefmt.config.programs = {
      actionlint.enable = true;
      zizmor = {
        enable = true;
        includes = [
          "**/action.yml"
          "**/action.yaml"
        ];
      };
    };

    treefmt.config.settings.formatter.zizmor.options = [
      "--config"
      "${zizmorConfigFile}"
    ];
  };
}
