#!/bin/bash

# ================================
# GitHub Collaborator Details Script
# ================================
# This script fetches and displays details of all collaborators
# for a given GitHub repository.

API_URL="https://api.github.com"

# Authentication (set via environment variables)
USERNAME=$username
TOKEN=$token

# Input arguments
REPO_OWNER=$1
REPO_NAME=$2

# -------------------------------
# Function: github_api_get
# -------------------------------
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# -------------------------------
# Function: list_user_details
# -------------------------------
function list_user_details {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    # Fetch all collaborators and extract useful fields
    users="$(
        github_api_get "$endpoint" | \
        jq -r '.[] | "Username: \(.login)\nID: \(.id)\nProfile: \(.html_url)\nPermissions: \(.permissions)\n------------------------"'
    )"

    # Output handling
    if [[ -z "$users" ]]; then
        echo "No collaborators found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Collaborator details for ${REPO_OWNER}/${REPO_NAME}:"
        echo "$users"
    fi
}

# -------------------------------
# Main Execution
# -------------------------------

# Validate input
if [[ -z "$REPO_OWNER" || -z "$REPO_NAME" ]]; then
    echo "Usage: $0 <repo_owner> <repo_name>"
    exit 1
fi

# Validate jq
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    exit 1
fi

# Validate credentials
if [[ -z "$USERNAME" || -z "$TOKEN" ]]; then
    echo "Error: GitHub credentials not set."
    exit 1
fi

echo "Fetching collaborator details for ${REPO_OWNER}/${REPO_NAME}..."
list_user_details
