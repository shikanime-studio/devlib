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

  # Merge workflows with templates
  workflows = mkMerge [
    cfg.workflows

    (mkIf cfg.templates.check.enable {
      check.settings = {
        name = "Check";
        on = {
          push.branches = [ "main" ];
          pull_request.branches = [ "main" "gh/*/*/base" ];
        };
        jobs = {
          check = {
            "runs-on" = "ubuntu-latest";
            steps = [
              {
                id = "createGithubAppToken";
                uses = "actions/create-github-app-token@v2";
                "with" = {
                  "app-id" = "\${{ vars.OPERATOR_APP_ID }}";
                  "private-key" = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                };
              }
              {
                uses = "actions/checkout@v5";
                "with" = {
                  "fetch-depth" = 0;
                  token = "\${{ steps.createGithubAppToken.outputs.token }}";
                };
              }
              {
                uses = "shikanime-studio/setup-nix-action@v1";
                "with"."github-token" = "\${{ steps.createGithubAppToken.outputs.token }}";
              }
              {
                name = "Check Nix Flake";
                run = ''
                  nix flake check \
                    --accept-flake-config \
                    --all-systems \
                    --no-pure-eval
                '';
              }
            ];
          };
        };
      };
    })

    (mkIf cfg.templates.sapling.enable {
      sapling.settings = {
        name = "Sapling";
        on.issue_comment.types = [ "created" ];
        jobs.sapling = {
          "runs-on" = "ubuntu-latest";
          steps = [
            {
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v2";
              "with" = {
                "app-id" = "\${{ vars.OPERATOR_APP_ID }}";
                "private-key" = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
              };
            }
            {
              uses = "actions/checkout@v5";
              "with" = {
                "fetch-depth" = 0;
                token = "\${{ steps.createGithubAppToken.outputs.token }}";
              };
            }
            {
              uses = "shikanime-studio/setup-nix-action@v1";
              "with"."github-token" = "\${{ steps.createGithubAppToken.outputs.token }}";
            }
            {
              uses = "shikanime-studio/sapling-action@v4";
              "with" = {
                "github-token" = "\${{ steps.createGithubAppToken.outputs.token }}";
                "gpg-passphrase" = "\${{ secrets.GPG_PASSPHRASE }}";
                "gpg-private-key" = "\${{ secrets.GPG_PRIVATE_KEY }}";
                "sign-commits" = true;
                username = "Operator 6O <operator6o@shikanime.studio>";
              };
            }
          ];
        };
      };
    })

    (mkIf cfg.templates.automata.enable {
      automata.settings = {
        name = "Automta";
        on = {
          schedule = [ { cron = "0 0 * * 0"; } ];
          workflow_dispatch = null;
        };
        jobs.automata = {
          "runs-on" = "ubuntu-latest";
          steps = [
            {
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v2";
              "with" = {
                "app-id" = "\${{ vars.OPERATOR_APP_ID }}";
                "private-key" = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
              };
            }
            {
              uses = "actions/checkout@v5";
              "with" = {
                "fetch-depth" = 0;
                token = "\${{ steps.createGithubAppToken.outputs.token }}";
              };
            }
            {
              uses = "shikanime-studio/setup-nix-action@v1";
              "with"."github-token" = "\${{ steps.createGithubAppToken.outputs.token }}";
            }
            {
              uses = "shikanime-studio/automata-action@v1";
              "with" = {
                "ghstack-username" = "operator6o";
                "github-token" = "\${{ steps.createGithubAppToken.outputs.token }}";
                "gpg-passphrase" = "\${{ secrets.GPG_PASSPHRASE }}";
                "gpg-private-key" = "\${{ secrets.GPG_PRIVATE_KEY }}";
                "sign-commits" = true;
                username = "Operator 6O <operator6o@shikanime.studio>";
              };
            }
          ];
        };
      };
    })
  ];

  # Generate workflow files for each configured workflow
  workflowFiles = mapAttrs (
    name: workflowCfg: settingsFormat.generate "${name}.yaml" workflowCfg.settings
  ) workflows;

  # Create shell commands to copy all workflow files
  workflowCommands = mapAttrsToList (
    name: file: "cat ${file} > ${config.env.DEVENV_ROOT}/.github/workflows/${name}.yaml"
  ) workflowFiles;
in
{
  options.github = {
    enable = mkEnableOption "generation of GitHub Actions workflow files";

    package = mkOption {
      type = types.package;
      default = pkgs.gh;
      description = "Package to use for GitHub Actions";
    };

    templates = mkOption {
      type = types.submodule {
        options = {
          automata = mkOption {
            type = types.submodule { options = { enable = mkEnableOption "automata workflow"; }; };
            default = { };
            description = "Automata workflow template";
          };
          check = mkOption {
            type = types.submodule { options = { enable = mkEnableOption "check workflow"; }; };
            default = { };
            description = "Check workflow template";
          };
          sapling = mkOption {
            type = types.submodule { options = { enable = mkEnableOption "sapling workflow"; }; };
            default = { };
            description = "Sapling workflow template";
          };
        };
      };
      default = { };
      description = "Templates for GitHub workflows.";
    };

    workflows = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            settings = mkOption {
              type = types.submodule { freeformType = settingsFormat.type; };
              description = ''
                GitHub workflow settings. Attribute name becomes the filename.
              '';
            };
          };
        }
      );
      default = { };
      description = "Custom GitHub workflows configuration.";
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    enterShell = ''
      mkdir -p ${config.env.DEVENV_ROOT}/.github/workflows
      ${concatStringsSep "\n" workflowCommands}
    '';

    git-hooks.hooks.actionlint.enable = true;
  };
}
