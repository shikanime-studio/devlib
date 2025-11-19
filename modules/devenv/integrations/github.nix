{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.github;
  settingsFormat = pkgs.formats.yaml { };
in
{
  options.github = {
    enable = mkEnableOption "generation of GitHub Actions workflow files";

    package = mkOption {
      type = types.package;
      default = pkgs.gh;
      description = "Package to use for GitHub Actions";
    };

    workflows = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            settings = mkOption {
              type = types.submodule {
                freeformType = settingsFormat.type;
              };

              description = ''
                GitHub workflow settings.
              '';
            };
          };
        }
      );

      default = { };

      description = ''
        GitHub workflows configuration. Each attribute name becomes the workflow filename.
      '';

      example = literalExpression ''
        {
          check = {
            settings = {
              name = "Check";
              on = {
                push.branches = [ "main" ];
                pull_request.branches = [ "main" ];
              };
              jobs = {
                check = {
                  runs-on = "ubuntu-latest";
                  steps = [
                    { uses = "actions/checkout@v5"; }
                    { uses = "shikanime-studio/setup-nix-action@v1"; }
                    {
                      name = "Check Nix Flake";
                      run = "nix flake check --accept-flake-config --all-systems --no-pure-eval";
                    }
                  ];
                };
              };
            };
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    files = mkMerge [
      (mapAttrs' (name: workflowCfg: {
        name = ".github/workflows/${name}.yaml";
        value.yaml = workflowCfg.settings;
      }) cfg.workflows)
    ];

    git-hooks.hooks.actionlint.enable = true;

    treefmt.config.programs.prettier.enable = true;
  };
}
