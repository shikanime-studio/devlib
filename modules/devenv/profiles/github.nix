{ config, lib, ... }:

with lib;

{
  imports = [
    ./base.nix
  ];

  github = {
    enable = true;

    actions =
      with config.github.lib;
      let
        ghstackCondition = concatStringsSep " && " [
          "startsWith(github.head_ref, 'gh/')"
          "endsWith(github.head_ref, '/head')"
        ];

        mergeCondition = concatStringsSep " || " [
          "github.event.pull_request.user.login == 'dependabot[bot]'"
          "github.event.pull_request.user.login == 'yorha-operator-6o[bot]'"
        ];
      in
      {
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

        cleanup-pr = {
          env = {
            GITHUB_TOKEN = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
            BASE_REF = mkWorkflowRef "github.base_ref";
            HEAD_REF = mkWorkflowRef "github.head_ref";
            REPO = mkWorkflowRef "github.repository";
          };
          "if" = "!(${ghstackCondition})";
          run = mkWorkflowRun [
            "git"
            "push"
            "origin"
            "--delete"
            ''"$HEAD_REF"''
            "||"
            "true"
          ];
        };

        cleanup-ghstack = {
          env = {
            GITHUB_TOKEN = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
            BASE_REF = mkWorkflowRef "github.base_ref";
            HEAD_REF = mkWorkflowRef "github.head_ref";
            REPO = mkWorkflowRef "github.repository";
          };
          "if" = ghstackCondition;
          run = ''
            for role in base head orig; do
              git push origin --delete "''${HEAD_REF%/head}/$role" || true
            done
          '';
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

        comment-land-ghstack = {
          env = {
            GITHUB_TOKEN = mkWorkflowRef "secrets.GITHUB_TOKEN";
            PR_HTML_URL = mkWorkflowRef "github.event.pull_request.html_url";
          };
          "if" = concatStringsSep " && " [
            "(${mergeCondition})"
            "(${ghstackCondition})"
          ];
          run = mkWorkflowRun [
            "gh"
            "pr"
            "comment"
            ''"$PR_HTML_URL"''
            "--body"
            ".land"
            "|"
            "ghstack"
          ];
        };

        comment-land-pr = {
          env = {
            GITHUB_TOKEN = mkWorkflowRef "secrets.GITHUB_TOKEN";
            PR_HTML_URL = mkWorkflowRef "github.event.pull_request.html_url";
          };
          "if" = concatStringsSep " && " [
            "(${mergeCondition})"
            "!(${ghstackCondition})"
          ];
          run = mkWorkflowRun [
            "gh"
            "pr"
            "comment"
            ''"$PR_HTML_URL"''
            "--body"
            ".land"
            "|"
            "pr"
          ];
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

        nix-flake-check.run = mkWorkflowRun [
          "nix"
          "flake"
          "check"
          "--accept-flake-config"
          "--all-systems"
          "--no-pure-eval"
        ];

        sapling = {
          uses = "shikanime-studio/sapling-action@v6";
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

        triage-bot = {
          env = {
            GITHUB_TOKEN = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
            PR_NUMBER = mkWorkflowRef "github.event.pull_request.number";
          };
          "if" = mergeCondition;
          run = mkWorkflowRun [
            "gh"
            "pr"
            "edit"
            ''"$PR_NUMBER"''
            "--add-label"
            "dependencies"
          ];
        };

        triage-ghstack = {
          env = {
            GITHUB_TOKEN = mkWorkflowRef "steps.createGithubAppToken.outputs.token";
            PR_NUMBER = mkWorkflowRef "github.event.pull_request.number";
          };
          "if" = ghstackCondition;
          run = mkWorkflowRun [
            "gh"
            "pr"
            "edit"
            ''"$PR_NUMBER"''
            "--add-label"
            "ghstack"
          ];
        };
      };

    workflows = with config.github.lib; {
      check = {
        enable = true;
        settings = {
          name = "Check";
          on = {
            pull_request.branches = [
              "main"
              "gh/*/*/base"
            ];
            push.branches = [
              "main"
              "release-*"
            ];
          };
          jobs = {
            check = {
              runs-on = "ubuntu-latest";
              steps = with config.github.actions; [
                create-github-app-token
                checkout
                setup-nix
                nix-flake-check
              ];
            };
          };
        };
      };

      cleanup = {
        enable = true;
        settings = {
          name = "Cleanup";
          on.pull_request.types = [
            "closed"
          ];
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

      land = {
        enable = true;
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
        enable = true;
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
        enable = true;
        settings = {
          name = "Triage";
          on.pull_request.branches = [
            "main"
            "gh/*/*/base"
          ];
          on.pull_request.types = [
            "opened"
            "reopened"
          ];
          jobs.triage = {
            runs-on = "ubuntu-latest";
            steps = with config.github.actions; [
              create-github-app-token
              checkout
              triage-bot
              triage-ghstack
            ];
          };
        };
      };

      update = {
        enable = true;
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
}
