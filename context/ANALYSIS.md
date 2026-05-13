# Viwoods Notification Filter Analysis

[← Back to README](../README.md) · [Project Context](CONTEXT.md) · [Installation Guide](INSTALLATION.md)

## Firmware 1.4.0 (Android 16)

All three filter points from 1.3.8 are present in 1.4.0 at updated code offsets.
The `ALLOWED_PKGS` whitelist changed from `{com.google.android.gms, com.google.android.apps.wellbeing}` to `{com.android.dialer, com.android.mms}`.

### Filter 1 — checkDisqualifyingFeatures() [Line 6420]

**File:** `NotificationManagerService.smali`

```smali
invoke-virtual {p0, p2}, ...->areNotificationsEnabledForPackageInt(I)Z
move-result p1
xor-int/2addr p1, v3    # ORIGINAL: XOR inverts the boolean result
```

**Patch:** Replace `xor-int/2addr p1, v3` with `const/4 p1, 0x0`

This forces `p1 = 0` so only the user's own per-app toggle (`isRecordBlockedLocked`) can block a notification.

---

### Filter 2 — PostNotificationRunnable.postNotification() [Line 184]

**File:** `NotificationManagerService$PostNotificationRunnable.smali`

```smali
invoke-static {v0, v1}, ...->areNotificationsEnabledForPackageInt(...)Z
move-result v0
# PATCH: insert const/4 v0, 0x1 here
```

**Patch:** Insert `const/4 v0, 0x1` after `move-result v0` to force permission always granted.

---

### Filter 3 — enqueueNotificationInternal() ALLOWED_PKGS [Line 9389]

**File:** `NotificationManagerService.smali`

```smali
sget-object v2, ...->ALLOWED_PKGS:Ljava/util/Set;
invoke-interface {v2, v1}, Ljava/util/Set;->contains(Ljava/lang/Object;)Z
move-result v2
if-nez v2, :cond_2    # ORIGINAL: only whitelisted packages allowed through
```

**Patch:** Replace `if-nez v2, :cond_2` with `goto :cond_2` to unconditionally bypass the whitelist.

The "eink project,Blocked notification from package:" log at line 9396 becomes dead code.

---

## Firmware 1.3.8 (Android 16)

### Filter 1 — checkDisqualifyingFeatures() [Line 6413]

Same XOR inversion bug. Patch: `xor-int/2addr p1, v3` → `const/4 p1, 0x0`

### Filter 2 — PostNotificationRunnable.postNotification() [Line 188]

Same permission check. Patch: insert `const/4 v0, 0x1` after `move-result v0`

### Filter 3 — enqueueNotificationInternal() ALLOWED_PKGS

Same structure. ALLOWED_PKGS contained: `com.google.android.gms`, `com.google.android.apps.wellbeing`
Patch: `if-nez v2, :cond_2` → `goto :cond_2`
