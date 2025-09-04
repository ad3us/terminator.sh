#!/bin/bash

usage() {
    echo "Usage: $0"
    echo "Script identifies potentially useless processes and daemons"
    exit 1
}

#spinner animation
spinner() {
    local pid=$1 #process id of the main task
    local spin='◐◓◑◒' #spinner characters
    local i=0
    while kill -0 "$pid" &>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r[%c] Processing... Please wait..." "${spin:$i:1}"
        sleep 0.3 
    done
    printf "\r[✔] Analysis complete!     \n"
}

#some fancy stuff to look it more cool
hacker_message() {
    local messages=(
        "Initiating Process Terminator..."
        "Scanning system core..."
        "Detecting rogue processes..."
        "Analyzing resource anomalies..."
        "Identifying zombie processes..."
        "Hunting orphaned daemons..."
        "Finalizing termination report..."
    )
    echo -e "\e[32m> ${messages[$1]}\e[0m" # Green text for hacker vibes
    sleep 1 # Artificial delay for each message
}

#name of the script
ascii_art() {
    cat << "EOF"
___________                  .__               __                
\__    ___/__________  _____ |__| ____ _____ _/  |_  ___________ 
  |    |_/ __ \_  __ \/     \|  |/    \\__  \\   __\/  _ \_  __ \
  |    |\  ___/|  | \/  Y Y  \  |   |  \/ __ \|  | (  <_> )  | \/
  |____| \___  >__|  |__|_|  /__|___|  (____  /__|  \____/|__|   

EOF
    echo -e "\e[32mSystem analysis initiated...\e[0m"
    sleep 2
}

#checking as if script run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root to analyze all processes. Please use sudo."
    exit 1
fi

#output file
output_file="/tmp/useless_processes_report.txt"
> "$output_file" # Clear the file before writing

ascii_art #showing ascii

#also fancy stuff
for i in {0..6}; do
    hacker_message "$i"
done

#finding processess
(
    #zombies
    echo -e "\n\e[1;34m=== Zombie Processes ===\e[0m" | tee -a "$output_file"
    zombie_processes=$(ps aux | awk '$8=="Z" {print $2, $11}')
    if [[ -n "$zombie_processes" ]]; then
        echo "The following zombie processes were detected:" | tee -a "$output_file"
        echo "$zombie_processes" | sed 's/^/  - /' | tee -a "$output_file"
    else
        echo "No zombie processes found." | tee -a "$output_file"
    fi

    sleep 2

    #processess that eating too much RAM
    echo -e "\n\e[1;34m=== Resource-Intensive Processes ===\e[0m" | tee -a "$output_file"
    echo "Top 10 processes consuming the most CPU and memory:" | tee -a "$output_file"
    ps aux --sort=-%cpu,-%mem | head -n 11 | awk '{print "  - " $0}' | tee -a "$output_file"

    sleep 2

    # child orphaned processes
    echo -e "\n\e[1;34m=== Orphaned Processes ===\e[0m" | tee -a "$output_file"
    orphaned_processes=$(ps -ef | awk '$3==1 {print $2, $8}')
    if [[ -n "$orphaned_processes" ]]; then
        echo "The following orphaned processes were detected:" | tee -a "$output_file"
        echo "$orphaned_processes" | sed 's/^/  - /' | tee -a "$output_file"
    else
        echo "No orphaned processes found." | tee -a "$output_file"
    fi

    sleep 2

    #inactive processess and services
    echo -e "\n\e[1;34m=== Inactive Systemd Services ===\e[0m" | tee -a "$output_file"
    if command -v systemctl &>/dev/null; then
        echo "The following inactive systemd services were detected:" | tee -a "$output_file"
        systemctl list-units --type=service --state=inactive | tail -n +2 | head -n -7 | awk '{print "  - " $1}' | tee -a "$output_file"
    else
        echo "Systemd is not available. Skipping inactive service check." | tee -a "$output_file"
    fi

    sleep 2

    #useless stuff
    echo -e "\n\e[1;34m=== Unnecessary Services ===\e[0m" | tee -a "$output_file"
    unnecessary_services=("cups" "bluetooth" "avahi-daemon" "snapd" "rpcbind")
    echo "Checking for unnecessary services that are currently active:" | tee -a "$output_file"
    any_unnecessary=false
    for service in "${unnecessary_services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            echo "  - $service is active but may not be necessary." | tee -a "$output_file"
            any_unnecessary=true
        fi
    done
    if ! $any_unnecessary; then
        echo "No unnecessary services found." | tee -a "$output_file"
    fi
) &
main_task_pid=$! # Capture the PID of the background process

spinner "$main_task_pid"

#eof
echo -e "\n\e[32mAnalysis complete. Report saved to $output_file\e[0m"





























































































































