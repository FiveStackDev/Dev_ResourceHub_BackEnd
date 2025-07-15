# 🏢 Organizations Module

> Multi-organizational settings and profile management for ResourceHub

## 📋 Overview

Manages organizational profiles, settings, and configurations with branding customization and communication capabilities.

---

## 🔗 API Endpoints

### 🏢 Organization Settings Service
**Base URL:** `http://localhost:9090/orgsettings`

| 🌐 Method | 🔗 Endpoint | 📝 Description | 👥 Access |
|-----------|-------------|----------------|-----------|
| `GET` | `/details/{orgid}` | Get organization profile details | Admin, SuperAdmin |
| `PUT` | `/profile/{orgid}` | Update organization profile | Admin, SuperAdmin |
| `PUT` | `/email/{orgid}` | Update organization email settings | Admin, SuperAdmin |
| `POST` | `/sendEmail` | Send organizational emails | Admin, SuperAdmin |

---

## ✨ Key Features

- 🏢 **Profile Management** - Complete organizational information
- ⚙️ **Settings Configuration** - Customizable preferences
- 📧 **Email Management** - Communication channel setup
- 🎨 **Branding & Customization** - Logos and visual identity
- 🏗️ **Multi-Organization Support** - Handle multiple organizations
- 📞 **Communication Tools** - Organizational messaging

---

## 📊 Data Model

### 🏷️ Organization Profile
```typescript
{
  org_name: string,           // Organization name
  org_logo: string,           // Logo URL/path
  org_address?: string,       // Physical address (optional)
  org_email?: string          // Primary email (optional)
}
```

---

## 🎯 Use Cases

- 🏢 **Corporate Environments** - Multiple departments/divisions
- 🎓 **Educational Institutions** - Different schools/faculties  
- 🏥 **Healthcare Systems** - Various hospitals/clinics
- 🏛️ **Government Agencies** - Different departments/offices
- 🛒 **Retail Chains** - Multiple store locations
