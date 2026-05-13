#!/system/bin/sh

MODDIR=${0%/*}
LOGFILE="$MODDIR/service.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

# Wait for system to be fully booted
until [ "$(getprop sys.boot_completed)" = "1" ]; do
  sleep 2
done

sleep 5

log "Viwoods Notification Unlocker service starting..."

# Whitelist all installed packages from battery optimization
# This ensures apps are not killed before they can receive notifications
pm list packages | cut -d: -f2 | while read -r pkg; do
  cmd deviceidle whitelist "+$pkg" 2>/dev/null
  cmd appops set "$pkg" RUN_ANY_IN_BACKGROUND allow 2>/dev/null
done

log "Battery optimization bypass applied to all packages"
log "Done"
