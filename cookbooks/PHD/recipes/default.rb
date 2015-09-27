#
# Cookbook Name:: PCC
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
selinux_state "Disabled" do
  action :disabled
end

execute "Disable IPtables" do
  command "sudo /etc/init.d/iptables save && sudo /etc/init.d/iptables stop && sudo /sbin/chkconfig iptables off"
  creates "/tmp/something"
  action :run
end


%w(
nc
postgresql-devel
krb5-libs
krb5-workstation
openldap
openldap-clients
pam_krb5
sssd
authconfig
openssh-clients
python-ldap
	).each do |p|
	yum_package p do 
		action :install
	end
end

