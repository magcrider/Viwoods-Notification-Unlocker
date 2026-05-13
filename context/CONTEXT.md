# Viwoods AiPaper — Notification Unlocker Project Context

[← Back to README](../README.md) · [Technical Analysis](ANALYSIS.md) · [Installation Guide](INSTALLATION.md)

## Device

**Viwoods AiPaper** — an Android 16-based e-ink reader tablet.
- Tested firmware: **1.1.0**, **1.2.3**, **1.3.8**, **1.4.0**
- Requires **Magisk** root (unlocked bootloader, `init_boot` patched via MTKClient)
- ADB shell is restricted on this device — use the Viwoods debug tool for shell commands

---

## Problem

Viwoods ships firmware with a **hardcoded notification whitelist** inside `services.jar`. Apps not on the whitelist are silently blocked before notifications are posted, regardless of Android notification permissions.

Logcat evidence:
```
I NotificationService: eink project,Blocked notification from package: com.whatsapp
```

---

## Three Blocking Filters (All Firmware Versions ≥ 1.3.8)

The patching target is `/system/framework/services.jar` → `classes2.dex` → `com.android.server.notification.NotificationManagerService`.

### Filter 1 — `checkDisqualifyingFeatures()`

`areNotificationsEnabledForPackageInt(uid)` result is XOR'd with `v3=1`, inverting it. The inverted result is OR'd with `isRecordBlockedLocked()` to make the suppression decision.

**Patch:** `xor-int/2addr p1, v3` → `const/4 p1, 0x0`
Forces the permission check to always return "not blocked", preserving user per-app toggles.

### Filter 2 — `PostNotificationRunnable.postNotification()`

The active notification posting runnable independently checks `areNotificationsEnabledForPackageInt(uid)` and uses the result downstream to block the notification.

**Patch:** Insert `const/4 v0, 0x1` after `move-result v0`
Forces permission to always granted.

### Filter 3 — `enqueueNotificationInternal()` ALLOWED_PKGS

At the entry point of `enqueueNotificationInternal()`, the package name is checked against a static `ALLOWED_PKGS` set. Non-whitelisted packages are logged and rejected immediately.

ALLOWED_PKGS contents by firmware:
- **1.3.8:** `{com.google.android.gms, com.google.android.apps.wellbeing}`
- **1.4.0:** `{com.android.dialer, com.android.mms}`

**Patch:** `if-nez v2, :cond_2` → `goto :cond_2`
Bypasses the whitelist check entirely.

---

## Additional Blocking — GMS and Wellbeing (Known Limitation)

In firmware 1.4.0, `enqueueNotificationInternal()` special-cases two packages before reaching the ALLOWED_PKGS check:

```smali
if-nez v2, :cond_1a    # com.google.android.gms → goto_b (returns 0)
goto/16 :goto_c        # com.google.android.apps.wellbeing → goto_b (returns 0)
```

Both `cond_1a` and `goto_c` route to `goto_b` which logs `"enqueueNotificationInternal gms Notification,so return!!"` and returns 0 (blocked).

These packages are blocked via a **separate code path** that our Filter 3 patch does not cover. In practice this is not critical because GMS uses its own background infrastructure for FCM delivery. However, direct GMS/Wellbeing notifications through `enqueueNotificationInternal` will still be silently dropped.

**Status:** Outstanding — requires additional patch in a future version.

---

## Battery Optimization Fix

Viwoods firmware aggressively kills background processes via `com.viwoods.refresh.service`. Apps are killed before they can receive and process FCM push messages.

Fix via `service.sh` (runs after every boot):
```sh
pm list packages | cut -d: -f2 | while read -r pkg; do
  cmd deviceidle whitelist "+$pkg" 2>/dev/null
  cmd appops set "$pkg" RUN_ANY_IN_BACKGROUND allow 2>/dev/null
done
```

This whitelists all installed packages from battery optimization. `pm list packages` (without `-3`) is used to include system apps like Gmail.

**Limitation:** Apps installed after the last reboot are not covered until next reboot.

---

## Build Process

Extract `services.jar` from device:
```sh
# Via Viwoods debug tool (ADB restricted, copy to sdcard first)
shell dd if=/system/framework/services.jar of=/sdcard/services.jar bs=4096
# Then copy via MTP to PC
```

Decompile, patch, recompile:
```powershell
java -jar apktool.jar d services.jar -o services_decompiled
# Edit smali files
java -jar apktool.jar b services_decompiled -o services_patched.jar
```

**Important — ZIP creation on Windows:** Use Python's `zipfile` module to create the Magisk ZIP. PowerShell's `Compress-Archive` uses backslash path separators which Android cannot properly extract into directory structures.

```python
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as zf:
    zf.write('services.jar', 'services.jar')
    zf.write('module.prop', 'module.prop')
    # etc — forward slashes only
```

Flash via MTKClient (required since ADB is restricted):
```sh
python mtk.py w init_boot_a "magisk_patched.img"
```

---

## Google Services Setup Order

**Critical:** Enable Google Services BEFORE rooting with Magisk.

Enabling Google Services on a rooted device triggers a factory reset (Viwoods detects the modified system during GMS registration). The correct order is:
1. Fresh device → enable Google Services → complete account setup
2. Then root with Magisk

---

## Outstanding Items

### GMS / Wellbeing notifications
Notifications from `com.google.android.gms` and `com.google.android.apps.wellbeing` are blocked via a separate code path not covered by current patches. Requires additional smali patch in a future version.

### Gmail notifications
Gmail notifications may not work even after module installation. Likely causes:
- Gmail in-app setting set to "None" → change to "All new mail" in Gmail → Settings → [account] → Notifications
- Notification channels not registered if Gmail was installed before the module was active — clearing Gmail app data and reopening triggers channel re-registration

### Launcher
The stock Viwoods launcher has no notification drawer. Recommended companion: **inkOS** — https://github.com/gezimos/inkOS

---

## Repository

- **Upstream:** https://github.com/ScreenSensitive/Viwoods-Notification-Unlocker
- **Fork:** https://github.com/magcrider/Viwoods-Notification-Unlocker
- **Working directory:** `C:\Users\Harvey Botero\Desktop\GIT\viwoods`
- Decompiled smali, build tools, and raw backups are gitignored (400MB+ total)
