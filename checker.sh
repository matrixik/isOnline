#!/bin/bash
# Website status checker. by ET (etcs.me)

# Source: https://stackoverflow.com/a/246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

WORKSPACE="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
# List of websites. each website in new line. leave an empty line in the end.
LISTFILE=$WORKSPACE/websites.lst
# Append working URIs to this file
WORKINGFILE=$WORKSPACE/working.lst

# `Quiet` is true when in crontab; show output when it's run manually from shell.
# Set THIS_IS_CRON=1 in the beginning of your crontab -e.
# else you will get the output to your email every time
if [ -n "$THIS_IS_CRON" ]; then QUIET=true; else QUIET=false; fi

function test {
  response=$(curl -L --write-out "%{http_code}" --silent --output /dev/null $1)
  filename=$( echo $1 | cut -f1 -d"/" )
  if [ "$QUIET" = false ] ; then echo -n "$p "; fi

  case "$response" in
    200|300|301|302|304|307|308)
      # website working
      if [ "$QUIET" = false ] ; then
        echo -n "$response "; echo -e "\e[32m[ok]\e[0m"
        echo "$filename" >> $WORKINGFILE
      fi
      ;;
    *)
      # website down
      if [ "$QUIET" = false ] ; then echo -n "$response "; echo -e  "\e[31m[DOWN]\e[0m"; fi
      ;;
  esac
}

# main loop
while read p; do
  test $p
done < $LISTFILE
