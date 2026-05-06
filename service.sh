#!/system/bin/sh
# Viwoods Notification Unlocker - Boot service
# Disables battery optimization for all user-installed apps so they
# can receive notifications without being killed in the background

# Wait for system to be fully booted
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

# Apply to every user-installed app (covers future installs too)
pm list packages | cut -d: -f2 | while read -r pkg; do
    dumpsys deviceidle whitelist +"$pkg" 2>/dev/null
    cmd appops set "$pkg" RUN_ANY_IN_BACKGROUND allow 2>/dev/null
done
