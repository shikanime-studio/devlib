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

    templates = {
      automata.enable = mkEnableOption "Generate built-in automata workflow";
      sapling.enable = mkEnableOption "Generate built-in sapling workflow";
      check.enable = mkEnableOption "Generate built-in check workflow";
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
      (mapAttrs (name: workflowCfg: {
        ".github/workflows/${name}.yaml".yaml = workflowCfg.settings;
      }) cfg.workflows)

      (mkIf cfg.templates.automata.enable {
        ".github/workflows/automata.yaml".yaml = {
          name = "Update";
          on = {
            schedule = [ { cron = "0 0 * * 0"; } ];
            workflow_dispatch = null;
          };
          jobs.update = {
            runs-on = "ubuntu-latest";
            steps = [
              {
                id = "createGithubAppToken";
                uses = "actions/create-github-app-token@v2";
                "with" = {
                  app-id = "\${{ vars.OPERATOR_APP_ID }}";
                  private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                };
              }
              {
                uses = "actions/checkout@v5";
                "with" = {
                  fetch-depth = 0;
                  token = "\${{ steps.createGithubAppToken.outputs.token }}";
                };
              }
              {
                uses = "shikanime-studio/setup-nix-action@v1";
                "with" = {
                  github-token = "\${{ steps.createGithubAppToken.outputs.token }}";
                };
              }
              {
                uses = "shikanime-studio/automata-action@v1";
                "with" = {
                  ghstack-username = "operator6o";
                  github-token = "\${{ steps.createGithubAppToken.outputs.token }}";
                  gpg-passphrase = "\${{ secrets.GPG_PASSPHRASE }}";
                  gpg-private-key = "\${{ secrets.GPG_PRIVATE_KEY }}";
                  sign-commits = true;
                  username = "Operator 6O <operator6o@shikanime.studio>";
                };
              }
            ];
          };
        };
      })

      (mkIf cfg.templates.sapling.enable {
        ".github/workflows/sapling.yaml".yaml = {
          name = "Land";
          on.issue_comment.types = [ "created" ];
          jobs.land = {
            runs-on = "ubuntu-latest";
            steps = [
              {
                id = "createGithubAppToken";
                uses = "actions/create-github-app-token@v2";
                "with" = {
                  app-id = "\${{ vars.OPERATOR_APP_ID }}";
                  private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                };
              }
              {
                uses = "actions/checkout@v5";
                "with" = {
                  fetch-depth = 0;
                  token = "\${{ steps.createGithubAppToken.outputs.token }}";
                };
              }
              {
                uses = "shikanime-studio/setup-nix-action@v1";
                "with" = {
                  github-token = "\${{ steps.createGithubAppToken.outputs.token }}";
                };
              }
              {
                uses = "shikanime-studio/sapling-action@v4";
                "with" = {
                  github-token = "\${{ steps.createGithubAppToken.outputs.token }}";
                  gpg-passphrase = "\${{ secrets.GPG_PASSPHRASE }}";
                  gpg-private-key = "\${{ secrets.GPG_PRIVATE_KEY }}";
                  sign-commits = true;
                  username = "Operator 6O <operator6o@shikanime.studio>";
                };
              }
            ];
          };
        };
      })

      (mkIf cfg.templates.check.enable {
        ".github/workflows/check.yaml".yaml = {
          name = "Check";
          on = {
            push.branches = [ "main" ];
            pull_request.branches = [
              "main"
              "gh/*/*/base"
            ];
          };
          jobs.check = {
            runs-on = "ubuntu-latest";
            steps = [
              {
                id = "createGithubAppToken";
                uses = "actions/create-github-app-token@v2";
                "with" = {
                  app-id = "\${{ vars.OPERATOR_APP_ID }}";
                  private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                };
              }
              {
                uses = "actions/checkout@v5";
                "with" = {
                  fetch-depth = 0;
                  token = "\${{ steps.createGithubAppToken.outputs.token }}";
                };
              }
              {
                uses = "shikanime-studio/setup-nix-action@v1";
                "with" = {
                  github-token = "\${{ steps.createGithubAppToken.outputs.token }}";
                };
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
      })
    ];

    git-hooks.hooks.actionlint.enable = true;
  };
}
