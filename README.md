# NOTE: ReginOS (SteamOS like distro)
Working on a SteamOS like Arch distro that will be a much better option.<br>
Follow ReignOS discord when announcement is ready: [Discord Link](https://disboard.org/server/1344845464175902750)<br>
ReignOS website: [Link](http://reign-studios.com/ReignOS/)

# Installing MSI-Claw-Gamepad-Mode
* Install CachyOS (see below) [recomended]
* Run ```sudo ./install.sh``` on a CachyOS install
* Restart computer
* Gamepade mode should now be working in Steam games, Chrome browser, CachyOS or Ubuntu like distros etc.

# Important notes
* Install script is tested on CachyOS and will try to install everything needed
* Install script also adds a fix to make WiFi work again after sleep
* Install script will install InputPlumber which is needed for menu buttons
* CachyOS is probably the best option atm.
* NOTE: You may want to install a virtual/touch keyboard for desktop & enable it in KDE: "sudo pacman -S maliit-keyboard"
* For other Arch distros there is also this DKMS driver option as well but less tested: https://aur.archlinux.org/packages/hid-msi-claw-dkms-git

# Installing on CachyOS handheld-edition
* Disable Secure-Boot in BIOS
* Install using a USB hub that DOES NOT support HDMI if possible as they sometimes have issues
* Reboot computer using keyboard and mouse to sign into Steam
* Navigate to ```Menu->Power->Switch to Desktop```
* Install this package and reboot

### CachyOS desktop-edition
* Disable Secure-Boot in BIOS
* Run ```install.sh --desktop``` script and reboot (this should configure & install most everything needed)
* Configure Steam to auto start and start in Big-Picture mode
    * If you have an MicroSD card, format it using "KDE Partition Manager" as "btrfs"

# Benchmark (Shadow of the Tomb Raider)
* Win11 24H2: Avg FPS 63 (XeSS Balanced setting)
* CachyOS (12/22/2024): Avg FPS 67 (FSR Balanced on rez slider)