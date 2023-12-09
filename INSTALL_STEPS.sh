#0. Подготовка ВМ

# apt-get update
# apt-get dist-upgarde
# update-kernel
# reboot

# remove-old-kernels
# apt-get autoremove
# apt-get clean

#systemctl mask suspend.target
#systemctl mask hibernate.target

# apt-get autoremove
# apt-get clean
# init 0

#0.1. Смена Machine-ID ВМ:
rm -f /etc/machine-id
dbus-uuidgen --ensure=/etc/machine-id
cat /etc/machine-id

#0.2. Настройка netplan ВМ (/etc/netplan/50-cloud-init.yaml)
network:
  version: 2
  renderer: networkd
  ethernets:
    alleths:
      match:
        name: en*
      dhcp4: true
      dhcp4-overrides:
        use-dns: false
        use-ntp: false
        use-hostname: false
        use-domains: false

#1. Подготовка ОС
#1.1. Подключить ОС к доступным репозиторием на площадке (Репозитории для тестового стенда):
echo -e "rpm [cert8] http://update.altsp.su/pub/distributions/ALTLinux CF2/branch/x86_64 classic  \nrpm [cert8] http://update.altsp.su/pub/distributions/ALTLinux CF2/branch/x86_64-i586 classic  \nrpm [cert8] http://update.altsp.su/pub/distributions/ALTLinux CF2/branch/noarch classic" >> /etc/apt/sources.list
echo -e "rpm [cert8] http://89.22.182.55/pub/distributions/ALTLinux CF2/branch/x86_64 classic  \nrpm [cert8] http://89.22.182.55/pub/distributions/ALTLinux CF2/branch/x86_64-i586 classic  \nrpm [cert8] http://89.22.182.55/pub/distributions/ALTLinux CF2/branch/noarch classic" >> /etc/apt/sources.list
apt-repo list

#1Репозитории также указываются в директории "/etc/apt/sources.list.d/":
/etc/apt/sources.list.d/altsp-C.list
rm -rf /etc/apt/sources.list.d/altsp-C.list

#1.2. Выполнить разметку диска для установки ПО (в команде указать второй диск - для определения диска, выполнить команду lsblk. По умолчанию - vdb):
pvcreate /dev/vdb && vgcreate vg_acr /dev/vdb && lvcreate -n lv_acr vg_acr -L 10G && lvcreate -n lv_acrlog vg_acr -L 50G && mkfs.ext4 /dev/mapper/vg_acr-lv_acr && mkfs.ext4 /dev/mapper/vg_acr-lv_acrlog && mkdir -p /var/lib/Acronis && mkdir -p /usr/lib/Acronis && echo "/dev/mapper/vg_acr-lv_acr /usr/lib/Acronis ext4 defaults 0 0" >> /etc/fstab && echo "/dev/mapper/vg_acr-lv_acrlog  /var/lib/Acronis ext4 defaults 0 0" >> /etc/fstab && mount -a

#1.3. Выполнить обновление пакетов и установку компонентов
#1.3.1. Выполнить обновление пакетов и установку стандратных компонентов:
apt-get update && apt-get -y dist-upgrade && apt-get -y install kernel-source-5.10 kernel-headers-modules-std-def gcc make java-sdk-1.8.0-openjdk && /usr/sbin/update-kernel -y

#1.3.2 Установка пакета для работы сценариев Python. Пакет необходим для запросов в БД ПО «Кибер Бэкап» и передачи информации в систему мониторинга: 
apt-get install -y python-modules-sqlite3 python-module-requests

#1.3.3. Установка дополнительных пакетов (Для работы с Bootable Media Builder без установки графического окружения на сервере управления или узле хранения):
apt-get install -y libXtst-devel libXi xauth

#1.3.4. Для проверки дополнительно можно установить приложение xclock:
apt-get install -y xclock

#1.3.5. Установка дополнительных шрифтов в ОС:
apt-get install -y fonts-ttf-ms
apt-get install --reinstall -y fonts-ttf-gnu-freefont-sans

#1.4.6. Выполнить перезагрузку ОС:
reboot

#1.4.7. Изменить конфигурацию /etc/openssh/sshd_config глобально для всех пользователей ОС:
sed 's/#X11Forwarding yes/X11Forwarding yes/1' /etc/openssh/sshd_config
systemctl restart sshd.service 

#2. Установка ПО "Кибер Бэкап"
#2.0. PAM (Предварительно загрузить)
#scp pam_listfile.so {USER}@{IP/FQDN}:/home/{USER} 

#2.1. Загрузить ПО Кибер Бэкап в директорию /root/ (или директорию пользователя ОС):
scp CyberBackup_16_64-bit.x86_64 {USER}@{IP/FQDN}:/home/{USER} 

#2.2. Загрузить файл "hosts" в директорию /etc/ и "hosts.altlinux.tmpl" /etc/cloud/templates/ соответсвенно.
scp hosts* {USER}@{IP/FQDN}:/home/{USER} 
mv /home/{USER}/hosts /etc/
mv /home/{USER}/hosts.altlinux.tmpl  /etc/cloud/templates/
#Добавление записей в ручную:
echo -e "\n#Management Server:\nIP FQDN\n\n#Storage Node:\nIP FQDN" >> /etc/hosts && echo -e "\n#Management Server:\nIP FQDN\n\n#Storage Node:\nIP FQDN" >> /etc/cloud/templates/hosts.altlinux.tmpl

#2.3. Запустить установку ПО "Кибер Бэкап":
#2.3.1. Applience Mode:
sh СyberBackup_15_64-bit.x86_64 -a -i AcronisCentralizedManagementServer,BackupAndRecoveryAgent,BackupAndRecoveryBootableComponents,StorageServer

#2.3.2.Management Server:
sh CyberBackup_15_64-bit.x86_64 -a -i AcronisCentralizedManagementServer,BackupAndRecoveryAgent,BackupAndRecoveryBootableComponents
sh CyberBackup_16_64-bit.x86_64 -a -i AcronisCentralizedManagementServer,BackupAndRecoveryAgent,BackupAndRecoveryBootableComponents

#2.3.3. Storage Node:
sh CyberBackup_15_64-bit.x86_64 -a --ams={IP/FQDN} --id=BackupAndRecoveryAgent,StorageServer,BackupAndRecoveryBootableComponents
sh CyberBackup_16_64-bit.x86_64 -a --ams={IP/FQDN} --id=BackupAndRecoveryAgent,StorageServer,BackupAndRecoveryBootableComponents

#2.3.4. Agent:
sh CyberBackup_15_64-bit.x86_64 -a --ams={IP/FQDN} --id=BackupAndRecoveryAgent,BackupAndRecoveryBootableComponents
sh CyberBackup_16_64-bit.x86_64 -a --ams={IP/FQDN}--id=BackupAndRecoveryAgent,BackupAndRecoveryBootableComponents

#2.3.5. Удаление ПО 
/usr/lib/Acronis/BackupAndRecovery/uninstall/uninstall

#2.4. Замена pam_listfile.
#2.4.1. Создать резервную копию исходного файла
#mv /lib64/security/pam_listfile.so /lib64/security/_pam_listfile.so
#2.4.1. Выполнить замену на цеелвой файл (Для авторизации в консоли управления).
#mv pam_listfile.so /lib64/security