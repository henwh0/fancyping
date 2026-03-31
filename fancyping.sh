#!/bin/bash

source ~/scripts/ansi_colors.sh

if [ -z "$1" ]; then
    printf '%b\n' "${RED}Use a hostname as an argument.${NC}"
    exit 3
fi

ctrl_c() {
    printf '%b\n' "${RED}User interrupted script.${NC}"
    exit 2
}
trap ctrl_c SIGINT


hostname=$1
hostname_oob="${hostname/./-oob.}"

timer_start=$(date +%s)
ping_count=0
host_display="$hostname"
if [ ${#host_display} -gt 25 ]; then
  host_display="${host_display:0:23}.."
fi

while true; do

  ((ping_count ++))
  elapsed_time=$(( $(date +%s) - timer_start ))

  printf "\n[%02d:%02d:%02d] Ping: %d\n" $((elapsed_time/3600)) $((elapsed_time%3600/60)) $((elapsed_time%60)) "$ping_count"
  printf "+---------------------------+-----------+----------+\n"
  printf "| %-25s | %-9s | %-8s |\n" "Hostname" "ETH" "OOB"
  printf "+---------------------------+-----------+----------+\n"

  ping -c 1 -W 1 "$hostname" &>/dev/null & pid1=$!
  ping -c 1 -W 1 "$hostname_oob" &>/dev/null & pid2=$!
  wait $pid1 && status_eth="${GREEN}Active${NC}" || status_eth="${RED}Inactive${NC}"
  wait $pid2 && status_oob="${GREEN}Active${NC}" || status_oob="${RED}Inactive${NC}"

  printf "| %-25s | %-20b | %-19b |\n" "$host_display" "$status_eth" "$status_oob"
  printf "+---------------------------+-----------+----------+\n"
  sleep 2
done
