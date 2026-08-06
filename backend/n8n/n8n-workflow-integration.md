# NLP-Digitox — n8n Workflow Integration (OTP Webhooks)

This document tracks the n8n workflows that handle OTP generation, email delivery, and verification for the forgot-password flow.

---

## Workflow URLs

> **⚠️ IMPORTANT:** These URLs currently point to `localhost` for local development only.
> Before shipping to real users, n8n must be deployed to a publicly reachable server with HTTPS.
> Once deployed, update the URLs in the Flutter app (`lib/ui/auth/forgot_password_request_screen.dart`,
> `lib/ui/auth/forgot_password_otp_screen.dart`, `lib/ui/auth/forgot_password_new_screen.dart`)
> and update the table below.

| Webhook | Local URL | Live URL (HTTPS) |
|---------|-----------|-------------------|
| Request OTP | `http://localhost:5678/webhook-test/request-otp` | *(deploy first, then update)* |
| Verify OTP | `http://localhost:5678/webhook-test/verify-otp` | *(deploy first, then update)* |
| Reset Password | `http://localhost:5678/webhook-test/reset-password` | *(deploy first, then update)* |

---

## n8n Host Configuration

### Local Development
```
N8N_HOST = localhost
N8N_PORT = 5678
N8N_BASE_URL = http://localhost:5678
```

### Production (to be filled after deployment)
```
N8N_HOST = <your-deployed-host>
N8N_PORT = 443
N8N_BASE_URL = https://<your-deployed-host>
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

- [ ] Deploy n8n to a publicly reachable server (VPS, Railway, Render, or n8n Cloud)
- [ ] Enable HTTPS on the n8n instance
- [ ] Import/configure the three webhook workflows
- [ ] Update the **Live URL** column in the table above
- [ ] Update all three Flutter screens to use the live HTTPS URLs
- [ ] Test the full forgot-password flow end-to-end with a real device

---

## Flutter Files Using These URLs

Each screen has a `static const String _n8nBaseUrl` at the top of its state class. To switch from local to production, change this one line in each file:

| Screen | File | Constant to Update | Webhook Used |
|--------|------|-------------------|-------------|
| Forgot Password — Request | `lib/ui/auth/forgot_password_request_screen.dart` | `_n8nBaseUrl` | `request-otp` |
| Forgot Password — OTP | `lib/ui/auth/forgot_password_otp_screen.dart` | `_n8nBaseUrl` | `verify-otp` |
| Forgot Password — New Password | `lib/ui/auth/forgot_password_new_screen.dart` | `_n8nBaseUrl` | `reset-password` |

### Quick Switch — Find & Replace

When n8n is deployed, do a project-wide find & replace:

```
Find:    http://localhost:5678
Replace: https://<your-deployed-host>
```

This will update all 3 screens at once.

---

> **Last Updated:** 30 July 2026
> **Current Base URL:** `http://localhost:5678` (local development)
> **Status:** Local development — webhooks configured against localhost n8n instance.
> **Next:** Deploy n8n → update URL above → test end-to-end from a real device.
