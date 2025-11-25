{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  cachix = {
    enable = mkDefault true;
    push = "shikanime-studio";
  };

  containers = pkgs.lib.mkForce { };

  docker.enable = mkDefault true;

  github = {
    enable = mkDefault true;

    actions = with config.github.lib; {
      automata = {
        uses = "shikanime-studio/automata-action@v1";
        "with" = {
          ghstack-username = "operator6o";
          github-token = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
          gpg-passphrase = mkWorkflowRef "secrets.GPG_PASSPHRASE";
          gpg-private-key = mkWorkflowRef "secrets.GPG_PRIVATE_KEY";
          sign-commits = true;
          username = "Operator 6O <operator6o@shikanime.studio>";
        };
      };

      create-github-app-token = {
        id = "createGithubAppToken";
        uses = "actions/create-github-app-token@v2";
        "with" = {
          app-id = mkWorkflowRef "vars.OPERATOR_APP_ID";
          private-key = mkWorkflowRef "secrets.OPERATOR_PRIVATE_KEY";
        };
      };

      checkout = {
        uses = "actions/checkout@v5";
        "with" = {
          fetch-depth = 0;
          token = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
        };
      };

      direnv.uses = "shikanime-studio/direnv-action@v2";

      docker-login = {
        uses = "docker/login-action@v3";
        "with" = {
          registry = "ghcr.io";
          username = mkWorkflowRef "github.actor";
          password = mkWorkflowRef "secrets.GITHUB_TOKEN";
        };
      };

      nix-flake-check.run = mkWorkflowRun [
        "nix"
        "flake"
        "check"
        "--accept-flake-config"
        "--all-systems"
        "--no-pure-eval"
      ];

      sapling = {
        uses = "shikanime-studio/sapling-action@v5";
        "with" = {
          github-token = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
          gpg-passphrase = mkWorkflowRef "secrets.GPG_PASSPHRASE";
          gpg-private-key = mkWorkflowRef "secrets.GPG_PRIVATE_KEY";
          sign-commits = true;
          username = "Operator 6O <operator6o@shikanime.studio>";
        };
      };

      setup-nix = {
        uses = "shikanime-studio/setup-nix-action@v1";
        "with".github-token = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
      };
    };

    workflows = with config.github.lib; {
      main = {
        enable = mkDefault true;
        settings = {
          name = "Main";
          on = {
            push.branches = [
              "main"
              "release-*"
            ];
            pull_request.branches = [
              "main"
              "gh/*/*/base"
            ];
          };
          jobs.check = {
            runs-on = "ubuntu-latest";
            steps = with config.github.actions; [
              create-github-app-token
              checkout
              setup-nix
              direnv
              nix-flake-check
            ];
          };
        };
      };

      land = {
        enable = mkDefault true;
        settings = {
          name = "Land";
          on.issue_comment.types = [ "created" ];
          jobs.land = {
            runs-on = "ubuntu-latest";
            steps = with config.github.actions; [
              create-github-app-token
              checkout
              setup-nix
              sapling
            ];
          };
        };
      };

      release = {
        enable = mkDefault true;
        settings = {
          name = "Release";
          on.push.tags = [ "v?[0-9]+.[0-9]+.[0-9]+*" ];
          jobs = {
            check = {
              runs-on = "ubuntu-latest";
              steps = with config.github.actions; [
                create-github-app-token
                checkout
                setup-nix
                direnv
                nix-flake-check
              ];
            };

            publish = {
              needs = [ "check" ];
              runs-on = "ubuntu-latest";
              steps = [
                create-github-app-token
                checkout
                {
                  env.GITHUB_TOKEN = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
                  run = mkWorkflowRun [
                    "gh"
                    "release"
                    "create"
                    (mkWorkflowRef "github.ref_name")
                    "--repo"
                    (mkWorkflowRef "github.repository")
                    "--generate-notes"
                  ];
                }
              ];
            };
          };
        };
      };

      stale = {
        enable = mkDefault true;
        settings = {
          name = "Stale";
          on = {
            schedule = [ { cron = "30 1 * * *"; } ];
          };
          jobs.stale = {
            runs-on = "ubuntu-latest";
            steps = with config.github.actions; [
              create-github-app-token
              {
                uses = "actions/stale@v10";
                "with" = {
                  days-before-close = 14;
                  days-before-stale = 30;
                  repo-token = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
                  stale-issue-label = "stale";
                  stale-pr-label = "stale";
                };
              }
            ];
          };
        };
      };

      triage = {
        enable = mkDefault true;
        settings = {
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
            steps = with config.github.actions; [
              create-github-app-token
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
      };

      update = {
        enable = mkDefault true;
        settings = {
          name = "Update";
          on = {
            schedule = [ { cron = "0 0 * * 0"; } ];
            workflow_dispatch = null;
          };
          jobs.update = {
            runs-on = "ubuntu-latest";
            steps = with config.github.actions; [
              create-github-app-token
              checkout
              setup-nix
              automata
            ];
          };
        };
      };
    };
  };

  gitignore.enable = mkDefault true;

  languages = {
    nix.enable = mkDefault true;

    python.uv = {
      enable = true;
      sync.enable = true;
    };

    shell.enable = mkDefault true;
  };

  packages = [
    pkgs.gh
    pkgs.ghstack
    pkgs.sapling
  ];

  treefmt = {
    enable = mkDefault true;
    config.programs.prettier.enable = true;
  };
}
