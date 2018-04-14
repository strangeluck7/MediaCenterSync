#!/bin/bash
# This script keeps media center volume mounted

set -x

################################
VOLUMELIST=( "Videos" )
################################

for VOL in "${VOLUMELIST[@]}"
do
  # check to see if each volume is mounted by parsing df-h output
  VOLTEST=$(df -h | grep "SERVER_NAME/${VOL}" > /Users/strangeluck/Scripts/0 && echo "Yes" || echo "No")
  echo "${VOL} mounted: ${VOLTEST}"
  if [ "${VOLTEST}" = "No" ]; then
    mkdir /mnt/"${VOL}"
    mount_smbfs //'<USER>':'<PASSWORD>'@SERVER_NAME/"${VOL}" /mnt/"${VOL}"
    echo "Mounting volume ${VOL}"
    fi
done

exit 0;
