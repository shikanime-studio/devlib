#!/usr/bin/env nix
#! nix develop --impure --command nu

def get_flake_packages []: nothing -> list {
    nix flake show --impure --json --all-systems
    | from json
    | get packages
    | transpose system packages
    | each { |item|
        $item.packages | transpose name info | get name
    }
    | flatten
    | where $it not-in ["devenv-test", "devenv-up"]
    | uniq
    | sort
}

def update_skaffold_artifacts []: record -> record {
    print "[skaffold] Updating skaffold.yaml with nix flake packages..."
    let packages = get_flake_packages
    print $"[skaffold] Found packages: ($packages | str join ', ')"
    $in | upsert build.artifacts (
        $packages | each { |pkg|
            {
                image: $"ghcr.io/shikanime/niximgs/($pkg)",
                custom: {
                    buildCommand: "./build.nu"
                }
            }
        }
    )
}

# Update workflows
print "[workflows] Updating GitHub Actions workflows..."
nu $"($env.FILE_PWD)/.github/workflows/update.nu"
    | lines
    | each { |line|
        print $"[workflows] ($line)"
    }
    | ignore
