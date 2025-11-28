{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  automata.enable = mkDefault true;

  cachix = {
    enable = mkDefault true;
    push = "shikanime-studio";
  };

  containers = pkgs.lib.mkForce { };

  docker.enable = mkDefault true;

  golangci-lint.settings = {
    version = 2;
    linters = {
      enable = [
        "bodyclose"
        "dogsled"
        "dupl"
        "durationcheck"
        "exhaustive"
        "gocritic"
        "godot"
        "gomoddirectives"
        "goprintffuncname"
        "govet"
        "importas"
        "ineffassign"
        "makezero"
        "misspell"
        "nakedret"
        "nilerr"
        "noctx"
        "nolintlint"
        "prealloc"
        "predeclared"
        "revive"
        "rowserrcheck"
        "sqlclosecheck"
        "staticcheck"
        "tparallel"
        "unconvert"
        "unparam"
        "unused"
        "wastedassign"
        "whitespace"
      ];
      settings = {
        misspell.locale = "US";
        gocritic = {
          enabled-tags = [
            "diagnostic"
            "experimental"
            "opinionated"
            "style"
          ];
          disabled-checks = [
            "importShadow"
            "unnamedResult"
          ];
        };
      };
    };
    formatters = {
      enable = [
        "gci"
        "gofmt"
        "gofumpt"
        "goimports"
      ];
      settings.gci.sections = [
        "standard"
        "default"
        "localmodule"
      ];
    };
  };

  github = {
    enable = mkDefault true;

    actions = with config.github.lib; {
      add-dependencies-labels = {
        env = {
          GITHUB_TOKEN = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
          PR_NUMBER = mkWorkflowRef "github.event.pull_request.number";
        };
        "if" = concatStringsSep " || " [
          "github.event.pull_request.user.login == 'yorha-operator-6o[bot]'"
          "github.event.pull_request.user.login == 'dependabot[bot]'"
        ];
        run = mkWorkflowRun [
          "gh"
          "pr"
          "edit"
          "$PR_NUMBER"
          "--add-label"
          "dependencies"
        ];
      };

      cleanup = {
        env = {
          GITHUB_TOKEN = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
          PR_BASE_REF = mkWorkflowRef "github.event.pull_request.base.ref";
          PR_HEAD_REF = mkWorkflowRef "github.event.pull_request.head.ref";
          REPO = mkWorkflowRef "github.repository";
        };
        run = ''
          if [[ "$PR_HEAD_REF" =~ ^gh/[^/]+/[^/]+/head$ && "$PR_BASE_REF" =~ ^gh/[^/]+/[^/]+/base$ && "''${PR_HEAD_REF%/head}" == "''${PR_BASE_REF%/base}" ]]; then
            for role in base head orig; do
              git push origin --delete "''${PR_HEAD_REF%/head}/$role" || true
            done
          else
            git push origin --delete "$PR_HEAD_REF" || true
          fi
        '';
      };

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

      create-release = {
        env = {
          GITHUB_TOKEN = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
          REF_NAME = mkWorkflowRef "github.ref_name";
          REPO = mkWorkflowRef "github.repository";
        };
        run = mkWorkflowRun [
          "gh"
          "release"
          "create"
          "$REF_NAME"
          "--repo"
          "$REPO"
          "--generate-notes"
        ];
      };

      checkout = {
        uses = "actions/checkout@v6";
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

      stale = {
        uses = "actions/stale@v10";
        "with" = {
          days-before-close = 14;
          days-before-stale = 30;
          repo-token = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
          stale-issue-label = "stale";
          stale-pr-label = "stale";
        };
      };
    };

    workflows = with config.github.lib; {
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
              steps = with config.github.actions; [
                create-github-app-token
                checkout
                create-release
              ];
            };
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
              "closed"
            ];
            check_suite.types = [ "completed" ];
          };
          jobs = {
            labels = {
              "if" = "github.event.action == 'opened'";
              runs-on = "ubuntu-latest";
              steps = with config.github.actions; [
                create-github-app-token
                checkout
                add-dependencies-labels
              ];
            };

            cleanup = {
              "if" = "github.event.action == 'closed'";
              runs-on = "ubuntu-latest";
              steps = with config.github.actions; [
                create-github-app-token
                checkout
                cleanup
              ];
            };
          };
        };
      };

      update = {
        enable = mkDefault true;
        settings = {
          name = "Update";
          on = {
            schedule = [ { cron = "0 4 * * 0"; } ];
            workflow_dispatch = null;
          };
          jobs = {
            dependencies = {
              runs-on = "ubuntu-latest";
              steps = with config.github.actions; [
                create-github-app-token
                checkout
                setup-nix
                automata
              ];
            };

            stale = {
              runs-on = "ubuntu-latest";
              steps = with config.github.actions; [
                create-github-app-token
                stale
              ];
            };
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
