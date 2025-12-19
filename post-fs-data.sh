#!/system/bin/sh
# E-ink Notification Unblock - SELinux Context Fixer
# This ensures the patched services.jar has the correct SELinux context

MODDIR=${0%/*}

# Set proper SELinux context for services.jar
chcon u:object_r:system_file:s0 "$MODDIR/system/framework/services.jar" 2>/dev/null

# Set proper permissions
chmod 644 "$MODDIR/system/framework/services.jar" 2>/dev/null
