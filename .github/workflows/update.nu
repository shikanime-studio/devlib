#!/usr/bin/env nix
#! nix develop --impure --command nu

def get_latest_action []: string -> string {
    let tags = gh api $"repos/($in)/tags" | from json | get name
    let semver = $tags | where ($it =~ '^v[0-9]+$')
    if ($semver | is-empty) {
        $in
    } else {
        $semver | first
    }
}

def parse_action []: nothing -> record {
    let parts = ($in | split row "@")
    if ($parts | length) > 1 {
        { repo: ($parts | first), version: ($parts | last) }
    } else {
        { repo: ($parts | first), version: "" }
    }
}

def update_workflow_job_step_actions []: record -> record {
    if "uses" in $in {
        let action = $in.uses | parse_action
        let next_version = $action.repo | get_latest_action
        let next_uses = if ($next_version | is-empty) {
            $"($action.repo)@($action.version)"
        } else {
            $"($action.repo)@($next_version)"
        }
        $in | update uses $next_uses
    } else {
        $in
    }
}

def update_workflow_job_actions []: record -> record {
    $in | update steps {
        par-each { |step|
            $step | update_workflow_job_step_actions
        }
    }
}


def update_workflow_actions []: record -> record {
    $in
    | update jobs {
        items { |$name, job|
            { $name: ($job | update_workflow_job_actions) }
        }
        | into record
    }
}

def parse_image []: string -> string {
    $in | split row "/" | last | split row ":" | get 0
}

def get_skaffold_images []: nothing -> list<string> {
    open $"($env.FILE_PWD)/../../skaffold.yaml"
    | get build.artifacts
    | each { |artifact| $artifact.image | parse_image }
}

def update_workflow_packages []: record -> record {
    let images = get_skaffold_images
    print $"Images: ($images | str join ', ')"
    $in | upsert jobs.packages.strategy.matrix.image $images
}

def update_workflow [name: string]: record -> record {
    if $name == "packages.yaml" {
        $in | update_workflow_packages | update_workflow_actions
    } else {
        $in | update_workflow_actions
    }
}

print "Updating GitHub Actions workflows..."
glob $"($env.FILE_PWD)/*.{yml,yaml}"
    | par-each { |workflow|
        open $workflow
        | update_workflow ($workflow | path basename)
        | save --force $workflow
    }
    | ignore
