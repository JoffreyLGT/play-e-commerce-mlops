#!/usr/bin/env bash

PYTHON_EXE=python3.11
# Exit if an error occurs
set -e

# echo "Install mookme and setup Git hooks"
npm install
npx mookme init --only-hook --skip-types-selection

# Get the full path to this script's directory
current_dir=$(dirname $(readlink -f "${BASH_SOURCE:-$0}"))
# And the parent dir to ensure we can call the scripts
root_dir="$(dirname "$current_dir")"
# Get current user name
user="$(id -un)"

backend_venv=$root_dir/backend/.venv
# Check if backend_venv exists and if RESET_VENV is true
if [[ -d "$backend_venv" && "$RESET_VENV" == "true" ]]; then
    echo "RESET_VENV is set to true, delete backend venv to recreate it."
    rm -rf $backend_venv
elif [[ -d "$backend_venv" && ! -e "$backend_venv/$user" ]]; then
    echo "backend venv exists but was created by another user, delete it."
    rm -rf $backend_venv
fi
# Create the venv only if it doesn't exists.
if [ -d "$backend_venv" ]; then
    echo "Backend venv already exists."
else
    echo "Setup backend venv."
    cd $root_dir/backend
    poetry install
    touch "$backend_venv/$user"
    echo "Done"
fi

echo "Setup datascience venv"
datascience_venv=$root_dir/datascience/.venv
# Check if datascience_venv exists and if RESET_VENV is true
if [[ -d "$datascience_venv" && "$RESET_VENV" == "true" ]]; then
    echo "RESET_VENV is set to true, delete datascience venv to recreate it."
    rm -rf $datascience_venv
elif [[ -d "$datascience_venv" && ! -e "$datascience_venv/$user" ]]; then
    echo "datascience venv exists but was created by another user, delete it."
    rm -rf $datascience_venv
fi

if [ -d "$datascience_venv" ]; then
    echo "datascience venv already exists."
else
    cd $root_dir/datascience
    poetry install
    touch "$datascience_venv/$user"
    echo "Done"
fi

# Start DB container for local environment
if [[ $IS_DEV_CONTAINER != "true" && $USE_DB_CONTAINER == "true" ]]; then
    cd $root_dir
    echo "Start db container"
    TARGET=development docker-compose -f docker-compose.yaml up -d db
fi

echo "Environment successfully configured"
