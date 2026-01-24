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
        update = {
          uses = "shikanime-studio/actions/update@v7";
          "with" = {
            email = "operator6o@shikanime.studio";
            fullname = "Operator 6O";
            github-token = githubToken;
            gpg-passphrase = mkWorkflowRef "secrets.GPG_PASSPHRASE";
            gpg-private-key = mkWorkflowRef "secrets.GPG_PRIVATE_KEY";
            sign-commits = true;
            username = "operator6o";
          };
        };

        cachix-push = {
          continue-on-error = true;
          uses = "cachix/cachix-action@v16";
          "with".authToken = mkWorkflowRef "secrets.CACHIX_AUTH_TOKEN";
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
            REF_NAME = mkWorkflowRef "github.ref_name || github.event.inputs.ref_name";
            REPO = mkWorkflowRef "github.repository";
          };
          run = ''gh release create "$REF_NAME" --repo "$REPO" --generate-notes || true'';
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

        git-push-release = {
          env.REF_NAME = mkWorkflowRef "github.ref_name || github.event.inputs.ref_name";
          run = "VERSION=\"\${REF_NAME#v}\"; BASE=\"\${VERSION%.*}\"; BRANCH=\"release-$BASE\"; git push origin \"HEAD:refs/heads/$BRANCH\"";
        };

        nix-flake-check.run = "nix flake check --accept-flake-config --no-pure-eval";

        backport = {
          uses = "shikanime-studio/actions/backport@v7";
          "with" = {
            github-token = githubToken;
            gpg-passphrase = mkWorkflowRef "secrets.GPG_PASSPHRASE";
            gpg-private-key = mkWorkflowRef "secrets.GPG_PRIVATE_KEY";
            sign-commits = true;
          };
        };

        close = {
          uses = "shikanime-studio/actions/close@v7";
          "with" = {
            github-token = githubToken;
            username = "operator6o";
          };
        };

        land = {
          uses = "shikanime-studio/actions/land@v7";
          "with" = {
            github-token = githubToken;
            email = "operator6o@shikanime.studio";
            fullname = "Operator 6O";
            username = "operator6o";
            gpg-passphrase = mkWorkflowRef "secrets.GPG_PASSPHRASE";
            gpg-private-key = mkWorkflowRef "secrets.GPG_PRIVATE_KEY";
            sign-commits = true;
          };
        };

        rebase = {
          uses = "shikanime-studio/actions/rebase@v7";
          "with" = {
            github-token = githubToken;
            email = "operator6o@shikanime.studio";
            fullname = "Operator 6O";
            username = "operator6o";
            gpg-passphrase = mkWorkflowRef "secrets.GPG_PASSPHRASE";
            gpg-private-key = mkWorkflowRef "secrets.GPG_PRIVATE_KEY";
            sign-commits = true;
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
      cleanup = {
        enable = true;
        settings = {
          jobs.cleanup = {
            runs-on = "ubuntu-slim";
            steps =
              with config.github.actions;
              let
                create-github-app-token-with-permissions = create-github-app-token // {
                  "with" = create-github-app-token."with" // {
                    permission-contents = "write";
                  };
                };
              in
              [
                create-github-app-token-with-permissions
                checkout
                cleanup-pr
                cleanup-ghstack
              ];
          };
          name = "Cleanup";
          on.pull_request.types = [
            "closed"
          ];
          permissions.contents = "write";
        };
      };

      commands = {
        enable = true;
        settings = {
          jobs = {
            backport = {
              "if" =
                "github.event.issue.pull_request != null && contains(github.event.comment.body, '.backport')";
              runs-on = "ubuntu-slim";
              steps =
                with config.github.actions;
                let
                  create-github-app-token-with-permissions = create-github-app-token // {
                    "with" = create-github-app-token."with" // {
                      permission-contents = "write";
                      permission-issues = "write";
                      permission-pull-requests = "write";
                    };
                  };
                in
                [
                  create-github-app-token-with-permissions
                  checkout
                  setup-nix
                  backport
                ];
            };

            close = {
              "if" = "github.event.issue.pull_request != null && contains(github.event.comment.body, '.close')";
              runs-on = "ubuntu-slim";
              steps =
                with config.github.actions;
                let
                  create-github-app-token-with-permissions = create-github-app-token // {
                    "with" = create-github-app-token."with" // {
                      permission-contents = "write";
                      permission-issues = "write";
                      permission-pull-requests = "write";
                    };
                  };
                in
                [
                  create-github-app-token-with-permissions
                  checkout
                  setup-nix
                  close
                ];
            };

            land = {
              "if" = "github.event.issue.pull_request != null && contains(github.event.comment.body, '.land')";
              runs-on = "ubuntu-slim";
              steps =
                with config.github.actions;
                let
                  create-github-app-token-with-permissions = create-github-app-token // {
                    "with" = create-github-app-token."with" // {
                      permission-contents = "write";
                      permission-issues = "write";
                      permission-pull-requests = "write";
                    };
                  };
                in
                [
                  create-github-app-token-with-permissions
                  checkout
                  setup-nix
                  land
                ];
            };

            rebase = {
              "if" = "github.event.issue.pull_request != null && contains(github.event.comment.body, '.rebase')";
              runs-on = "ubuntu-slim";
              steps =
                with config.github.actions;
                let
                  create-github-app-token-with-permissions = create-github-app-token // {
                    "with" = create-github-app-token."with" // {
                      permission-contents = "write";
                      permission-issues = "write";
                      permission-pull-requests = "write";
                    };
                  };
                in
                [
                  create-github-app-token-with-permissions
                  checkout
                  setup-nix
                  rebase
                ];
            };
          };
          name = "Commands";
          on.issue_comment.types = [ "created" ];
          permissions = {
            contents = "write";
            issues = "write";
            pull-requests = "write";
          };
        };
      };

      integration = {
        enable = true;
        settings = {
          jobs = {
            check = {
              runs-on = "ubuntu-latest";
              steps =
                with config.github.actions;
                let
                  create-github-app-token-with-permissions = create-github-app-token // {
                    "with" = create-github-app-token."with" // {
                      permission-contents = "read";
                    };
                  };
                in
                [
                  create-github-app-token-with-permissions
                  checkout
                  setup-nix
                  nix-flake-check
                ];
            };
            test = {
              runs-on = "ubuntu-latest";
              steps =
                with config.github.actions;
                let
                  create-github-app-token-with-permissions = create-github-app-token // {
                    "with" = create-github-app-token."with" // {
                      permission-contents = "read";
                    };
                  };
                in
                [
                  create-github-app-token-with-permissions
                  checkout
                  setup-nix
                  devenv-test
                ];
            };
          };
          name = "Integration";
          on.pull_request.branches = [
            "main"
            "gh/*/*/base"
          ];
          permissions.contents = "read";
        };
      };

      release = {
        enable = true;
        settings = {
          jobs = {
            check = {
              runs-on = "ubuntu-latest";
              steps =
                with config.github.actions;
                let
                  create-github-app-token-with-permissions = create-github-app-token // {
                    "with" = create-github-app-token."with" // {
                      permission-contents = "write";
                    };
                  };
                in
                [
                  create-github-app-token-with-permissions
                  checkout
                  setup-nix
                  cachix-push
                  nix-flake-check
                ];
            };

            test = {
              runs-on = "ubuntu-latest";
              steps =
                with config.github.actions;
                let
                  create-github-app-token-with-permissions = create-github-app-token // {
                    "with" = create-github-app-token."with" // {
                      permission-contents = "write";
                    };
                  };
                in
                [
                  create-github-app-token-with-permissions
                  checkout
                  setup-nix
                  cachix-push
                  devenv-test
                ];
            };

            release-tag = {
              needs = [
                "check"
                "test"
              ];
              "if" =
                let
                  push_event = "startsWith(github.ref, 'refs/tags/v')";
                  workflow_dispatch = "github.event_name == 'workflow_dispatch' && startsWith(github.event.inputs.ref_name, 'v')";
                in
                "(${push_event}) || (${workflow_dispatch})";
              runs-on = "ubuntu-slim";
              steps =
                with config.github.actions;
                let
                  create-github-app-token-with-permissions = create-github-app-token // {
                    "with" = create-github-app-token."with" // {
                      permission-contents = "write";
                    };
                  };
                in
                [
                  create-github-app-token-with-permissions
                  checkout
                  create-release
                ];
            };

            release-branch = {
              needs = [
                "check"
                "test"
              ];
              "if" =
                let
                  push_event = "startsWith(github.ref, 'refs/tags/v') && endsWith(github.ref_name, '.0')";
                  workflow_dispatch =
                    "github.event_name == 'workflow_dispatch' && "
                    + "startsWith(github.event.inputs.ref_name, 'v') && "
                    + "endsWith(github.event.inputs.ref_name, '.0')";
                in
                "(${push_event}) || (${workflow_dispatch})";
              runs-on = "ubuntu-slim";
              steps =
                with config.github.actions;
                let
                  create-github-app-token-with-permissions = create-github-app-token // {
                    "with" = create-github-app-token."with" // {
                      permission-contents = "write";
                    };
                  };
                in
                [
                  create-github-app-token-with-permissions
                  checkout
                  git-push-release
                ];
            };
          };
          name = "Release";
          on = {
            push = {
              branches = [
                "main"
                "release-[0-9]+.[0-9]+"
              ];
              tags = [ "v?[0-9]+.[0-9]+.[0-9]+*" ];
            };
            workflow_dispatch = {
              inputs.ref_name = {
                description = "Tag or branch to release";
                required = true;
              };
            };
          };
          permissions.contents = "write";
        };
      };

      triage = {
        enable = true;
        settings = {
          jobs.triage = {
            runs-on = "ubuntu-slim";
            steps =
              with config.github.actions;
              let
                create-github-app-token-with-permissions = create-github-app-token // {
                  "with" = create-github-app-token."with" // {
                    permission-contents = "read";
                    permission-issues = "write";
                    permission-pull-requests = "write";
                  };
                };
              in
              [
                create-github-app-token-with-permissions
                checkout
                triage-bot
                triage-ghstack
              ];
          };
          name = "Triage";
          on.pull_request.branches = [
            "main"
            "gh/*/*/base"
          ];
          on.pull_request.types = [
            "opened"
            "reopened"
          ];
          permissions = {
            contents = "read";
            pull-requests = "write";
          };
        };
      };

      update = {
        enable = true;
        settings = {
          jobs = {
            dependencies = {
              runs-on = "ubuntu-slim";
              steps =
                with config.github.actions;
                let
                  create-github-app-token-with-permissions = create-github-app-token // {
                    "with" = create-github-app-token."with" // {
                      permission-contents = "write";
                      permission-issues = "write";
                      permission-pull-requests = "write";
                    };
                  };
                in
                [
                  create-github-app-token-with-permissions
                  checkout
                  setup-nix
                  update
                ];
            };

            stale = {
              runs-on = "ubuntu-slim";
              steps =
                with config.github.actions;
                let
                  create-github-app-token-with-permissions = create-github-app-token // {
                    "with" = create-github-app-token."with" // {
                      permission-contents = "write";
                      permission-issues = "write";
                      permission-pull-requests = "write";
                    };
                  };
                in
                [
                  create-github-app-token-with-permissions
                  stale
                ];
            };
          };
          name = "Update";
          on = {
            schedule = [ { cron = "0 4 * * 0"; } ];
            workflow_dispatch = null;
          };
          permissions = {
            contents = "write";
            issues = "write";
            pull-requests = "write";
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
