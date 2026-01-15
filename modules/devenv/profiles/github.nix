{ config, lib, ... }:

with lib;

{
  imports = [
    ./base.nix
  ];

  github = with config.github.lib; {
    enable = true;

    actions =
      let
        ghstackCondition = "startsWith(github.head_ref, 'gh/') && endsWith(github.head_ref, '/head')";

        mergeCondition =
          "github.event.pull_request.user.login == 'dependabot[bot]' || "
          + "github.event.pull_request.user.login == 'yorha-operator-6o[bot]'";

        githubToken = mkWorkflowRef "steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN";
      in
      {
        automata = {
          uses = "shikanime-studio/automata-action@v1";
          "with" = {
            ghstack-username = "operator6o";
            github-token = githubToken;
            gpg-passphrase = mkWorkflowRef "secrets.GPG_PASSPHRASE";
            gpg-private-key = mkWorkflowRef "secrets.GPG_PRIVATE_KEY";
            sign-commits = true;
            username = "Operator 6O <operator6o@shikanime.studio>";
          };
        };

        cleanup-pr = {
          env = {
            BASE_REF = mkWorkflowRef "github.base_ref";
            HEAD_REF = mkWorkflowRef "github.head_ref";
            REPO = mkWorkflowRef "github.repository";
          };
          "if" = "!(${ghstackCondition})";
          run = ''git push origin --delete "$HEAD_REF" || true'';
        };

        cleanup-ghstack = {
          env = {
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
          continue-on-error = true;
          id = "createGithubAppToken";
          uses = "actions/create-github-app-token@v2";
          "with" = {
            app-id = mkWorkflowRef "vars.OPERATOR_APP_ID";
            private-key = mkWorkflowRef "secrets.OPERATOR_PRIVATE_KEY";
          };
        };

        create-release = {
          env = {
            GITHUB_TOKEN = githubToken;
            REF_NAME = mkWorkflowRef "github.ref_name";
            REPO = mkWorkflowRef "github.repository";
          };
          run = ''gh release create "$REF_NAME" --repo "$REPO" --generate-notes'';
        };

        checkout = {
          uses = "actions/checkout@v6";
          "with" = {
            fetch-depth = 0;
            token = githubToken;
          };
        };

        comment-land-ghstack = {
          env = {
            GITHUB_TOKEN = githubToken;
            PR_HTML_URL = mkWorkflowRef "github.event.pull_request.html_url";
          };
          "if" = "(${mergeCondition}) && (${ghstackCondition})";
          run = ''gh pr comment "$PR_HTML_URL" --body .land | ghstack'';
        };

        comment-land-pr = {
          env = {
            GITHUB_TOKEN = githubToken;
            PR_HTML_URL = mkWorkflowRef "github.event.pull_request.html_url";
          };
          "if" = "(${mergeCondition}) && !(${ghstackCondition})";
          run = ''gh pr comment "$PR_HTML_URL" --body .land | pr'';
        };

        devenv-test.run = "nix develop --accept-flake-config --no-pure-eval --command devenv test";

        docker-login = {
          env = {
            DOCKER_REGISTRY = "ghcr.io";
            GITHUB_TOKEN = mkWorkflowRef "secrets.GITHUB_TOKEN";
            USERNAME = mkWorkflowRef "github.actor";
          };
          run = ''nix run nixpkgs#docker -- login "$DOCKER_REGISTRY" --username "$USERNAME" --password "$GITHUB_TOKEN"'';
        };

        git-push-release-unstable.run = "git push origin HEAD:refs/heads/release-unstable --force";

        nix-flake-check.run = "nix flake check --accept-flake-config --no-pure-eval";

        sapling = {
          uses = "shikanime-studio/sapling-action@v6";
          "with" = {
            github-token = githubToken;
            gpg-passphrase = mkWorkflowRef "secrets.GPG_PASSPHRASE";
            gpg-private-key = mkWorkflowRef "secrets.GPG_PRIVATE_KEY";
            sign-commits = true;
            username = "Operator 6O <operator6o@shikanime.studio>";
          };
        };

        setup-nix = {
          uses = "cachix/install-nix-action@v31";
          "with".github_access_token = githubToken;
        };

        stale = {
          uses = "actions/stale@v10";
          "with" = {
            days-before-close = 14;
            days-before-stale = 30;
            repo-token = githubToken;
            stale-issue-label = "stale";
            stale-pr-label = "stale";
          };
        };

        triage-bot = {
          env = {
            GITHUB_TOKEN = githubToken;
            PR_NUMBER = mkWorkflowRef "github.event.pull_request.number";
          };
          "if" = mergeCondition;
          run = ''gh pr edit "$PR_NUMBER" --add-label dependencies'';
        };

        triage-ghstack = {
          env = {
            GITHUB_TOKEN = githubToken;
            PR_NUMBER = mkWorkflowRef "github.event.pull_request.number";
          };
          "if" = ghstackCondition;
          run = ''gh pr edit "$PR_NUMBER" --add-label ghstack'';
        };
      };

    workflows = {
      integration = {
        enable = true;
        settings = {
          name = "Integration";
          on.pull_request.branches = [
            "main"
            "gh/*/*/base"
          ];
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
            test = {
              runs-on = "ubuntu-latest";
              steps = with config.github.actions; [
                create-github-app-token
                checkout
                setup-nix
                devenv-test
              ];
            };
          };
        };
      };

      release = {
        enable = true;
        settings = {
          name = "Release";
          on = {
            push = {
              branches = [
                "main"
                "release-[0-9]+-[0-9]+"
              ];
              tags = [ "v?[0-9]+.[0-9]+.[0-9]+*" ];
            };
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

            test = {
              runs-on = "ubuntu-latest";
              steps = with config.github.actions; [
                create-github-app-token
                checkout
                setup-nix
                devenv-test
              ];
            };

            release-unstable = {
              needs = [
                "check"
                "test"
              ];
              "if" = "github.event_name == 'push' && github.ref == 'refs/heads/main'";
              runs-on = "ubuntu-slim";
              steps = with config.github.actions; [
                create-github-app-token
                checkout
                git-push-release-unstable
              ];
            };

            release-tag = {
              needs = [
                "check"
                "test"
              ];
              "if" = "startsWith(github.ref, 'refs/tags/v')";
              runs-on = "ubuntu-slim";
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
        enable = true;
        settings = {
          name = "Cleanup";
          on.pull_request.types = [
            "closed"
          ];
          jobs.cleanup = {
            runs-on = "ubuntu-slim";
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
            runs-on = "ubuntu-slim";
            steps = with config.github.actions; [
              create-github-app-token
              checkout
              setup-nix
              sapling
            ];
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
            runs-on = "ubuntu-slim";
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
              runs-on = "ubuntu-slim";
              steps = with config.github.actions; [
                create-github-app-token
                checkout
                setup-nix
                automata
              ];
            };

            stale = {
              runs-on = "ubuntu-slim";
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

  renovate = {
    enable = true;
    settings = {
      extends = [ "config:base" ];
      lockFileMaintenance.enabled = true;
    };
  };
}
