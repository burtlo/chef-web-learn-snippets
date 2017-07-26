This automation generates the sample code and output for the hosted Chef variations of the _Manage a node with Chef server_ module.

* [Red Hat Enterprise Linux](https://learn.chef.io/modules/manage-a-node-chef-server/rhel/hosted)
* [Windows Server](https://learn.chef.io/modules/manage-a-node-chef-server/windows/hosted)
* [Ubuntu](https://learn.chef.io/modules/manage-a-node-chef-server/ubuntu/hosted)

Here's how to run this automation.

### Software

* VMware Fusion (last tested using 8.5.3)

### Accounts

* A hosted Chef account. Last tested using the `learn-chef-2` organization.

### Files

Adjust these as necessary if you're using a hosted Chef account other than the `learn-chef-2` organization.

Add these files to `scenarios/manage_a_node/hosted/.chef`

* `knife.rb`:

  ```
  current_dir = File.dirname(__FILE__)
  log_level                :info
  log_location             STDOUT
  node_name                "chef-user-1"
  client_key               "#{current_dir}/chef-user-1.pem"
  chef_server_url          "https://api.chef.io/organizations/learn-chef-2"
  cookbook_path            ["#{current_dir}/../cookbooks"]
  ```

* `chef-user-1.pem`: The private key associated with the client named "chef-user-1".

Add the following to `scenarios/manage_a_node/hosted/secrets/private_key`.

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA1TneEq/UucF6hHVtRtQlTHQDGJjcSvrCteYSmRnhstWL0kNj
yRYvmWoR2Nybl9j2bsfYSaIHvJp1bqbaCo1CzzjGHHWE1w2zVo4IgVNq9N0Xe0tk
eA8Ye/08+KHd/7HnrZ5x7505NCXjZyh/Rf7Oef0Rbizsiy6iIXkNJ1PqQHb0JaGY
i4PWkrVEq/s5npR1d76KCgdoyEx27iF9fwHz3JtRqC86WNaAL3752hxs9uBIL4xP
CGtI9Bkx0ZfQcpy2orJDc4rXYyrASZfRkfbHi4x6IrI/8w7CHOMy/dys6/qT9jlm
ye/wiZMu5TBoJMbQMQt/+edYqYZ/Edrb1w+IhwIDAQABAoIBACN9SjUaBvIT/exm
DxYm4T5kYM+LQb9JFXdpH9dTs3ksieUpSkaB5tJGEUpjDZKsjffKU3mN+nOt0bXl
F42CDYioDnFWLhINObhCU7ASzk6LLglbdxF0kcKxV6CacHTKi6EeKiCTrp27YKoe
13AzBPLQ6EHKQGS6Eko397SABxFLbU72pygUVulyKPINi0lXVvDiJRKtx6Dz71El
33YOv9fyWZtngLo65xvy9xIhKjQ2BMzD85P0HXluJUiwsyvJ/Y3TtomLwOhpAFUA
JCmPaD2JuddzNO3NE/0IEJ5jOWROQUqtCR5iQoPPB9mj5EXIgGq2g+XnM9JDH29R
UTGwDoECgYEA+WKLrQ/f/LVZZQKhL7E6VaBJmwBqNKwEeG4WenE6frBvpZRdcFZC
K7VGv1NzJ8jEjlygz7of1yr3PDm9LfliePexuBwfQNywy4wS3iATtmokYE4lXI6P
GtfXbDQu4bBzHbEOxRoaQNkk835MHpAsFS2pt+olmxr9eR22cT5x+xECgYEA2uHI
tDg/tX4ktlnfx91U3FbqO57/cAh7zrEcvX5I3kAdXdZmBCws2N6eS33s2mkmr4as
x6++yN3LV4iBdKaK2VGaNfqF6NnLJDHSFvvlFwXCzLr9z+/De9l2eZBrDZ0rJPOg
o3vvkzI5k1kZGEGZjWhq64lw93GlbYkbHFOuWhcCgYATA82Mm4pDlXxEdGff4A6H
mtoh5G00qO0KVbKHEX0ZTdClemOJfjo7ZO4JBo7gOLGr/SoRzKpC2LbTM7/V8o7s
lE5LsHE9m9YrHvoNT7rRDNTLNwooPYJx1IVLbcspUC/m0qpCoxPfX+8uVbHuHqYN
01Z+fG7znaI4CujvR4ifUQKBgQCyqfBBI1TlmbTv4AapRwI45P1Hc26ADXy555pV
Fxr1x5HxAcu+Bi0JTRYa+wv18DTyu9SXHt51aY3MwpEhHbxizZg6DWd2/SgzQDOE
LVL/auVqZgw9yjFgC88IRZkMwMjx3ae3KrgRB8M1glnYkdt8MMptvn+mi26ELZEi
my/LOwKBgQC48l57O1zkuqW/si0NS7mkDwQ8/gO3JQ4uLSeIO46e2Lnqw25HV9+P
U8dhO9POOup/5nSIN6aYDi7KpcKYuet1JHKFfOqcHQpY4Z5yIuaKaYxl3VlbC3+Z
hqKuGNdGYqgO5udgNCmeewpSrnsY9S/CmR4cw1b0kmp3FwqgN1vWZg==
-----END RSA PRIVATE KEY-----
```

### Commands

(Examples shown from Z shell)

* Move to working directory.

  ```
  $ cd scenarios/manage_a_node/hosted
  ```

* Delete ipaddress files if they exist.

  ```
  $ rm node1-*-ipaddress.txt
  ```

* Bring up infrastructure (we need this step because the Windows instance requires reboot right away.)

  ```
  $ vagrant up --no-provision
  ```

* Run the automation.

  ```
  $ rake scenario:resume\[manage_a_node/hosted\]
  ```

* Copy snippets to the Learn Chef snippets directory.

  ```
  $ export
  $ rake snippets:copy\[manage_a_node/hosted\]
  ```

* Verify and commit the changes to Learn Chef.

* Tear down the automation

  ```
  $ vagrant destroy --force
  ```
