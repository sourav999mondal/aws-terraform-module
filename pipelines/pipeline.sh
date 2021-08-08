#!/bin/bash

if [ $? -ne 0 ]; then
    write_info "aws_check_if_there_is_an_active_build: $?"
fi

if [[ -z "$1" ]]; then
    write_error "You need to use this script with a parameter. (Either 'ci', 'cd' or 'notification')"
    exit 1
fi
modules=(aws-ec2)

###############################################################################
#
#  _____ _____
# /  __ \_   _|
# | /  \/ | |
# | |     | |
# | \__/\_| |_
#  \____/\___/
#
###############################################################################

if [[ "$1" == "ci" ]]; then
    write_info "CI Pipeline started.."

    # Initialising git configuration here because terraform modules are stored in private git repositories.
    git_init_config

for module in ${modules[@]} ; do
        # Get into the module directory
        if [ ! -d "$module" ]; then
            write_info "Could not find $module module. Looks like it has been removed or renamed."
            continue
        else
            cd "$module"
        fi
# We first init, then plan, then apply the plan and DESTROY everything, since this is just a terraform-module
        terraform init -no-color && terraform plan -no-color -out plan_$module.out

        if [ $? -ne 0 ]; then
            write_error "Tests failed for $module module."
            exit 1
        fi
# Return back to the git root.
        cd ..
    done
	
    write_info "Stage CI for $module finished."
    exit 0
fi
###############################################################################
#
#  ___________
# /  __ \  _  \
# | /  \/ | | |
# | |   | | | |
# | \__/\ |/ /
#  \____/___/
#
###############################################################################

if [[ "$1" == "cd" ]]; then
    write_info "CD Pipeline started.."

    for module in ${modules[@]} ; do
        write_info "Module CD services/$module started."
        cd $module && terraform init && terraform apply && cd ..

        if [ $? -ne 0 ]; then
            write_error "Error while applying resources"
            exit 1
        fi

        write_info "Stage CD for $module finished."
    done
    write_info "CD Pipeline finished."
fi

		