#!/bin/bash

off="\033[0m"
red="\033[0;31m"
gray="\033[0;37m"
cyan="\033[1;36m"
white="\033[1;37m"
green="\033[0;32m"
yellow="\033[0;33m"
magenta="\033[0;35m"

decorator_init="echo -e ${yellow}$(printf '.%.0s' {1..93})${off}"
decorator_done="echo -e ${gray}$(printf '=%.0s' {1..63})${off}"
JOB="${green}JOB:${gray} --> $(printf '%.0s' {1..1})${off}"

# ... start docker-compose build:
docker_compose_run(){
    echo -e "\n$JOB call ${magenta}docker-compose ${yellow}build ${off}"
    docker-compose --env-file cfgs/.env -f build/docker-compose.yml up --build -d
}

# ... database server status check:
mongodb_server_logs(){
    local head_lines=5
    local tail_lines=1
    echo -e "\n$JOB call ${magenta}docker ${off}get ${magenta}resume-mongo${yellow} logs${off}"
    $decorator_init
    { docker logs resume-mongo | head -n "$head_lines"; echo -e "${yellow}$(printf ' %.0s' {1..100})${off}"; docker logs resume-mongo | tail -n "$tail_lines"; }
    echo -e "\n$JOB call ${magenta}docker ${off}grep ${magenta}MONGO ${yellow}auth creds: ${off}"
    $decorator_init
    docker exec resume-mongo printenv | egrep 'MONGO_|GOSU_|JSYAML_|HOME' | while read -r line; do
    # docker exec resume-mongo printenv | grep MONGO_ | while read -r line; do
        key="${line%%=*}"
        value="${line#*=}"
    printf "%b%-27s%b= %b%s%b\n" "${magenta}" "$key" "${yellow}" "${green}" "$value" "${off}"
    done
}

# ... fasapi server status check:
fastapi_server_logs(){
    local head_lines=50
    echo -e "\n$JOB call ${magenta}docker ${off}get ${magenta}resume-fastapi ${yellow}logs${off}"
    { docker logs resume-fastapi | head -n "$head_lines"; echo -e "${gray}$(printf ' %.0s' {1..71})${off}";}
    $decorator_init
    echo -e "$JOB call ${magenta}docker ${off}exec ${magenta}resume-fastapi ${yellow}F.S check:${off}"
    docker exec -it resume-fastapi ls -asl /dbapp/
}

# ... database server navigation cli help:
mongodb_server_cli_help(){
    $decorator_init
    echo -e "$JOB${gray} mongodb cli help: ${yellow}show dbs ${off}"
    echo -e "$JOB${gray} mongodb cli help: ${yellow}use admin ${off}"
    echo -e "$JOB${gray} mongodb cli help: ${yellow}show users ${off}"
    echo -e "$JOB${gray} mongodb cli help: ${yellow}resume_db ${off}"
    echo -e "$JOB${gray} mongodb cli help: ${yellow}show collections ${off}"
    echo -e "$JOB${gray} mongodb cli help: ${yellow}db.resume.find().pretty() ${off}"
}

# ... database server shell session:
mongodb_server_access(){
    local user=admin
    local pass=admin
    mongodb_server_cli_help
    $decorator_init
    echo -e "$JOB ${red}NOTE:${off} ${gray}Accessing ${magenta}Mongo Data Base Server in ${yellow}Docker${off} container:\n\t\tFor syntax help, see ${magenta}CLI${off} notes above.\n\t\tPress ${gray}[${magenta}Ctrl+C${gray}]${off} to exit ${magenta}Docker${off} ${yellow}shell:\n${off}"
    echo -e "$JOB call ${magenta}MongoDB ${green}Docker ${yellow}Shell Session${off} with ${magenta}mongosh ${gray}-u ${yellow}${user} ${gray}-p ${yellow}${pass} ${gray}--authenticationDatabase ${yellow}admin ${off}"
    python3 src/helpers/timer.py 3
    $decorator_done
    set -a  # ... export all sourced variables:
    source cfgs/.env
    set +a  # ... Stop exporting:
    # docker exec -it resume-mongo mongosh -u ${user} -p ${pass} --authenticationDatabase admin
    eval ./build/sh_scripts/terminal_sessions.sh docker exec -it resume-mongo mongosh -u ${user} -p ${pass} --authenticationDatabase admin
}

# ... Mongo-Express docker image Notice:
java_script_security_notice() {
    $decorator_init
    message=$(echo -e "\n${white}Mongo-Express ${red}Security ${white}Notice: ${gray}_____________________________________________________${off}")
    message+=$(echo -e "\n\t${red}JSON ${yellow}documents are parsed through a ${white}JavaScript virtual machine${off}, that means,")
    message+=$(echo -e "\n\tthe ${red}web interface${off} can be used for ${red}executing malicious JavaScript${yellow} on a server:")
    message+=$(echo -e "\n\t${white}mongo-express ${magenta}should only be used ${green}privately${off} for development purposes:")
    message+=$(echo -e "\n\n${white}Mongo-Express ${magenta}web server ${off}access: ${gray}_____________________________________________________${off}")
    message+=$(echo -e "\n\t${white}Authentication${off} is ${yellow}required${off} for the first time ${white}mongo-express ${magenta}web server ${off}access:")
    message+=$(echo -e "\n\tUse credentials configured in ${magenta}cfgs/.env ${off}file:")
    message+=$(echo -e "\n\tUnless ${magenta}cfgs/.env ${off}file modified prior to this dev-build:")
    message+=$(echo -e "\n\t${magenta}USER${off}: ${yellow}noadmin${off}")
    message+=$(echo -e "\n\t${magenta}PASS${off}: ${yellow}noadmin${off}")
    for (( i=0; i<${#message}; i++ )); do
        echo -ne "${message:$i:1}"
        sleep 0.01
    done
    echo
}
# ... web based info | urls:
ui_client_sessions(){
    fastapi_swagger="http://127.0.0.1:8000/docs"
    fastapi_ReDoc="http://127.0.0.1:8000/redoc"
    fastapi_ReDoc_resume_tag="http://127.0.0.1:8000/redoc#tag/resume"
    fastapi_tutorial="https://fastapi.tiangolo.com/tutorial/path-params/#data-validation"
    
    mongo_express="http://localhost:8081"
    mongo_express_docker_hub="https://hub.docker.com/_/mongo-express"
    mongodb_compatibilities="https://www.mongodb.com/resources/products/compatibilities/docker"
    java_script_security_notice
    $decorator_init
    echo -e "$JOB call ${white}open${off} in browser ${white}FastAPI ${green}Swagger  ${off}Docs:\t default ${yellow}url: ${gray}--> ${yellow}|${magenta} ${fastapi_swagger}${off}"
    echo -e "$JOB call ${white}open${off} in browser ${white}FastAPI ${green}ReDoc    ${off}Docs:\t default ${yellow}url: ${gray}--> ${yellow}|${magenta} ${fastapi_ReDoc}${off}"
    echo -e "$JOB call ${white}open${off} in browser ${white}Mongo ${green}Express ${off}web-client: default ${yellow}url: ${gray}--> ${yellow}|${magenta} ${mongo_express}${off}"
    python3 src/helpers/timer.py 1
    open $fastapi_swagger
    open $fastapi_ReDoc
    open $mongo_express
    $decorator_init
    echo -e "$JOB call ${white}show docs urls${off} in session:\n\
    \tmore on ${white}Mongo ${green}\t Express: ${off}web-client\t${off}Docs: ${cyan}url: ${gray}-->${cyan} ${mongo_express_docker_hub}${off}\n\
    \tmore on ${white}Mongo ${green}\t Database: ${off}Docker\t${off}Docs: ${cyan}url: ${gray}-->${cyan} ${mongodb_compatibilities}${off}\n\
    \tmore on ${white}FastAPI ${green} Tutorials:\t\t${off}Docs: ${cyan}url: ${gray}-->${cyan} ${fastapi_tutorial}${off}"
    # open $fastapi_tutorial
    # open $mongo_express_docker_hub
    # open $mongodb_compatibilities
}

docker_network_check(){
    $decorator_init
    echo -e "$JOB call ${magenta}docker ${off}network inspect${magenta} build_app-network ${gray}| ${green}grep ${gray}Name ${off}\n\t  ...${yellow} active docker network check details${off}:\n"
    docker network inspect build_app-network | grep Name 
    $decorator_init
}

docker_run_curl_tests(){
    $decorator_init
    echo -e "$JOB call ${magenta}docker ${off}exec -it${magenta} tests-manual ${green}./tests/using_CURL/run_CURL_tests.sh${off}\n\t  ...${yellow} calling shell based test scripts in tests-manual docker container ${off}:\n"
    docker exec -it tests-manual ./tests/curl_tests/run_curl_tests.sh
}

docker_run_pytests(){
    $decorator_init
    echo -e "$JOB call ${magenta}docker ${off}exec -it${magenta} tests-manual ${green}sys_test.py${off}\n\t  ...${yellow} calling pytest scripts in tests container ${off}:\n"
    python3 src/helpers/timer.py 3
    docker exec -it tests-manual pytest -v -r charts tests/py_tests/sys_test.py
    $decorator_init
    echo -e "$JOB call ${magenta}docker ${off}exec -it${magenta} tests-manual ${green}test_mock_endpoints.py${off}\n\t  ...${yellow} calling pytest scripts in tests container ${off}:\n"
    python3 src/helpers/timer.py 3
    docker exec -it tests-manual pytest -v -r charts tests/py_tests/test_mock_endpoints.py
    $decorator_init
    echo -e "$JOB call ${magenta}docker ${off}exec -it${magenta} tests-manual ${green}test_crud_cycle_true_endpoints.py${off}\n\t  ...${yellow} calling pytest scripts in tests container ${off}:\n"
    python3 src/helpers/timer.py 3
    docker exec -it tests-manual ./tests/curl_tests/get_auth_key.sh
    docker exec -it tests-manual pytest -v -r charts tests/py_tests/test_crud_cycle_true_endpoints.py
    $decorator_init
    echo -e "$JOB call ${magenta}docker ${off}exec -it${magenta} tests-manual ${green}test_true_endpoints_sets.py${off}\n\t  ...${yellow} calling pytest scripts in tests container ${off}:\n"
    python3 src/helpers/timer.py 3
    docker exec -it tests-manual ./tests/curl_tests/collect_existing_tokens.sh
    docker exec -it tests-manual ./tests/curl_tests/revoke_api_tokens.sh
    docker exec -it tests-manual ./tests/curl_tests/get_auth_key.sh 
    docker exec -it tests-manual pytest -v -r charts tests/py_tests/test_true_endpoints_sets.py
}

# ... docker cleanup:
docker_cleanup(){
    echo -e "\n$JOB call ${green}docker ${red}stop ${gray}(docker ps -a -q)${off}"
    python3 src/helpers/timer.py 1
    docker stop $(docker ps -a -q) 
    echo -e "\n$JOB call ${green}docker ${gray}system ${red}prune -af --volumes${off}"
    python3 src/helpers/timer.py 1
    docker system prune -af --volumes
}


# ... docker cleanup:
docker_container_logs_tail(){
    $decorator_init
    terminal_sessions="build/sh_scripts/container_logs_terminal_sessions.sh"
    echo -e "\n$JOB call ${gray}open terminal sessions for each docker container: ${yellow}$(dirname ${terminal_sessions})${off}/${green}$(basename $terminal_sessions)${gray} docker logs -f ${off}name"
    python3 src/helpers/timer.py 10
    ./build/sh_scripts/container_logs_terminal_sessions.sh 
}

docker_dev_container_session(){
    $decorator_init
    echo -e "\n$JOB call ${gray}open terminal session for dev and test purpose: ${yellow}$(dirname ${terminal_sessions})${off}/${green}$(basename $terminal_sessions)${gray} docker run -it --network ${off}build_app-network"
    # docker run -it --network build_app-network -v $(pwd):/dbapp build-tests-manual bash
    # eval ./build/sh_scripts/terminal_sessions.sh docker run -it --network build_app-network -v $(pwd):/dbapp build-tests-manual bash
    python3 src/helpers/timer.py 5
    eval ./build/sh_scripts/terminal_sessions.sh docker run -it --network build_app-network build-tests-manual bash
}

# ... main: 
main(){
    docker_cleanup
    echo -e "\n$JOB Starting ${yellow}Dev ${green}Environment ${gray}Build:${off}"
    python3 src/helpers/timer.py 3
    docker_compose_run
    mongodb_server_logs
    fastapi_server_logs
    ui_client_sessions
    docker_network_check
    docker_container_logs_tail
    docker_run_curl_tests
    docker_run_pytests
    mongodb_server_access
    docker_dev_container_session
}

# ... main call:
main
