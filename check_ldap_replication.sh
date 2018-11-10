#!/bin/bash
#
# Name: check_ldap_replication.sh
#
# nrpe plug-in that checks ldap replication against master
#
# Copy this script to the client machine in the following directory:
#       /usr/lib64/nagios/plugins directory.
# Do not copy with the .sh extension.
#
# Change the variables below to match your installation.
#
# Add script plug-in command definition to /etc/nagios/nrpe.cfg (see below)
#
# [check_ldap_replication]=/usr/lib64/nagios/plugins/check_ldap_replication $ARG1$
#
# Restart nrpe on the client (sudo systemctl restart nrpe)
#
# On the nagios/naemon server perform the following test of the new script.
# Do this from the nagios/anemon server plugin directory:
#     /usr/lib64/nagios/plugins
# using check_nrpe
#
#     /usr/lib64/nagios/plugins/check_nrpe -H ldap001v -c check_ldap_replication ldap001.yourdomain.com
#
# you should get a return like this
#
#     OK- ldap001.yourdomain.com 20181231011858Z#000000#00#000000 0
#
# Configure your Nagios/Naemon/Thruk front end to use the plugin
MASTER_LDAP_SERVER=$1
SLAVE_LDAP_SERVER=`hostname`
#
BIND_DISTINGUISHED_NAME="cn=Administrator,dc=yourdomain,dc=com"
BIND_PASSWORD="password"
LDAP_BASE="dc=yourdomain,dc=com"
LDAP_PORT=389 #...or port 636
LDAP_PROTOCOL=3 #... or ldap protocol 2
#
ldap_replication_check ()
{
      MASTER_CONTEXT_CSN=`ldapsearch -x -D $BIND_DISTINGUISHED_NAME -w $BIND_PASSWORD -H ldaps://${MASTER_LDAP_SERVER}:$LDAP_PORT -P $LDAP_PROTOCOL -s base -b $LDAP_BASE contextCSN | grep contextCSN | awk '{print $NF}' | grep -v contextCSN`
      TEST_RUN=`echo $?`
      if [ $TEST_RUN -eq 0 ]; then
          SLAVE_CONTEXT_CSN=`ldapsearch -x -D $BIND_DISTINGUISHED_NAME -w $BIND_PASSWORD -H ldaps://${SLAVE_LDAP_SERVER}:$LDAP_PORT -P $LDAP_PROTOCOL -s base -b $LDAP_BASE contextCSN | grep contextCSN | awk '{print $NF}' | grep -v contextCSN`
          if $TEST_RUN -eq 0 ]; then
              DESCRIPTION="${SLAVE_LDAP_SERVER} ${SLAVE_CONTEXT_CSN}"
              if [[ "${SLAVE_CONTEXT_CSN}" != "${MASTER_CONTEXT_CSN}" ]]; then
                  RESULTS='failed'
              else
                  RESULTS='ok'
              fi
              DESCRIPTION="${SLAVE_LDAP_SERVER} ${SLAVE_CONTEXT_CSN}"
           else
              RESULTS='unknown'
              DESCRIPTION="${SLAVE_LDAP_SERVER} unknown"
           fi
      else
          RESULTS='unknown'
          DESCRIPTION="${SLAVE_LDAP_SERVER} unknown"
      fi
 }

 output_results_with_nrpe_codes ()
 {
      # Plugin Return Code/Service State
      #   0	==> OK
      #   1	==> WARNING
      #   2	==> CRITICAL
      #   3	==> UNKNOWN
      case "${RESULTS}" in
         'ok')
               echo "OK- ${DESCRIPTION} 0"
               exit 0
               ;;
         'warning')
               echo "WARNING- ${DESCRIPTION} 1"
               exit 1
               ;;
         'failed')
               echo "CRITICAL- ${DESCRIPTION} 2"
               exit 2
               ;;
         'unknown')
               echo "UNKNOWN- ${DESCRIPTION} 3"
               exit 3
               ;;
       esac
 }
#
# Main procedure calling the declared functions above.
#
ldap_replication_check
output_results_with_nrpe_codes
#
