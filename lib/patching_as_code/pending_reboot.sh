#!/bin/bash
NEED_REBOOT=0

if [ -f '/usr/bin/needs-restarting' ]
then
  case $(/opt/puppetlabs/bin/facter os.release.major) in
    7|8|9)
      /usr/bin/needs-restarting -r 2>/dev/null 1>/dev/null
      if [ $? -eq 1 ]
      then
	NEED_REBOOT=1
      fi
    ;;
    6)
      /usr/bin/needs-restarting 2>/dev/null 1>/dev/null
      if [ $? -gt 0 ]
      then
	NEED_REBOOT=1
      fi
    ;;
  esac
fi

if [ $(/opt/puppetlabs/bin/facter osfamily) = 'Debian' ] || [ $(/opt/puppetlabs/bin/facter osfamily) = 'Suse' ]
then
  if [ -f '/var/run/reboot-required' ]
  then
    NEED_REBOOT=1
  fi
fi

# flip result for correct exitcode (0 means reboot needed, 1 means no reboot needed)
[ $NEED_REBOOT -eq 1 ]