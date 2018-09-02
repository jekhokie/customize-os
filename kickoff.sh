#!/usr/bin/env bash

# vars
depsDir=broadcom-deps
broadcomFwCutter=b43-fwcutter_019-2_amd64.deb
broadcomWl=broadcom-wl-5.100.138.tar.bz2

# ensure the script is run as root
if [[ `whoami` != "root" ]]; then
    echo "Must run this script as root/with sudo - please try again."
    exit 1
fi

# install Broadcom wifi drivers (i.e. older desktops with Ubuntu 16+)
echo "Do you need to install Broadcom drivers for your Wifi?"
echo -n "These steps would be for Ubuntu 16.04 on a Dell XPS 420 system [y/n]: "
read needBroadcom

if [[ $needBroadcom =~ [y|Y] ]]; then
    mkdir $depsDir
    echo "Please download the following packages and place them into the broadcom-deps/ directory in this"
    echo "current directory (where this script is being run from)"
    echo "    http://ftp.us.debian.org/debian/pool/contrib/b/b43-fwcutter/$broadcomFwCutter"
    echo "    http://www.lwfinger.com/b43-firmware/$broadcomWl"
    read -p "PRESS ENTER WHEN PACKAGES ARE IN PLACE"

    echo "Installing required drivers and dependencies..."
    apt-get purge bcmwl-kernel-source
    dpkg -i $depsDir/$broadcomFwCutter
    tar xfvj $depsDir/$broadcomWl
    b43-fwcutter -w /lib/firmware broadcom-wl-5.100.138/linux/wl_apsta.o
    modprobe b43

    echo "Drivers have been installed - please connect to your wifi network"
    echo "using the GUI options and press Enter when ready to proceed"
    read -p "PRESS ENTER WHEN READY TO PROCEED..."
elif [[ $needBroadcom =~ [n|N] ]]; then
    echo "Skipping Broadcom driver installation."
else
    echo "Must choose either 'y/Y' or 'n/N' - please try again."
    exit 1
fi

# ensure network connectivity is present
ping -c 1 www.google.com 2>&1 >/dev/null
if [ $? -eq 0 ]; then
    echo "Successfully tested network connectivity - proceeding."
else
    echo "Network connectivity could not be verified - please double-check your network connection."
    echo "Note if you just installed Broadcom drivers you may need to reboot your machine."
    exit 1
fi

# install Ansible to prepare for package installation and customization
dpkg -l ansible 2>&1 >/dev/null
if [ $? -eq 0 ]; then
    echo "Ansible is already installed - proceeding"
else
    echo "Installing Ansible for further customization..."
    apt-get -y install ansible
    echo "Ansible install successful."
fi

# figure out what user to customize for and where the user is located
echo "What user ID would you like to configure for (jkarimi)?: "
read userId

# check if the user exists
userProps=$(getent passwd $userId)
if [ $? -ne 0 ]; then
    echo "No user '${userId}' found - please try again."
    exit 1
fi

userHome=$(echo ${userProps} | cut -d: -f6)
if [ $? -ne 0 ]; then
    echo "Could not find home directory for user '${userId}' - please try again."
    exit 1
fi

# install desired packages
echo "Customizing your Operating System installation via Ansible..."
ansible-playbook provision-local.yml --extra-vars "user_id=${userId} user_home=${userHome}"
