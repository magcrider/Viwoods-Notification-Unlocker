# Viwoods AiPaper — Notification Unlocker Project Context

## Device

**Viwoods AiPaper** — an Android-based e-ink reader tablet.
- Firmware: **1.3.8**
- Rooted with **Magisk** (bootloader unlocked, `init_boot.img` patched)
- Device boots normally with the module installed, no bootloop issues

---

## Problem

Viwoods ships firmware with a **hardcoded notification whitelist**. Only apps explicitly approved by Viwoods can post notifications. All other apps (WhatsApp, Gmail, third-party apps) are silently blocked. The blocking is done inside `services.jar` — the core Android framework services file — making it invisible to standard Android notification settings.

---

## Investigation

The patching target is `/system/framework/services.jar`, specifically `classes2.dex` inside it, class `com.android.server.notification.NotificationManagerService`.

Three separate filtering points were found in firmware 1.3.8 (more than in prior firmware versions 1.1.0 / 1.2.3):

### Filter 1 — `checkDisqualifyingFeatures()`
**File:** `NotificationManagerService.smali` ~line 6413

The method calls `areNotificationsEnabledForPackageInt(uid)` → `PermissionHelper.hasPermission(uid)` → `checkPermission("android.permission.POST_NOTIFICATIONS", uid)`. Viwoods only grants `POST_NOTIFICATIONS` to whitelisted apps.

The result was XOR'd with `v3=1`, inverting it, then fed into a suppression check. This was a Viwoods-specific bug on top of the whitelist — even whitelisted apps could be affected under certain conditions.

**Patch:** replaced `xor-int/2addr p1, v3` with `const/4 p1, 0x0` — forces the result to always bypass suppression.

### Filter 2 — `PostNotificationRunnable.postNotification()`
**File:** `NotificationManagerService$PostNotificationRunnable.smali` ~line 188

This is the **actual active code path** for posting notifications in firmware 1.3.8. `EnqueueNotificationRunnable` creates a `PostNotificationRunnable` and posts it to the handler. This runnable independently checks `areNotificationsEnabledForPackageInt(uid)` at line 184 and stores the result in `v0`. At line 362, `if-eqz v0, :cond_4` blocks the notification if the app is not whitelisted — no XOR bug here, clean logic, but still enforcing the whitelist.

**Patch:** added `const/4 v0, 0x1` after `move-result v0` at line 186 — forces the permission result to always be "granted", bypassing the whitelist. Standard Android per-app notification toggles (`isRecordBlockedLocked`) are preserved so users can still disable individual apps in Settings.

### Filter 3 — `enqueueNotificationInternal()` ALLOWED_PKGS check
**File:** `NotificationManagerService.smali` ~line 9360

At the very entry point of `enqueueNotificationInternal()`, before any other processing, the firmware checks the package name against a static `ALLOWED_PKGS` set. If the package is not in the set, it logs `"eink project,Blocked notification from package: <pkg>"` and returns false immediately. Only `com.google.android.gms` and `com.google.android.apps.wellbeing` are explicitly hardcoded as allowed outside the set.

This was the log message visible in logcat: `I NotificationService: eink project,Blocked notification from package: com.whatsapp`

**Patch:** replaced `if-nez v2, :cond_2` with `goto :cond_2` — bypasses the `ALLOWED_PKGS` check entirely, making all packages proceed to normal notification processing.

---

## How the Patch is Applied

The workflow uses **apktool** to decompile and recompile `services.jar`:

```powershell
# Decompile (already done — result is in services_decompiled/)
java -jar apktool.jar d backup/services.jar.original -o services_decompiled

# After editing smali files, recompile
java -jar apktool.jar b services_decompiled -o extracted/services_patched.jar

# Copy into module
cp extracted/services_patched.jar module/services.jar

# Repackage ZIP for Magisk
Compress-Archive -Path "module\*" -DestinationPath "Viwoods-Notification-Unlocker-1.3.8.zip"
```

The `post-fs-data.sh` script in the module copies `services.jar` from the module root to `$MODDIR/system/framework/services.jar` at boot, sets the SELinux context (`chcon u:object_r:system_file:s0`), and permissions (644). Magisk then overlays this over `/system/framework/services.jar` via its magic mount.

---

## Battery Optimization Fix

After unlocking notifications, a secondary problem emerged: **Viwoods firmware kills background app processes aggressively**. WhatsApp's process was being killed before it could receive and process FCM push messages (`result=CANCELLED` in GCM logcat). The fix is `service.sh`, which runs after every boot:

```sh
until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 2; done

pm list packages | cut -d: -f2 | while read -r pkg; do
    dumpsys deviceidle whitelist +"$pkg" 2>/dev/null
    cmd appops set "$pkg" RUN_ANY_IN_BACKGROUND allow 2>/dev/null
done
```

This whitelists all 241 installed packages (system + user) from battery optimization. `pm list packages` (without `-3`) is required because system-preloaded apps like Gmail (`com.google.android.gm`) are not listed with `-3` (user-only flag).

**Limitation:** apps installed after the last reboot are not covered until the next reboot.

---

## Module Structure

```
module/
├── META-INF/com/google/android/
│   ├── update-binary       (minimal Magisk installer)
│   └── updater-script      (empty, required by format)
├── module.prop             (id, name, version, author, description)
├── post-fs-data.sh         (copies + SELinux context for services.jar)
├── service.sh              (battery optimization whitelist at boot)
└── services.jar            (patched framework — 22MB)
```

Root-level files (`module.prop`, `post-fs-data.sh`, `service.sh`, `services.jar`) match the upstream repo's flat structure.

---

## Repository

- **Upstream:** https://github.com/ScreenSensitive/Viwoods-Notification-Unlocker
- **Fork:** https://github.com/magcrider/Viwoods-Notification-Unlocker
- **PR:** https://github.com/ScreenSensitive/Viwoods-Notification-Unlocker/pull/2
- **Branch:** `firmware/1.3.8` (merged into fork's `main`)
- **Working directory:** `c:\Users\Harvey Botero\Desktop\GIT\viwoods`

The upstream repo previously supported firmware 1.1.0 and 1.2.3. Firmware 1.3.8 introduced the additional `PostNotificationRunnable` and `ALLOWED_PKGS` filters not present in earlier versions.

---

## Launcher

The stock Viwoods launcher has no notification drawer (swipe down only refreshes the e-ink screen). The user settled on **inkOS** — https://github.com/gezimos/inkOS — a minimalist e-ink-friendly launcher with a notification tray. It is already referenced in the upstream README as the recommended companion.

---

## Outstanding Items

### Gmail notifications
Gmail notifications were not working after all other fixes. Diagnosis showed:
- Battery optimization: resolved (service.sh covers Gmail)
- GMS (Google Play Services) is running and receiving FCM
- Gmail's email notification channels (`Primary`, `Promotions`, etc.) were not registered in the notification system — only Drive-related channels (COMMENTS, SHARES) were present
- Gmail sync was set to `period=1d00h00m00s` (once daily) instead of FCM push

**Most likely cause:** Gmail's in-app notification setting is set to "None".  
**Next step to try:** Gmail app → Menu → Settings → [account] → Notifications → set to "All new mail".  
This is separate from the module and not part of the PR.

### Fork main merge
Completed — `firmware/1.3.8` has been merged into `magcrider/main`.

### Upstream PR
Open and awaiting review by ScreenSensitive. No CI checks configured on the upstream repo.

---

## Files NOT committed (gitignore)

| Path | Reason |
|------|--------|
| `apktool.jar` / `apktool` | Build tools, 24MB |
| `backup/` | Original unpatched services.jar (22MB) |
| `extracted/` | Build output |
| `services_decompiled/` | Decompiled smali source (229MB) |
| `verify_patch/` | Secondary decompile for verification (207MB) |
| `*.zip` | Release artifacts, not source |
| `module/` | Files already at root level |
