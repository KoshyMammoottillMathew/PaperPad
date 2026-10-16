# PaperPad Privacy

PaperPad is designed around a simple principle: **your notes stay on your device**.

## Data collection

The current PaperPad source code does not collect personal information, note contents, usage analytics, advertising identifiers, telemetry or tracking data.

PaperPad has:

- no user accounts
- no analytics SDK
- no advertising SDK
- no tracking SDK
- no PaperPad backend or API
- no cloud database
- no iCloud or CloudKit synchronization
- no third-party SDK dependencies
- no location, contacts, camera, microphone or photo-library access

## Storage

Notes are encoded locally and stored using `UserDefaults` in the iOS App Group container shared by the PaperPad application and PaperPad widget.

The App Group exists so the widget can display the user's notes and update completion state without sending the data to an external service.

## Network communication

The current PaperPad application and widget contain no application-level networking code for transmitting notes or user information.

## Home Screen widget

If a user adds the PaperPad widget to their Home Screen, note text displayed by the widget may be visible to people who can see that device's Home Screen. PaperPad does not transmit that displayed content to the developer.

## Open-source verification

PaperPad is open source so its data handling can be inspected directly. Any future feature that introduces external data processing, analytics, advertising, telemetry, cloud synchronization or third-party data handling should require an explicit privacy review and an update to this document before release.

## Scope

This document describes the behavior of the PaperPad source code in this repository. It does not make guarantees about the operating system, modified builds distributed by third parties, or software added by downstream forks.
