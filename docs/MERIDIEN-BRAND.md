# MERIDIEN - Brand Guidelines

## Product Name

**MERIDIEN**

*Multi-tenant Enterprise Retail & Inventory Digital Intelligence Engine*

---

## Brand Identity

### Name Meaning & Symbolism

**MERIDIEN** (derived from "Meridian") represents:

- 📍 **Meridian Line** - A line of longitude that passes through a given place, symbolizing:
  - Central point of reference for navigation
  - Precision and accuracy in tracking
  - Global reach and connectivity
  
- 🌟 **Peak Performance** - Meridian also means the highest point or zenith:
  - Peak efficiency in business operations
  - Excellence in retail management
  - Summit of technological innovation

- 🧭 **Direction & Guidance** - A navigational reference:
  - Guiding businesses toward success
  - Clear direction in inventory management
  - Strategic intelligence for decision-making

---

## Brand Positioning

### Tagline Options

1. **"Navigate Your Business to Success"**
2. **"Your North Star for Retail Excellence"**
3. **"Intelligent Retail, Simplified"**
4. **"Where Business Meets Intelligence"**
5. **"Precision in Every Transaction"**

### Primary Tagline (Recommended)
**"Navigate Your Business to Success"**

---

## Visual Identity

### Color Palette

#### Primary Colors
```
Midnight Blue     #1A2332   RGB(26, 35, 50)    - Trust, stability, professionalism
Ocean Blue        #2563EB   RGB(37, 99, 235)   - Innovation, technology, intelligence
```

#### Secondary Colors
```
Emerald Green     #10B981   RGB(16, 185, 129)  - Growth, success, profit
Amber            #F59E0B   RGB(245, 158, 11)  - Energy, attention, alerts
```

#### Neutral Colors
```
Slate 900        #0F172A   RGB(15, 23, 42)    - Text primary
Slate 600        #475569   RGB(71, 85, 105)   - Text secondary
Slate 200        #E2E8F0   RGB(226, 232, 240) - Borders
White            #FFFFFF   RGB(255, 255, 255) - Background
```

#### Status Colors
```
Success Green    #059669   RGB(5, 150, 105)   - Completed, active
Warning Amber    #D97706   RGB(217, 119, 6)   - Pending, attention
Error Red        #DC2626   RGB(220, 38, 38)   - Cancelled, error
Info Blue        #0284C7   RGB(2, 132, 199)   - Information
```

### Typography

#### Primary Font Family
**Inter** (for UI/Digital)
- Weights: 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)
- Modern, clean, excellent readability

#### Secondary Font Family
**Poppins** (for Marketing/Headers)
- Weights: 400 (Regular), 600 (SemiBold), 700 (Bold)
- Friendly, professional, approachable

#### Monospace Font (for Code/Data)
**JetBrains Mono**
- For displaying order numbers, SKUs, tracking codes

### Logo Concept

```
╔══════════════════════════════════════╗
║                                      ║
║     ━━━╋━━━    MERIDIEN             ║
║     ━━━╋━━━                          ║
║                                      ║
║     Multi-tenant Enterprise Retail   ║
║     & Inventory Digital Intelligence ║
║                                      ║
╚══════════════════════════════════════╝

Symbol: Cross/Compass design (╋) representing:
- Cardinal directions (navigation)
- Intersection of business and technology
- Central hub for operations
```

---

## Brand Voice & Tone

### Voice Characteristics

**Professional yet Approachable**
- We speak with authority but remain accessible
- Technical when needed, simple when possible
- Confident but never arrogant

**Clear and Precise**
- No jargon unless necessary
- Direct communication
- Actionable insights

**Empowering and Supportive**
- We help businesses grow
- We simplify complex operations
- We celebrate customer success

### Tone Guidelines

#### When writing documentation:
✅ Clear, structured, step-by-step
✅ Use active voice
✅ Include examples
✅ Anticipate questions

#### When writing marketing copy:
✅ Focus on benefits, not just features
✅ Use customer success stories
✅ Emphasize ROI and efficiency
✅ Speak to pain points

#### When writing error messages:
✅ Explain what happened
✅ Suggest how to fix it
✅ Never blame the user
✅ Provide next steps

### Writing Examples

**❌ Bad:** "An error occurred while processing your request."

**✅ Good:** "We couldn't process your order. Please check that all required fields are filled and try again."

---

**❌ Bad:** "MERIDIEN is a SaaS platform with multi-tenant architecture."

**✅ Good:** "MERIDIEN helps you manage your entire retail operation from one place—track inventory, process orders, and grow your business."

---

## Product Naming Convention

### Full Product Name
**MERIDIEN** - Multi-tenant Enterprise Retail & Inventory Digital Intelligence Engine

### Short Reference
**MERIDIEN**

### Internal Code Name
`meridien` (lowercase, for technical use)

### Project Identifiers
- **GitHub Repo:** `meridien-backend`, `meridien-frontend`
- **Docker Images:** `meridien/api`, `meridien/web`
- **Database:** `meridien_production`, `meridien_dev`
- **API Namespace:** `/api/v1/meridien/...` or just `/api/v1/...`

### Module/Package Names

**Go Modules:**
```go
module github.com/yourorg/meridien-backend
```

**Dart/Flutter:**
```yaml
name: meridien
description: MERIDIEN - Navigate Your Business to Success
```

---

## File & Directory Naming

### Configuration Files
```
meridien.config.js
meridien.env.example
meridien-docker-compose.yml
```

### Documentation
```
MERIDIEN-SETUP.md
MERIDIEN-API-DOCS.md
MERIDIEN-USER-GUIDE.md
```

### Environment Variables
```
MERIDIEN_APP_NAME=MERIDIEN
MERIDIEN_VERSION=1.0.0
MERIDIEN_ENV=production
```

---

## API Response Branding

### Success Response
```json
{
  "success": true,
  "message": "Customer created successfully",
  "data": {...},
  "meta": {
    "powered_by": "MERIDIEN",
    "version": "1.0.0"
  }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Validation failed",
  "error": {...},
  "meta": {
    "powered_by": "MERIDIEN",
    "support": "support@meridien.com"
  }
}
```

---

## User Interface Elements

### Login Screen
```
╔════════════════════════════════════╗
║                                    ║
║          ━━━╋━━━                  ║
║         MERIDIEN                   ║
║                                    ║
║   Navigate Your Business to Success║
║                                    ║
║   Email:    [____________]         ║
║   Password: [____________]         ║
║                                    ║
║   [    Sign In    ]                ║
║                                    ║
╚════════════════════════════════════╝
```

### Dashboard Header
```
MERIDIEN | Dashboard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Today's Orders: 42  |  Revenue: $12,450
```

### Email Templates
```
Subject: Welcome to MERIDIEN

Dear [Name],

Welcome to MERIDIEN - your intelligent partner for retail success!

We're excited to help you streamline your operations and grow your business.

Best regards,
The MERIDIEN Team
Navigate Your Business to Success
```

---

## Marketing Messaging

### Value Propositions

**For Small Businesses:**
"Start managing your inventory and orders like an enterprise, without the enterprise cost."

**For Growing Businesses:**
"Scale your operations seamlessly with intelligent automation and real-time insights."

**For Multi-location Retailers:**
"Manage all your stores from one central hub with powerful multi-tenant capabilities."

**For Dropshippers:**
"From supplier to customer, track every order with precision and ease."

### Feature Highlights

**Intelligent Inventory**
"Never run out of stock or overorder. MERIDIEN predicts what you need, when you need it."

**Multi-tenant Architecture**
"One platform, unlimited businesses. Perfect for franchises, chains, and multi-brand operations."

**Real-time Intelligence**
"Know your numbers instantly. From sales to profits, every metric at your fingertips."

**Middle East Ready**
"Built for the region. Integrated with Posta, DHL, Aramex. Supports Arabic. VAT compliant."

---

## Social Media Presence

### Profile Bio
```
🧭 MERIDIEN - Navigate Your Business to Success
🏪 Enterprise-grade retail & inventory management
🌍 Built for Middle Eastern retailers
💡 Intelligent. Simple. Powerful.
🔗 [website]
```

### Hashtags
- #MERIDIEN
- #RetailIntelligence
- #InventoryManagement
- #BusinessGrowth
- #RetailTech
- #MERIDIENSuccess (for customer stories)

---

## Customer-Facing Documentation Style

### Headers
```markdown
# Welcome to MERIDIEN

## Getting Started with MERIDIEN

### Your First Order in MERIDIEN
```

### Feature Announcements
```markdown
🎉 **New in MERIDIEN v1.2**

We're excited to announce advanced reporting features...
```

### Tutorials
```markdown
📚 **MERIDIEN Tutorial: Managing Inventory**

In this guide, you'll learn how to...

Step 1: Navigate to Inventory
Step 2: Add a new product
...
```

---

## Legal & Copyright

### Copyright Notice
```
© 2024 MERIDIEN. All rights reserved.
MERIDIEN is a trademark of [Your Company Name].
```

### Footer Text
```
MERIDIEN - Multi-tenant Enterprise Retail & Inventory Digital Intelligence Engine
Navigate Your Business to Success
```

### License Headers (in code)
```go
/*
 * MERIDIEN - Multi-tenant Enterprise Retail & Inventory Digital Intelligence Engine
 * Copyright (c) 2024 [Your Company Name]
 * Licensed under [License Type]
 */
```

---

## Version Naming

### Version Format
**MERIDIEN v[MAJOR].[MINOR].[PATCH]**

Examples:
- MERIDIEN v1.0.0 (Initial MVP)
- MERIDIEN v1.1.0 (Production features added)
- MERIDIEN v2.0.0 (Major architecture changes)

### Release Code Names (Optional)
Based on navigation/exploration themes:
- **v1.0 "Navigator"** - MVP Release
- **v1.5 "Explorer"** - Production Ready
- **v2.0 "Voyager"** - Enterprise Scale

---

## Support & Community

### Support Email
`support@meridien.com` or `hello@meridien.com`

### Documentation Site
`docs.meridien.com` or `meridien.com/docs`

### Community Forum
`community.meridien.com`

### Status Page
`status.meridien.com`

---

## Environment-Specific Branding

### Development
```
MERIDIEN [DEV]
🔧 Development Environment
```

### Staging
```
MERIDIEN [STAGING]
⚠️ Staging Environment - For Testing Only
```

### Production
```
MERIDIEN
Navigate Your Business to Success
```

---

## Do's and Don'ts

### ✅ DO:
- Use "MERIDIEN" in all caps when referring to the product
- Use the tagline "Navigate Your Business to Success"
- Emphasize intelligence, precision, and navigation themes
- Focus on empowering businesses
- Highlight multi-tenant capabilities
- Showcase Middle Eastern market features

### ❌ DON'T:
- Write "Meridien" or "meridien" in user-facing content
- Use "BM" or "Business Management" as product name
- Overuse technical jargon in marketing
- Make promises we can't keep
- Compare negatively to competitors
- Use generic stock photos

---

## Competitive Positioning

### We are NOT:
- Just another inventory app
- A generic POS system
- Enterprise-only (too expensive for small business)
- One-size-fits-all

### We ARE:
- Intelligent and adaptive
- Built specifically for Middle Eastern retail
- Scalable from 1 to 100+ businesses
- Focused on ROI and efficiency
- Multi-tenant by design
- Powered by modern technology

---

## Launch Messaging

### Pre-launch Teaser
```
🧭 Something intelligent is coming...

Retail management, reimagined.
Coming [Date]

MERIDIEN
Navigate Your Business to Success
```

### Launch Announcement
```
🎉 Introducing MERIDIEN

The intelligent platform that transforms how you manage your retail business.

✅ Real-time inventory tracking
✅ Automated order processing
✅ Multi-store management
✅ Integrated shipping (Posta, DHL, Aramex)
✅ Powerful analytics

From your first sale to your thousandth, MERIDIEN grows with you.

Start your journey → [Link]
```

---

## Customer Success Stories Format

```
📈 [Company Name] Success Story

"MERIDIEN helped us reduce stockouts by 80% and increase revenue by 35%"
- [Name], [Title] at [Company]

The Challenge:
[Description of problem]

The Solution:
[How MERIDIEN helped]

The Results:
• [Metric 1]
• [Metric 2]
• [Metric 3]

#MERIDIENSuccess
```

---

## Internal Communication

### Slack/Teams Channel Names
- `#meridien-dev`
- `#meridien-product`
- `#meridien-support`
- `#meridien-releases`

### Meeting Titles
- "MERIDIEN Sprint Planning"
- "MERIDIEN Product Review"
- "MERIDIEN Customer Feedback Session"

---

## Merchandise & Swag Ideas (Future)

- T-shirts with compass logo and "Navigate Your Business"
- Notebooks with navigation/journey themes
- Stickers with "Powered by MERIDIEN"
- Coffee mugs with dashboard mockups

---

**Brand Guidelines Version:** 1.0  
**Last Updated:** 2025-12-23  
**Status:** Official - Use for all MERIDIEN communications

---

## Quick Reference

**Product Name:** MERIDIEN  
**Tagline:** Navigate Your Business to Success  
**Primary Color:** Ocean Blue (#2563EB)  
**Font:** Inter  
**Symbol:** ╋ (Compass cross)  
**Voice:** Professional, Clear, Empowering  

---

**This document is the single source of truth for all MERIDIEN branding.**
