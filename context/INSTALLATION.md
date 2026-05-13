# Viwoods Notification Unlocker — Installation Guide

[← Back to README](../README.md) · [Project Context](CONTEXT.md) · [Technical Analysis](ANALYSIS.md)

## Requirements

- Viwoods AiPaper with firmware **1.1.0**, **1.2.3**, **1.3.8**, or **1.4.0**
- Unlocked bootloader
- **Magisk** installed (via patched `init_boot` image)
- Google Services enabled (see note below)

> **Important:** Enable Google Services BEFORE rooting. Enabling Google Services on a rooted device triggers a factory reset on Viwoods firmware.

---

## Installation

1. Download the ZIP matching your firmware version from **Releases**
2. Transfer it to your device (USB file transfer / MTP)
3. Open **Magisk → Modules → Install from storage**
4. Select the ZIP file
5. Reboot when prompted

---

## Verification

After rebooting, confirm the patch is active:

```sh
adb logcat | grep "eink"
```

If the patch is working, you should see **no output** — the `"eink project,Blocked notification"` log will be silent.

Check the patched file size:
```sh
adb shell ls -la /system/framework/services.jar
```

| Firmware | Expected size |
|----------|--------------|
| 1.4.0 | 22,609,231 bytes |
| 1.3.8 | 22,599,162 bytes |

---

## Testing Notifications

1. Install WhatsApp, Telegram, or any messaging app
2. Send yourself a test message from another device
3. The notification should appear on the Viwoods screen

**Gmail:** If Gmail notifications don't appear after installing the module, open Gmail → Menu → Settings → [your account] → Notifications → set to **"All new mail"**.

---

## Troubleshooting

**Module causes bootloop:**
Hold Volume Down during boot to enter Magisk Safe Mode — the module will be automatically disabled. No factory reset needed.

**Notifications still blocked:**
- Confirm the module is active in Magisk (green checkmark)
- Reboot and check `adb logcat | grep "eink"` — if still showing blocked messages, the patched `services.jar` may not be loading
- Verify `/system/framework/services.jar` file size matches the expected value above

**Google apps (Gmail, Drive) not receiving notifications:**
GMS (`com.google.android.gms`) notifications go through a separate code path not fully covered by the current patch. This is a known limitation and being investigated for a future version.

---

## Uninstall

1. Open **Magisk → Modules**
2. Remove **Viwoods Notification Unlocker**
3. Reboot — the original notification whitelist is restored

---

## Support

- GitHub Issues: https://github.com/magcrider/Viwoods-Notification-Unlocker/issues
- XDA Thread: https://xdaforums.com/t/guide-unlock-bootloader-root-viwoods-reader-with-magisk.4772639/
