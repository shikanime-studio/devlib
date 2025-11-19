{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.shikanime-studio;
in
{
  options.shikanime-studio = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Shikanime Studio";
    };

    github.actions = {
      create-github-app-token = {
        name = mkOption {
          type = types.str;
          default = "actions/create-github-app-token";
          readOnly = true;
          description = "Name of the create-github-app-token workflow";
        };

        version = mkOption {
          type = types.str;
          default = "v2";
          description = "Version of the create-github-app-token workflow";
        };

        extraOptions = mkOption {
          type = types.attrs;
          default = { };
          description = "Extra options to pass to the create-github-app-token workflow";
        };
      };

      checkout = {
        name = mkOption {
          type = types.str;
          default = "actions/checkout";
          readOnly = true;
          description = "Name of the checkout workflow";
        };

        version = mkOption {
          type = types.str;
          default = "v5";
          readOnly = true;
          description = "Version of the checkout action";
        };

        extraOptions = mkOption {
          type = types.attrs;
          default = { };
          description = "Extra options to pass to the checkout action";
        };
      };

      setup-nix = {
        name = mkOption {
          type = types.str;
          default = "shikanime-studio/setup-nix-action";
          readOnly = true;
          description = "Name of the setup-nix workflow";
        };

        version = mkOption {
          type = types.str;
          default = "v1";
          description = "Version of the setup-nix-action";
        };

        extraOptions = mkOption {
          type = types.attrs;
          default = { };
          description = "Extra options to pass to the setup-nix-action";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    cachix = {
      enable = true;
      push = shikanime-studio;
    };

    containers = pkgs.lib.mkForce { };

    docker.enable = true;

    github = {
      enable = true;
      workflows =
        with config.github.lib;
        let
          createGithubAppToken =
            let
              workflows = cfg.github.actions.create-github-app-token;
            in
            {
              id = "createGithubAppToken";
              uses = "${workflows.name}@${workflows.version}";
              "with" = {
                app-id = mkWorkflowRef "vars.OPERATOR_APP_ID";
                private-key = mkWorkflowRef "secrets.OPERATOR_PRIVATE_KEY";
              }
              // workflows.extraOptions;
            };

          checkout =
            let
              workflows = cfg.github.actions.checkout;
            in
            {
              uses = "${workflows.name}@${workflows.version}";
              "with" = {
                fetch-depth = 0;
                token = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
              }
              // workflows.extraOptions;
            };

          setupNix =
            let
              workflows = cfg.github.actions.setup-nix;
            in
            {
              uses = "${workflows.name}@${workflows.version}";
              "with" = {
                github-token = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
              }
              // workflows.extraOptions;
            };
        in
        {
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
              runs-on = "ubuntu-latest";
              steps = [
                createGithubAppToken
                checkout
                setupNix
                {
                  name = "Check Nix Flake";
                  run = mkWorkflowRun [
                    "nix"
                    "flake"
                    "check"
                    "--accept-flake-config"
                    "--all-systems"
                    "--no-pure-eval"
                  ];
                }
              ];
            };
          };
          land.settings = {
            name = "Land";
            on.issue_comment.types = [ "created" ];
            jobs.land = {
              runs-on = "ubuntu-latest";
              steps = [
                createGithubAppToken
                checkout
                setupNix
                {
                  uses = "shikanime-studio/sapling-action@v5";
                  "with" = {
                    github-token = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
                    gpg-passphrase = mkWorkflowRef "secrets.GPG_PASSPHRASE";
                    gpg-private-key = mkWorkflowRef "secrets.GPG_PRIVATE_KEY";
                    sign-commits = true;
                    username = "Operator 6O <operator6o@shikanime.studio>";
                  };
                }
              ];
            };
          };
          release.settings = {
            name = "Release";
            on.push.tags = [ "v?[0-9]+.[0-9]+.[0-9]+*" ];
            jobs.release = {
              runs-on = "ubuntu-latest";
              steps = [
                createGithubAppToken
                checkout
                {
                  env.GITHUB_TOKEN = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
                  run = mkWorkflowRun [
                    "gh"
                    "release"
                    "create"
                    "\${{ github.ref_name }}"
                    "--repo"
                    "\${{ github.repository }}"
                    "--generate-notes"
                  ];
                }
              ];
            };
          };
          triage.settings = {
            name = "Triage";
            on = {
              pull_request.types = [
                "opened"
                "synchronize"
              ];
              check_suite.types = [ "completed" ];
            };
            jobs.triage = {
              runs-on = "ubuntu-latest";
              steps = [
                createGithubAppToken
                checkout
                {
                  env.GITHUB_TOKEN = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
                  "if" = concatStringsSep " || " [
                    "github.event.pull_request.user.login == 'yorha-operator-6o[bot]'"
                    "github.event.pull_request.user.login == 'dependabot[bot]'"
                  ];
                  run = mkWorkflowRun [
                    "gh"
                    "pr"
                    "edit"
                    (mkWorkflowRef "github.event.pull_request.number")
                    "--add-label"
                    "dependencies"
                  ];
                }
              ];
            };
          };
          update.settings = {
            name = "Update";
            on = {
              schedule = [ { cron = "0 0 * * 0"; } ];
              workflow_dispatch = null;
            };
            jobs.update = {
              runs-on = "ubuntu-latest";
              steps = [
                createGithubAppToken
                checkout
                setupNix
                {
                  uses = "shikanime-studio/automata-action@v1";
                  "with" = {
                    ghstack-username = "operator6o";
                    github-token = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
                    gpg-passphrase = mkWorkflowRef "secrets.GPG_PASSPHRASE";
                    gpg-private-key = mkWorkflowRef "secrets.GPG_PRIVATE_KEY";
                    sign-commits = true;
                    username = "Operator 6O <operator6o@shikanime.studio>";
                  };
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
  };
}
