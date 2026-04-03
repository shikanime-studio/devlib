{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.github.workflows.nix;

  yamlFormat = pkgs.formats.yaml { };

  githubToken = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
in
{
  options.github.workflows.nix = {
    enable = mkEnableOption "nix";

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
      flake-check = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for nix flake check";
      };
      nix-build = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for nix build";
      };
      setup-checks-jobs = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for setup-checks-jobs";
      };
      setup-nix = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for setup-nix";
      };
      setup-packages-jobs = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for setup-packages-jobs";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      github.settings.workflows.nix = {
        name = "Nix";
        on.workflow_call = {
          inputs.cachix-name = {
            type = "string";
            default = "";
          };
          secrets = {
            OPERATOR_PRIVATE_KEY.required = true;
            CACHIX_AUTH_TOKEN.required = false;
          };
        };

        permissions.contents = "read";

        jobs = {
          checks = {
            name = "Checks";
            needs = [ "setup-checks-jobs" ];
            "if" = "\${{ needs['setup-checks-jobs'].outputs.continue == 'true' }}";
            runs-on = "\${{ matrix.runner }}";
            strategy = {
              fail-fast = false;
              matrix.include = "\${{ fromJSON(needs['setup-checks-jobs'].outputs.matrix) }}";
            };
            steps = [
              (
                {
                  continue-on-error = true;
                  id = "createGithubAppToken";
                  uses = "actions/create-github-app-token@v3";
                  "with" = {
                    app-id = "\${{ vars.OPERATOR_APP_ID }}";
                    private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                    permission-contents = "read";
                  };
                }
                // cfg.settings.create-github-app-token
              )
              (
                {
                  uses = "actions/checkout@v6";
                  "with" = {
                    fetch-depth = 0;
                    persist-credentials = false;
                    token = githubToken;
                  };
                }
                // cfg.settings.checkout
              )
              (
                {
                  uses = "shikanime-studio/actions/nix/setup@v8";
                  "with" = {
                    cachix-auth-token = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
                    cachix-name = "\${{ inputs['cachix-name'] }}";
                    github-token = githubToken;
                  };
                }
                // cfg.settings.setup-nix
              )
              (
                {
                  env.SYSTEM = "\${{ matrix.system }}";
                  run = "nix flake check --accept-flake-config --no-pure-eval --system \"$SYSTEM\"";
                  shell = "bash";
                }
                // cfg.settings.flake-check
              )
            ];
          };

          packages = {
            name = "Packages";
            needs = [ "setup-packages-jobs" ];
            "if" = "\${{ needs['setup-packages-jobs'].outputs.continue == 'true' }}";
            runs-on = "\${{ matrix.runner }}";
            strategy = {
              fail-fast = false;
              matrix.include = "\${{ fromJSON(needs['setup-packages-jobs'].outputs.matrix) }}";
            };
            steps = [
              (
                {
                  continue-on-error = true;
                  id = "createGithubAppToken";
                  uses = "actions/create-github-app-token@v3";
                  "with" = {
                    app-id = "\${{ vars.OPERATOR_APP_ID }}";
                    private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                    permission-contents = "read";
                  };
                }
                // cfg.settings.create-github-app-token
              )
              (
                {
                  uses = "actions/checkout@v6";
                  "with" = {
                    fetch-depth = 0;
                    persist-credentials = false;
                    token = githubToken;
                  };
                }
                // cfg.settings.checkout
              )
              (
                {
                  uses = "shikanime-studio/actions/nix/setup@v8";
                  "with" = {
                    cachix-auth-token = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
                    cachix-name = "\${{ inputs['cachix-name'] }}";
                    github-token = githubToken;
                  };
                }
                // cfg.settings.setup-nix
              )
              (
                {
                  env = {
                    NAME = "\${{ matrix.name }}";
                    SYSTEM = "\${{ matrix.system }}";
                  };
                  run = "nix build --accept-flake-config --no-pure-eval \".#packages.$SYSTEM.$NAME\"";
                  shell = "bash";
                }
                // cfg.settings.nix-build
              )
            ];
          };

          setup-checks-jobs = {
            name = "Setup Checks Jobs";
            runs-on = "ubuntu-latest";
            outputs = {
              continue = "\${{ steps.setup-checks-jobs.outputs.continue }}";
              matrix = "\${{ steps.setup-checks-jobs.outputs.matrix }}";
            };
            steps = [
              (
                {
                  continue-on-error = true;
                  id = "createGithubAppToken";
                  uses = "actions/create-github-app-token@v3";
                  "with" = {
                    app-id = "\${{ vars.OPERATOR_APP_ID }}";
                    private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                    permission-contents = "read";
                  };
                }
                // cfg.settings.create-github-app-token
              )
              (
                {
                  uses = "actions/checkout@v6";
                  "with" = {
                    fetch-depth = 0;
                    persist-credentials = false;
                    token = githubToken;
                  };
                }
                // cfg.settings.checkout
              )
              (
                {
                  uses = "shikanime-studio/actions/nix/setup@v8";
                  "with".github-token = githubToken;
                }
                // cfg.settings.setup-nix
              )
              (
                {
                  id = "setup-checks-jobs";
                  uses = "shikanime-studio/actions/nix/setup-checks-jobs@v8";
                }
                // cfg.settings.setup-checks-jobs
              )
            ];
          };

          setup-packages-jobs = {
            name = "Setup Packages Jobs";
            runs-on = "ubuntu-latest";
            outputs = {
              continue = "\${{ steps.setup-packages-jobs.outputs.continue }}";
              matrix = "\${{ steps.setup-packages-jobs.outputs.matrix }}";
            };
            steps = [
              (
                {
                  continue-on-error = true;
                  id = "createGithubAppToken";
                  uses = "actions/create-github-app-token@v3";
                  "with" = {
                    app-id = "\${{ vars.OPERATOR_APP_ID }}";
                    private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                    permission-contents = "read";
                  };
                }
                // cfg.settings.create-github-app-token
              )
              (
                {
                  uses = "actions/checkout@v6";
                  "with" = {
                    fetch-depth = 0;
                    persist-credentials = false;
                    token = githubToken;
                  };
                }
                // cfg.settings.checkout
              )
              (
                {
                  uses = "shikanime-studio/actions/nix/setup@v8";
                  "with".github-token = githubToken;
                }
                // cfg.settings.setup-nix
              )
              (
                {
                  id = "setup-packages-jobs";
                  uses = "shikanime-studio/actions/nix/setup-packages-jobs@v8";
                }
                // cfg.settings.setup-packages-jobs
              )
            ];
          };
        };
      };
    })

    (mkIf (cfg.enable && config.github.workflows.integration.enable) {
      github.settings.workflows.integration.jobs.nix = {
        "if" = "\${{ github.event_name == 'workflow_call' || github.event.pull_request.draft == false }}";
        uses = "./.github/workflows/nix.yaml";
        secrets = {
          OPERATOR_PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
          CACHIX_AUTH_TOKEN = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
        };
      };
    })

    (mkIf (cfg.enable && config.github.workflows.release.enable) {
      github.settings.workflows.release.jobs.nix = {
        uses = "./.github/workflows/nix.yaml";
        secrets = {
          OPERATOR_PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
          CACHIX_AUTH_TOKEN = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
        };
      };

      github.settings.workflows.release.jobs.release-branch.needs = [ "nix" ];
      github.settings.workflows.release.jobs.release-tag.needs = [ "nix" ];
    })
  ];
}
