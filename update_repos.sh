#!/bin/bash

# Store the parent directory
PARENT_DIR=$(pwd)

# Function to determine the default branch (main or master)
get_default_branch() {
    # Try main first, then master
    if git rev-parse --verify main >/dev/null 2>&1; then
        echo "main"
    elif git rev-parse --verify master >/dev/null 2>&1; then
        echo "master"
    else
        echo "main"  # Default to main if neither exists
    fi
}

# For each directory in the current path
for dir in */; do
    if [ -d "$dir/.git" ]; then  # Check if it's a git repository
        echo "Processing repository: $dir"
        
        # Enter the directory
        cd "$dir"
        
        # Store the current branch name
        CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
        echo "Current branch: $CURRENT_BRANCH"
        
        # Check if there are any changes to stash
        if ! git diff --quiet || ! git diff --cached --quiet; then
            echo "Stashing changes..."
            git stash push -m "Auto-stash before updating repo"
            STASHED=1
        else
            STASHED=0
        fi
        
        # Get the default branch (main or master)
        DEFAULT_BRANCH=$(get_default_branch)
        echo "Default branch is: $DEFAULT_BRANCH"
        
        # Checkout the default branch
        git checkout "$DEFAULT_BRANCH"
        
        # Pull latest changes
        echo "Pulling latest changes..."
        git pull
        
        # If we were on a different branch, restore it
        if [ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]; then
            echo "Restoring branch: $CURRENT_BRANCH"
            git checkout "$CURRENT_BRANCH"
        fi
        
        # If we stashed changes, restore them
        if [ $STASHED -eq 1 ]; then
            echo "Applying stashed changes..."
            git stash apply stash@{0}
            git stash drop stash@{0}
        fi
        
        # Return to parent directory
        cd "$PARENT_DIR"
        echo "Finished processing $dir"
        echo "----------------------------------------"
    fi
done

echo "All repositories have been processed!" 