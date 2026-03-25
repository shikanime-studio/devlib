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
      cachix-push = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for cachix-push";
      };
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
      nix-flake-check = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for nix-flake-check";
      };
      setup-nix = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for setup-nix";
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
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
              }
              // cfg.settings.create-github-app-token;
            }
            {
              uses = "actions/checkout@v6";
              "with" = {
                fetch-depth = 0;
                persist-credentials = false;
                token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
              }
              // cfg.settings.checkout;
            }
            {
              env.REF_NAME = "\${{ github.ref_name || github.event.inputs.ref_name }}";
              run = "VERSION=\"\${REF_NAME#v}\"; BASE=\"\${VERSION%.*}\"; BRANCH=\"release-$BASE\"; git push origin \"HEAD:refs/heads/$BRANCH\"";
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
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
              }
              // cfg.settings.create-github-app-token;
            }
            {
              uses = "actions/checkout@v6";
              "with" = {
                fetch-depth = 0;
                persist-credentials = false;
                token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
              }
              // cfg.settings.checkout;
            }
            {
              env = {
                GITHUB_TOKEN = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
                REF_NAME = "\${{ github.ref_name || github.event.inputs.ref_name }}";
                REPO = "\${{ github.repository }}";
              };
              run = "gh release create \"$REF_NAME\" --repo \"$REPO\" --generate-notes || true";
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
