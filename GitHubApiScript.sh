#!/bin/bash

#############################################
# GitHub Repository Access Checker Script
#
# Features:
# - List users with READ (pull) access
# - List users with ADMIN access
# - Uses GitHub REST API
#
# Prerequisites:
# - curl
# - jq
# - GitHub Personal Access Token (PAT)
#############################################

# Exit immediately if a command fails
set -e

# Base GitHub API URL
API_URL="https://api.github.com"

# GitHub credentials (export before running script)
# export username="your_username"
# export token="your_personal_access_token"
USERNAME="${username}"
TOKEN="${token}"

# Validate credentials
if [[ -z "$USERNAME" || -z "$TOKEN" ]]; then
    echo "ERROR: Please set 'username' and 'token' as environment variables."
    exit 1
fi

# Validate input parameters
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <repo_owner> <repo_name>"
    exit 1
fi

REPO_OWNER="$1"
REPO_NAME="$2"

#############################################
# Function: github_api_get
# Description: Generic function to call GitHub API
# Arguments:
#   $1 - API endpoint (without base URL)
#############################################
github_api_get() {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

#############################################
# Function: list_users_with_read_access
# Description: Lists users having READ (pull) access
#############################################
list_users_with_read_access() {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    echo "Fetching users with READ access..."

    local users
    users=$(github_api_get "$endpoint" | \
        jq -r '.[] | select(.permissions.pull == true and .permissions.push == false and .permissions.admin == false) | .login')

    if [[ -z "$users" ]]; then
        echo "No users with READ access found."
    else
        echo "Users with READ access:"
        echo "$users"
    fi
}

#############################################
# Function: list_users_with_admin_access
# Description: Lists users having ADMIN access
#############################################
list_users_with_admin_access() {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    echo "Fetching users with ADMIN access..."

    local admins
    admins=$(github_api_get "$endpoint" | \
        jq -r '.[] | select(.permissions.admin == true) | .login')

    if [[ -z "$admins" ]]; then
        echo "No users with ADMIN access found."
    else
        echo "Users with ADMIN access:"
        echo "$admins"
    fi
}

#############################################
# Main Execution
#############################################

echo "Repository: ${REPO_OWNER}/${REPO_NAME}"
echo "----------------------------------------"

list_users_with_read_access
echo "----------------------------------------"
list_users_with_admin_access
