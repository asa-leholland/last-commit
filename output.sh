#!/bin/sh

# Specify the target branch
target_branch="main"

# Get the name of the current branch
current_branch=$(git symbolic-ref --short HEAD)

# Get the count of local uncommitted insertions and deletions before stashing
pre_stash_insertions=$(git diff --shortstat 2>/dev/null | tail -n 1 | awk '{print $4}')
pre_stash_deletions=$(git diff --shortstat 2>/dev/null | tail -n 1 | awk '{print $6}')

# Stash uncommitted changes
git stash

# Compare the current branch against the specified target branch
if [ "$current_branch" != "$target_branch" ]; then
  git checkout "$target_branch"  # Switch to the specified target branch
fi

# Calculate the total insertions and deletions in the commit history
total_insertions=0
total_deletions=0

while read -r line; do
  insertions=$(echo "$line" | awk '{print $1}')
  deletions=$(echo "$line" | awk '{print $2}')
  total_insertions=$((total_insertions + insertions))
  total_deletions=$((total_deletions + deletions))
done < <(git log --shortstat --oneline "$target_branch..$current_branch" | grep -E "([0-9]+ insertions\(\+\))|([0-9]+ deletions\(-\))")

# Get the total insertions and deletions from the last lines of `git diff --shortstat`
shortstat_output=$(git diff --shortstat 2>/dev/null)
insertions=$(echo "$shortstat_output" | tail -n 1 | awk '{print $4}')
deletions=$(echo "$shortstat_output" | tail -n 1 | awk '{print $6}')

# Add the uncommitted changes (both before and after stashing) to the total
total_insertions=$((total_insertions + pre_stash_insertions + insertions))
total_deletions=$((total_deletions + pre_stash_deletions + deletions))

# Print the result in the desired format
if ((total_insertions + total_deletions > 0)); then
  printf "𝜟=%d (+%d/-%d)\n" "$((total_insertions + total_deletions))" "$total_insertions" "$total_deletions"
else
  printf "𝜟=0 (+0/-0)\n"
fi

# Return to the original branch and unstash changes
git checkout "$current_branch"
git stash pop
