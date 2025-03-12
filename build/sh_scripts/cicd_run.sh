#!/bin/bash

off="\033[0m"
red="\033[0;31m"
gray="\033[0;37m"
cyan="\033[1;36m"
white="\033[1;37m"
green="\033[0;32m"
yellow="\033[0;33m"
magenta="\033[0;35m"

decorator_init="echo -e ${yellow}$(seq -s '.' 93 | tr -d '[:digit:]')${off}"
decorator_done="echo -e ${gray}$(seq -s '=' 63 | tr -d '[:digit:]')${off}"
JOB="${green}JOB:${gray} -->${off}"

pipeline_sequence_check(){
    echo -e "$JOB [$(date +'%Y-%m-%d %H:%M:%S')] Starting ${yellow}CI/CD pipeline ${green}Environment ${gray}Build:${off}"
    sleep 1

    set -e  # Stop on failure
    
    $decorator_init
    echo -e "$JOB\t${magenta}FastAPI server check${off}:"
    # if ! ping -c 4 -W 5 resume-fastapi; then
    if ! ping -c 4 -W 5 resume-fastapi &>/dev/null; then
        echo -e "$JOB\t${red}ERROR:${white} FastAPI is ${red}unreachable!${off}\n"
        $decorator_done
        exit 1
    fi

    $decorator_init
    echo -e "$JOB\t${magenta}Requesting FastAPI app: ${gray}--> ${yellow}[${cyan} http://resume-fastapi:8000 ${yellow}]${off}"
    # if ! curl -v http://resume-fastapi:8000/; then
    if ! curl --silent --fail http://resume-fastapi:8000/ > /dev/null; then
        echo -e "$JOB\t${red}ERROR:${white} FastAPI server is ${red}unreachable!${off}\n"
        $decorator_done
        exit 1
    fi

    $decorator_init
    echo -e "$JOB\t${magenta}Generating${green} API key for ${magenta}Pytests${off}:"
    if ! ./tests/curl_tests/get_auth_key.sh; then
        echo -e "$JOB\t${red}ERROR:${white} Key generation ${red}failed!${off}\n"
        $decorator_done
        exit 1
    fi

    $decorator_init
    echo -e "$JOB\t${magenta}Running ${yellow}Py tests${off}:"
    sleep 1
    echo -e "$JOB\t${magenta}Running ${yellow}sys_test.py${off} for the fun of it ${yellow}because I can${off}:))"
    pytest -v -rA charts tests/py_tests/sys_test.py
    $decorator_init
    echo -e "$JOB\t${magenta}Running ${yellow}test_mock_endpoints.py${off}\tthese are mock tests ${cyan}using ${red}fake ${cyan}fastAPI ${yellow}test client ${off}with ${cyan}real app endpoints${off}:"
    # echo -e "$JOB\t${magenta}Running ${yellow}test_mock_endpoints.py${off}:"
    pytest -v -rA charts tests/py_tests/test_mock_endpoints.py
    $decorator_init
    echo -e "$JOB\t${magenta}Running ${yellow}test_true_endpoints_sets.py${off}\tthese are ${magenta}C.R.U.D${yellow} tests:${cyan} using ${magenta}real ${cyan}test data and ${yellow}true fastAPI client ${off}with ${cyan}actual app endpoints${off}:"
    # echo -e "$JOB\t${magenta}Running ${yellow}test_true_endpoints_sets.py${off}:"
    pytest -v -rA charts tests/py_tests/test_true_endpoints_sets.py
    $decorator_init
    echo -e "$JOB\t${magenta}Test Env Prep:${yellow} Running shell script to handle authentication prerequisites${off}:"
    ./tests/curl_tests/collect_existing_tokens.sh
    ./tests/curl_tests/revoke_api_tokens.sh
    ./tests/curl_tests/get_auth_key.sh
    
    # echo -e "$JOB\t${magenta}Running ${yellow}test_crud_cycle_true_endpoints.py${off}:"
    echo -e "$JOB\t${magenta}Running ${yellow}test_crud_cycle_true_endpoints.py${off}\tthese are ${magenta}sets of tests ${yellow}grouped by test data set${magenta} per endpoint:${cyan}using ${magenta}real ${cyan}test data and ${yellow}true fastAPI client ${off}with ${cyan}actual app endpoints${off}:"
    sleep 1
    pytest -v -rA charts tests/py_tests/test_crud_cycle_true_endpoints.py
    
    $decorator_init
    echo -e "$JOB\t${magenta}Cleanup${green} API keys from ${magenta}Mongo DB${off}:"
    # if ! ./tests/curl_tests/collect_existing_tokens.sh; then
    if ! ./tests/curl_tests/collect_existing_tokens.sh &>/dev/null; then
        echo -e "$JOB\t${red}ERROR:${white} script call ${red}failed!${off}"
        $decorator_done
        exit 1
    fi

    echo "$JOB\t${magenta}Running ${yellow}revoke_api_tokens.sh CURL call${off}:"
    sleep 1
    ./tests/curl_tests/revoke_api_tokens.sh
}

pipeline_sequence_check
