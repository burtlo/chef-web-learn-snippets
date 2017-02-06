#
# Cookbook:: automate_deploy_cookbook
# Recipe:: config_runner
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Configure the runner

# scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/private_key ~/.ssh/private_key ec2-user@test-jags15hai32gppmi.us-east-1.opsworks-cm.io:
#
# ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/private_key ec2-user@test-jags15hai32gppmi.us-east-1.opsworks-cm.io 'ls'
#
# ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/private_key ec2-user@test-jags15hai32gppmi.us-east-1.opsworks-cm.io 'sudo automate-ctl install-runner ec2-52-91-211-142.compute-1.amazonaws.com centos --ssh-identity-file private_key --yes'
