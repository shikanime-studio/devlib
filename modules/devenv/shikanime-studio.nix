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
  };

  github = {
    enable = mkDefault true;

    actions = with config.github.lib; {
      bot-triage = {
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
          ''"$PR_NUMBER"''
          "--add-label"
          "dependencies"
          "--assignee"
          "@yorha-operator-6o"
        ];
      };

      cleanup-pr = {
        env = {
          GITHUB_TOKEN = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
          BASE_REF = mkWorkflowRef "github.base_ref";
          HEAD_REF = mkWorkflowRef "github.head_ref";
          REPO = mkWorkflowRef "github.repository";
        };
        "if" = "!contains(github.event.pull_request.labels.*.name, 'ghstack')";
        run = mkWorkflowRun [
          "git"
          "push"
          "origin"
          "--delete"
          ''"$HEAD_REF"''
        ];
      };

      cleanup-ghstack = {
        env = {
          GITHUB_TOKEN = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
          BASE_REF = mkWorkflowRef "github.base_ref";
          HEAD_REF = mkWorkflowRef "github.head_ref";
          REPO = mkWorkflowRef "github.repository";
        };
        "if" = "contains(github.event.pull_request.labels.*.name, 'ghstack')";
        run = ''
          for role in base head orig; do
            git push origin --delete "''${HEAD_REF%/head}/$role" || true
          done
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
          ''"$REF_NAME"''
          "--repo"
          ''"$REPO"''
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
        env = {
          DOCKER_REGISTRY = "ghcr.io";
          GITHUB_TOKEN = mkWorkflowRef "secrets.GITHUB_TOKEN";
          USERNAME = mkWorkflowRef "github.actor";
        };
        run = mkWorkflowRun [
          "nix"
          "run"
          "nixpkgs#docker"
          "--"
          "login"
          ''"$DOCKER_REGISTRY"''
          "--username"
          ''"$USERNAME"''
          "--password"
          ''"$GITHUB_TOKEN"''
        ];
      };

      ghstack-merge = {
        env = {
          GITHUB_TOKEN = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
          PR_HTML_URL = mkWorkflowRef "github.event.issue.pull_request.html_url";
        };
        "if" = "contains(github.event.issue.labels.*.name, 'ghstack')";
        run = mkWorkflowRun [
          "nix"
          "run"
          "nixpkgs#sapling"
          "--"
          "ghstack"
          "land"
          ''"$PR_HTML_URL"''
        ];
      };

      ghstack-triage = {
        env = {
          GITHUB_TOKEN = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
          PR_NUMBER = mkWorkflowRef "github.event.pull_request.number";
        };
        "if" = concatStringsSep " && " [
          "startsWith(github.head_ref, 'gh/')"
          "endsWith(github.head_ref, '/head')"
        ];
        run = mkWorkflowRun [
          "gh"
          "pr"
          "edit"
          ''"$PR_NUMBER"''
          "--add-label"
          "ghstack"
        ];
      };

      pr-merge = {
        env = {
          GITHUB_TOKEN = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
          PR_HTML_URL = mkWorkflowRef "github.event.issue.pull_request.html_url";
        };
        "if" = "!contains(github.event.issue.labels.*.name, 'ghstack')";
        run = mkWorkflowRun [
          "gh"
          "pr"
          "merge"
          "--auto"
          ''"$PR_HTML_URL"''
        ];
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

      push = {
        enable = mkDefault true;
        settings = {
          name = "Push";
          on = {
            push.branches = [
              "main"
              "release-*"
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

      integration = {
        enable = mkDefault true;
        settings = {
          name = "Integration";
          on.pull_request.branches = [
            "main"
            "gh/*/*/base"
          ];
          jobs = {
            triage = {
              runs-on = "ubuntu-latest";
              steps = with config.github.actions; [
                create-github-app-token
                checkout
                bot-triage
                ghstack-triage
              ];
            };
            check = {
              needs = [ "triage" ];
              runs-on = "ubuntu-latest";
              steps = with config.github.actions; [
                create-github-app-token
                checkout
                setup-nix
                direnv
                nix-flake-check
              ];
            };
            merge = {
              "if" = "contains(github.event.pull_request.labels.*.name, 'auto')";
              needs = [ "check" ];
              runs-on = "ubuntu-latest";
              steps = with config.github.actions; [
                create-github-app-token
                checkout
                setup-nix
                ghstack-merge
                pr-merge
              ];
            };
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

      cleanup = {
        enable = mkDefault true;
        settings = {
          name = "Cleanup";
          on = {
            pull_request.types = [
              "closed"
            ];
            check_suite.types = [ "completed" ];
          };
          jobs.cleanup = {
            runs-on = "ubuntu-latest";
            steps = with config.github.actions; [
              create-github-app-token
              checkout
              cleanup-pr
              cleanup-ghstack
            ];
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
                direnv
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
