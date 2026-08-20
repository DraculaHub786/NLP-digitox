# NLP-Digitox — n8n Workflow Integration (OTP Webhooks)

This document tracks the n8n workflows that handle OTP generation, email delivery, and verification for the forgot-password flow.

---

## Workflow URLs

The n8n instance is deployed at `https://n8n.nlpdigitox.me` and the three password-reset webhooks are live:

| Webhook | Live URL (HTTPS) |
|---------|-------------------|
| Request OTP | `https://n8n.nlpdigitox.me/webhook/request-otp` |
| Verify OTP | `https://n8n.nlpdigitox.me/webhook/verify-otp` |
| Reset Password | `https://n8n.nlpdigitox.me/webhook/reset-password` |

---

## n8n Host Configuration

### Production
```
N8N_HOST = n8n.nlpdigitox.me
N8N_PORT = 443
N8N_BASE_URL = https://n8n.nlpdigitox.me
```

---

## Workflow Descriptions

### 1. Request OTP (`/webhook/request-otp`)
- **Method:** POST
- **Input:** `{ "email": "user@example.com" }`
- **Output (success):** `{ "success": true, "message": "OTP sent to your email" }`
- **Output (error):** `{ "success": false, "error": "Error message" }`
- **Purpose:** Accepts an email, generates a 6-digit OTP, stores it (with expiry), and sends it via email.

### 2. Verify OTP (`/webhook/verify-otp`)
- **Method:** POST
- **Input:** `{ "email": "user@example.com", "otp": "123456" }`
- **Output (success):** `{ "success": true, "resetToken": "<token>" }`
- **Output (error):** `{ "success": false, "error": "Invalid or expired OTP" }`
- **Purpose:** Validates the OTP against stored value. Returns a one-time `resetToken` used in the final step.

### 3. Reset Password (`/webhook/reset-password`)
- **Method:** POST
- **Input:** `{ "email": "user@example.com", "resetToken": "<token>", "newPassword": "Str0ng!Pass" }`
- **Output (success):** `{ "success": true, "message": "Password reset successful" }`
- **Output (error):** `{ "success": false, "error": "Invalid or expired reset token" }`
- **Purpose:** Validates the reset token, updates the user's password in Firebase Auth, and invalidates the token.

---

## Deployment Checklist

- [x] Deploy n8n to a publicly reachable server (VPS, Railway, Render, or n8n Cloud)
- [x] Enable HTTPS on the n8n instance
- [x] Import/configure the three webhook workflows
- [x] Update the **Live URL** column in the table above
- [x] Update all three Flutter screens to use the live HTTPS URLs
- [ ] Test the full forgot-password flow end-to-end with a real device

---

## Flutter Files Using These URLs

Each screen has a `static const String _n8nBaseUrl` at the top of its state class set to the production base URL:

| Screen | File | Constant to Update | Webhook Used |
|--------|------|-------------------|-------------|
| Forgot Password — Request | `lib/ui/auth/forgot_password_request_screen.dart` | `_n8nBaseUrl` | `request-otp` |
| Forgot Password — OTP | `lib/ui/auth/forgot_password_otp_screen.dart` | `_n8nBaseUrl` | `verify-otp` |
| Forgot Password — New Password | `lib/ui/auth/forgot_password_new_screen.dart` | `_n8nBaseUrl` | `reset-password` |

---

> **Last Updated:** 20 August 2026
> **Status:** Live — webhooks configured against the deployed n8n instance at `https://n8n.nlpdigitox.me`.
> **Next:** Test the full forgot-password flow end-to-end with a real device.
