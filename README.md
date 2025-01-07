# Installing MSI-Claw-Gamepad-Mode
* Install CachyOS (see below) [recomended]
* Run "sudo ./install.sh" on a CachyOS install
* Restart computer
* Gamepade mode should now be working in Steam games, Chrome browser, CachyOS or Ubuntu like distros etc.<br>

# Important notes
* Install script is tested on CachyOS and will try to install everything needed<br>
* Install script also adds a fix to make WiFi work again after sleep<br>
* Install script will install InputPlumber which is needed for menu buttons<br>
* CachyOS is probably the best option atm.<br>
* NOTE: You may want to install a virtual/touch keyboard for desktop & enable it in KDE: "sudo pacman -S maliit-keyboard"
* For other Arch distros there is also this DKMS driver option as well but less tested: https://aur.archlinux.org/packages/hid-msi-claw-dkms-git

# Installing on a Gamescope distro like CachyOS handheld-edition
* Disable Secure-Boot in BIOS
* Install using a USB hub that DOES NOT support HDMI if possible as they sometimes have issues
* Reboot computer using keyboard and mouse to sign into Steam
* Navigate to "Menu->Power->Switch to Desktop"
* Install this package and reboot

### CachyOS desktop-edition
* Install so the device auto logs in without needing a password
* Install a touchscreen keyboard with: "sudo pacman -S maliit-keyboard" then in Virtual Keyboard settings enable it within KDE
* Install Steam with: "sudo pacman -S steam"
* Configure Steam to auto start and start in Big-Picture mode

# Benchmark (Shadow of the Tomb Raider)
* Win11 24H2: Avg FPS 63 (XeSS Balanced setting)
* CachyOS (12/22/2024): Avg FPS 67 (FSR Balanced on rez slider)