{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.github.workflows.skaffold;

  yamlFormat = pkgs.formats.yaml { };
in
{
  options.github.workflows.skaffold = {
    enable = mkEnableOption "skaffold";

    settings = {
      checkout = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for checkout";
      };
      create-github-app-token = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for create-github-app-token";
      };
      direnv = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for direnv";
      };
      setup-nix = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for setup-nix";
      };
      setup-profiles-jobs = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for setup-profiles-jobs";
      };
      integration = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for skaffold integration";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      github.settings.workflows.skaffold = {
        name = "Skaffold";
        on.workflow_call.secrets.OPERATOR_PRIVATE_KEY.required = true;

        permissions.contents = "read";

        jobs = {
          setup-profiles-jobs = {
            name = "Setup Profiles Jobs";
            runs-on = "ubuntu-latest";
            outputs = {
              continue = "\${{ steps.setup-profiles-jobs.outputs.continue }}";
              matrix = "\${{ steps.setup-profiles-jobs.outputs.matrix }}";
            };
            steps = [
              {
                uses = "actions/checkout@v6";
                "with" = {
                  fetch-depth = 0;
                  persist-credentials = false;
                  token = "\${{ secrets.GITHUB_TOKEN }}";
                }
                // cfg.settings.checkout;
              }
              {
                uses = "shikanime-studio/actions/nix/setup@v8";
                "with" = {
                  github-token = "\${{ secrets.GITHUB_TOKEN }}";
                }
                // cfg.settings.setup-nix;
              }
              (
                {
                  id = "setup-profiles-jobs";
                  uses = "shikanime-studio/actions/skaffold/setup-profiles-jobs@v8";
                }
                // optionalAttrs (cfg.settings.setup-profiles-jobs != { }) {
                  "with" = cfg.settings.setup-profiles-jobs;
                }
              )
            ];
          };

          build-render = {
            name = "Build & Render";
            runs-on = "ubuntu-latest";
            permissions = {
              contents = "read";
              packages = "write";
            };
            steps = [
              {
                uses = "actions/checkout@v6";
                "with" = {
                  fetch-depth = 0;
                  persist-credentials = false;
                  token = "\${{ secrets.GITHUB_TOKEN }}";
                }
                // cfg.settings.checkout;
              }
              {
                uses = "docker/login-action@v3";
                "with" = {
                  registry = "ghcr.io";
                  username = "\${{ github.actor }}";
                  password = "\${{ secrets.GITHUB_TOKEN }}";
                };
              }
              {
                uses = "shikanime-studio/actions/nix/setup@v8";
                "with" = {
                  github-token = "\${{ secrets.GITHUB_TOKEN }}";
                }
                // cfg.settings.setup-nix;
              }
              (
                {
                  uses = "shikanime-studio/actions/direnv@v8";
                }
                // optionalAttrs (cfg.settings.direnv != { }) { "with" = cfg.settings.direnv; }
              )
              (
                {
                  uses = "shikanime-studio/actions/skaffold/integration@v8";
                }
                // optionalAttrs (cfg.settings.integration != { }) {
                  "with" = cfg.settings.integration;
                }
              )
            ];
          };

          build-render-profile = {
            name = "Build & Render (Profile)";
            needs = [ "setup-profiles-jobs" ];
            "if" = "\${{ needs['setup-profiles-jobs'].outputs.continue == 'true' }}";
            runs-on = "ubuntu-latest";
            permissions = {
              contents = "read";
              packages = "write";
            };
            strategy = {
              fail-fast = false;
              matrix.include = "\${{ fromJSON(needs['setup-profiles-jobs'].outputs.matrix) }}";
            };
            steps = [
              {
                uses = "actions/checkout@v6";
                "with" = {
                  fetch-depth = 0;
                  persist-credentials = false;
                  token = "\${{ secrets.GITHUB_TOKEN }}";
                }
                // cfg.settings.checkout;
              }
              {
                uses = "docker/login-action@v3";
                "with" = {
                  registry = "ghcr.io";
                  username = "\${{ github.actor }}";
                  password = "\${{ secrets.GITHUB_TOKEN }}";
                };
              }
              {
                uses = "shikanime-studio/actions/nix/setup@v8";
                "with" = {
                  github-token = "\${{ secrets.GITHUB_TOKEN }}";
                }
                // cfg.settings.setup-nix;
              }
              (
                {
                  uses = "shikanime-studio/actions/direnv@v8";
                }
                // optionalAttrs (cfg.settings.direnv != { }) { "with" = cfg.settings.direnv; }
              )
              {
                uses = "shikanime-studio/actions/skaffold/integration@v8";
                "with" = {
                  profile = "\${{ matrix.name }}";
                }
                // cfg.settings.integration;
              }
            ];
          };
        };
      };
    })

    (mkIf (cfg.enable && config.github.workflows.integration.enable) {
      github.settings.workflows.integration = {
        jobs = {
          skaffold = {
            "if" = "\${{ github.event_name == 'workflow_call' || github.event.pull_request.draft == false }}";
            permissions = {
              contents = "read";
              packages = "write";
            };
            uses = "./.github/workflows/skaffold.yaml";
            secrets.OPERATOR_PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
          };
        };
        on.workflow_call.secrets.OPERATOR_PRIVATE_KEY.required = mkDefault true;
      };
    })

    (mkIf (cfg.enable && config.github.workflows.release.enable) {
      github.settings.workflows.release = {
        jobs = {
          skaffold = {
            permissions = {
              contents = "read";
              packages = "write";
            };
            uses = "./.github/workflows/skaffold.yaml";
            secrets.OPERATOR_PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
          };

          release-branch.needs = [ "skaffold" ];
          release-tag.needs = [ "skaffold" ];
        };
        on.workflow_call.secrets.OPERATOR_PRIVATE_KEY.required = mkDefault true;
      };
    })
  ];
}
