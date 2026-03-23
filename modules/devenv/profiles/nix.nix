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
        "packages-systems" = {
          name = "Packages Systems";
          runs-on = "ubuntu-latest";
          outputs.matrix = "\${{ steps.matrix.outputs.matrix }}";
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v2";
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
                token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
              };
            }
            {
              uses = "cachix/install-nix-action@v31";
              "with".github_access_token =
                "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
            }
            {
              id = "matrix";
              run = ''
                matrix="$(
                  nix flake show --json --all-systems --accept-flake-config --no-pure-eval \
                    | nix run nixpkgs#jq -- -c '
                      .packages
                      | keys
                      | map(select(test("linux$")))
                      | map({
                          system: .,
                          os: (if test("^(aarch64|armv6l|armv7l)-linux$") then "ubuntu-24.04-arm" else "ubuntu-latest" end),
                        })
                    '
                )"
                echo "matrix=$matrix" >> "$GITHUB_OUTPUT"
              '';
            }
          ];
        };

        "check-systems" = {
          name = "Check Systems";
          runs-on = "ubuntu-latest";
          outputs.matrix = "\${{ steps.matrix.outputs.matrix }}";
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v2";
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
                token = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
              };
            }
            {
              uses = "cachix/install-nix-action@v31";
              "with".github_access_token =
                "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
            }
            {
              id = "matrix";
              run = ''
                matrix="$(
                  nix flake show --json --all-systems --accept-flake-config --no-pure-eval \
                    | nix run nixpkgs#jq -- -c '
                      (.checks // .packages)
                      | keys
                      | map(select(test("linux$")))
                      | map({
                          system: .,
                          os: (if test("^(aarch64|armv6l|armv7l)-linux$") then "ubuntu-24.04-arm" else "ubuntu-latest" end),
                        })
                    '
                )"
                echo "matrix=$matrix" >> "$GITHUB_OUTPUT"
              '';
            }
          ];
        };

        check = {
          name = "Check";
          needs = [ "check-systems" ];
          runs-on = "\${{ matrix.os }}";
          strategy.matrix.include = "\${{ fromJSON(needs['check-systems'].outputs.matrix) }}";
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v2";
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
              uses = "cachix/cachix-action@v16";
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
          needs = [ "packages-systems" ];
          runs-on = "\${{ matrix.os }}";
          strategy.matrix.include = "\${{ fromJSON(needs['packages-systems'].outputs.matrix) }}";
          steps = [
            {
              continue-on-error = true;
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v2";
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
              uses = "cachix/cachix-action@v16";
              "with" = {
                authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
                name = "\${{ inputs['cachix-name'] }}";
              };
            }
            {
              run = ''
                packages="$(
                  nix flake show --json --all-systems --accept-flake-config --no-pure-eval \
                    | nix run nixpkgs#jq -- -r --arg system "''${{ matrix.system }}" '.packages[$system] | keys[]'
                )"
                for package in $packages; do
                  nix build -L --accept-flake-config --no-pure-eval ".#packages.''${{ matrix.system }}.$package"
                done
              '';
            }
          ];
        };
      };
    };

    integration.jobs = {
      nix = {
        uses = "./.github/workflows/nix.yaml";
        secrets = {
          OPERATOR_PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
          CACHIX_AUTH_TOKEN = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
        };
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
