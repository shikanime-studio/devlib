{ pkgs, ... }:

{
  cachix = {
    enable = true;
    push = "shikanime-studio";
  };

  docker.enable = true;

  github = {
    enable = true;
    workflows = {
      automata.settings = {
        name = "Update";
        on = {
          schedule = [
            { cron = "0 0 * * 0"; }
          ];
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
              "with" = {
                "github-token" = "\${{ steps.createGithubAppToken.outputs.token }}";
              };
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

      check.settings = {
        name = "Check";
        on = {
          push.branches = [ "main" ];
          pull_request.branches = [
            "main"
            "gh/*/*/base"
          ];
        };
        jobs.check = {
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
              "with" = {
                "github-token" = "\${{ steps.createGithubAppToken.outputs.token }}";
              };
            }
            {
              name = "Check Nix Flake";
              run = "nix flake check --accept-flake-config --all-systems --no-pure-eval";
            }
          ];
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
              "with" = {
                "github-token" = "\${{ steps.createGithubAppToken.outputs.token }}";
              };
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

      release.settings = {
        name = "Release";
        on.push.tags = [
          "v?[0-9]+.[0-9]+.[0-9]+*"
        ];
        jobs.release = {
          permissions = {
            contents = "write";
          };
          "runs-on" = "ubuntu-latest";
          steps = [
            {
              name = "Release";
              run = "gh release create \${{ github.ref_name }} --repo \${{ github.repository }} --generate-notes";
              env.GITHUB_TOKEN = "\${{ secrets.GITHUB_TOKEN }}";
            }
          ];
        };
      };
    };
  };

  gitignore.enable = true;

  languages = {
    nix.enable = true;
    shell.enable = true;
  };

  packages = [
    pkgs.gh
    pkgs.ghstack
    pkgs.sapling
  ];

  treefmt = {
    enable = true;
    config.programs.prettier.enable = true;
  };
}
