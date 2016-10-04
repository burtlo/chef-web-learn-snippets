#!/bin/bash
hostname -I | cut -d" " -f 1 > /vagrant/$(hostname)-ipaddress.txt
