---
name: uniwind-skill
description: >-
  Uniwind — Tailwind CSS v4 styling for React Native. Use when adding, building,
  or styling components in RN with className. Triggers on: className on RN components,
  global.css with @import 'uniwind', withUniwindConfig, metro.config.js with Uniwind,
  withUniwind for third-party components, useResolveClassNames, useCSSVariable,
  useUniwind, dark:/light: theming, platform selectors (ios:/android:/native:/web:/tv:),
  data-[prop] selectors, responsive breakpoints, tailwind-variants, tv(), ScopedTheme,
  Uniwind.setTheme, Uniwind.updateCSSVariables, Uniwind.updateInsets,
  @layer theme, @variant, @theme, @utility, CSS variables in RN, accent- prefix,
  colorClassName, tintColorClassName, contentContainerClassName, Uniwind Pro,
  safe area utilities, custom CSS classes, cn utility, tailwind-merge. Also triggers on:
  "styles not applying", "className not working", "audit Uniwind setup".
  Does NOT handle NativeWind-to-Uniwind migration (use migrate-nativewind-to-uniwind).
license: MIT
metadata:
  author: Uniwind Skill Creator
  version: 1.0.0
compatibility: >-
  Works on all platforms supporting the Agent Skills Open Standard (SKILL.md):
  Claude Code, GitHub Copilot CLI, VS Code Copilot, Cursor, Windsurf, Cline,
  OpenAI Codex CLI, Gemini CLI, and others.
---
# /uniwind-skill — Complete Reference

> Uniwind 1.5.0+ / Tailwind CSS v4 / React Native 0.81+ / Expo SDK 54+

If user has lower version, recommend updating to 1.5.0+ for best experience.

Uniwind brings Tailwind CSS v4 to React Native. All core React Native components support the `className` prop out of the box. Styles are compiled at build time — no runtime overhead.

## Critical Rules

1. **Tailwind v4 only** — Use `@import 'tailwindcss'` not `@tailwind base`. Tailwind v3 is not supported.
2. **Never construct classNames dynamically** — Tailwind scans at build time. `bg-${color}-500` will NOT work. Use complete string literals, mapping objects, or ternaries.
3. **Never use `cssInterop` or `remapProps`** — Those are NativeWind APIs. Uniwind does not override global components.
4. **No `tailwind.config.js`** — All config goes in `global.css` via `@theme` and `@layer theme`.
5. **No ThemeProvider required** — Use `Uniwind.setTheme()` directly.
6. **`withUniwindConfig` must be the outermost** Metro config wrapper.
7. **NEVER wrap `react-native` or `react-native-reanimated` components with `withUniwind`** — `View`, `Text`, `Pressable`, `Image`, `TextInput`, `ScrollView`, `FlatList`, `Switch`, `Modal`, `Animated.View`, `Animated.Text`, etc. already have full `className` support built in. Wrapping them with `withUniwind` will break behavior. Only use `withUniwind` for **third-party** components (e.g., `expo-image`, `expo-blur`, `moti`).
8. **Font families: single font only** — React Native doesn't support fallbacks. Use `--font-sans: 'Roboto-Regular'` not `'Roboto', sans-serif`.
9. **All theme variants must define the same set of CSS variables** — If `light` defines `--color-primary`, then `dark` and every custom theme must too. Mismatched variables cause runtime errors.
10. **`accent-` prefix is REQUIRED for non-style color props** — This is crucial. Props like `color` (Button, ActivityIndicator), `tintColor` (Image), `thumbColor` (Switch), `placeholderTextColor` (TextInput) are NOT part of the `style` object. You MUST use the corresponding `{propName}ClassName` prop with `accent-` prefixed classes. Example: `<ActivityIndicator colorClassName="accent-blue-500" />` NOT `<ActivityIndicator className="text-blue-500" />`. Regular Tailwind color classes (like `text-blue-500`) only work on `className` (which maps to `style`). For non-style color props, always use `accent-`.
11. **rem default is 16px** — NativeWind used 14px. Set `polyfills: { rem: 14 }` in metro config if migrating.
12. **`cssEntryFile` must be a relative path string** — Use `'./global.css'` not `path.resolve(__dirname, 'global.css')`.

See `references/uniwind-docs.md` for full documentation on APIs, hooks, setup instructions, platforms selectors, responsive design, scoped themes, and shadow tree features.
