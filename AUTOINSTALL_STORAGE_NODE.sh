#!/bin/bash

KERNEL_NAME=$(uname -s)
HW_NAME=$(uname -m)
HOSTNAME=$(hostname)

PACKAGES_ALT="gcc make kernel-source-5.10 kernel-headers-modules-std-def"
PACKAGES_PYTHON="libsqllite3 python-modules-sqlite3 python-module-requests"

LOG="/home/CYBERPROTECT/LOGS/ASN_UNIVERSAL_LOG_CYBERPROTECT_INSTALL.log"

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

log "$(date)"

echo "" >> $LOG

log "############################################"
log "Checking who is running the script.."
log "############################################"

echo "" >> $LOG

if [ "$(id -u)" != "0" ];
then
        log "This script must be run as root!"
        log "############################################"
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

if $(hostname | grep -qi 'bsn');
then
        log "############################################"
        log "This server is a Storage Node!"
        log "############################################"
elif $(hostname | grep -qi 'bsn');
then
        log "############################################"
        log "This server is a Management Server!"
        log "############################################"
        exit 1       
else
        log "############################################"
        log "The server name does not match the script execution condition."
        log "Script execution has stopped."
        log "############################################"
        exit 1
fi

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

log "Search tag 'noexec' on directory /var/lib/Acronis, /usr/lib/Acronis and /backup_storage"

if $(mount | egrep "Acronis|backup" | grep -qi noexec);
then
        log "Tag noexec found:"
        log "$(mount | egrep "Acronis|backup")"
        echo "" >> $LOG
        log $(mount)
        log "Script execution has stopped."
        log "############################################"
        exit 1
else
        log "Tag noexec not found!"
        log "$(mount | egrep "Acronis|backup")" 
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

log "############################################"
log  "Stage 3. Install Software"
log "############################################"

echo "" >> $LOG
 
if $(hostname | grep -qi 'bsn');
then    
        log "############################################"
        log "Search Software CyberBackup in Linux System..."
        log "############################################"
 
        echo "" >> $LOG

        if ! systemctl list-units --type=service --state=loaded | grep -i "Acronis Storage Node";
        then
                log "Storage Node not installed."
                
                echo "" >> $LOG
                
                log "Installation Storage Node ..."
                sh /home/CYBERPROTECT/CyberBackup_16_64-bit.x86_64 -a --ams={IP/FQDN} --id=BackupAndRecoveryAgent,StorageServer,BackupAndRecoveryBootableComponents
                
                echo "" >> $LOG
                
                log "Storage Node installed."
                
                echo "" >> $LOG
                
                systemctl list-units --type=service --state=loaded | grep -i acronis >> $LOG
                
        else
                log "Storage Node installed."

                echo "" >> $LOG

                systemctl list-units --type=service --state=loaded | grep -i acronis >> $LOG
                
                echo "" >> $LOG

                log "Script execution has stopped."
                log "############################################"
                exit 1
                log "############################################"
        fi
fi

echo "" >> $LOG

log "############################################"
log "CyberBackup software installed!"
log "############################################"