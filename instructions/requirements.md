# CraftWeave — Craft Learning App Requirements

## 1. App Overview

CraftWeave is an Apple Vision Pro app that helps weaving artisans record and preserve their weaving techniques.

An artisan can record their hand and finger movements while weaving, add voice explanations at important moments, and save the recording as a 3D learning reference.

The main user for the MVP is the **weaving artisan**. The app helps artisans document their knowledge so it can be replayed and shared with future learners.

---

# 2. Main Goals

1. Help artisans easily record their weaving techniques.
2. Help artisans explain important steps using voice notes.
3. Preserve the recorded weaving process for future learning.
4. Make it easy for artisans to review their own recordings.
5. Keep the recording process simple and quick.

---

# 3. User Stories

## US-001

As an artisan, I want to start a new recording so that I can document a weaving technique.

## US-002

As an artisan, I want to record my hand and finger movements so that the weaving technique can be replayed later.

## US-003

As an artisan, I want to add voice notes while recording so that I can explain important parts of the technique.

## US-004

As an artisan, I want to pause or stop a recording so that I can control the recording process.

## US-005

As an artisan, I want to name my recording so that I can find the technique later.

## US-006

As an artisan, I want to see my saved recordings so that I can review techniques I have documented.

## US-007

As an artisan, I want to replay a recording in 3D so that I can check whether the recorded movement was captured correctly.

## US-008

As an artisan, I want to see where I added voice notes so that I can understand the explanations connected to each movement.

---

# 4. Features

## F-001 Start Recording

### What it does

Starts a new weaving technique recording.

The app prepares the camera and recording area.

### When it appears

When the artisan taps "New Recording".

### If something goes wrong

Show:

"Unable to start recording."

Allow the artisan to try again.

---

## F-002 Record Hand Movement

### What it does

Records the artisan's hand and finger movements while weaving.

The app captures the movement as 3D data for later replay.

### When it appears

After the artisan starts a new recording.

### If something goes wrong

Show:

"Movement recording stopped."

Allow the artisan to try again.

---

## F-003 Add Voice Note

### What it does

Lets the artisan record a short voice explanation.

The voice note is connected to the point in the movement recording where it was created.

Example:

> "Pull the thread gently here."

### When it appears

While recording or reviewing a recording.

### If something goes wrong

Show:

"Unable to record voice note."

Allow the artisan to try again.

---

## F-004 Pause and Stop Recording

### What it does

Allows the artisan to pause or stop the recording.

### When it appears

During a recording.

### If something goes wrong

Keep the recorded movement up to the last successful point.

---

## F-005 Save Technique

### What it does

Saves the recorded movement and voice notes on the Apple Vision Pro

The artisan gives the recording a name.

Example:

"Basic Songket Weaving"

### When it appears

After the artisan stops recording.

### If something goes wrong

Show:

"Unable to save technique."

Allow the artisan to try again.

---

## F-006 Technique Library

### What it does

Shows all weaving techniques recorded by the artisan.

Each item shows:

* Technique name
* Date
* Recording length

### When it appears

From the Home Screen.

### If something goes wrong

Show:

"No techniques recorded yet."

---

## F-007 3D Replay

### What it does

Replays the recorded hand and finger movements in 3D.

The artisan can:

* Play
* Pause
* Replay
* Move through the timeline

### When it appears

When the artisan opens a saved technique.

### If something goes wrong

Show:

"Unable to play recording."

---

## F-008 Voice Note Markers

### What it does

Shows markers on the replay timeline where the artisan added voice notes.

The artisan can tap a marker to hear the explanation.

### When it appears

During 3D replay.

### If something goes wrong

Show:

"Voice note unavailable."

The movement replay should continue.

---

# 5. Screens

## S-001 Home Screen

### What is on the screen

* "New Recording" button.
* Recent techniques.
* "View All" button.

### How to get here

This is the first screen when opening the app.

---

## S-002 Recording Screen

### What is on the screen

* Camera recording area.
* Hand movement preview.
* Recording timer.
* Voice note button.
* Pause button.
* Stop button.

### How to get here

Tap "New Recording" from S-001.

---

## S-003 Save Recording Screen

### What is on the screen

* Recording preview.
* Recording name field.
* Save button.
* Delete button.

### How to get here

Appears after the artisan stops recording.

---

## S-004 Technique Library

### What is on the screen

* List of saved techniques.
* Technique name.
* Recording date.
* Recording length.

### How to get here

Tap "View All" from S-001.

---

## S-005 Technique Details

### What is on the screen

* Technique name.
* Recording date.
* Recording length.
* Number of voice notes.
* Replay button.

### How to get here

Tap a technique from S-004.

---

## S-006 3D Replay Screen

### What is on the screen

* 3D hand movement.
* Play button.
* Pause button.
* Replay timeline.
* Voice note markers.

### How to get here

Tap "Replay" from S-005.

---

# 6. Data

## D-001

Recorded weaving technique.

Contains:

* Technique name.
* Recording date.
* Recording length.
* Hand and finger movement data.

---

## D-002

Voice notes.

Contains:

* Voice recording.
* Position in the movement recording.
* Recording length.

---

## D-003

Saved technique list.

A list of all techniques recorded by the artisan.

---

## D-004

3D movement data.

The hand and finger movement information needed to replay the technique.

---

## D-005

Recording playback information.

Contains:

* Current playback position.
* Voice note positions.
* Playback state.

---

## D-006

Local recording storage.

The recorded movement and voice notes are saved on the iPhone.

---

## D-007 — Data Source and Storage Rules

* Movement recordings are created by the artisan using the iPhone.
* Voice notes are recorded by the artisan.
* Recordings are stored locally on the iPhone.
* The MVP does not require an internet connection.
* The MVP does not require a user account.
* The MVP does not require cloud storage.

---

# 7. Extra Details

* Build using Swift and SwiftUI.
* Use a simple MVVM structure.
* Use a small Design System.
* The Design System should contain:

  * Typography
  * Colors
  * 4-point Spacing
* Support Light Mode and Dark Mode.
* Camera permission is required for movement recording.
* Microphone permission is required for voice notes.
* Location permission is not required.
* The app should work offline.
* Recordings should remain on the iPhone.
* No learner account or social features are needed for the MVP.
* No cloud sharing is needed for the MVP.
* The MVP focuses on **artisan recording**, not learner browsing.
* The 3D replay is mainly used by the artisan to check and review their recorded technique.

---

# 8. Build Steps

* **B-001**: Create the iOS project in Xcode using SwiftUI.

* **B-002**: Setup the basic Design System.

  * Add shared Typography.
  * Add shared Colors.
  * Add 4-point Spacing.

* **B-003**: Build **S-001 (Home Screen)**.

  * Add "New Recording".
  * Add recent techniques.
  * Add "View All".

* **B-004**: Build **S-002 (Recording Screen)**.

* **B-005**: Add **F-001 (Start Recording)**.

  * Request camera permission.
  * Prepare the recording area.
  * Start the recording timer.

* **B-006**: Add **F-002 (Record Hand Movement)**.

  * Capture hand and finger movement.
  * Store the movement data.
  * Show the movement preview.

* **B-007**: Add **F-003 (Add Voice Note)**.

  * Request microphone permission.
  * Record the artisan's voice.
  * Save the voice note position.

* **B-008**: Add **F-004 (Pause and Stop Recording)**.

  * Allow the artisan to pause.
  * Allow the artisan to stop.
  * Keep the recorded data.

* **B-009**: Build **S-003 (Save Recording Screen)**.

* **B-010**: Add **F-005 (Save Technique)** using **D-001, D-002, and D-006**.

  * Enter technique name.
  * Save movement data.
  * Save voice notes.

* **B-011**: Build **S-004 (Technique Library)** using **D-003**.

* **B-012**: Build **S-005 (Technique Details)**.

* **B-013**: Build **S-006 (3D Replay Screen)**.

* **B-014**: Add **F-007 (3D Replay)** using **D-004 and D-005**.

  * Play movement.
  * Pause movement.
  * Replay movement.
  * Move through the timeline.

* **B-015**: Add **F-008 (Voice Note Markers)**.

  * Show markers on the timeline.
  * Allow the artisan to play each voice note.

* **B-016**: Add basic error handling.

  * Camera permission denied.
  * Microphone permission denied.
  * Movement recording fails.
  * Voice recording fails.
  * Recording cannot be saved.
  * Recording cannot be replayed.

* **B-017**: Test the full artisan workflow.

  * Start recording.
  * Record movement.
  * Add voice notes.
  * Stop recording.
  * Save technique.
  * Open saved technique.
  * Replay movement.

* **B-018**: Improve the UI.

  * Check spacing.
  * Check typography.
  * Check Light Mode.
  * Check Dark Mode.
  * Check accessibility.

* **B-019**: Prepare the MVP for TestFlight.
