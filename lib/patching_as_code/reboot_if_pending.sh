REBOOT_NEEDED=false

if [ -f '/usr/bin/needs-restarting' ]
then
  case $(facter os.release.major) in
    7|8)
      /usr/bin/needs-restarting -r 2>/dev/null 1>/dev/null
      if [ $? -eq 0 ]
      then
        REBOOT_NEEDED=true
      fi
    ;;
    6)
      /usr/bin/needs-restarting 2>/dev/null 1>/dev/null
      if [ $? -gt 0 ]
      then
        REBOOT_NEEDED=true
      fi
    ;;
  esac
fi

if [ $(facter osfamily) = 'Debian' ] || [ $(facter osfamily) = 'Suse' ]
then
  if [ -f '/var/run/reboot-required' ]
  then
    REBOOT_NEEDED=true
  fi
fi

if [ "$REBOOT_NEEDED" = "true" ]; then
    echo "Patching_as_code: A reboot is required"
    echo "Patching_as_code: Scheduling a reboot to happen in 5 minutes"
    shutdown -r +5
else
    echo "Patching_as_code: No reboot is needed, doing nothing"
fi
