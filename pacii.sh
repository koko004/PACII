#!/bin/sh
show_menu(){
    normal=`echo "\033[m"`
    menu=`echo "\033[36m"` #Blue
    number=`echo "\033[33m"` #yellow
    bgred=`echo "\033[41m"`
    fgred=`echo "\033[31m"`
    printf "\n${menu}*********************************************${normal}\n"
    printf "${menu}**${number} 1)${menu} Create a VM from template ${normal}\n"
    printf "${menu}**${number} 2)${menu} Download and create new Cloud Init Image Template ${normal}\n"
    printf "${menu}*********************************************${normal}\n"
    printf "Please enter a menu option and enter or ${fgred}x to exit. ${normal}"
    read opt
}

option_picked(){
    msgcolor=`echo "\033[01;31m"` # bold red
    normal=`echo "\033[00;00m"` # normal white
    message=${@:-"${normal}Error: No message passed"}
    printf "${msgcolor}${message}${normal}\n"
}

clear
show_menu
while [ $opt != '' ]
    do
    if [ $opt = '' ]; then
      exit;
    else
      case $opt in
        1) clear;
            option_picked "Option 1 Picked";
echo "Create new VM from template"
echo 'Whats is your TEMPLATE ID'
read TEMPLATEIDORIGIN
echo 'Set ID for new VM Machine'
read NEWMACHINEID
echo 'Set name for newm VM Machine'
read NEWMACHINENAME
#generating new machine
qm clone $TEMPLATEIDORIGIN $NEWMACHINEID --name $NEWMACHINENAME --full
           show_menu;
        ;;
        2) clear;
            option_picked "Option 2 Picked";
echo "Download and create Cloud Init Template"
#create new template
echo 'Paste your cloud-image download link below'
read IMAGEDOWNLOAD
echo 'Set VM-ID for template'
read TEMPLATEID
echo 'Set RAM'
read RAM
echo 'Set Cores'
read CORES
echo 'Set name for template'
read TEMPLATENAME

#wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
wget $IMAGEDOWNLOAD

#Set variable for downloaded image
DOWNLOADED=$(find . -type f -name '*.img')
echo "$DOWNLOADED"

#generating template
qm create $TEMPLATEID --memory $RAM --core $CORES --name $TEMPLATENAME --net0 virtio,bridge=vmbr0
qm importdisk $TEMPLATEID $DOWNLOADED local-lvm
qm set $TEMPLATEID --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$TEMPLATEID-disk-0
qm set $TEMPLATEID --ide2 local-lvm:cloudinit
qm set $TEMPLATEID --boot c --bootdisk scsi0
qm set $TEMPLATEID --serial0 socket --vga serial0
qm template $TEMPLATEID
            show_menu;
        ;;
        x)exit;
        ;;
        \n)exit;
        ;;
        *)clear;
            option_picked "Pick an option from the menu";
            show_menu;
        ;;
      esac
    fi
done
