#!/bin/bash

KERNEL_NAME=$(uname -s)
HW_NAME=$(uname -m)
HOSTNAME=$(hostname)

PACKAGES_ALT="gcc make kernel-source-5.10 kernel-headers-modules-std-def"
PACKAGES_PYTHON="python-modules-sqlite3 python-module-requests"

LOG="/root/UNIVERSAL_LOG_CYBERPROTECT_INSTALL.log"

R_PATH="/root/REMOTEUPDATE"

log(){
   message="$(date +"%y-%m-%d %T") $@"
   echo $message
   echo $message >>$LOG
}

rm -rf $LOG

log "############################################"
log "Running the script.."
log "############################################"

echo  "" >> $LOG

log "############################################"
log "Checking who is running the script.."
log "############################################"

echo  "" >> $LOG

log "############################################"
if [ "$(id -u)" != "0" ];
then
   log "This script must be run as root!"
   exit 1
else
   log "Thist script run as root. Runing next steps..."
fi
log "############################################"

echo  "" >> $LOG

log "############################################"
log "Pre-Checking Linux System..."
log "############################################"
log "Stage 0. Checking OS"
log "############################################"
echo  "" >> $LOG
log "Server:"
hostnamectl >> $LOG
echo  "" >> $LOG
log "Listing Linux Services:"
systemctl list-units --type=service --state=running >> $LOG
echo  "" >> $LOG
log "NTP:"
timedatectl status | grep NTP >> $LOG
echo  "" >> $LOG
log "Available repository list:"
apt-repo list >> $LOG
log "############################################"
echo  "" >> $LOG
log "############################################"
log "Stage 0. Checking file system"
log "############################################"
echo  "" >> $LOG
log "Lists information about all available or the specified block devices:"
lsblk -l -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT,PARTLABEL,UUID | sort -V >> $LOG
echo  "" >> $LOG
log "Partition tables:"
fdisk -l >> $LOG
echo  "" >> $LOG
log "Displays the amount of space available on the file system containing each file name argument:" 
df -hT >> $LOG
echo :: >> $LOG
log "Displays the amount of space available on directory Software:"
df -hT /var/lib/Acronis /usr/lib/Acronis >> $LOG
echo "" >> $LOG
log "Display mount point:"
grep "Acronis*" /etc/fstab >> $LOG
echo "" >> $LOG

if $(egrep "/var/lib/Acronis|/usr/lib/Acronis" /etc/fstab | grep -q noexec)
then
        log "Tag noexec found:"
        echo "" >> $LOG
        log $(egrep "/var/lib/Acronis|/usr/lib/Acronis" /etc/fstab | grep noexec)
        exit 1
else
        log "Tag noexec not found!"
fi
echo "" >> $LOG


CURRENT_VERSION="/var/lib/Acronis/UpgradeTool/CURRENT_VERSION.txt"
LOCAL_VERSION="/var/lib/Acronis/UpgradeTool/LOCAL_VERSION.txt"

if [ "$(sed -n 's/MAJOR_VERSION=//p' $LOCAL_VERSION)" == "$(sed -n 's/MAJOR_VERSION=//p' $CURRENT_VERSION)" ];
then
        log  "The software version has been checked. No update required."
else
        log  "The software version has been checked. A software update is required."

        if [ "$(sed -n 's/MAJOR_VERSION=//p' $LOCAL_VERSION)" == "$(sed -n 's/MAJOR_VERSION=//p' $CURRENT_VERSION)" ];
then
        log  "The software version has been checked. No update required."
else
        log  "The software version has been checked. A software update is required."



        log  "The distribution package is loading."



        log  "A crontab job is being created to update the software."

        . /etc/os-release
        OS_NAME=$ID
        Start=$(date +"%M" --date="+120 seconds")
        echo "$Start * * * * "$R_PATH/${OS_NAME}-update.sh"" > $R_PATH/crontab_add.txt
        crontab -l | cat - $R_PATH/crontab_add.txt >$R_PATH/crontab.txt && crontab $R_PATH/crontab.txt

fi