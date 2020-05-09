#!/bin/bash

DEFAULT='\033[0;39m'
WHITE='\033[0;97m'
GREEN='\033[0;32m'
LIGHTGREEN='\033[0;92m'
CYAN='\033[0;36m'
LIGHTCYAN='\033[0;96m'

mv config.json config-dev.json

echo -e "${GREEN}All files successfuly generated!"
echo -e "${GREEN}Fetching dependencies..."

vapor xcode --verbose

echo -e "${LIGHTGREEN}Open project {{cookiecutter.product_name}} whit Xcode.${DEFAULT}"