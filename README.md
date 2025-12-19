# Viwoods Notification Unlocker (Magisk Module)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)](https://www.android.com/)
[![Magisk](https://img.shields.io/badge/Magisk-30.5%2B-00B39B.svg)](https://github.com/topjohnwu/Magisk)

A Magisk module that removes the hardcoded notification whitelist on Viwoods eink reader devices, allowing all apps to display notifications.

***

## 📱 **Compatibility**

**Tested Configuration:**
- **Device:** Viwoods Reader  
- **ViWoods Software Version:** 1.1.0

**Other Viwoods Devices:**
- May work on other Viwoods eink readers *(untested)*
- Different software versions may have different patch locations
- **Use at your own risk**

**Requirements:**
- **Unlocked bootloader**
- **Rooted with Magisk 30.5+** *(patched init_boot.img via Magisk app required)*

> ⚠️ **WARNING:** This module is **specifically tested ONLY on Viwoods software version 1.1.0**. Other versions may have different code structure and the patch may not work or could cause issues.

---

## 🔍 **The Problem**

Viwoods eink readers implement aggressive notification blocking through a **hardcoded whitelist** in the Android framework. Only pre-approved apps can display notifications.

### **Technical Details**
**Location:** `/system/framework/services.jar`
- **DEX File:** `classes2.dex`
- **Class:** `com.android.server.notification.NotificationManagerService`
- **Method:** `enqueueNotificationInternal()`
- **Smali Line:** 9366

**Blocking Behavior:**
```java
// Pseudocode
if (!ALLOWED_PKGS.contains(packageName)) {
    Log.d(TAG, "eink project,Blocked notification from package: " + packageName);
    return; // Notification dropped
}
```

**Result:** Third-party apps *(Signal, Telegram, Gmail, etc.)* cannot display notifications.

***

## ✅ **The Solution**

**Patches line 9366** in `NotificationManagerService.smali`:

| **Original** | **Patched** |
|--------------|-------------|
| `if-nez v2, :cond_68` | `goto :cond_68` |

**Effect:** Bypasses whitelist check entirely - **all apps work**.

**Systemless** via Magisk - fully reversible.

***

## 📦 **Module Installation**

**Requires rooted device with Magisk 30.5+**

1. Download `.zip` from Releases
2. **Magisk Manager** → **Modules** → **Install from storage**
3. Select `.zip` → **Reboot**

**Recommended:** InkOS Launcher for notification tray.

---

## 🗑️ **Uninstallation**

**Magisk Manager** → **Modules** → **Viwoods Notification Unlocker** → **Trash** → **Reboot**

***

## 📊 **Before & After**

| **Before** | **After** |
|------------|-----------|
| `eink project,Blocked notification from package: org.telegram.messenger` | ✅ **No blocking messages** |
| ❌ **Third-party apps blocked** | ✅ **All apps work** |

---

## ⚠️ **Warnings**

- **Tested ONLY on Viwoods Reader (Non color) 1.1.0**
- OTA updates may break module
- **Use at your own risk**

***

## 🔧 **Technical**

**SELinux Enforcing compatible** via `post-fs-data.sh`:
```bash
chcon u:object_r:system_file:s0 "$MODDIR/system/framework/services.jar"
```

***

## ⚖️ **Disclaimer**

**"AS IS"** - no warranty. Not responsible for bricked devices, data loss, or voided warranties.

**Star ⭐ if it helped!**
