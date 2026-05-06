# Viwoods Notification Filter Analysis - Firmware 1.3.8

## Location: NotificationManagerService.smali (Lines 6407-6480)

### Notification Suppression Logic Found

The Viwoods notification blocking mechanism is located in a method that handles notification posting. This is the critical filtering point:

```smali
.line 9157
:cond_17
invoke-virtual {p0, p2}, Lcom/android/server/notification/NotificationManagerService;->areNotificationsEnabledForPackageInt(I)Z
move-result p1                    # p1 = areNotificationsEnabledForPackageInt(p2)
xor-int/2addr p1, v3             # p1 = p1 XOR v3 (INVERTS the result!)
```

**Key Finding:** 
- `v3` is set to 1 earlier in the method
- The XOR inverts the boolean result from `areNotificationsEnabledForPackageInt`
- If notifications ARE enabled → p1 becomes 0 (false)
- If notifications ARE DISABLED → p1 becomes 1 (true)

### Flow After Permission Check

```smali
.line 9158
iget-object p3, p0, Lcom/android/server/notification/NotificationManagerService;->mNotificationLock:Ljava/lang/Object;
monitor-enter p3
.line 9159
:try_start_2
invoke-virtual {p0, p5}, Lcom/android/server/notification/NotificationManagerService;->isRecordBlockedLocked(Lcom/android/server/notification/NotificationRecord;)Z
move-result p4
or-int/2addr p1, p4               # p1 = p1 OR isRecordBlockedLocked(p5)
.line 9160
monitor-exit p3
```

### Suppression Decision

```smali
if-eqz p1, :cond_19               # If p1 == 0 (no suppression needed), skip to cond_19
.line 9161
invoke-virtual {v0}, Landroid/app/Notification;->isMediaNotification()Z
move-result p1
if-nez p1, :cond_19               # Skip if it's a media notification
invoke-virtual {p0, v1, p2, v0}, Lcom/android/server/notification/NotificationManagerService;->isCallNotification(Ljava/lang/String;ILandroid/app/Notification;)Z
move-result p1
if-nez p1, :cond_19               # Skip if it's a call notification
.line 9162-9480
[SUPPRESS NOTIFICATION - log "Suppressing notification from package..."]
```

## Patch Strategy

To disable the notification whitelist filter, we need to:

1. **Option A:** Make `p1` always 0 after line 6413
   - This would allow all notifications through regardless of whitelist status

2. **Option B:** Remove the XOR inversion at line 6413
   - Change `xor-int/2addr p1, v3` to do nothing

3. **Option C:** Skip the permission check entirely
   - Jump directly to cond_19 (allow notification)

**Recommended:** Option A - Setting `p1` to 0 immediately after the permission check is the cleanest approach. This makes the conditional at line 6433 always false, bypassing suppression.

## Implementation

Replace lines 6413 after the areNotificationsEnabledForPackageInt call:
```
xor-int/2addr p1, v3              # ORIGINAL: inverts boolean
```

With:
```
const/4 p1, 0x0                   # NEW: set p1 to always 0 (allow notification)
```

This ensures `if-eqz p1, :cond_19` at line 6433 is always true, skipping the suppression logic.
