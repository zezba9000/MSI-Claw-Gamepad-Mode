# validate root access
if [[ $EUID -ne 0 ]]; then
    echo "You must run this script with sudo"
    exit 1
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
 KEYBOARD_KEY_b9=f15  #Right Button
 KEYBOARD_KEY_ba=f16  #Left Button
EOF'

# install menu buttons config systemd
echo ""
echo "Install menu buttons config for systemd..."
CONFIG=/etc/systemd/hwdb.d/60-keyboard.hwdb
if [ -e "$CONFIG" ]; then
    echo "Menu-Button systemd Config already exists '$CONFIG'"
else
    mkdir "/etc/systemd/hwdb.d"
    echo "Creating systemd Menu-Button config file '$CONFIG'"
    touch $CONFIG
fi

echo "Updating Menu-Button systemd config"
bash -c 'cat > /etc/systemd/hwdb.d/60-keyboard.hwdb << '\''EOF'\''
###########################################################
# MSI (aka "Micro Star")
###########################################################

evdev:atkbd:dmi:bvn*:bvr*:bd*:svnMICRO-STAR*:pn*:*
evdev:atkbd:dmi:bvn*:bvr*:bd*:svnMicro-Star*:pn*:*
 KEYBOARD_KEY_76=f21                                    # Toggle touchpad, sends meta+ctrl+toggle
 KEYBOARD_KEY_91=config                                 # MSIControl Center
 KEYBOARD_KEY_a0=mute                                   # Fn+F9
 KEYBOARD_KEY_ae=volumedown                             # Fn+F7
 KEYBOARD_KEY_b0=volumeup                               # Fn+F8
 KEYBOARD_KEY_b2=www                                    # e button
 KEYBOARD_KEY_c2=ejectcd
 KEYBOARD_KEY_df=sleep                                  # Fn+F12
 KEYBOARD_KEY_e2=bluetooth                              # satellite dish2
 KEYBOARD_KEY_e4=f21                                    # Fn+F3 Touchpad disable
 KEYBOARD_KEY_ec=email                                  # envelope button
 KEYBOARD_KEY_ee=camera                                 # Fn+F6 camera disable
 KEYBOARD_KEY_f1=f20                                    # Microphone mute
 KEYBOARD_KEY_f2=rotate_display                         # Rotate screen
 KEYBOARD_KEY_f6=wlan                                   # satellite dish1
 KEYBOARD_KEY_f7=brightnessdown                         # Fn+F4
 KEYBOARD_KEY_f8=brightnessup                           # Fn+F5
 KEYBOARD_KEY_f9=search

evdev:atkbd:dmi:bvn*:bvr*:bd*:svnMICRO-STAR*:pnGE60*:*
evdev:atkbd:dmi:bvn*:bvr*:bd*:svnMICRO-STAR*:pnGE70*:*
 KEYBOARD_KEY_c2=ejectcd

# some MSI models generate ACPI/input events on the LNXVIDEO input devices,
# plus some extra synthesized ones on atkbd as an echo of actually changing the
# brightness; so ignore those atkbd ones, to avoid loops
evdev:atkbd:dmi:bvn*:bvr*:bd*:svnMICRO-STAR*:pn*U-100*:*
evdev:atkbd:dmi:bvn*:bvr*:bd*:svnMICRO-STAR*:pn*U100*:*
evdev:atkbd:dmi:bvn*:bvr*:bd*:svnMICRO-STAR*:pn*N033:*
evdev:atkbd:dmi:bvn*:bvr*:bd*:svnMicro-Star*:pn*VR420*:*
evdev:atkbd:dmi:bvn*:bvr*:bd*:svnMicro-Star*:pn*PR200*:*
 KEYBOARD_KEY_f7=reserved
 KEYBOARD_KEY_f8=reserved

# MSI Wind U90/U100 generates separate touchpad on/off keycodes so ignore touchpad toggle keycode.
# Also ignore Wi-Fi and Bluetooth keycodes, because they are generated when the HW rfkill state
# changes, but the userspace also toggles the SW rfkill upon receiving these keycodes.
evdev:atkbd:dmi:bvn*:bvr*:bd*:svnMICRO-STAR*:pnU90/U100:*
 KEYBOARD_KEY_e4=unknown
 KEYBOARD_KEY_e2=unknown
 KEYBOARD_KEY_f6=unknown

# Keymaps MSI Prestige And MSI Modern FnKeys and Special keys
evdev:atkbd:dmi:bvn*:bvr*:bd*:svnMicro-Star*:pn*Prestige*:*
evdev:atkbd:dmi:bvn*:bvr*:bd*:svnMicro-Star*:pn*Modern*:*
 KEYBOARD_KEY_91=prog1                                  # Fn+F7 Creation Center, sometime F7
 KEYBOARD_KEY_f2=prog2                                  # Fn+F12 Screen rotation
 KEYBOARD_KEY_8d=prog3                                  # Fn+A Change True Color selections
 KEYBOARD_KEY_8c=prog4                                  # Fn+Z Launch True Color
 KEYBOARD_KEY_f5=fn_esc                                 # Fn+esc Toggle the behaviour of Fn keys
 KEYBOARD_KEY_97=unknown                                # Lid close
 KEYBOARD_KEY_98=unknown                                # Lid open

evdev:name:MSI Laptop hotkeys:dmi:bvn*:bvr*:bd*:svn*:pnM[iI][cC][rR][oO]-S[tT][aA][rR]*:*
 KEYBOARD_KEY_0213=f22
 KEYBOARD_KEY_0214=f23

# MSI Claw
evdev:name:AT Translated Set 2 keyboard:dmi:*:svnMicro-StarInternationalCo.,Ltd.:pnClawA1M:*
 KEYBOARD_KEY_b9=f15                                   # Right Face Button
 KEYBOARD_KEY_ba=f16                                   # Left Face Button
EOF'

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