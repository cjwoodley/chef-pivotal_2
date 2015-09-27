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
    httpd
    mod_ssl
    postgresql
    postgresql-devel
    postgresql-server
    postgresql-jdbc
    compat-readline5
    createrepo
    sigar
    sudo
    python-ldap
    openldap
    openldap-clients
    openldap-servers
    pam_krb5
    sssd
    authconfig
    krb5-workstation
    krb5-libs
    krb5-server
	).each do |p|
	yum_package p do 
		action :install
	end
end

directory "/opt/sources/" do
  owner "root"
  group "root"
  mode 00755
  action :create
end

directory "/opt/sources/java" do
  owner "root"
  group "root"
  mode 00755
  action :create
end

directory "/opt/sources/pcc" do
  owner "root"
  group "root"
  mode 00755
  action :create
end

#need to figured out how to get the source files there 

#cmdInstallIPS =  ". /home/bodsadmin/.bash_profile && /opt/bods_sources/DS_42_LNX64/setup.sh -r /home/bodsadmin/ds.ini"
rpm_package "jdk-7u71-linux-x64.rpm" do
	action :nothing
	source "/opt/sources/java/jdk-7u71-linux-x64.rpm"
end

bash "update-alternatives java" do
  action :nothing
  code <<-EOH
    /usr/sbin/alternatives --install "/usr/bin/java" "java" "/usr/java/latest/bin/java" 1
    /usr/sbin/alternatives --set java /usr/java/latest/bin/java

    /usr/sbin/alternatives --install "/usr/bin/javac" "javac" "/usr/java/latest/bin/javac" 1
    /usr/sbin/alternatives --set javac /usr/java/latest/bin/javac
  EOH
end

#need to figure out interactive response
bash "Install-Pcc" do 
	action :nothing
	cwd "/opt/sources/pcc"
	code <<-EOH
		tar -xzvf PCC-2.3.0-443.x86_64.tgz
		./PCC-2.3.0-443/install
	EOH
end

bash "Load-PHD-Packages" do
	action :nothing
	cwd "/opt/sources/pcc"
	code <<-EOH
		sudo -u gpadmin icm_client import -r /opt/sources/java/jdk-7u71-linux-x64.rpm
		chown gpadmin:gpadmin PHD-2.1.0.0-175.tgz
		sudo -u gpadmin tar -xzvf PHD-2.1.0.0-175.tgz
		sudo -u gpadmin icm_client import -s ./PHD-2.1.0.0-175

		chown gpadmin:gpadmin PADS-1.2.1.0-10335.tgz
		sudo -u gpadmin tar -xzvf PADS-1.2.1.0-10335.tgz
		sudo -u gpadmin icm_client import -s ./PADS-1.2.1.0-10335

		chown gpadmin:gpadmin PRTS-1.3.0-48613.tgz
		sudo -u gpadmin tar -xzvf PRTS-1.3.0-48613.tgz
		sudo -u gpadmin icm_client import -s ./PRTS-1.3.0-48613

	EOH
end

