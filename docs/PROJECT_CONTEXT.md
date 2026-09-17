# Yamazaki Public Project Context

> Last verified from repository documentation: 2026-09-17

## Purpose

Yamazaki is an MIT-licensed, local, native macOS menu-bar utility for region OCR and screenshot translation.

## Technology And Entry Points

- SwiftPM with SwiftUI, AppKit, Apple Vision, and the macOS Translation framework.
- Main implementation: `Sources/FreeScanOCR/main.swift`.
- Build and verification: `swift build` and `./script/build_and_run.sh`.
- Packaging: `./script/package_dmg.sh`.
- Current documented version: `0.7.0`; verify `VERSION` before release work.

## Stable Boundaries

- OCR remains on-device and the app remains a menu-bar utility.
- Screen capture uses the system region-selection workflow.
- Translation depends on the system Translation framework.
- Snipaste is not bundled in the public release.
- Generated applications, DMGs, permission state, private history, and credentials stay outside Git.

## Current State And Risks

OCR, screenshot translation, customizable shortcuts, language options, watermark filtering, clipboard output, launch behavior, and packaging are implemented. Screen Recording permission remains sensitive to bundle identity and signature changes. Latest work state belongs in `docs/CURRENT_HANDOFF.md`.

## Repository Relationship

This repository is synchronized from a private working repository. Only reviewed and sanitized source changes may cross into the public project.
