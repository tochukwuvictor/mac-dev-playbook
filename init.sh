#!/usr/bin/env bash
# Based on https://github.com/geerlingguy/mac-dev-playbook

set -euo pipefail

PYTHON_VERSION="3.9"
SCRIPT_DIR="$(dirname "$0")"

confirm_action() {
  local question answer
  question="${1?Must provide question}"

  read -rp "${question} [yes/no] " answer
  case ${answer} in
    yes) ;;
    no)
      echo -e "\nExiting..."
      exit 1
      ;;
    *) confirm_action "${question}";;
  esac
}


# Ensure Apple's command line tools are installed
if ! xcode-select --print-path; then
    xcode-select --install
    confirm_action "Have you finished installing xcode?"
fi

# Install homebrew
brew_bin_location="/usr/local/bin/brew"
if [[ "$(uname -a)" == *"arm"* ]]; then
  brew_bin_location="/opt/homebrew/bin/brew"
fi

if ! $brew_bin_location; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" | \
        tee installation_temp_file
    eval "$(cat installation_temp_file | grep -A2 "Add Homebrew to your PATH" | tail -n+2)"
    rm installation_temp_file
fi

# Install python
brew install python@"${PYTHON_VERSION}"

# Install ansible
python3 -m pip install --user ansible
python3 -m pip install --user paramiko
export PATH="${HOME}/Library/Python/${PYTHON_VERSION}/bin:${PATH}"

# Run ansible playbook
cd "$SCRIPT_DIR" || exit 1

ansible-galaxy install -r requirements.yml
cp default.config.yml config.yml
confirm_action "Have you reviewed config.yml and made any desired changes?"
chmod -x ansible-vault.pass
ansible-playbook main.yml -i inventory --vault-password-file ansible-vault.pass

cd .. || exit 1
