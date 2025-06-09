#!/usr/bin/env bash
set -Eeuo pipefail

rm -f commands.log

# logging
log()  { echo -e "\033[0;36m[LOG]\033[0m $1" >&2; }
warn() { echo -e "\033[0;33m[WRN]\033[0m $1" >&2; }
err()  { echo -e "\033[0;31m[ERR]\033[0m $1" >&2; }
die()  { err "$1"; exit 1; }

log_cmd() { echo -e "\033[0;36m$ $@\033[0m" >&2; echo "$@" >>commands.log; $@; }

confirm() {
    read -p "$1 [yN] " -n1 -r && echo
    [[ "$REPLY" =~ ^[Yy]$ ]] || exit 1
}

# (0) Tests.
[[ $(cat /sys/firmware/efi/fw_platform_size) == "64" ]] || die "You are not booted using UEFI 64-bit"
ping -c1 archlinux.org &>/dev/null || die "No internet connection"
timedatectl | grep -q "System clock synchronized: yes" || die "Clock not synchronised"

# (1) Disk partitioning, formatting, and mounting.
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

            # Wipe disk.
            log_cmd wipefs -af $DISK
            log_cmd sgdisk -Zo $DISK

            # Partitioning.
            SWAP_SIZE=$(awk '/MemTotal/ { print $2 * 2 }' /proc/meminfo)

            log_cmd sgdisk -n 1:0:+1G            -t 1:EF00 $DISK # EFI
            log_cmd sgdisk -n 2:0:+"$SWAP_SIZE"K -t 2:8200 $DISK # swap
            log_cmd sgdisk -n 3:0:0              -t 3:8304 $DISK # root

            ESP_PART="$DISK-part1"
            SWAP_PART="$DISK-part2"
            ROOT_PART="$DISK-part3"

            log_cmd partprobe $DISK

            # Formatting.
            log_cmd mkfs.fat -F32 $ESP_PART
            log_cmd mkswap $SWAP_PART
            log_cmd mkfs.ext4 $ROOT_PART

            # Mounting.
            log_cmd mount $ROOT_PART /mnt
            log_cmd mount --mkdir $ESP_PART /mnt/boot
            log_cmd swapon $SWAP_PART

            break
            ;;

        premounted)
            # Just check that we have something mounted on /mnt.
            mountpoint -q /mnt || die "Nothing mounted on /mnt"
            break
            ;;
    esac
done
