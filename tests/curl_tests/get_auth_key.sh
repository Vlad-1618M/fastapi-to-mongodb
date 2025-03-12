#!/bin/bash

# ... colors:
off="\033[0m"
red="\033[0;31m"
gray="\033[0;37m"
cyan="\033[1;36m"
white="\033[1;37m"
green="\033[0;32m"
yellow="\033[0;33m"
magenta="\033[0;35m"

# ... decorators | used in output formatting:
decorator_init="echo -e ${yellow}$(printf '.%.0s' {1..93})${off}"
decorator_done="echo -e ${gray}$(printf '=%.0s' {1..63})${off}"
JOB="${green}JOB:${gray} --> $(printf '%.0s' {1..1})${off}"

# BASE_URL="http://127.0.0.1:8000"
BASE_URL="http://resume-fastapi:8000"

# ... jq lib exists check:
if ! command -v jq &> /dev/null; then
    $decorator_init
    echo -e "$JOB ${red}Deps Error: ${magenta}jq${off} is not installed: Install ${magenta}jq${off} using one of the following methods:"
    echo -e "\t- For ${green}Debian/Ubuntu:\t\t${gray}--> ${yellow}sudo apt-get install jq${off}"
    echo -e "\t- For ${green}Fedora:\t\t\t${gray}--> ${yellow}sudo dnf install jq${off}"
    echo -e "\t- For ${green}CentOS/RHEL:\t\t${gray}--> ${yellow}sudo yum install jq${off}"
    echo -e "\t- For ${green}macOS (with Homebrew):\t${gray}--> ${yellow}brew install jq${off}"
    $decorator_done
    exit 1
fi

echo -e "\n$JOB Requesting ${magenta}FastAPI$gray -->\t${yellow}[${cyan} ${BASE_URL} ${yellow}]${off}: server to generate an ${magenta}API ${off}Access token ..."

# ... Request API Key
RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/generate-api-key")

# ... check fastAPI response:
if ! echo "$RESPONSE" | jq empty 2>/dev/null; then
    echo -e "$JOB ${red}Error:${off} Invalid response from API: $RESPONSE"
    exit 1
fi

# ... get the API key:
API_KEY=$(echo "$RESPONSE" | jq -r '.api_key // empty')

# ... validate API key:
if [[ -z "$API_KEY" ]]; then
    echo -e "$JOB ${red}Error:${off} API did not return a valid key."
    exit 1
fi

echo -e "$JOB ${green}Success:${off} API key generated:\t${yellow}[$cyan $API_KEY $yellow]${off}"

# ... store API key:
echo "$API_KEY" > /tmp/api_key.txt
chmod 600 /tmp/api_key.txt
echo -e "$JOB ${green}Success:${off} API key stored:\t${gray}[ /tmp/api_key.txt ]${off}"
