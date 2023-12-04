#!/bin/bash

KERNEL_NAME=$(uname -s)
HW_NAME=$(uname -m)
HOSTNAME=$(hostname)

PACKAGES_ALT="gcc make kernel-source-5.10 kernel-headers-modules-std-def"
PACKAGES_PYTHON="python-modules-sqlite3 python-module-requests"

LOG="/root/UNIVERSAL_LOG_CYBERPROTECT_INSTALL.log"

log(){
   message="$(date +"%y-%m-%d %T") $@"
   echo $message
   echo $message >>$LOG
}

rm -rf $LOG

log "############################################"
log "Running the script.."
log "############################################"

echo "" >> $LOG

log "############################################"
log "Checking who is running the script.."
log "############################################"

echo "" >> $LOG

if [ "$(id -u)" != "0" ];
then
   log "This script must be run as root!"
   exit 1
else
   log "Thist script run as root. Runing next steps..."
fi

echo "" >> $LOG

log "############################################"

echo "" >> $LOG

log "############################################"
log "Pre-Checking Linux System..."
log "############################################"
log "Stage 0. Checking OS"
log "############################################"
echo "" >> $LOG

log "Server: $(hostname)"
echo "" >> $LOG
hostnamectl >> $LOG
log "Machine ID: $(cat /etc/machine-id)"

echo "" >> $LOG

log "Listing Linux Services..."
systemctl list-units --type=service --state=running >> $LOG

echo "" >> $LOG

log "$(timedatectl status | grep NTP )"
echo "" >> $LOG
timedatectl >> $LOG

echo "" >> $LOG

log "Available repository list..."
apt-repo list >> $LOG

echo "" >> $LOG

log "############################################"
log "Stage 1. Checking file system"
log "############################################"

echo "" >> $LOG

log "Lists information about all available or the specified block devices..."
lsblk -l -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT,PARTLABEL,UUID | sort -V >> $LOG

echo "" >> $LOG

if $(grep -q "Acronis" /etc/fstab)
then
        log "Mount points found for software installation"
        findmnt -l | grep Acronis >> $LOG
        echo "" >> $LOG
else
        log "Not mount points found for software installation"
        exit 1
fi

echo "" >> $LOG

log "Displays the amount of space available on the file system containing each file name argument:" 
df --output=source,size,used,avail,pcent,target >> $LOG

echo "" >> $LOG

log "Displays the amount of space available on directory Software:"

if [ $(df --output=source,avail,target,pcent -k /usr/lib/Acronis/ | grep Acronis | awk '{print $4}' | sed "s/%//") -le '2' ] && [ $(df --output=source,avail,target,pcent -k /var/lib/Acronis/ | grep Acronis | awk '{print $4}' | sed "s/%//") -le '2' ];
then

        log "There is free space for software installation"
        echo "" >> $LOG
        df --output=source,size,used,avail,pcent,target /var/lib/Acronis /usr/lib/Acronis >> $LOG
else
        log "There is no free space to install software. Check the installation conditions."
        exit 1

fi

echo "" >> $LOG

log "############################################"
log  "Stage 3. Checking installed packages on OS"
log "############################################"

log "$(rpm -qa)"
echo "" >> $LOG

log "############################################"
log "Search installed packages on Linux System..."
log "############################################"

echo "" >> $LOG
 
if [ "$KERNEL_NAME" = "Linux" -a "$HW_NAME" = "x86_64" ]
then
        if [ "$(grep -iE "ALT" /etc/*release)" ]
        then
                log -e "$KERNEL_NAME"
                log "$HW_NAME"
        for PACKAGE_ALT in $PACKAGES_ALT
        do
                if ! rpm -qa "$PACKAGE_ALT"
                then
                        echo "" >> $LOG
                        log "Package $PACKAGE_ALT not installed!" >> $PATH_LOG
                        log "Installation needed packages: $PACKAGE_ALT"
                        grep "update.altsp.su" /etc/apt/sources.list >/dev/null
        if [ $? -ne 0 ];
        then
                echo -e "$SOURCE" >> /etc/apt/sources.list >> $PATH_LOG
        else
                ping $SOURCE_RANDOM_IP
        fi
                apt-get install -y "$PACKAGE_ALT" >> $PATH_LOG
        else
                log "Package $PACKAGE_ALT installed."
        fi
        done
        fi
else
        OS_VERSION=notsupported >> $PATH_LOG
fi

echo "" >> $LOG