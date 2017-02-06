#
# Cookbook:: automate_deploy_cookbook
# Recipe:: workstation
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# org_name = ""
# server_fqdn = ""
# username = node['chef_automate']['username']
# password = node['chef_automate']['password']
#
# # (Internal prerequisite)
#
# AUTOMATE_PASSWORD=lRU4bvdqR3bt3BCK delivery token --ent default --user admin --server test-jags15hai32gppmi.us-east-1.opsworks-cm.io
#
# # Generate SSH key.
#
# ssh-keygen -t rsa -b 4096 -C "jsmith@example.com" -f $HOME/.ssh/id_rsa -N ""
#
# ls ~/.ssh/id_rsa*
#
# cat ~/.ssh/id_rsa.pub
#
# # Update your user profile
#
# delivery api put users/admin --server test-jags15hai32gppmi.us-east-1.opsworks-cm.io --ent default --user admin --data='{ "_links": { "change-password": { "href": "/api/v0/e/default/internal-users/admin/change-password" }, "self": {      "href":"/api/v0/e/default/users/admin" } }, "email": "jsmith@example.com", "first": "Jane", "last": "Smith", "name":"admin", "ssh_pub_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2YAi43fzYUEORyqqJKK8uov2+DU56BdWGc+hs3bUNyJoddlkBLQzzQ0IsIXtf4ZA+pfc4+TsQF0KE6QUyQNg8uRNwGVYSgy1+dkfI41syUBycoa3yVfPUmaikOjeQm3CtMNcf9lBz4vX37m7hwH9ABTFi4lLrFrrP+fAP+PK/t4GYVzygalzn3mQaN+ZcPdmkWpclMEnbjSOESEaf3Q5mxzTImum8VoEQ6ZImE3kMGeLNxoEE9FzTu5EBmZSYNcg0TVRFoCkks1EGtZt6pRtBXbhe3aCKzKf2rpw2kiZG7dY/1bNFerjEdvb6KivrneRKNJaHNv4kQUcxKxxdOVEjMB4wQWRcUxbwz1UOkOo4UtKdXNvqda49uYoieBTOtrwGCO9LLk+sc4/khpkVfOr6ddJJfv+ytUODPVOxD5P2J9qG2JPf8eZYQE5aVt/1wAGlV6wWfzmeuNWRoLWaBt+fVlfFDGTw6i5qLmXlol/n2aclWHUqIESP/HiaK7KSIS/6skEFIFAWHxxYQbdZJpGO4qhXK50WbiA0GCPKHw7/j0oQZTINhSadzKgeT3INTIcj5YFuHJF0ljMMK2WHvgirMQjlcg0BVLHmazoQpb2pT7zYVdXQkyLmS/sP1BUJi3ZrzdgA1rew2X4QSrOC0Rg+9e2ZuASy11xfeVwtalKL+w== jsmith@example.com",  "user_type": "internal" }'
#
# # Create a workflow organization
#
# delivery api post orgs --server test-jags15hai32gppmi.us-east-1.opsworks-cm.io --ent default --user admin --data='{"name": "my-org"}'
#
# # Configure the command-line tools
#
# delivery setup --server=test-jags15hai32gppmi.us-east-1.opsworks-cm.io --ent=default --org=my-org --user=admin
#
# # Generate an API token
#
# AUTOMATE_PASSWORD=lRU4bvdqR3bt3BCK delivery token
#
# # Set your Git identity
#
# git config --global user.name "Jane Smith"
#
# git config --global user.email jsmith@example.com
#
# # Authenticate with Chef Automate's Git server
#
# ssh -T -p 8989 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l "admin@default" test-jags15hai32gppmi.us-east-1.opsworks-cm.io
