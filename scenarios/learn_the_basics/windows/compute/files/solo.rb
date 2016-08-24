tmp = 'C:/temp/chef-solo'
file_cache_path tmp
cookbook_path ["C:/temp/vendored-cookbooks"]
log_level :warn
verbose_logging false
json_attribs      "C:/temp/dna.json"
encrypted_data_bag_secret nil

http_proxy nil
http_proxy_user nil
http_proxy_pass nil
https_proxy nil
https_proxy_user nil
https_proxy_pass nil
no_proxy nil
