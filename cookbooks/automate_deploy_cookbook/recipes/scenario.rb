#
# Cookbook:: automate_deploy_cookbook
# Recipe:: scenario
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Create the project

## Get the learn_chef_apache2 cookbook

# git status
#
# git reset --hard HEAD
#
# git status
#
# ## Create the project and the pipeline
#
# cd ~/learn-chef/cookbooks/learn_chef_apache2
#
# delivery init
#
# delivery api ... # wait for Verify to finish
#
# delivery api get jobs --server test-jags15hai32gppmi.us-east-1.opsworks-cm.io --ent default --user admin
#
# ## Take a closer look at your Chef Automate project
#
# tree -a .delivery
#
# ## Configure the build cookbook to publish to Chef server
#
# Show config.json
#
# Modify config.json
#
# ```
# {
#   "version": "2",
#   "build_cookbook": {
#     "name": "build_cookbook",
#     "path": ".delivery/build_cookbook"
#   },
#   "skip_phases": [],
#   "job_dispatch": {
#     "version": "v2"
#   },
#   "dependencies": [],
#   "delivery-truck": {
#     "publish": {
#       "chef_server": true
#     }
#   }
# }
# ```
#
# git status
#
# git add .delivery/config.json
#
# git commit -m "Publish to Chef server"
#
# ## Submit the change
#
# delivery review
#
# ## Approve the change
#
# delivery api post orgs/studio/projects/learn_chef_apache2/changes/2291ed0b-901a-4cce-b3c8-de4e790a88a6/merge --server test-jags15hai32gppmi.us-east-1.opsworks-cm.io --ent default --user admin
#
# ## Deliver the change
#
# delivery api ... # wait for Acceptance to finish
#
# delivery api ... # click Approve button
#
# delivery api post orgs/studio/projects/learn_chef_apache2/changes/461995fa-fcca-4358-a7c1-5327f0373939/approve --server test-jags15hai32gppmi.us-east-1.opsworks-cm.io --ent default --user admin
#
# ## Integrate the change to your local master branch
#
# git checkout master
#
# git pull --prune
