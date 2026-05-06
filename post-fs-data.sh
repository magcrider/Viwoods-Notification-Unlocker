#!/system/bin/sh
# Viwoods Notification Unlocker - Installation Script
# This script patches the NotificationManagerService to disable the notification whitelist

MODDIR=${0%/*}

# Ensure module directory structure exists
mkdir -p "$MODDIR/system/framework"

# Copy patched services.jar to the system framework directory
cp "$MODDIR/services.jar" "$MODDIR/system/framework/services.jar" 2>/dev/null

# Set proper SELinux context
chcon u:object_r:system_file:s0 "$MODDIR/system/framework/services.jar" 2>/dev/null

# Set proper permissions
chmod 644 "$MODDIR/system/framework/services.jar" 2>/dev/null
