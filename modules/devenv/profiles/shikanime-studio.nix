{
  pkgs,
  lib,
  config,
  ...
}:

{
  github.workflows = {
    check.settings = {
      name = "Check";
      on = {
        push.branches = [ "main" ];
        pull_request.branches = [
          "main"
          "gh/*/*/base"
        ];
      };
      jobs = {
        check = {
          "runs-on" = "ubuntu-latest";
          "if" = "\${{ github.event_name != 'pull_request' || !github.event.pull_request.draft }}";
          steps = [
            { uses = "actions/checkout@v5"; }
            {
              uses = "DeterminateSystems/nix-installer-action@v20";
              "with"."github-token" = "\${{ secrets.NIX_GITHUB_TOKEN }}";
            }
            { uses = "DeterminateSystems/magic-nix-cache-action@v13"; }
            {
              name = "Check Nix Flake";
              run = ''
                nix flake check \
                  --all-systems \
                  --no-pure-eval \
                  --accept-flake-config
              '';
            }
          ];
        };
      };
    };

    land.settings = {
      name = "Land";
      on.issue_comment.types = [ "created" ];
      jobs.land = {
        "runs-on" = "ubuntu-latest";
        steps = [
          {
            id = "createGithubAppToken";
            uses = "actions/create-github-app-token@v2";
            "with"."app-id" = "\${{ vars.OPERATOR_APP_ID }}";
            "with"."private-key" = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
          }
          {
            uses = "actions/checkout@v5";
            "with"."fetch-depth" = 0;
            "with".token = "\${{ steps.createGithubAppToken.outputs.token }}";
          }
          {
            uses = "DeterminateSystems/nix-installer-action@v20";
            "with"."github-token" = "\${{ steps.createGithubAppToken.outputs.token }}";
          }
          { uses = "DeterminateSystems/magic-nix-cache-action@v13"; }
          {
            uses = "shikanime-studio/sapling-action@v3";
            "with".token = "\${{ steps.createGithubAppToken.outputs.token }}";
            "with"."sign-commits" = true;
            "with"."gpg-private-key" = "\${{ secrets.GPG_PRIVATE_KEY }}}";
            "with"."gpg-passphrase" = "\${{ secrets.GPG_PASSPHRASE }}";
          }
        ];
      };
    };

    update.settings = {
      name = "Update";
      on = {
        schedule = [ { cron = "0 0 * * 0"; } ];
        workflow_dispatch = { };
      };
      jobs.update = {
        "runs-on" = "ubuntu-latest";
        steps = [
          {
            id = "createGithubAppToken";
            uses = "actions/create-github-app-token@v2";
            "with"."app-id" = "\${{ vars.OPERATOR_APP_ID }}";
            "with"."private-key" = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
            "with".owner = "\${{ github.repository_owner }}";
          }
          {
            uses = "actions/checkout@v5";
            "with"."fetch-depth" = 0;
            "with".token = "\${{ steps.createGithubAppToken.outputs.token }}";
          }
          {
            uses = "DeterminateSystems/nix-installer-action@v20";
            "with"."github-token" = "\${{ steps.createGithubAppToken.outputs.token }}";
          }
          { uses = "DeterminateSystems/magic-nix-cache-action@v13"; }
          {
            run = ''
              nix flake update
              nix run nixpkgs#sapling -- config \
                --local ui.username "github-actions[bot]" \
                --local ui.email "github-actions[bot]@users.noreply.github.com"
              nix run nixpkgs#sapling -- ci \
                -m "Update Flake"
              nix run nixpkgs#sapling ghstack
            '';
          }
        ];
      };
    };
  };
}
