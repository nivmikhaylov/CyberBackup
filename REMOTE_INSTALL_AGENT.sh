#!/bin/bash

AGENTS="/mnt/CYBERPROTECT/AGENTS/ALLOW_UPDATE_AGENT"
D_PATH="/mnt/CYBERPROTECT"

KERNEL_NAME=$(uname -s)
HW_NAME=$(uname -m)
HOSTNAME=$(hostname)

TIME=$(date +"%y-%m-%d %T")
INSTALL_LOG="/mnt/CYBERPROTECT/LOGS/$(hostname)_REMOTE_INSTALL_AGENT.log"

PING_HOST="update.altsp.su"
PACKAGES_ALT="gcc make kernel-source-5.10 kernel-headers-modules-std-def"

CONNECT_SERVER="/opt/acronis/var/aakore/reg.yml"
CURRENT_VERSION="/mnt/Acronis_Update/BackupAndRecovery_version.txt"
LOCAL_VERSION="/var/lib/Acronis/BackupAndRecovery_version.txt"

log(){
   message="$(date +"%y-%m-%d %T") $@"
   echo $message
   echo $message >>$INSTALL_LOG
}

function ping_check
{
ping -q -c 2 -W 1 $PING_HOST
ping_status= echo $?
}

echo "############################################"
echo "Mount remote reposiroty..."
mkdir /mnt/CYBERPROTECT
mount -t nfs 10.60.17.131:/backup_infra/CYBERPROTECT /mnt/CYBERPROTECT
echo "############################################"

echo "" >> $INSTALL_LOG

log "############################################"
log "############################################"
log "Remote reposiroty connect..."

echo "" >> $INSTALL_LOG

log "$(mount | grep /mnt/CYBERPROTECT)" >> $INSTALL_LOG

echo "" >> $INSTALL_LOG

log "############################################" >> $INSTALL_LOG

echo "" >> $INSTALL_LOG

log "############################################"
log "Checking who is running the script.."
log "############################################"

echo "" >> $INSTALL_LOG

if [ "$(id -u)" != "0" ];
then
        log "This script must be run as root!"
        log "############################################"
        exit 1
else
        log "Thist script run as root. Runing next steps..."
fi

echo "" >> $INSTALL_LOG

log "############################################"
log "Stage 0. Checking OS"
log "############################################"

echo "" >> $INSTALL_LOG

log "Agent: $(hostname)"

echo "" >> $INSTALL_LOG

hostnamectl >> $INSTALL_LOG

echo "" >> $INSTALL_LOG

timedatectl >> $INSTALL_LOG

echo "" >> $INSTALL_LOG

lscpu >> $INSTALL_LOG

echo "" >> $INSTALL_LOG

lsmem >> $INSTALL_LOG

echo "" >> $INSTALL_LOG

lsblk -l -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT,PARTLABEL,UUID | sort -V >> $INSTALL_LOG

echo "" >> $INSTALL_LOG

df --output=source,size,used,avail,pcent,target >> $INSTALL_LOG

echo "" >> $INSTALL_LOG

sleep 10

log "############################################"
log "Stage 1. Search installed packages on Linux System..."
log "############################################"

echo "" >> $INSTALL_LOG

if [ "$KERNEL_NAME" = "Linux" -a "$HW_NAME" = "x86_64" ]
then
        
        if [ "$(grep -iE "ALT" /etc/*release)" ]
        then

        for PACKAGE_ALT in $PACKAGES_ALT
        do
        PACKAGE=`rpm -qa $PACKAGE_ALT | grep $PACKAGE_ALT `
                if [ -n "$PACKAGE" ]
                then
                        log "$PACKAGE_ALT installed"
                        
                        echo "" >> $INSTALL_LOG
                
                else
                        log "$PACKAGE_ALT not installed"
                        
                        echo "" >> $INSTALL_LOG
                                if !(ping_check = 0); 
                                then
                                        echo -e "rpm [cert8] http://89.22.182.55/pub/distributions/ALTLinux CF2/branch/x86_64 classic  \nrpm [cert8] http://89.22.182.55/pub/distributions/ALTLinux CF2/branch/x86_64-i586 classic  \nrpm [cert8] http://89.22.182.55/pub/distributions/ALTLinux CF2/branch/noarch classic" >> /etc/apt/sources.list
                                fi
                        apt-get install -y "$PACKAGE_ALT" >> $INSTALL_LOG
                        sed -i '/89.22.182.55/,$d' /etc/apt/sources.list
                fi
        done
        
        fi

else
        OS_VERSION=notsupported

fi

echo "" >> $INSTALL_LOG

log "############################################"
log  "Stage 3. Install Software"
log "############################################"

echo "" >> $INSTALL_LOG

if ! systemctl list-units --type=service --state=loaded | grep -i "Acronis Agent Core Service";
        then
                log "Agent not installed."
                
                echo "" >> $INSTALL_LOG
                
                log "Installation Agent..."

                echo "" >> $INSTALL_LOG

                sh /mnt/CYBERPROTECT/CyberBackup_16_64-bit.x86_64 -a --ams=SR-BMS --id=BackupAndRecoveryAgent,BackupAndRecoveryBootableComponents >> $INSTALL_LOG

                echo "" >> $INSTALL_LOG
                
                log "Agent installed."
                
                echo "" >> $INSTALL_LOG
                
                systemctl list-units --type=service --state=loaded | grep -i acronis >> $INSTALL_LOG

                echo "" >> $INSTALL_LOG

                log "$(grep server $CONNECT_SERVER)"

                echo "" >> $INSTALL_LOG
                
        else
                log "Agent installed."

                echo "" >> $INSTALL_LOG

                systemctl list-units --type=service --state=loaded | grep -i acronis >> $INSTALL_LOG
                
                echo "" >> $INSTALL_LOG

                log "$(grep server $CONNECT_SERVER)"

                echo "" >> $INSTALL_LOG

                log "Script execution has stopped."
                log "############################################"
                exit 1
                log "############################################"
fi

echo "" >> $INSTALL_LOG

log "Unmount NFS..."

sleep 10

log "$(lsof /mnt/CYBERPROTECT)"

umount -l $D_PATH

sleep 10

echo "Script execution has stopped."