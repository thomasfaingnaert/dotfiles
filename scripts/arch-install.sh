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

# Check if in Secure Boot Setup Mode, so we can generate and enroll keys.
running_setup_mode=0

if [[ "$(od -j4 -N1 -t x1 -An /sys/firmware/efi/efivars/SetupMode-8be4df61-93ca-11d2-aa0d-00e098032b8c | tr -d ' ')" == "01" ]]; then
    running_setup_mode=1
fi

if (( running_setup_mode != 1 )); then
    warn "Not running in UEFI Setup Mode. sbctl will not be able to enroll new keys."
    confirm "Do you want to continue?"
fi

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

# Defaults.
INITRAMFS_HOOKS="(base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems resume fsck)"
EXTRA_PACKAGES=""

cat <<EOF
Available partitioning schemes:

premounted      Partitioning, formatting, and mounting already done. (/mnt)
ext4            Wipe disk: EFI | swap | ext4 root
ext4-crypt      Wipe disk: EFI | crypt ( LVM ( swap | ext4 root ) )

EOF

PS3="Select partitioning scheme: "
select PART_SETUP in premounted ext4 ext4-crypt; do
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
            mount --mkdir $ESP_PART /mnt/efi
            swapon $SWAP_PART

            # Overrides.
            ROOT_UUID=$(blkid "$ROOT_PART" --match-tag UUID --output value)
            KERNEL_CMDLINE_ROOT="root=UUID=$ROOT_UUID rw"

            break
            ;;

        ext4-crypt)
            choose_disk

            echo "Will install to $DISK (-> $(realpath "$DISK"))."
            confirm "Are you sure? All data will be wiped."

            SWAP_SIZE=$(awk '/MemTotal/ { print $2 * 2 }' /proc/meminfo)

            ESP_PART="$DISK-part1"
            CRYPT_PART="$DISK-part2"

            debug_on

            # Wipe disk.
            wipefs -af $DISK
            sgdisk -Zo $DISK

            # Partitioning.
            sgdisk -n 1:0:+1G -t 1:EF00 $DISK # EFI
            sgdisk -n 2:0:0   -t 2:8309 $DISK # cryptroot

            partprobe $DISK

            # Crypt setup.
            cryptsetup -v luksFormat $CRYPT_PART
            cryptsetup open $CRYPT_PART cryptroot

            # LVM setup.
            # Leave 256 MiB free space at the end so we can use e2scrub(8) for ext4.
            pvcreate /dev/mapper/cryptroot
            vgcreate vg0 /dev/mapper/cryptroot
            lvcreate -L "$SWAP_SIZE"K vg0 -n swap
            lvcreate -l 100%FREE vg0 -n root
            lvreduce -L -256M vg0/root

            # Formatting.
            mkfs.fat -F32 $ESP_PART
            mkswap /dev/vg0/swap
            mkfs.ext4 /dev/vg0/root

            # Mounting.
            mount /dev/vg0/root /mnt
            mount --mkdir $ESP_PART /mnt/efi
            swapon /dev/vg0/swap

            # Overrides.
            INITRAMFS_HOOKS="(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt lvm2 filesystems resume fsck)"
            EXTRA_PACKAGES="lvm2"
            CRYPT_UUID=$(blkid "$CRYPT_PART" --match-tag UUID --output value)
            KERNEL_CMDLINE_ROOT="cryptdevice=UUID=$CRYPT_UUID:root root=/dev/vg0/root rw"

            break
            ;;

        premounted)
            # Just check that we have something mounted on /mnt.
            mountpoint -q /mnt || die "Nothing mounted on /mnt"

            # Overrides.
            ROOT_PART="$(findmnt --raw --noheadings --first-only -o source /mnt)"
            ROOT_UUID=$(blkid "$ROOT_PART" --match-tag UUID --output value)
            KERNEL_CMDLINE_ROOT="root=UUID=$ROOT_UUID rw"

            break
            ;;
    esac
done

# (2.2) Install essential packages.
pacstrap -K /mnt base linux linux-firmware intel-ucode amd-ucode "$EXTRA_PACKAGES"

# (3.1) fstab
genfstab -U /mnt >> /mnt/etc/fstab

# (3.3) Timezone
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Brussels /etc/localtime
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt systemctl enable systemd-timesyncd

# (3.4) Localization
sed -i 's/#\(en_GB.UTF-8\)/\1/' /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo 'LANG=en_GB.UTF-8' >/mnt/etc/locale.conf

# (3.5) Network configuration
read -p "Enter hostname: " HOSTNAME
echo "$HOSTNAME" >/mnt/etc/hostname

arch-chroot /mnt pacman --noconfirm -S networkmanager
arch-chroot /mnt systemctl enable NetworkManager

# (3.6) Initramfs

# Configure for UKI.
mkdir -p /mnt/etc/cmdline.d
echo "$KERNEL_CMDLINE_ROOT" >/mnt/etc/cmdline.d/root.conf

sed -i '/_uki=/s/^#//' /mnt/etc/mkinitcpio.d/linux.preset
sed -i '/_image=/s/^/#/' /mnt/etc/mkinitcpio.d/linux.preset
sed -i '/^default_uki=/s|=.*|="/efi/EFI/BOOT/BOOTx64.EFI"|' /mnt/etc/mkinitcpio.d/linux.preset

# Set hooks and regenerate UKI.
sed -i "/^HOOKS=/s/=.*/=$INITRAMFS_HOOKS/" /mnt/etc/mkinitcpio.conf
mkdir -p /mnt/efi/EFI/BOOT
mkdir -p /mnt/efi/EFI/Linux
arch-chroot /mnt mkinitcpio -P
rm -f /mnt/boot/initramfs-*.img

# (3.7) Lock the root account.
arch-chroot /mnt passwd --lock root

# (3.8) Boot loader
# Not needed for UKI.

# (5) Post-installation.

# 1) Create a local user account with sudo rights.
arch-chroot /mnt useradd -m -G wheel -s /bin/bash thomas
arch-chroot /mnt passwd thomas

# 2) Install and configure sudo.
arch-chroot /mnt pacman --noconfirm -S sudo
sed -i '/# %wheel ALL=(ALL:ALL) ALL/s/^# //' /mnt/etc/sudoers

# Secure boot.
arch-chroot /mnt pacman --noconfirm -S sbctl

arch-chroot /mnt sbctl create-keys

if (( running_setup_mode == 1 )); then
    arch-chroot /mnt sbctl enroll-keys --microsoft
else
    warn "Not running in UEFI Setup Mode. You need to enroll the keys yourself using sbctl enroll-keys --microsoft after boot."
fi

arch-chroot /mnt sbctl sign -s /mnt/efi/EFI/BOOT/BOOTx64.EFI
arch-chroot /mnt sbctl sign -s /mnt/efi/EFI/Linux/arch-linux-fallback.efi

arch-chroot /mnt sbctl status
arch-chroot /mnt sbctl verify
