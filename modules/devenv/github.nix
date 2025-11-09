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

  # Generate workflow files for each configured workflow
  workflowFiles = mapAttrs (
    name: workflowCfg: settingsFormat.generate "${name}.yaml" workflowCfg.settings
  ) cfg.workflows;

  # Create shell commands to copy all workflow files
  workflowCommands = mapAttrsToList (
    name: file: "cat ${file} > ${config.env.DEVENV_ROOT}/.github/workflows/${name}.yaml"
  ) workflowFiles;
in
{
  options.github = {
    enable = mkEnableOption "generation of GitHub Actions workflow files";

    package = mkOption {
      type = types.package;
      default = pkgs.gh;
      description = "Package to use for GitHub Actions";
    };

    workflows = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            settings = mkOption {
              type = types.submodule {
                freeformType = settingsFormat.type;
              };

              description = ''
                GitHub workflow settings.
              '';
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
                    {
                      uses = "DeterminateSystems/nix-installer-action@v19";
                      "with".github-token = "$\{{ secrets.NIX_GITHUB_TOKEN }}";
                    }
                    { uses = "DeterminateSystems/magic-nix-cache-action@v13"; }
                    {
                      name = "Check Nix Flake";
                      run = "nix flake check --all-systems --no-pure-eval --accept-flake-config";
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

    enterShell = ''
      mkdir -p ${config.env.DEVENV_ROOT}/.github/workflows
      ${concatStringsSep "\n" workflowCommands}
    '';

    git-hooks.hooks.actionlint.enable = true;
  };
}
