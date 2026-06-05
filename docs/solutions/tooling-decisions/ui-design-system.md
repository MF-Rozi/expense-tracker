---
title: UI Design System Specification - The Financial Atelier
status: active
date: 2026-06-04
---

# Visual Language & Tokens

## 🎨 Color Palette (Material 3 Alignment)

- **Primary Brand Gradient:** `LinearGradient(colors: [Color(0xFF00113A), Color(0xFF002366)])` (Used for Hero banners and primary buttons)
- **Surface Background:** `Color(0xFFF8F9FA)` (Soft, minimal gray background)
- **Text On-Surface:** `Color(0xFF191C1D)` (High contrast charcoal)
- **Text On-Surface-Variant:** `Color(0xFF444650)` (Slate gray for subtitles and labels)
- **Accent Containers:**
  - Lifestyle/Shopping: `Primary Container` overlays
  - Essential/Dining: `Secondary Container` soft green (`#A0F399`)
  - Fixed Costs/Housing: `Tertiary Container` soft red/rose (`#FFDAD6`)

## 📐 Typography & Shapes

- **Headlines (Display/Titles):** `Manrope` (Font weight: Extrabold/Bold for premium editorial look)
- **Body & Labels (Utility/Forms):** `Inter` (Font weight: Medium/Regular for crisp legibility)
- **Capsule Geometry:** All structural containers utilize full-radius parameters (`borderRadius: BorderRadius.circular(100)` or `StadiumBorder`) to build the "layered capsule" appearance.

# Feature Layout Specs: Category Management

## 1. Portfolio Distribution Header

A full-width primary gradient stadium capsule displaying total "Active Envelopes" with a nested horizontal distribution tracking bar highlighting budget allocations visually.

## 2. Asymmetric Category List Tile

A grid array of container capsules holding:

- An absolute-positioned background icon watermark set to `5% opacity`.
- A custom themed circular avatar box holding a sharp Material Symbol icon.
- A trailing `edit` button link.
- Category name styled in bold `Manrope`.

## 3. Interactive Placeholders

Add-actions utilize a matching stadium footprint defined by a light dashed border (`border-type: dashed`, color: `outline-variant`) holding an `add_circle` emblem and a tracking title string.
