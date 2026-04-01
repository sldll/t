#!/bin/bash
set -euo pipefail

sleep 0.2


#sed -i 's|command=date.*|command=date +%a\\ %b\\ %d,\\ %H:%M|' /etc/i3blocks.conf
#mkdir /home/$USERNAME/bak
#
#cp /etc/xdg/foot/foot.ini /home/$USERNAME/bak/foot.ini.bak
#cp /etc/sway/config /home/$USERNAME/bak/config.bak 
#cp /etc/i3blocks.conf /home/$USERNAME/bak/i3blocks.conf.bak 
#
#sed -i '1s/^/font=terminus:size=14\n/' /etc/xdg/foot/foot.ini
#sed -i '1s/^/pad=45x45\n/' /etc/xdg/foot/foot.ini
#
#sed -i '1s/^/output eDP-1 resolution 1920x1080 position 0 0\n/' /etc/sway/config
#sed -i '1s/^/output HDMI-A-1 resolution 1920x1080 position 1920 0\n/' /etc/sway/config
#sed -i '1s/^/exec_always gammastep -P -O 3900\n/' /etc/sway/config
#sed -i '1s/^/workspace_auto_back_and_forth yes\n/' /etc/sway/config
#sed -i '1s/^/hide_edge_borders smart\n/' /etc/sway/config
#sed -i '1s/^/default_border pixel 2\n/' /etc/sway/config
#sed -i '1s/^/input type:keyboard {\n    xkb_options "caps:escape_shifted_capslock"\n}\n/' /etc/sway/config
#
#sed -i 's/position top/position bottom/' /etc/sway/config
#sed -i 's/mod+f fullscreen/mod+f layout toggle tabbed split/' /etc/sway/config
#sed -i 's/Mod4/Mod1/' /etc/sway/config
#sed -i 's/mod+Shift+q/mod+c/' /etc/sway/config
#sed -i 's/menu wmenu-run/menu rofi -show drun -show-icons/' /etc/sway/config
#
#sed -i '\|share/back|d' /etc/sway/config
#
#sed -i 's/$/XF86Audio/ && pkill -RTMIN+1 i3blocks|' /etc/sway/config
#
#sed -i '/mod+w/c\bindsym Mod1+w exec firefox' /etc/sway/config
#sed -i '/mod+space/c\bindsym Mod1+space exec waylock -fork-on-lock -ignore-empty-password  -init-color 0x000000 -input-color 0x000000' /etc/sway/config
#sed -i '/status_command/c\status_command i3blocks' /etc/sway/config
#sed -i '/statusline/c\statusline #11917F' /etc/sway/config
#
#sed -i '/position bottom/a\font pango:terminus 20' /etc/sway/config
#sed -i '/background/c\background #181818' /etc/sway/config
#sed -i '/term foot/a\bindsym Mod1+Tab workspace back_and_forth' /etc/sway/config
#sed -i '/term foot/a\bindsym --locked KP_Add exec playerctl play-pause' /etc/sway/config
#sed -i '/term foot/a\bindsym Mod1+z floating toggle' /etc/sway/config


echo
echo "🥵💀🥵💀🥵💀🥵💀🥵💀🥵💀🥵💀🥵💀🥵💀🥵💀🥵💀🥵💀"
echo

HOST=ubuntu
CNTRY=NL
R="Europe/Amsterdam"
DOT=dot

HDD=nvme0n1
DISK="/dev/$HDD"
EX=p
CR=crt
SIZE1=+500M
SIZE2=+80G
SIZE3=

read -rp "user: " USERNAME
while true; do
    read -rsp "pswd: " PASSWORD
    echo
    read -rsp "pswd: " PASSWORD_CONFIRM
    echo
    if [ "$PASSWORD" = "$PASSWORD_CONFIRM" ]; then
        break
    else
        echo "pswd mismatch"
    fi
done

#sgdisk -Z $DISK
#sgdisk -o $DISK

#sgdisk -n 1::$SIZE1 -t 1:EF00 -c 1:"EFI" $DISK
#sgdisk -n 2::$SIZE2 -t 2:8300 -c 2:"ROOT" $DISK
#sgdisk -n 3::$SIZE3 -t 3:8300 -c 3:"B" $DISK

reflector -c "$CNTRY" -p https --age 4 --latest 15 --save /etc/pacman.d/mirrorlist

sed -i 's/#Color/Color\nILoveCandy/' /etc/pacman.conf
sed -i 's/^SigLevel.*/SigLevel = Never/' /etc/pacman.conf

cryptsetup luksFormat --batch-mode ${DISK}${EX}2
cryptsetup luksOpen ${DISK}${EX}2 $CR

mkfs.fat ${DISK}${EX}1
mkfs.ext4 /dev/mapper/$CR

mount /dev/mapper/$CR /mnt
mount -o umask=0077 -m ${DISK}${EX}1 /mnt/boot

fallocate -l 8G /mnt/sf
chmod 600 /mnt/sf
mkswap /mnt/sf
swapon -p 10 /mnt/sf

pacstrap -KP /mnt base

genfstab -U /mnt >> /mnt/etc/fstab

echo
lsblk

read -n 1 -s -r -p "base installed. going into chroot. press key"

arch-chroot /mnt bash <<😈
set -e

pacman -S --noconfirm mkinitcpio

sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect microcode modconf keyboard block encrypt filesystems)/' /etc/mkinitcpio.conf

curl -LO https://github.com/sldll/s/raw/main/p
grep -v '^\s*#' p | pacman -S --needed --noconfirm -

echo "root:$PASSWORD" | chpasswd

useradd -mG wheel $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

sed -i 's/fmask=0022,dmask=0022/umask=0077/' /etc/fstab
sed -i '/\bext4\b/ s/\brelatime\b/noatime/g' /etc/fstab

bootctl install
echo "title ubuntu" >> /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options cryptdevice=/dev/${DISK}${EX}2:$CR root=/dev/mapper/$CR rw" >> /boot/loader/entries/arch.conf

echo "[zram0]" >> /etc/systemd/zram-generator.conf
echo "zram-size = ram / 2" >> /etc/systemd/zram-generator.conf
echo "compression-algorithm = lz4" >> /etc/systemd/zram-generator.conf
echo "swap-priority = 100" >> /etc/systemd/zram-generator.conf

mkdir -p /etc/systemd/coredump.conf.d/
echo "[Coredump]" >> /etc/systemd/coredump.conf.d/custom.conf
echo "Storage=none" >> /etc/systemd/coredump.conf.d/custom.conf
echo "ProcessSizeMax=0" >> /etc/systemd/coredump.conf.d/custom.conf

echo "vm.swappiness=60" >> /etc/sysctl.d/99-swappiness.conf

echo "$HOST" >> /etc/hostname

ln -sf /usr/share/zoneinfo/$R /etc/localtime
hwclock --systohc

systemctl enable NetworkManager
systemctl enable fstrim.timer

su - $USERNAME -c 'mkdir $DOT && cd $DOT && git clone https://github.com/sldll/s . &&  stow . --adopt --no-folding && git restore .'

echo
echo "🥵💀🥵💀🥵💀🥵💀🥵💀🥵💀🥵💀🥵💀🥵💀🥵💀🥵💀🥵💀"
echo

😈
