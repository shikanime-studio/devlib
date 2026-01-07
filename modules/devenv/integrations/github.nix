{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.github;

  yamlFormat = pkgs.formats.yaml { };
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
          freeformType = yamlFormat.type;
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
          options = {
            enable = mkEnableOption "enable this workflow";

            settings = mkOption {
              type = types.submodule {
                freeformType = yamlFormat.type;
              };
              default = { };
              description = "Workflow YAML settings";
            };
          };
        }
      );

      default = { };

      description = ''
        GitHub workflows configuration. Each attribute name becomes the workflow filename.
      '';

      example = literalExpression ''
        {
          check = {
            enable = mkDefault true;
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
    github.lib = {
      mkWorkflowRef = name: "\${{ ${name} }}";
      mkWorkflowRun = args: concatStringsSep " " args;
    };

    packages = [ cfg.package ];

    tasks = {
      "devenv:treefmt:run".after = [ "devlib:github:workflows:install" ];

      "devlib:github:workflows:install" = {
        before = [ "devenv:enterShell" ];
        description = "Install GitHub Actions workflow files";
        exec =
          let
            enabled = filterAttrs (_: w: w.enable) cfg.workflows;
          in
          concatStringsSep "\n" (
            mapAttrsToList (
              name: workflow:
              let
                file = yamlFormat.generate "${name}.yaml" workflow.settings;
              in
              ''
                mkdir -p "${config.env.DEVENV_ROOT}/.github/workflows"
                cat ${file} > "${config.env.DEVENV_ROOT}/.github/workflows/${name}.yaml"
              ''
            ) enabled
          );
      };
    };

    treefmt.config.programs.actionlint.enable = mkDefault true;
  };
}
