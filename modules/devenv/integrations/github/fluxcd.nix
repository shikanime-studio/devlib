{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.github.workflows.fluxcd;

  yamlFormat = pkgs.formats.yaml { };

  githubToken = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
in
{
  options.github.workflows.fluxcd = {
    enable = mkEnableOption "fluxcd";

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
      skaffold = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for skaffold integration";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      github.settings.workflows.fluxcd = {
        name = "FluxCD";

        on = {
          workflow_call.inputs = {
            profile = {
              type = "string";
              required = false;
              description = "Optional Skaffold profile";
            };
            oci_repo = {
              type = "string";
              required = false;
              description = "Flux OCI repository (oci://...)";
            };
          };
          workflow_call.secrets.OPERATOR_PRIVATE_KEY.required = false;

          workflow_dispatch.inputs = {
            profile = {
              type = "string";
              required = false;
              description = "Optional Skaffold profile";
            };
            oci_repo = {
              type = "string";
              required = false;
              description = "Flux OCI repository (oci://...)";
            };
          };
        };

        permissions.contents = "read";

        jobs = {
          push-artifact = {
            name = "Push Artifact";
            runs-on = "ubuntu-latest";
            permissions = {
              contents = "read";
              packages = "write";
            };
            env = {
              OCI_REPO = "\${{ inputs.oci_repo || format('oci://ghcr.io/{0}/manifests/{1}', github.repository_owner, github.event.repository.name) }}";
              SKAFFOLD_PROFILE = "\${{ inputs.profile }}";
            };
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
                uses = "shikanime-studio/actions/checkout@v9";
                "with" = {
                  github-token = githubToken;
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
                uses = "shikanime-studio/actions/nix/setup@v9";
                "with" = {
                  github-token = githubToken;
                }
                // cfg.settings.setup-nix;
              }
              (
                {
                  id = "direnv";
                  uses = "shikanime-studio/actions/direnv@v9";
                }
                // optionalAttrs (cfg.settings.direnv != { }) { "with" = cfg.settings.direnv; }
              )
              (
                {
                  id = "skaffold";
                  uses = "shikanime-studio/actions/skaffold/integration@v9";
                  "with" = {
                    profile = "\${{ env.SKAFFOLD_PROFILE }}";
                  };
                  env = "\${{ fromJSON(steps.direnv.outputs.env) }}";
                }
                // cfg.settings.skaffold
              )
              {
                name = "Write Manifests";
                env.MANIFEST = "\${{ steps.skaffold.outputs.manifest }}";
                run = ''
                  mkdir -p ./deploy
                  printf '%s\n' "$MANIFEST" > ./deploy/manifests.yaml
                '';
              }
              {
                name = "Push Manifests";
                env = {
                  SOURCE_URL = "\${{ format('https://github.com/{0}.git', github.repository) }}";
                  REVISION = "\${{ format('{0}@sha1:{1}', github.ref_name, github.sha) }}";
                  TAG = "\${{ github.sha }}";
                };
                run = ''
                  TAG_SHORT="$(printf '%s' "$TAG" | cut -c 1-7)"
                  nix shell nixpkgs#fluxcd --command \
                    flux push artifact "$OCI_REPO:$TAG_SHORT" \
                      --path="./deploy" \
                      --source="$SOURCE_URL" \
                      --revision="$REVISION"
                '';
              }
            ];
          };
        };
      };
    })

    (mkIf (cfg.enable && config.github.workflows.integration.enable) {
      github.settings.workflows.integration.jobs.fluxcd = {
        "if" = "\${{ github.event_name == 'workflow_call' || github.event.pull_request.draft == false }}";
        uses = "./.github/workflows/fluxcd.yaml";
        permissions = {
          contents = "read";
          packages = "write";
        };
        secrets.OPERATOR_PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
      };
      github.settings.workflows.integration.on.workflow_call.secrets.OPERATOR_PRIVATE_KEY.required =
        mkDefault false;
    })

    (mkIf (cfg.enable && config.github.workflows.release.enable) {
      github.settings.workflows.release.jobs.fluxcd = {
        uses = "./.github/workflows/fluxcd.yaml";
        permissions = {
          contents = "read";
          packages = "write";
        };
        secrets.OPERATOR_PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
      };
      github.settings.workflows.release.on.workflow_call.secrets.OPERATOR_PRIVATE_KEY.required =
        mkDefault false;
    })
  ];
}
