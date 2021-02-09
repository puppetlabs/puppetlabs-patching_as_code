if [ -f '/usr/bin/needs-restarting' ]
then
  case $(facter os.release.major) in
    7|8)
      /usr/bin/needs-restarting -r 2>/dev/null 1>/dev/null
      if [ $? -eq 1 ]
      then
        echo "true"
      fi
    ;;
    6)
      /usr/bin/needs-restarting 2>/dev/null 1>/dev/null
      if [ $? -gt 0 ]
      then
        echo "true"
      fi
    ;;
  esac
fi

if [ $(facter osfamily) = 'Debian' ] || [ $(facter osfamily) = 'Suse' ]
then
  if [ -f '/var/run/reboot-required' ]
  then
    echo "true"
  fi
fi
