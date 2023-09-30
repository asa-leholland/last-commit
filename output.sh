#!/bin/sh

# Specify the target branch
target_branch="main"

# Get the name of the current branch
current_branch=$(git symbolic-ref --short HEAD)

# Compare the current branch against the specified target branch
if [ "$current_branch" != "$target_branch" ]; then
  git checkout "$target_branch"  # Switch to the specified target branch
fi

# Get the total insertions and deletions from the last lines of `git diff --shortstat`
shortstat_output=$(git diff --shortstat 2>/dev/null)
insertions=$(echo "$shortstat_output" | tail -n 1 | awk '{print $4}')
deletions=$(echo "$shortstat_output" | tail -n 1 | awk '{print $6}')

# Print the result in the desired format
if ((insertions + deletions > 0)); then
  printf "𝜟=%d (+%d/-%d)\n" "$((insertions + deletions))" "$insertions" "$deletions"
else
  printf "𝜟=0 (+0/-0)\n"
fi

# Return to the original branch
git checkout "$current_branch"
