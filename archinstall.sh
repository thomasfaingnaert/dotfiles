#!/usr/bin/env bash
set -Eeuo pipefail

# Coloured xtrace-like output.
# Inspired by: https://stackoverflow.com/questions/26067916/colored-xtrace-output
rm -f commands.log
do_debug=0
debug_on() { do_debug=1; }
debug_off() { do_debug=0; }
debug() {
    [[ "$do_debug" == "1" ]] || return 0

    # Print coloured current command.
    printf '\n\033[0;36m>>> %s\033[0m\n' "$BASH_COMMAND" >&2

    # Write command to file.
    printf '%s\n' "$BASH_COMMAND" >>commands.log
}

set -o functrace
shopt -s extdebug
trap debug DEBUG

# logging
log()  { echo -e "\033[0;36m[LOG]\033[0m $1" >&2; }
warn() { echo -e "\033[0;33m[WRN]\033[0m $1" >&2; }
err()  { echo -e "\033[0;31m[ERR]\033[0m $1" >&2; }
die()  { err "$1"; exit 1; }

confirm() {
    read -p "$1 [yN] " -n1 -r && echo
    [[ "$REPLY" =~ ^[Yy]$ ]] || exit 1
}

# (1.6 - 1.8) Tests.
[[ "$(cat /sys/firmware/efi/fw_platform_size)" == "64" ]] || die "You are not booted using UEFI 64-bit"
ping -c1 archlinux.org &>/dev/null || die "No internet connection"
timedatectl | grep -q "System clock synchronized: yes" || die "Clock not synchronised"

# (1.9 - 1.11) Disk partitioning, formatting, and mounting.
choose_disk() {
    lsblk --list -o PATH,MODEL,SIZE,TYPE | awk 'NR==1 || /disk/'
    echo

    PS3="Select disk to install to: "
    select DISK in $(lsblk --noheadings --list -o PATH,TYPE | awk '$2 == "disk" { print $1 }'); do
        for file in /dev/disk/by-id/*; do
            if [[ "$(realpath "$file")" == "$DISK" ]]; then
                DISK="$file"
                [[ -e "$DISK" ]] && break 2
            fi
        done
    done
}

cat <<EOF
Available partitioning schemes:

premounted      Partitioning, formatting, and mounting already done. (/mnt)
ext4            Wipe disk: EFI | swap | ext4 (/)

EOF

PS3="Select partitioning scheme: "
select PART_SETUP in premounted ext4; do
    case "$PART_SETUP" in
        ext4)
            choose_disk

            echo "Will install to $DISK (-> $(realpath "$DISK"))."
            confirm "Are you sure? All data will be wiped."

            SWAP_SIZE=$(awk '/MemTotal/ { print $2 * 2 }' /proc/meminfo)

            ESP_PART_NR="1"

            ESP_PART="$DISK-part1"
            SWAP_PART="$DISK-part2"
            ROOT_PART="$DISK-part3"

            debug_on

            # Wipe disk.
            wipefs -af $DISK
            sgdisk -Zo $DISK

            # Partitioning.
            sgdisk -n 1:0:+1G            -t 1:EF00 $DISK # EFI
            sgdisk -n 2:0:+"$SWAP_SIZE"K -t 2:8200 $DISK # swap
            sgdisk -n 3:0:0              -t 3:8304 $DISK # root

            partprobe $DISK

            # Formatting.
            mkfs.fat -F32 $ESP_PART
            mkswap $SWAP_PART
            mkfs.ext4 $ROOT_PART

            # Mounting.
            mount $ROOT_PART /mnt
            mount --mkdir $ESP_PART /mnt/boot
            swapon $SWAP_PART

            break
            ;;

        premounted)
            # Just check that we have something mounted on /mnt.
            mountpoint -q /mnt || die "Nothing mounted on /mnt"
            debug_on

            # TODO: Need $DISK, $ROOT_PART and $ESP_PART_NR

            break
            ;;
    esac
done

# (2.2) Install essential packages.
pacstrap -K /mnt base linux linux-firmware

# TODO: Other essential packages (CPU microcode etc, see wiki 2.2)

# (3.1) fstab
genfstab -U /mnt >> /mnt/etc/fstab

# (3.3) Timezone
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Brussels /etc/localtime
arch-chroot /mnt hwclock --systohc

# TODO: NTP (see wiki 3.3)

# (3.4) Localization
sed -i 's/#\(en_GB.UTF-8\)/\1/' /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo 'LANG=en_GB.UTF-8' >/mnt/etc/locale.conf

# (3.5) Network configuration
read -p "Enter hostname: " HOSTNAME
echo "$HOSTNAME" >/mnt/etc/hostname

# TODO: Install network software.

# (3.7) Set the root password
# TODO: Get rid of this?
arch-chroot /mnt passwd

# (3.8) Boot loader (systemd-boot)
# TODO: instead of ROOT_PART, use mountpoint.
# TODO: same with ESP_PART_NR?
# TODO: same with DISK?
arch-chroot /mnt bootctl install
ROOT_UUID=$(blkid "$ROOT_PART" --match-tag UUID --output value)
efibootmgr --create --disk $DISK --part $ESP_PART_NR --loader '\EFI\systemd\systemd-bootx64.efi' --label "Linux Boot Manager" --unicode
cat <<EOF >/mnt/boot/loader/entries/arch.conf
title  Arch Linux
linux  /vmlinuz-linux
initrd /initramfs-linux.img
options root=UUID=$ROOT_UUID rw
EOF

# (5) Post-installation.

# TODO: See general recommendations (user account, GUI, sound, trackpad).
