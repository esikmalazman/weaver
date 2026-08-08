# CraftWeave — Craft Learning App Requirements

## 1. App Overview

CraftWeave is an Apple Vision Pro app that helps weaving artisans record and preserve their weaving techniques.

An artisan can record their **hand movements and voice explanations** while weaving. The app saves the hand joint movement data as a JSON file and saves voice recordings separately.

The recorded data can later be replayed using a **3D hand model**, allowing the artisan to review the weaving movement.

The main user for the MVP is the **weaving artisan**.

The MVP focuses on recording and replaying the artisan's hand movements. It does not use the Apple Vision Pro main camera.

---

# 2. Main Goals

1. Help artisans easily record their weaving hand movements.
2. Allow artisans to add voice explanations during recording.
3. Save hand movement data so it can be replayed later.
4. Replay the recorded movement using a 3D hand model.
5. Keep the recording process simple and quick.

---

# 3. User Stories

## US-001

As an artisan, I want to start a new recording so that I can document a weaving technique.

## US-002

As an artisan, I want to record my hand and finger movements so that I can replay the technique later.

## US-003

As an artisan, I want to add voice notes while recording so that I can explain important parts of the technique.

## US-004

As an artisan, I want to pause or stop a recording so that I can control the recording process.

## US-005

As an artisan, I want to name my recording so that I can find the technique later.

## US-006

As an artisan, I want to see my saved recordings so that I can review techniques I have documented.

## US-007

As an artisan, I want to replay my hand movements using a 3D hand model so that I can review the recorded technique.

## US-008

As an artisan, I want to see when I added voice notes so that I can listen to the explanation at the correct moment.

---

# 4. Features

## F-001 Start Recording

### What it does

Starts a new weaving technique recording.

The app starts tracking the artisan's hands.

### When it appears

When the artisan taps "New Recording".

### If something goes wrong

Show:

"Unable to start hand tracking."

Allow the artisan to try again.

---

## F-002 Record Hand Movement

### What it does

Records the position and rotation of the artisan's hand joints.

The app records the movement over time.

The movement data is saved as JSON.

### When it appears

After the artisan starts a new recording.

### If something goes wrong

Show:

"Hand movement could not be recorded."

Allow the artisan to try again.

---

## F-003 Record Voice Note

### What it does

Lets the artisan record a short voice explanation.

The voice note is connected to a specific point in the movement recording.

Example:

> "Pull the thread gently here."

### When it appears

While recording.

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

Keep the movement data recorded before the problem happened.

---

## F-005 Save Technique

### What it does

Saves the recorded hand movement data and voice recordings.

The artisan gives the technique a name.

Example:

"Basic Songket Weaving"

The hand movement data is saved as a JSON file.

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

Replays the recorded hand movements using a 3D hand model.

The app reads the saved JSON file and applies the recorded joint positions and rotations to the 3D hand.

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

The artisan can select a marker to hear the explanation.

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

* Hand tracking status.
* 3D hand preview.
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

* 3D hand model.
* Play button.
* Pause button.
* Replay timeline.
* Voice note markers.

### How to get here

Tap "Replay" from S-005.

---

# 6. Data

## D-001 — Recording

Information about one weaving recording.

Contains:

* Technique name.
* Recording date.
* Recording length.
* Hand movement data.
* Voice notes.

---

## D-002 — Hand Joint Data

The movement information recorded from the artisan's hands.

Each recorded moment contains:

* Timestamp.
* Left hand joint data.
* Right hand joint data.
* Joint position.
* Joint rotation.

This data is saved as JSON.

---

## D-003 — Voice Notes

Information about each voice note.

Contains:

* Audio file.
* Start time.
* End time.
* Position in the movement recording.

---

## D-004 — Saved Techniques

A list of all techniques recorded by the artisan.

---

## D-005 — Playback Information

Information needed while replaying a technique.

Contains:

* Current playback position.
* Playback state.
* Voice note positions.

---

## D-006 — Local Files

The app stores the recording files on the Apple Vision Pro.

Example:

```text
Technique/
├── basic-songket-weaving.json
├── voice-note-001.m4a
└── voice-note-002.m4a
```

The JSON file contains the hand movement data.

The audio files contain the artisan's voice notes.

---

## D-007 — Data Source and Storage Rules

* Hand movement data comes from Apple's hand tracking system.
* Hand movement data is collected using `HandTrackingProvider`.
* The app does not access the main camera.
* Hand movement data is saved as JSON.
* Voice notes are recorded by the artisan.
* Voice notes are saved as audio files.
* Recording data is stored locally on the Apple Vision Pro.
* The MVP does not require an internet connection.
* The MVP does not require a user account.
* The MVP does not require cloud storage.

---

# 7. Extra Details

* Build using Swift and SwiftUI.
* Build for Apple Vision Pro / visionOS.
* Use a simple MVVM structure.
* Use a small Design System.
* The Design System should contain:

  * Typography
  * Colors
  * 4-point Spacing
* Support Light Mode and Dark Mode.
* Microphone permission is required for voice notes.
* Hand tracking requires ARKit hand-tracking authorization.
* Camera permission is **not required**.
* Main camera access is **not required**.
* Location permission is not required.
* The app should work offline.
* Recordings should remain on the Apple Vision Pro.
* No learner account or social features are needed for the MVP.
* No cloud sharing is needed for the MVP.
* The MVP focuses on **artisan recording and replay**, not learner browsing.
* The hand movement JSON is used to drive a 3D hand model during replay.
* The MVP records scheduled hand-joint updates rather than video.

Apple provides `HandTrackingProvider` specifically for receiving live hand and joint data, and its `HandAnchor` contains the hand skeleton used for tracking.

---

# 8. Build Steps

* **B-001**: Create the visionOS project in Xcode using SwiftUI.

* **B-002**: Setup the basic Design System.

  * Add shared Typography.
  * Add shared Colors.
  * Add 4-point Spacing.

* **B-003**: Build **S-001 (Home Screen)**.

  * Add "New Recording".
  * Add recent techniques.
  * Add "View All".

* **B-004**: Setup hand tracking using **ARKit `HandTrackingProvider`**.

  * Request the required hand-tracking authorization.
  * Start the hand tracking session.
  * Read left and right hand joint data.

* **B-005**: Build **S-002 (Recording Screen)**.

  * Show hand tracking status.
  * Show a simple 3D hand preview.
  * Add recording timer.
  * Add voice note button.
  * Add pause button.
  * Add stop button.

* **B-006**: Add **F-002 (Record Hand Movement)**.

  * Read hand joint updates.
  * Record each update with a timestamp.
  * Save joint positions.
  * Save joint rotations.

* **B-007**: Add JSON recording.

  * Convert the recorded hand movement data into JSON.
  * Save the JSON file locally.
  * Make sure the JSON can be loaded again for replay.

* **B-008**: Add **F-003 (Record Voice Note)**.

  * Request microphone permission.
  * Record the artisan's voice.
  * Save the audio file.
  * Save the voice note start and end time.

* **B-009**: Add **F-004 (Pause and Stop Recording)**.

  * Allow the artisan to pause.
  * Allow the artisan to continue.
  * Allow the artisan to stop.
  * Keep all successfully recorded data.

* **B-010**: Build **S-003 (Save Recording Screen)**.

  * Enter technique name.
  * Preview recording information.
  * Save or delete the recording.

* **B-011**: Add **F-005 (Save Technique)** using **D-001, D-002, D-003, and D-006**.

* **B-012**: Build **S-004 (Technique Library)** using **D-004**.

* **B-013**: Build **S-005 (Technique Details)**.

* **B-014**: Build **S-006 (3D Replay Screen)**.

  * Load the saved JSON file.
  * Create the 3D hand model.
  * Prepare the hand joints for animation.

* **B-015**: Add **F-007 (3D Replay)** using **D-002 and D-005**.

  * Read the JSON movement data.
  * Move the 3D hand according to the recorded joint data.
  * Play the movement in the correct time order.
  * Pause the movement.
  * Replay the movement.
  * Move through the timeline.

* **B-016**: Add **F-008 (Voice Note Markers)**.

  * Show markers based on the saved voice note timestamps.
  * Allow the artisan to select a marker.
  * Play the corresponding audio recording.

* **B-017**: Add basic error handling.

  * Hand tracking unavailable.
  * Hand tracking permission denied.
  * Microphone permission denied.
  * Hand movement recording fails.
  * JSON cannot be saved.
  * Audio cannot be saved.
  * Recording cannot be loaded.
  * Recording cannot be replayed.

* **B-018**: Test the full artisan workflow.

  * Start recording.
  * Track hand movement.
  * Add voice notes.
  * Stop recording.
  * Save technique.
  * Open saved technique.
  * Replay the hand movement.
  * Play voice notes.


* **B-020**: Prepare the MVP for TestFlight.
