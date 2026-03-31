{
  imports = [ ./base.nix ];

  git-hooks.hooks.flake-checker.enable = true;

  gitignore.templates = [
    "repo:shikanime-studio/gitignore/refs/heads/main/Devenv.gitignore"
  ];

  languages.nix.enable = true;

  renovate.settings.nix.enabled = true;

  treefmt.config.programs = {
    deadnix.enable = true;
    nixfmt.enable = true;
    statix.enable = true;
  };

  github.settings.workflows = {
    nix = {
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
          needs = [ "setup-checks" ];
          "if" = "\${{ needs['setup-checks'].outputs.continue == 'true' }}";
          runs-on = "\${{ matrix.runner }}";
          strategy = {
            fail-fast = false;
            matrix.include = "\${{ fromJSON(needs['setup-checks'].outputs.matrix) }}";
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
              };
            }
            {
              uses = "actions/checkout@v6";
              "with" = {
                fetch-depth = 0;
                persist-credentials = false;
                token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
              };
            }
            {
              uses = "cachix/install-nix-action@v31";
              "with".github_access_token =
                "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
            }
            {
              "if" = "\${{ inputs['cachix-name'] != '' }}";
              continue-on-error = true;
              uses = "cachix/cachix-action@v17";
              "with" = {
                authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
                name = "\${{ inputs['cachix-name'] }}";
              };
            }
            { run = "nix run nixpkgs#direnv allow"; }
            { run = "nix run nixpkgs#direnv export gha >> \"$GITHUB_ENV\""; }
            { run = "nix flake check --accept-flake-config --no-pure-eval --system \"\${{ matrix.system }}\""; }
          ];
        };

        packages = {
          name = "Packages";
          needs = [ "setup-packages" ];
          "if" = "\${{ needs['setup-packages'].outputs.continue == 'true' }}";
          runs-on = "\${{ matrix.runner }}";
          strategy = {
            fail-fast = false;
            matrix.include = "\${{ fromJSON(needs['setup-packages'].outputs.matrix) }}";
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
              };
            }
            {
              uses = "actions/checkout@v6";
              "with" = {
                fetch-depth = 0;
                persist-credentials = false;
                token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
              };
            }
            {
              uses = "cachix/install-nix-action@v31";
              "with".github_access_token =
                "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
            }
            {
              "if" = "\${{ inputs['cachix-name'] != '' }}";
              continue-on-error = true;
              uses = "cachix/cachix-action@v17";
              "with" = {
                authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
                name = "\${{ inputs['cachix-name'] }}";
              };
            }
            {
              run = "nix build --accept-flake-config --no-pure-eval \".#packages.\${{ matrix.system }}.\${{ matrix.name }}\"";
            }
          ];
        };

        setup-checks = {
          name = "Setup Checks";
          runs-on = "ubuntu-latest";
          outputs = {
            continue = "\${{ steps.setup-checks.outputs.continue }}";
            matrix = "\${{ steps.setup-checks.outputs.matrix }}";
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
              };
            }
            {
              uses = "actions/checkout@v6";
              "with" = {
                fetch-depth = 0;
                persist-credentials = false;
                token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
              };
            }
            {
              uses = "cachix/install-nix-action@v31";
              "with".github_access_token =
                "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
            }
            {
              id = "setup-checks";
              uses = "shikanime-studio/actions/nix/setup-check-jobs@v8";
            }
          ];
        };

        setup-packages = {
          name = "Setup Packages";
          runs-on = "ubuntu-latest";
          outputs = {
            continue = "\${{ steps.setup-packages.outputs.continue }}";
            matrix = "\${{ steps.setup-packages.outputs.matrix }}";
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
              };
            }
            {
              uses = "actions/checkout@v6";
              "with" = {
                fetch-depth = 0;
                persist-credentials = false;
                token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
              };
            }
            {
              uses = "cachix/install-nix-action@v31";
              "with".github_access_token =
                "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
            }
            {
              id = "setup-packages";
              uses = "shikanime-studio/actions/nix/setup-packages-jobs@v8";
            }
          ];
        };
      };
    };

    integration.jobs.nix = {
      "if" = "\${{ github.event.pull_request.draft == false }}";
      uses = "./.github/workflows/nix.yaml";
      secrets = {
        OPERATOR_PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
        CACHIX_AUTH_TOKEN = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
      };
    };

    release.jobs = {
      nix = {
        uses = "./.github/workflows/nix.yaml";
        secrets = {
          OPERATOR_PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
          CACHIX_AUTH_TOKEN = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
        };
      };

      release-branch.needs = [ "nix" ];
      release-tag.needs = [ "nix" ];
    };
  };
}
