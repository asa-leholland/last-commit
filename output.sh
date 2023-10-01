#!/bin/sh

# Specify the target branch
target_branch="main"

function quiet_fetch() {
  git fetch --quiet
}

quiet_fetch

# Get the name of the current branch
current_branch=$(git symbolic-ref --short HEAD)

# Get the count of local uncommitted insertions and deletions before stashing
pre_stash_insertions=$(git diff --shortstat 2>/dev/null | tail -n 1 | awk '{print $4}')
pre_stash_deletions=$(git diff --shortstat 2>/dev/null | tail -n 1 | awk '{print $6}')
if [ "$pre_stash_insertions" == "" ]; then
  pre_stash_insertions=0
fi
if [ "$pre_stash_deletions" == "" ]; then
  pre_stash_deletions=0
fi
printf "Uncommitted:    𝜟=%d (+%d/-%d)\n" "$((pre_stash_insertions + pre_stash_deletions))" "$pre_stash_insertions" "$pre_stash_deletions"

function quiet_stash() {
  git stash push --keep-index --quiet --message "" --include-untracked
}
quiet_stash

function quiet_checkout_target_branch() {
  if [ "$current_branch" != "$target_branch" ]; then
    git checkout "$target_branch" --quiet
    git pull --quiet
  fi
}
quiet_checkout_target_branch

# Calculate the total insertions and deletions in the commit history
committed_insertions=0
committed_deletions=0

while read -r line; do
  insertions=$(echo "$line" | awk '{print $1}')
  deletions=$(echo "$line" | awk '{print $2}')
  committed_insertions=$((committed_insertions + insertions))
  committed_deletions=$((committed_deletions + deletions))
done < <(git log --shortstat --oneline "$target_branch..$current_branch" | grep -E "([0-9]+ insertions\(\+\))|([0-9]+ deletions\(-\))")

printf "Committed:      𝜟=%d (+%d/-%d)\n" "$((committed_insertions + committed_deletions))" "$committed_insertions" "$committed_deletions"

# Get the total insertions and deletions from the last lines of `git diff --shortstat`
shortstat_output=$(git diff --shortstat 2>/dev/null)
insertions=$(echo "$shortstat_output" | tail -n 1 | awk '{print $4}')
deletions=$(echo "$shortstat_output" | tail -n 1 | awk '{print $6}')

total_insertions=$((committed_insertions + pre_stash_insertions))
total_deletions=$((committed_deletions + pre_stash_deletions))

# Print the result in the desired format
if ((total_insertions + total_deletions > 0)); then
  printf "All Changes:    𝜟=%d (+%d/-%d)\n" "$((total_insertions + total_deletions))" "$total_insertions" "$total_deletions"
else
  printf "All Changes:    𝜟=0 (+0/-0)\n"
fi

# Return to the original branch and unstash changes
git checkout "$current_branch" --quiet
git stash pop --quiet
