---
description: 'Color and styling rules for accessible, professional web designs'
applyTo: '**/*.css, **/*.scss, **/*.tsx, **/*.jsx, **/*.vue, **/*.html, **/*.svelte'
---

# CSS Color & Style Guide

Follow these rules when creating or modifying styles.

## 60-30-10 Rule

- **60% Primary**: Background, large surfaces → Cool/neutral (white, light gray, light blue)
- **30% Secondary**: UI elements, cards → Cool/neutral tones
- **10% Accent**: CTAs, highlights → Can be warm/bright

## Background Colors

**Use:**
- White, off-white (#ffffff, #f9fafb)
- Light cool colors (light blues, light grays)
- Subtle neutral tones (#f3f4f6, #e5e7eb)

**Never use:**
- Red, orange, yellow backgrounds
- Purple, magenta, pink
- Any saturated/hot color as primary background

## Text Colors

**High contrast (required):**
- Dark text on light: #1f2937, #111827, #374151
- Light text on dark: #f9fafb, #e5e7eb
- Minimum contrast ratio: 4.5:1 (WCAG AA)

**Never use:**
- Yellow text (poor readability)
- Pink text
- Low contrast combinations

## Hot Colors (Red, Orange, Yellow)

**Reserve for:**
- Error states and alerts
- Warnings and critical actions
- Delete/destructive buttons
- Required field indicators

**Never use for:**
- Backgrounds
- Regular buttons
- Decorative elements
- Large UI areas

## Gradients

**Best practices:**
- Keep color shifts minimal (#E6F2FF → #F5F7FA)
- Stay within same color family
- Prefer linear over radial for backgrounds
- Never mix hot and cool in one gradient

## Quick Reference

```css
/* Safe text colors */
--text-primary: #1f2937;
--text-secondary: #4b5563;
--text-muted: #6b7280;

/* Safe backgrounds */
--bg-primary: #ffffff;
--bg-secondary: #f9fafb;
--bg-tertiary: #f3f4f6;

/* Accent (use sparingly) */
--accent-primary: #2563eb;  /* Blue */
--accent-success: #059669;  /* Green */
--accent-warning: #d97706;  /* Amber - warnings only */
--accent-error: #dc2626;    /* Red - errors only */
```
