# validate root access
if [[ $EUID -ne 0 ]]; then
    echo "You must run this script with sudo"
    exit 1
fi

# check if desktop mode enabled
DESKTOP=false  # Default value

# Iterate over all arguments
for arg in "$@"; do
  case "$arg" in
    --desktop)
      DESKTOP=true
      shift    # Remove this argument from the list
      ;;
    *)
      # Optionally handle other arguments
      ;;
  esac
done

# install dependencies
echo "Installing dependencies"
pacman -Syu
echo "Installing GCC..."
pacman -S gcc
echo "Installing InputPlumber..."
pacman -S inputplumber

if [ "$DESKTOP" = true ]; then
    echo "Installing Steam..."
    pacman -S steam
    echo "Installing Disk manager..."
    pacman -S partitionmanager
fi

# install virtual keybaord
echo "Installing Virtual Keyboard..."
pacman -S maliit-keyboard
kwriteconfig6 --file kcminputrc --group OnScreenKeyboard --key Enabled true
kwriteconfig6 --file kcminputrc --group OnScreenKeyboard --key PreferredProvider maliit

# force auto-login
if [ "$DESKTOP" = true ]; then
    echo "Enable auto-login"
    CONFIG=/etc/sddm.conf.d/login.conf
    touch $CONFIG
    bash -c "cat > $CONFIG <<EOF
    [Autologin]
    User=$SUDO_USER
    Session=plasma
    Relogin=false
    EOF"
fi

# disable asking KDE questions
if [ "$DESKTOP" = true ]; then
    echo "Disable asking KDE questions"
    kwriteconfig6 --file ksmserverrc --group General --key loginMode default
    kwriteconfig6 --file ksmserverrc --group General --key confirmLogout false
    kwriteconfig6 --file ksmserverrc --group General --key logoutPrompt false
    kwriteconfig6 --file ksmserverrc --group General --key offerShutdown false
fi

# always mount drives
if [ "$DESKTOP" = true ]; then
    echo "Always mount drives"
    kwriteconfig6 --file kded_device_automounterrc --group General --key AutomountEnabled true
    kwriteconfig6 --file kded_device_automounterrc --group General --key AutomountOnLogin true
    kwriteconfig6 --file kded_device_automounterrc --group General --key AutomountOnAttached true
fi

# compile HID mode app
echo "Compiling HID mode app..."
gcc -o2 main.c -o msi-claw-gamepad-mode

# invoke HID mode app
echo "Coping service app to /.MSI-Claw"
mkdir "/.MSI-Claw"
cp ./msi-claw-gamepad-mode /.MSI-Claw/msi-claw-gamepad-mode
chown root /.MSI-Claw/msi-claw-gamepad-mode
chmod u+x /.MSI-Claw/msi-claw-gamepad-mode
~/.MSI-Claw/msi-claw-gamepad-mode

# install xpad config
echo ""
echo "Install xpad config..."
CONFIG=/etc/udev/rules.d/90-msi-claw.rules
if [ -e "$CONFIG" ]; then
    echo "xPad Config already exists '$CONFIG'"
else
    echo "Creating xPad config file '$CONFIG'"
    touch $CONFIG
fi

echo "Updating xPad config"
bash -c 'cat > /etc/udev/rules.d/90-msi-claw.rules << '\''EOF'\''
ATTRS{idVendor}=="0db0", ATTRS{idProduct}=="1901", RUN+="/sbin/modprobe xpad" RUN+="/bin/sh -c '\''echo 0db0 1901 > /sys/bus/usb/drivers/xpad/new_id'\''"
EOF'

# install menu buttons config
echo ""
echo "Install menu buttons config..."
CONFIG=/usr/lib/udev/hwdb.d/60.msi.hwdb
if [ -e "$CONFIG" ]; then
    echo "Menu-Button Config already exists '$CONFIG'"
else
    echo "Creating Menu-Button config file '$CONFIG'"
    touch $CONFIG
fi

echo "Updating Menu-Button config"
bash -c 'cat > /usr/lib/udev/hwdb.d/60.msi.hwdb << '\''EOF'\''
evdev:name:AT Translated Set 2 keyboard:dmi:*:svnMicro-StarInternationalCo.,Ltd.:pnClawA1M:*
 KEYBOARD_KEY_b9=f16  #Right Button (flipped until InputPlumber is fixed [should be F15])
 KEYBOARD_KEY_ba=f15  #Left Button (flipped until InputPlumber is fixed [should be F16])
EOF'

echo "Starting InputPlumber"
systemctl enable inputplumber
systemctl enable inputplumber-suspend
systemctl start inputplumber

# install HID trigger service
echo ""
echo "Installing HID trigger service..."
CONFIG=/etc/systemd/system/msi-claw-gamepad.service
if [ -e "$CONFIG" ]; then
    echo "Service config already exists '$CONFIG'"
else
    echo "Creating Service config file '$CONFIG'"
    touch $CONFIG
fi

echo "Updating Service config"
bash -c 'cat > /etc/systemd/system/msi-claw-gamepad.service << '\''EOF'\''
[Unit]
Description=MSI Claw Gamepad mode switch
After=multi-user.target suspend.target

[Service]
Type=simple
ExecStartPre=/usr/bin/sleep 2
ExecStart=/.MSI-Claw/msi-claw-gamepad-mode
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target suspend.target
EOF'

# Add WiFi not working after sleep fix
echo ""
echo "Adding WiFi after sleep fix..."
CONFIG=/usr/lib/systemd/system-sleep/iwlwifi-sleep.sh
if [ -e "$CONFIG" ]; then
    echo "WiFi service already exists '$CONFIG'"
else
    echo "WiFi Service config file '$CONFIG'"
    touch $CONFIG
fi

echo "Updating WiFi Service config"
bash -c 'cat > /usr/lib/systemd/system-sleep/iwlwifi-sleep.sh << '\''EOF'\''
#!/bin/bash

case "$1" in
  pre)
    /usr/sbin/modprobe -r iwlmvm iwlwifi
    ;;
  post)
    /usr/sbin/modprobe iwlwifi iwlmvm
    ;;
esac
EOF'
chmod +x $CONFIG

# finish
echo "Reloading systemd stuff..."
systemd-hwdb update
udevadm trigger
udevadm trigger /dev/input/event*
systemctl enable msi-claw-gamepad.service
systemctl daemon-reload
systemctl restart msi-claw-gamepad.service
echo "Service is enabled?"
systemctl is-enabled msi-claw-gamepad.service

# done
echo ""
echo "NOTE: You should now reboot device"