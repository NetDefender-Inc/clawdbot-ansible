#!/bin/bash
set -e

# Run the Ansible playbook
if [ "$EUID" -eq 0 ]; then
    ansible-playbook playbook.yml -e ansible_become=false "$@"
    PLAYBOOK_EXIT=$?
else
    ansible-playbook playbook.yml --ask-become-pass "$@"
    PLAYBOOK_EXIT=$?
fi

# After playbook completes successfully, switch to clawdbot user
if [ $PLAYBOOK_EXIT -eq 0 ]; then
    echo ""
    echo "🚀 Switching to clawdbot user..."
    echo ""
    sleep 1
    
    # The trick: replace current shell completely with sudo's shell
    # Don't use exec alone - use it within a login command
    exec sudo -u clawdbot -i
else
    echo "❌ Playbook failed with exit code $PLAYBOOK_EXIT"
    exit $PLAYBOOK_EXIT
fi
