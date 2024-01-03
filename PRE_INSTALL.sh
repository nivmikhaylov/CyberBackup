#!/bin/bash

LOG="/home/SOFTWARE/Logs/PRECHECK_UNIVERSAL_LOG_CYBERPROTECT_INSTALL.log"

log(){
        message="$(date +"%y-%m-%d %T") $@"
        echo $message
        echo $message >>$LOG
}


log "############################################"
log "Running the script.."
log "############################################"

echo "" >> $LOG

log "$(date)"

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
log "Pre-Checking Linux System..."
log "############################################"
log "Stage 0. Checking OS"
log "############################################"

echo "" >> $LOG

log "Server: $(hostname)"

echo "" >> $LOG

hostnamectl >> $LOG

echo "" >> $LOG

log "############################################"
log "Machine ID: $(cat /etc/machine-id)"
log "############################################"

echo "" >> $LOG

log "Listing Linux Services..."

echo "" >> $LOG

systemctl list-units --type=service --state=running >> $LOG

echo "" >> $LOG

if $(timedatectl status | grep -qi 'System clock synchronized: no');
then
        log "The system clock is not synchronized. Configure time synchronization."
else
        log "System clock synchronized"
fi

log "$(timedatectl status | grep NTP)"
log "$(timedatectl status | grep 'System clock synchronized')"

echo "" >> $LOG

timedatectl >> $LOG

echo "" >> $LOG

log "Available repository list..."

echo "" >> $LOG

apt-repo list >> $LOG

echo "" >> $LOG

log "############################################"
log "Stage 1. Checking file system"
log "############################################"

echo "" >> $LOG

log "Lists information about all available or the specified block devices..."

echo "" >> $LOG

lsblk -l -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT,PARTLABEL,UUID | sort -V >> $LOG

echo "" >> $LOG

if $(grep -q "Acronis" /etc/fstab)
then
        log "Mount points found for software installation"
        findmnt -l | grep Acronis >> $LOG
        echo "" >> $LOG
else
        log "############################################"
        log "Not mount points found for software installation."
        log "Script execution has stopped."
        log "############################################"
        exit 1
fi

echo "" >> $LOG

log "Displays the amount of space available on the file system containing each file name argument:" 
df --output=source,size,used,avail,pcent,target >> $LOG

echo "" >> $LOG

log "Displays the amount of space available on directory Software:"

if [ $(df --output=source,avail,target,pcent -k /usr/lib/Acronis/ | grep Acronis | awk '{print $4}' | sed "s/%//") -le '25' ] && [ $(df --output=source,avail,target,pcent -k /var/lib/Acronis/ | grep Acronis | awk '{print $4}' | sed "s/%//") -le '25' ];
then

        log "There is free space for software installation"
        echo "" >> $LOG
        df --output=source,size,used,avail,pcent,target /var/lib/Acronis /usr/lib/Acronis >> $LOG
else
        log "############################################"
        log "There is no free space to install software. Check the installation conditions."
        log "Script execution has stopped."
        log "############################################"
        exit 1
fi

log "Displays the amount of space available on backup directory:"

if [ $(df --output=source,avail,target,pcent -k /backup_storage | grep backup | awk '{print $4}' | sed "s/%//") -le '25' ];
then

        log "There is free space on backup directory"
        echo "" >> $LOG
        df --output=source,size,used,avail,pcent,target /backup_storage >> $LOG
else
        log "The backup directory contains files. Be careful!"
        log "You need to check the directory based on the script's output."
fi

echo "" >> $LOG

log ""Search tag 'noexec' on directory /var/lib/Acronis and /usr/lib/Acronis"."

if $(mount | egrep "vg_acr|vg_vol" | grep -qi noexec);
then
        log "Tag noexec not found!"
        log "$(mount | egrep "vg_acr|vg_vol")" 
else
        log "Tag noexec found:"
        log "$(mount | egrep "vg_acr|vg_vol")"
        echo "" >> $LOG
        log "Script execution has stopped."
        log "############################################"
        exit 1
fi

echo "" >> $LOG

log "############################################"
log  "Stage 2. Checking installed packages on OS"
log "############################################"

echo "" >> $LOG

log "############################################"
log "Search installed packages on Linux System..."
log "############################################"

echo "" >> $LOG

if [ "$KERNEL_NAME" = "Linux" -a "$HW_NAME" = "x86_64" ]
then
        if [ "$(grep -iE "ALT" /etc/*release)" ]
        then
                for PACKAGE_ALT in $PACKAGES_ALT
                do
                        if ! rpm -qa "$PACKAGE_ALT"
                        then
                                echo "" >> $LOG

                                log "############################################"
                                log "Package $PACKAGE_ALT not installed!" >> $PATH_LOG
                                log "Installation needed packages: $PACKAGE_ALT"
                                log "Script execution has stopped."
                                log "############################################"
                                exit 1
        else
                log "Package $PACKAGE_ALT installed."
        fi
        done
        fi
else
        OS_VERSION=notsupported >> $PATH_LOG
fi

echo "" >> $LOG

log "############################################"
log "Search installed Python and SQLITE packages on Linux System..."
log "############################################"

echo "" >> $LOG

for PACKAGE_PYTHON in $PACKAGES_PYTHON
do
        if ! rpm -qa "$PACKAGE_PYTHON"
        then
                echo "" >> $LOG
                
                log "############################################"
                log "Package $PACKAGE_PYTHON not installed!" >> $PATH_LOG
                log "Installation needed packages: $PACKAGE_PYTHON"
                log "Script execution has stopped."
                log "############################################"
                exit 1
        else
                log "Package $PACKAGE_PYTHON installed."

        fi
done

echo "" >> $LOG
