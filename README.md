# nrpe_ldap_replication_check_plugin
NRPE LDAP replication check plug-in

nrpe plug-in that checks a slave ldap replication against the master ldap server.

#Installation

Copy this script to the client machine in the following directory:

  /usr/lib64/nagios/plugins directory.

Do not copy with the .sh extension.

Change the variables below to match your installation.

Add the script plug-in command definition to /etc/nagios/nrpe.cfg 

  [check_ldap_replication]=/usr/lib64/nagios/plugins/check_ldap_replication $ARG1$

Restart nrpe on the client 

  sudo systemctl restart nrpe

On the nagios/naemon server perform the following test of the new script. Do this from the nagios/naemon server plugin directory: /usr/lib64/nagios/plugins using check_nrpe

  /usr/lib64/nagios/plugins/check_nrpe -H ldap001v -c check_ldap_replication ldap001.yourdomain.com

You should get a return like this

  OK- ldap001.yourdomain.com 20181231011858Z#000000#00#000000 0

Finish your configuration with your Nagios/Naemon/Thruk front end interface.
