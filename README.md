# MSI-Claw-Gamepad-Mode
* Install base dev package on your distro that includes gcc
* chmod 777 ./install.sh
* Run "sudo ./install.sh" on any distro that supports systemd
* Restart computer

# Important notes
* Gamepade mode should now be working in Steam games, Chrome browser, CachyOS or Ubuntu like distros etc.<br>
* Install script also adds a fix to make WiFi work again after sleep<br>
* CachyOS is probably the best option atm.<br>
* For other Arch distros there is also this DKMS driver option as well but less tested: https://aur.archlinux.org/packages/hid-msi-claw-dkms-git

# Installing on a Gamescope distro like CachyOS handheld-edition
* Install using a USB hub that DOES NOT support HDMI
* Reboot computer using keyboard and mouse to sign into Steam
* Navigate to "Menu->Power->Switch to Desktop"
* Install this package and reboot

# Benchmark (Shadow of the Tomb Raider)
* Win11 24H2: Avg FPS 63 (XeSS Balanced setting)
* CachyOS (12/22/2024): Avg FPS 67 (FSR Balanced on rez slider)