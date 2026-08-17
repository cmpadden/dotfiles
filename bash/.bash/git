# Git and GitHub workflow helpers.

git_llm_commmit() {
    git diff --cached -U1 --minimal -B --compact-summary --find-copies-harder -w |
        head -n 1000 |
        llm '<summarize these changes as a concise git commit message, do not mention counts of insertions or deletions>' |
        git commit -F -
}

gh-pr-to-buildkite() {
    local id="$1"
    local pipeline="${2:-dagster/dagster-dagster}"
    gh pr checkout "$id"

    local branch_existing
    branch_existing=$(git branch --show-current)
    echo "-> Previous branch: ${branch_existing}"

    local branch_new="colton/$(git branch --show-current)"
    echo "-> Renaming branch: ${branch_new}"
    git branch -M "$branch_new"

    echo '-> Pushing branch to remote origin'
    git push origin "$branch_new"

    local commit
    commit="$(git rev-parse HEAD)"
    echo "-> Using commit sha \`${commit}\`"

    echo "-> Launching buildkite pipeline \`${pipeline}\`"
    bk build create \
        --yes \
        --pipeline "$pipeline" \
        --branch "$branch_new" \
        --commit "$commit" \
        --message "Validating existing PR \`${id}\` from branch \`${branch_existing}\`" \
        --ignore-branch-filters
}

# Check out a GitHub pull request and open its diff in Neovim.
gh-pr-diff() {
    local id="$1"
    local target="${2:-origin/master}"
    git fetch origin
    gh pr checkout "$id"
    nvim -c ":DiffviewOpen ${target}...HEAD"
}
