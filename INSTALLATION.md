# Viwoods Notification Unlocker v1.3.8 - Installation Guide

## Module Files
- **Viwoods-Notification-Unlocker-1.3.8.zip** - Flashable Magisk module (9.2MB)

## Installation Steps

### Via Magisk App (Recommended)

1. **Transfer the ZIP to your device** (USB, ADB, or file transfer)
   ```bash
   adb push Viwoods-Notification-Unlocker-1.3.8.zip /sdcard/Download/
   ```

2. **Open Magisk Manager app** on your Viwoods device

3. **Navigate to "Modules"** section

4. **Tap the "+" or "Install from storage" button**

5. **Select the ZIP file:**
   ```
   Viwoods-Notification-Unlocker-1.3.8.zip
   ```

6. **Wait for installation to complete** (usually 10-30 seconds)

7. **Reboot your device** (tap "Reboot" in Magisk app or power off/on)

### Via ADB Manual Installation

```bash
# Push the ZIP to device
adb push Viwoods-Notification-Unlocker-1.3.8.zip /data/adb/modules/

# Or extract and push directly (advanced)
adb push module /data/adb/modules/viwoods_notification_unlocker_1.3.8/
```

## What This Module Does

- **Patches:** `/system/framework/services.jar` (NotificationManagerService)
- **Effect:** Disables the Viwoods manufacturer notification whitelist
- **Result:** All apps can now send notifications, even if blocked by Viwoods

## Testing the Module

### After Installation

1. **Verify system boot:**
   - Device should boot normally (no bootloop)
   - system_server should not crash
   - No Safe Mode trigger

2. **Check Magisk app:**
   - The module should appear in "Modules" list as **active**
   - Status should show ✓ (checkmark)

3. **Test notifications:**
   - Install a test app (e.g., a messaging app blocked by Viwoods)
   - Send a test notification
   - **Expected:** Notification appears on lock screen/notification bar
   - **Previous behavior:** Notification was silently dropped

### Logcat Verification

```bash
adb logcat | grep -i notification
```

Look for lines like:
```
NotificationService: Suppressing notification...  (SHOULD NOT APPEAR AFTER PATCH)
NotificationManagerService: Notification posted  (SHOULD APPEAR WITH PATCH)
```

## Troubleshooting

### Module causes bootloop
- The system will automatically enter **Magisk Safe Mode** (hold Volume Down at boot)
- Magisk will disable the problematic module
- No need to re-flash or factory reset

### Module doesn't appear in Magisk app
- Ensure ZIP is properly extracted
- Check that all files are in place (module.prop, services.jar, post-fs-data.sh)
- Try re-flashing the ZIP

### Notifications still blocked after installation
- Verify module is **active** in Magisk app (shown with ✓)
- Try rebooting the device again
- Check if the app has notification permissions in Settings
- Run `adb logcat` and look for suppression messages

## Rollback/Uninstall

1. Open **Magisk app**
2. Go to **Modules**
3. Find **"Viwoods Notification Unlocker"**
4. Tap the **delete/trash icon**
5. **Reboot** when prompted
6. Notifications will return to normal (whitelist re-enabled)

## File Integrity

### Module Contents
```
module/
├── META-INF/
│   └── com/google/android/
│       ├── update-binary
│       └── updater-script
├── module.prop              (Module metadata)
├── post-fs-data.sh          (Installation script)
└── services.jar             (Patched framework for 1.3.8)
```

### Verify Patch
```bash
# Check that patch was applied to services.jar
# File size should be exactly 22M (23452288 bytes)
# MD5 should be: 9e51323354cf6f8467747fa7de850c96
adb shell md5sum /system/framework/services.jar
```

## Support & Reporting Issues

- **Device:** Viwoods E-Ink Reader
- **Firmware:** 1.3.8
- **Original Module:** https://github.com/ScreenSensitive/Viwoods-Notification-Unlocker
- **XDA Thread:** https://xdaforums.com/t/guide-unlock-bootloader-root-viwoods-reader-with-magisk.4772639/

If issues occur, document:
1. Bootloop (yes/no)
2. Logcat output during issue
3. Which apps still have blocked notifications
4. Device model and Magisk version
