{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.github.workflows.release;

  yamlFormat = pkgs.formats.yaml { };
in
{
  options.github.workflows.release = {
    enable = mkEnableOption "release";

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
    };
  };

  config = mkIf cfg.enable {
    github.settings.workflows.release = {
      jobs = {
        release-branch = {
          "if" =
            "(startsWith(github.ref, 'refs/tags/v') && endsWith(github.ref_name, '.0')) || (github.event_name == 'workflow_dispatch' && startsWith(github.event.inputs.ref_name, 'v') && endsWith(github.event.inputs.ref_name, '.0'))";
          runs-on = "ubuntu-slim";
          permissions.contents = "write";
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v3";
              "with" = {
                app-id = "\${{ vars.OPERATOR_APP_ID }}";
                permission-contents = "write";
                permission-workflows = "write";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
              }
              // cfg.settings.create-github-app-token;
            }
            {
              uses = "shikanime-studio/actions/nix/setup@v9";
              "with" = {
                github-token = "\${{ steps.createGithubAppToken.outputs.token }}";
              };
            }
            {
              uses = "shikanime-studio/actions/checkout@v9";
              "with" = {
                github-token = "\${{ steps.createGithubAppToken.outputs.token }}";
              }
              // cfg.settings.checkout;
            }
            {
              env.REF_NAME = "\${{ github.ref_name || github.event.inputs.ref_name }}";
              run = "git push origin \"HEAD:refs/heads/release-$(printf '%s' \"$REF_NAME\" | sed -e 's/^v//' -e 's/[.][^.]*$//')\"";
            }
          ];
        };
        release-tag = {
          "if" =
            "(startsWith(github.ref, 'refs/tags/v')) || (github.event_name == 'workflow_dispatch' && startsWith(github.event.inputs.ref_name, 'v'))";
          runs-on = "ubuntu-slim";
          permissions.contents = "write";
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v3";
              "with" = {
                app-id = "\${{ vars.OPERATOR_APP_ID }}";
                permission-contents = "write";
                permission-workflows = "write";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
              }
              // cfg.settings.create-github-app-token;
            }
            {
              uses = "shikanime-studio/actions/nix/setup@v9";
              "with" = {
                github-token = "\${{ steps.createGithubAppToken.outputs.token }}";
              };
            }
            {
              uses = "shikanime-studio/actions/checkout@v9";
              "with" = {
                github-token = "\${{ steps.createGithubAppToken.outputs.token }}";
              }
              // cfg.settings.checkout;
            }
            {
              env = {
                GH_TOKEN = "\${{ steps.createGithubAppToken.outputs.token }}";
                REF_NAME = "\${{ github.ref_name || github.event.inputs.ref_name }}";
              };
              run = "gh release create \"$REF_NAME\" --repo \"\${{ github.repository }}\" || true";
            }
            {
              uses = "actions/download-artifact@v7";
              continue-on-error = true;
              "with" = {
                path = "artifacts";
                merge-multiple = true;
              };
            }
            {
              env = {
                GH_TOKEN = "\${{ steps.createGithubAppToken.outputs.token }}";
                REF_NAME = "\${{ github.ref_name || github.event.inputs.ref_name }}";
                REPO = "\${{ github.repository }}";
              };
              run = "find artifacts -type f -print0 | xargs -0 -r gh release upload \"$REF_NAME\" --repo \"$REPO\" --clobber";
              shell = "bash";
            }
          ];
        };
      };
      name = "Release";
      on = {
        push = {
          branches = [
            "main"
            "release-[0-9]+.[0-9]+"
          ];
          tags = [ "v?[0-9]+.[0-9]+.[0-9]+*" ];
        };
        workflow_dispatch.inputs.ref_name = {
          description = "Tag or branch to release";
          required = true;
        };
      };
      permissions.contents = "read";
    };
  };
}
