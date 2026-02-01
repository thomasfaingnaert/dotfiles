#!/usr/bin/env bash
set -euo pipefail

# To install dependencies:
# sudo pacman -S qemu-full edk2-ovmf socat

# Configuration
WORK_DIR="${WORK_DIR:-./arch-test}"
DISK_SIZE="${DISK_SIZE:-20G}"
RAM="${RAM:-4G}"
CPUS="${CPUS:-4}"
OVMF_CODE="${OVMF_CODE:-/usr/share/OVMF/x64/OVMF_CODE.secboot.4m.fd}"
OVMF_VARS="${OVMF_VARS:-/usr/share/OVMF/x64/OVMF_VARS.4m.fd}"
SCRIPTS_DIR="${SCRIPTS_DIR:-./arch}"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log() { echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $*" >&2; }
warn() { echo -e "${YELLOW}[$(date '+%H:%M:%S')] WARNING:${NC} $*" >&2; }
die() { echo -e "${RED}[$(date '+%H:%M:%S')] ERROR:${NC} $*" >&2; exit 1; }

cleanup() {
    [[ -n "${QEMU_PID:-}" ]] && kill "$QEMU_PID" 2>/dev/null || true
}
trap cleanup EXIT

# Check dependencies
check_deps() {
    local missing=()
    for cmd in qemu-system-x86_64 curl socat; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    [[ -f "$OVMF_CODE" ]] || missing+=("OVMF (edk2-ovmf)")

    if [[ ${#missing[@]} -gt 0 ]]; then
        die "Missing dependencies: ${missing[*]}"
    fi
}

# Download latest Arch ISO
download_iso() {
    local mirror="https://geo.mirror.pkgbuild.com/iso/latest"
    local iso_name

    log "Fetching latest ISO information..."
    iso_name=$(curl -sL "$mirror/sha256sums.txt" | grep -oP 'archlinux-\d{4}\.\d{2}\.\d{2}-x86_64\.iso' | head -1)
    [[ -n "$iso_name" ]] || die "Could not determine latest ISO name"

    local iso_path="$WORK_DIR/$iso_name"

    if [[ -f "$iso_path" ]]; then
        log "ISO already exists: $iso_path"
    else
        log "Downloading $iso_name..."
        curl -L -o "$iso_path" "$mirror/$iso_name" || die "Download failed"
    fi

    echo "$iso_path"
}

# Create disk image
create_disk() {
    local disk="$WORK_DIR/disk.qcow2"
    if [[ ! -f "$disk" ]] || [[ "${FORCE_NEW_DISK:-}" == "1" ]]; then
        log "Creating ${DISK_SIZE} disk image..."
        qemu-img create -f qcow2 "$disk" "$DISK_SIZE" >&2
    fi
    echo "$disk"
}

# Create UEFI vars copy (qcow2 for snapshot support)
create_uefi_vars() {
    local vars="$WORK_DIR/OVMF_VARS.qcow2"

    if [[ ! -f "$vars" ]] || [[ "${FORCE_NEW_DISK:-}" == "1" ]]; then
        log "Creating UEFI vars image..."
        qemu-img convert -f raw -O qcow2 "$OVMF_VARS" "$vars" >&2
    fi

    echo "$vars"
}

# Send a string to QEMU monitor as keypresses
send_string() {
    local socket="$1"
    local str="$2"

    for (( i=0; i<${#str}; i++ )); do
        local char="${str:$i:1}"
        local key=""

        case "$char" in
            [a-z]) key="$char" ;;
            [A-Z]) key="shift-${char,}" ;;
            [0-9]) key="$char" ;;
            ' ') key="spc" ;;
            '/') key="slash" ;;
            '-') key="minus" ;;
            '=') key="equal" ;;
            '.') key="dot" ;;
            ',') key="comma" ;;
            ':') key="shift-semicolon" ;;
            ';') key="semicolon" ;;
            '_') key="shift-minus" ;;
            '&') key="shift-7" ;;
            '|') key="shift-backslash" ;;
            '$') key="shift-4" ;;
            '"') key="shift-apostrophe" ;;
            "'") key="apostrophe" ;;
            '(') key="shift-9" ;;
            ')') key="shift-0" ;;
            '<') key="shift-comma" ;;
            '>') key="shift-dot" ;;
            *) continue ;;
        esac

        echo "sendkey $key" | socat - "unix-connect:$socket" >/dev/null 2>&1
        sleep 0.05
    done
}

send_enter() {
    echo "sendkey ret" | socat - "unix-connect:$1" >/dev/null 2>&1
}

send_monitor_command() {
    local socket="$1"
    local cmd="$2"
    echo "$cmd" | socat - "unix-connect:$socket" 2>/dev/null
}

send_mount_commands() {
    local socket="$1"

    send_string "$socket" "mkdir -p /shared"
    send_enter "$socket"
    sleep 0.5

    send_string "$socket" "mount -t 9p -o trans=virtio,version=9p2000.L shared /shared"
    send_enter "$socket"
    sleep 0.5

    send_string "$socket" "cd /shared"
    send_enter "$socket"
    sleep 0.3
}

send_unmount_commands() {
    local socket="$1"

    send_string "$socket" "cd / && umount /shared"
    send_enter "$socket"
    sleep 0.5
}

save_snapshot() {
    local socket="$1"
    local name="${2:-default}"

    log "Saving snapshot '$name'..."
    send_monitor_command "$socket" "savevm $name"
    sleep 1
    log "Snapshot saved."
}

load_snapshot() {
    local socket="$1"
    local name="${2:-default}"

    log "Loading snapshot '$name'..."
    send_monitor_command "$socket" "loadvm $name"
    sleep 1
    log "Snapshot loaded."
}

send_commands() {
    local socket="$1"

    log "Sending mount commands..."
    send_mount_commands "$socket"

    send_string "$socket" "clear"
    send_enter "$socket"
    sleep 0.3

    send_string "$socket" "echo 'Ready! Run: ./install.sh'"
    send_enter "$socket"

    log "Commands sent."
}

interactive_loop() {
    local socket="$1"

    echo >&2
    log "Interactive controls:"
    log "  ENTER  - Send mount commands"
    log "  s      - Save snapshot"
    log "  r      - Restore snapshot"
    log "  q      - Quit"
    echo >&2

    while true; do
        read -rsn1 key
        case "$key" in
            "") send_commands "$socket" ;;
            s|S) save_snapshot "$socket" ;;
            r|R) load_snapshot "$socket" ;;
            q|Q) log "Quitting..."; kill "$QEMU_PID" 2>/dev/null; break ;;
        esac
    done
}

# Main execution
main() {
    check_deps

    [[ -f "$SCRIPTS_DIR/install.sh" ]] || die "install.sh not found in $SCRIPTS_DIR"
    [[ -f "$SCRIPTS_DIR/post-install.sh" ]] || die "post-install.sh not found in $SCRIPTS_DIR"

    mkdir -p "$WORK_DIR"

    local iso_path disk_path uefi_vars monitor_socket
    iso_path=$(download_iso)
    disk_path=$(create_disk)
    uefi_vars=$(create_uefi_vars)
    monitor_socket="$WORK_DIR/monitor.sock"

    rm -f "$monitor_socket"

    log "Starting QEMU..."

    qemu-system-x86_64 \
        -name "arch-test" \
        -machine q35,accel=kvm \
        -cpu host \
        -smp "$CPUS" \
        -m "$RAM" \
        -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
        -drive if=pflash,format=qcow2,file="$uefi_vars" \
        -drive file="$disk_path",format=qcow2,if=none,id=disk0 \
        -device virtio-blk-pci,drive=disk0,serial=ARCH_TEST_DISK \
        -cdrom "$iso_path" \
        -boot order=d,menu=off \
        -virtfs local,path="$SCRIPTS_DIR",mount_tag=shared,security_model=mapped-xattr,id=shared \
        -device virtio-vga,xres=1280,yres=720 \
        -monitor unix:"$monitor_socket",server,nowait \
        -display gtk &
    QEMU_PID=$!

    sleep 2
    [[ -S "$monitor_socket" ]] || die "Monitor socket not created"

    interactive_loop "$monitor_socket"

    trap - EXIT
    wait $QEMU_PID 2>/dev/null || true

    log "QEMU exited"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --work-dir) WORK_DIR="$2"; shift 2 ;;
        --scripts-dir) SCRIPTS_DIR="$2"; shift 2 ;;
        --disk-size) DISK_SIZE="$2"; shift 2 ;;
        --ram) RAM="$2"; shift 2 ;;
        --cpus) CPUS="$2"; shift 2 ;;
        --force-new-disk) FORCE_NEW_DISK=1; shift ;;
        -h|--help)
            cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
    --work-dir DIR      Working directory (default: ./arch-test)
    --scripts-dir DIR   Directory containing install.sh and post-install.sh (default: .)
    --disk-size SIZE    Virtual disk size (default: 20G)
    --ram SIZE          RAM allocation (default: 4G)
    --cpus N            Number of CPUs (default: 4)
    --force-new-disk    Recreate disk image
EOF
            exit 0
            ;;
        *) die "Unknown option: $1" ;;
    esac
done

main
