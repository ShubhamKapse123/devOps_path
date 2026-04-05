#!/bin/bash

# ================================
# GitHub Collaborator Access Script
# ================================
# This script fetches and lists users who have READ (pull) access or ADMIN access
# to a given GitHub repository using GitHub REST API.

# -------------------------------
# Base GitHub API URL
# -------------------------------
API_URL="https://api.github.com"

# -------------------------------
# Authentication Credentials
# Expecting environment variables:
# export username="your_github_username"
# export token="your_personal_access_token"
# -------------------------------
USERNAME=$username
TOKEN=$token

# -------------------------------
# Input Arguments
# $1 -> Repository Owner (e.g., org/user)
# $2 -> Repository Name
# -------------------------------
REPO_OWNER=$1
REPO_NAME=$2

# -------------------------------
# Function: github_api_get
# Purpose : Generic helper to make authenticated GET requests
# Input   : API endpoint (relative path)
# Output  : JSON response from GitHub API
# -------------------------------
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Perform GET request using curl with basic authentication
    # -s : silent mode (no progress output)
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# -------------------------------
# Function: list_users_with_read_access
# Purpose : Fetch and filter users who have pull (read) or admin access
# Logic   :
#   1. Call GitHub API to get collaborators
#   2. Use jq to filter users with 'pull == true' OR 'admin == true'
#   3. Extract their GitHub usernames (login field) and permissions
# -------------------------------
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    # Fetch collaborators and filter users with read or admin access
    collaborators="$(
        github_api_get "$endpoint" | \
        jq -r '.[] | select(.permissions.pull == true or .permissions.admin == true) | "\(.login) - \(.permissions | to_entries | map(select(.value == true) | .key) | join(", "))"
    )";

    # -------------------------------
    # Output Handling
    # -------------------------------
    if [[ -z "$collaborators" ]]; then
        echo "No users with read or admin access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read or admin access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

# ================================
# Main Execution
# ================================

# Validate input arguments
if [[ -z "$REPO_OWNER" || -z "$REPO_NAME" ]]; then
    echo "Usage: $0 <repo_owner> <repo_name>"
    exit 1
fi

# Validate required tools
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    exit 1
fi

# Validate credentials
if [[ -z "$USERNAME" || -z "$TOKEN" ]]; then
    echo "Error: GitHub credentials not set."
    echo "Please export 'username' and 'token' environment variables."
    exit 1
fi

# Trigger execution
echo "Listing users with read or admin access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access