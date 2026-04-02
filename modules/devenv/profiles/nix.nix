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
          needs = [ "setup-checks-jobs" ];
          "if" = "\${{ needs['setup-checks-jobs'].outputs.continue == 'true' }}";
          runs-on = "\${{ matrix.runner }}";
          strategy = {
            fail-fast = false;
            matrix.include = "\${{ fromJSON(needs['setup-checks-jobs'].outputs.matrix) }}";
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
              uses = "shikanime-studio/actions/nix/setup@v8";
              "with" = {
                cachix-auth-token = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
                cachix-name = "\${{ inputs['cachix-name'] }}";
                github-token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
              };
            }
            {
              env.SYSTEM = "\${{ matrix.system }}";
              run = "nix flake check --accept-flake-config --no-pure-eval --system \"$SYSTEM\"";
              shell = "bash";
            }
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
              uses = "shikanime-studio/actions/nix/setup@v8";
              "with" = {
                cachix-auth-token = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
                cachix-name = "\${{ inputs['cachix-name'] }}";
                github-token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
              };
            }
            {
              env = {
                NAME = "\${{ matrix.name }}";
                SYSTEM = "\${{ matrix.system }}";
              };
              run = "nix build --accept-flake-config --no-pure-eval \".#packages.$SYSTEM.$NAME\"";
              shell = "bash";
            }
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
              uses = "shikanime-studio/actions/nix/setup@v8";
              "with".github-token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
            }
            {
              id = "setup-checks-jobs";
              uses = "shikanime-studio/actions/nix/setup-checks-jobs@v8";
            }
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
              uses = "shikanime-studio/actions/nix/setup@v8";
              "with".github-token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
            }
            {
              id = "setup-packages-jobs";
              uses = "shikanime-studio/actions/nix/setup-packages-jobs@v8";
            }
          ];
        };
      };
    };

    integration.jobs.nix = {
      "if" = "\${{ github.event_name == 'workflow_call' || github.event.pull_request.draft == false }}";
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
