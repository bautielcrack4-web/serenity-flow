# Project Context: Yuna (Serenity Flow)

## Core Overview
Yuna is a high-end wellness and productivity application built with Flutter. It focuses on personalized routines, breathing exercises, and audio-guided meditation.

## Technical Architecture
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (Postgres, Auth, Realtime)
- **Payments**: RevenueCat (iOS & Android IAP)
- **State Management**: Mix of standard Flutter state and service-based architecture.

## Primary Features
- **Breathing & Meditation Sessions**: Interactive sessions with haptic feedback (`HapticService`) and audio playback (`AudioService`).
- **Personalized Routines**: AI-driven or template-based routines managed through `SupabaseService`.
- **Apple Authentication**: Primary sign-in method using `sign_in_with_apple`.
- **Premium Monetization**: Paywall implemented in `MonetizationScreen` with RevenueCat integration.

## Design System
- **Typography**: Uses the 'Outfit' font family.
- **Colors**: Advanced theme system with "Serene Dawn" (Light) and "Midnight Zen" (Dark/Premium) themes using glassmorphism and organic gradients.
- **Components**: High-brightness aesthetic with deep shadows and glow effects.

## Key Directories
- `lib/core`: Design system and app-wide constants.
- `lib/screens`: Feature-based screen organization (Auth, Home, Monetization, Session).
- `lib/services`: Core logic for external integrations (Audio, Supabase, RevenueCat).
- `lib/models`: Data structures for routines and user state.
