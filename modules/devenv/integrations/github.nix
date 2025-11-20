{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.github;
  settingsFormat = pkgs.formats.yaml { };
in
{
  options.github = {
    enable = mkEnableOption "generation of GitHub Actions workflow files";

    lib = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
    };

    package = mkOption {
      type = types.package;
      default = pkgs.gh;
      description = "Package to use for GitHub Actions";
    };

    actions = mkOption {
      type = types.attrsOf (
        types.submodule {
          freeformType = settingsFormat.type;
        }
      );

      default = { };

      description = ''
        GitHub Actions configuration. Each attribute name becomes the action identifier.
      '';

      example = literalExpression ''
        {
          setup-nix = {
            uses = "shikanime-studio/setup-nix-action@v1";
            with.github-token = mkWorkflowRef "secrets.GITHUB_TOKEN";
          };
        }
      '';
    };

    workflows = mkOption {
      type = types.attrsOf (
        types.submodule {
          freeformType = settingsFormat.type;
        }
      );

      default = { };

      description = ''
        GitHub workflows configuration. Each attribute name becomes the workflow filename.
      '';

      example = literalExpression ''
        {
          check = {
            settings = {
              name = "Check";
              on = {
                push.branches = [ "main" ];
                pull_request.branches = [ "main" ];
              };
              jobs = {
                check = {
                  runs-on = "ubuntu-latest";
                  steps = [
                    { uses = "actions/checkout@v5"; }
                    { uses = "shikanime-studio/setup-nix-action@v1"; }
                    {
                      name = "Check Nix Flake";
                      run = "nix flake check --accept-flake-config --all-systems --no-pure-eval";
                    }
                  ];
                };
              };
            };
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    git-hooks.hooks.actionlint.enable = true;

    github.lib = {
      mkWorkflowRef = name: "\${{ ${name} }}";
      mkWorkflowRun = args: concatStringsSep " " args;
    };

    tasks = {
      "devlib:github:workflows:generate" = {
        description = "Generate GitHub Actions workflow files";
        before = [ "devenv:enterShell" ];
        exec = concatStringsSep "\n" (
          mapAttrsToList (
            name: workflow:
            let
              file = settingsFormat.generate "${name}.yaml" workflow;
            in
            ''
              mkdir -p "${config.env.DEVENV_ROOT}/.github/workflows"
              cat ${file} > "${config.env.DEVENV_ROOT}/.github/workflows/${name}.yaml"
            ''
          ) cfg.workflows
        );
      };
      "devenv:treefmt:run".after = [ "devlib:github:workflows:generate" ];
    };

    treefmt.config.programs.prettier.enable = true;
  };
}
