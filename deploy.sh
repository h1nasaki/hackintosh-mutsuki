#!/bin/bash

# List connected USB drives
list_usb_drives() {
    diskutil list | grep "external" | awk '{print $1}'
}

# Mount the EFI partition of a specified USB drive
mount_efi_partition() {
    local usb_drive=$1
    local efi_mount_point="/Volumes/EFI"

    # Find the EFI partition device
    efi_partition=$(diskutil list $usb_drive | grep "EFI" | awk '{print $6}')
    if [ -z "$efi_partition" ]; then
        echo "EFI partition not found."
        exit 1
    fi

    # Mount the EFI partition
    sudo mkdir -p $efi_mount_point
    sudo mount -t msdos /dev/$efi_partition $efi_mount_point

    echo "Mounted EFI partition at $efi_mount_point."
}

# Transfer the EFI directory from the script directory to the mounted EFI partition
transfer_efi_directory() {
    local efi_mount_point="/Volumes/EFI"
    local script_dir=$(dirname "$0")

    # Transfer the EFI directory
    sudo cp -r $script_dir/EFI $efi_mount_point

    echo "Transferred EFI directory to $efi_mount_point."
}

# Unmount the EFI partition
unmount_efi_partition() {
    local efi_mount_point="/Volumes/EFI"

    sudo diskutil unmount $efi_mount_point

    echo "Unmounted EFI partition from $efi_mount_point."
}

# Main process
main() {
    # Display connected USB drives
    echo "Connected USB drives:"
    list_usb_drives

    # Prompt user to specify the USB drive
    echo -n "Specify the USB drive to mount the EFI partition (e.g., disk2): "
    read usb_drive

    # Mount the EFI partition
    mount_efi_partition $usb_drive

    # Transfer the EFI directory
    transfer_efi_directory

    # Unmount the EFI partition
    unmount_efi_partition

    echo "Process completed."
}

# Run the script
main
