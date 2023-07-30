#!/bin/sh
set -e
set -x

exit_with_error() {
    echo "Error: $1"
    exit 1
}

if [ -z "$INPUT_SOURCE_FOLDER" ]; then
  exit_with_error "Source folder must be defined"
fi

if [ "$INPUT_DESTINATION_HEAD_BRANCH" = "main" ] || [ "$INPUT_DESTINATION_HEAD_BRANCH" = "master" ]; then
  exit_with_error "Destination head branch cannot be 'main' nor 'master'"
fi

# reviewers from pull request created
PULL_REQUEST_REVIEWERS=""
if [ -n "$INPUT_PULL_REQUEST_REVIEWERS" ]; then
  PULL_REQUEST_REVIEWERS="-r $INPUT_PULL_REQUEST_REVIEWERS"
fi

CLONE_DIR=$(mktemp -d)

export GITHUB_TOKEN=$API_TOKEN_GITHUB
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"

git clone "https://$API_TOKEN_GITHUB@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"

# Copy files to repository git
mkdir -p "$CLONE_DIR/$INPUT_DESTINATION_FOLDER/"
cp -rf "$INPUT_SOURCE_FOLDER" "$CLONE_DIR/$INPUT_DESTINATION_FOLDER/"

# Change temporary dir using subshell
(
  cd "$CLONE_DIR"
  git checkout -b "$INPUT_DESTINATION_HEAD_BRANCH"

  git add .

  if git status | grep -q "Changes to be committed"; then
    git commit --message "Update from https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
    
    # Push git commit
    git push -u origin HEAD:"$INPUT_DESTINATION_HEAD_BRANCH"
    
    # Create PR
    gh pr create -t "$INPUT_DESTINATION_HEAD_BRANCH" \
                 -b "$INPUT_DESTINATION_HEAD_BRANCH" \
                 -B "$INPUT_DESTINATION_BASE_BRANCH" \
                 -H "$INPUT_DESTINATION_HEAD_BRANCH" \
                 $PULL_REQUEST_REVIEWERS
  else
    echo "No changes detected!"
  fi
)
