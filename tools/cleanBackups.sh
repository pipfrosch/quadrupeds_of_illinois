#!/bin/bash

# these backup files are created by bluefish periodically
#  but only really serve a useful purpose if bluefish has
#  unexpectedly quit before most recent save.

find . -print |grep "~$" |while read backup; do
  rm -f "${backup}"
done
