#!/bin/bash

packages_file="packages.json"

RED=$(printf '\033[31m')
GREEN=$(printf '\033[32m')
YELLOW=$(printf '\033[33m')
BLUE=$(printf '\033[34m')
RESET=$(printf '\033[m')

jq -c '.[]' ${packages_file} | while read app; do
  desc=$(echo ${app} | jq -cr '.description')
  echo "${GREEN}Update${RESET} ${desc} ..."

  echo ${app} | jq -cr '.packages[]' | while read package; do
    base_repo=$(echo ${package} | jq -cr '.base_repo')
    multi_level=$(echo ${package} | jq -cr '."multi-level"')
    if ${multi_level}; then
      folder=$(echo ${package} | jq -cr '.folder')
    fi
    
    echo ${package} | jq -cr '.name[]' | while read package_name; do
      if ${multi_level}; then
        package_url="${base_repo}/trunk/${folder}/${package_name}"
      else
        package_url="${base_repo}/trunk/"
      fi
      echo "${YELLOW}${package_name}${RESET}"
      svn checkout -q ${package_url} ${package_name};
    done
  done

  echo "${GREEN}Done${RESET} ${desc} ..."
  echo ""
done

echo "${GREEN}ALL DONE!${RESET}"