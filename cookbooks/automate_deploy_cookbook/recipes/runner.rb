#
# Cookbook:: automate_deploy_cookbook
# Recipe:: runner
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# hostname
#
# echo $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) | xargs sudo hostname
#
# hostname
