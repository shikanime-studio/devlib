{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.github.workflows.javascript;

  yamlFormat = pkgs.formats.yaml { };

  githubToken = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
in
{
  options.github.workflows.javascript = {
    enable = mkEnableOption "javascript";

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
      pnpm-build = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for pnpm build";
      };
      pnpm-check = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for pnpm check";
      };
      pnpm-install = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for pnpm install";
      };
      pnpm-lint = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for pnpm lint";
      };
      setup-nix = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for setup-nix";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      github.settings.workflows.javascript = {
        name = "JavaScript";
        on.workflow_call.secrets.OPERATOR_PRIVATE_KEY.required = true;

        permissions.contents = "read";

        jobs = {
          build = {
            name = "Build";
            runs-on = "ubuntu-latest";
            steps = [
              {
                continue-on-error = true;
                id = "createGithubAppToken";
                uses = "actions/create-github-app-token@v3";
                "with" = {
                  app-id = "\${{ vars.OPERATOR_APP_ID }}";
                  private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                  permission-contents = "read";
                }
                // cfg.settings.create-github-app-token;
              }
              {
                uses = "actions/checkout@v6";
                "with" = {
                  fetch-depth = 0;
                  persist-credentials = false;
                  token = githubToken;
                }
                // cfg.settings.checkout;
              }
              {
                uses = "shikanime-studio/actions/nix/setup@v8";
                "with" = {
                  github-token = githubToken;
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
                  run = "corepack pnpm install --frozen-lockfile";
                }
                // optionalAttrs (cfg.settings.pnpm-install != { }) { env = cfg.settings.pnpm-install; }
              )
              (
                {
                  run = "corepack pnpm --recursive build";
                }
                // optionalAttrs (cfg.settings.pnpm-build != { }) { env = cfg.settings.pnpm-build; }
              )
            ];
          };

          check = {
            name = "Check";
            runs-on = "ubuntu-latest";
            steps = [
              {
                continue-on-error = true;
                id = "createGithubAppToken";
                uses = "actions/create-github-app-token@v3";
                "with" = {
                  app-id = "\${{ vars.OPERATOR_APP_ID }}";
                  private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                  permission-contents = "read";
                }
                // cfg.settings.create-github-app-token;
              }
              {
                uses = "actions/checkout@v6";
                "with" = {
                  fetch-depth = 0;
                  persist-credentials = false;
                  token = githubToken;
                }
                // cfg.settings.checkout;
              }
              {
                uses = "shikanime-studio/actions/nix/setup@v8";
                "with" = {
                  github-token = githubToken;
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
                run = "corepack pnpm install --frozen-lockfile";
                env = {
                  DEBUG = "\${{ runner.debug == '1' && '--debug=1' || '' }}";
                }
                // cfg.settings.pnpm-install;
              }
              {
                run = "corepack pnpm --recursive check";
                env = {
                  DEBUG = "\${{ runner.debug == '1' && '--debug=1' || '' }}";
                }
                // cfg.settings.pnpm-check;
              }
            ];
          };

          lint = {
            name = "Lint";
            runs-on = "ubuntu-latest";
            steps = [
              {
                continue-on-error = true;
                id = "createGithubAppToken";
                uses = "actions/create-github-app-token@v3";
                "with" = {
                  app-id = "\${{ vars.OPERATOR_APP_ID }}";
                  private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                  permission-contents = "read";
                }
                // cfg.settings.create-github-app-token;
              }
              {
                uses = "actions/checkout@v6";
                "with" = {
                  fetch-depth = 0;
                  persist-credentials = false;
                  token = githubToken;
                }
                // cfg.settings.checkout;
              }
              {
                uses = "shikanime-studio/actions/nix/setup@v8";
                "with" = {
                  github-token = githubToken;
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
                  run = "corepack pnpm install --frozen-lockfile";
                }
                // optionalAttrs (cfg.settings.pnpm-install != { }) { env = cfg.settings.pnpm-install; }
              )
              (
                {
                  run = "corepack pnpm --recursive lint";
                }
                // optionalAttrs (cfg.settings.pnpm-lint != { }) { env = cfg.settings.pnpm-lint; }
              )
            ];
          };
        };
      };
    })

    (mkIf (cfg.enable && config.github.workflows.integration.enable) {
      github.settings.workflows.integration = {
        jobs = {
          javascript = {
            "if" = "\${{ github.event_name == 'workflow_call' || github.event.pull_request.draft == false }}";
            uses = "./.github/workflows/javascript.yaml";
            secrets.OPERATOR_PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
          };
        };
        on.workflow_call.secrets.OPERATOR_PRIVATE_KEY.required = mkDefault true;
      };
    })

    (mkIf (cfg.enable && config.github.workflows.release.enable) {
      github.settings.workflows.release = {
        jobs = {
          javascript = {
            uses = "./.github/workflows/javascript.yaml";
            secrets.OPERATOR_PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
          };

          release-branch.needs = [ "javascript" ];
          release-tag.needs = [ "javascript" ];
        };
        on.workflow_call.secrets.OPERATOR_PRIVATE_KEY.required = mkDefault true;
      };
    })
  ];
}
