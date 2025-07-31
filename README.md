# ConfinedandUnbound

# 2D Remake of a Childhood Game — Built in RPG Maker XP

### Description

- A behavior-driven 2D pixel-art remake of a nostalgic 3D childhood game, created using RPG Maker XP and RGSS.
- Developed from gameplay footage, the project aims to faithfully capture the original experience while introducing improvements in story pacing, interaction design, and scripting efficiency.

---

## NOTICE

- Please read through this `README.md` to better understand the project's source code and setup instructions.
- Also, make sure to review the contents of the `License/` directory.
- Your attention to these details is appreciated — enjoy exploring the project!

---

## Problem Statement

- The original 3D childhood game is no longer accessible on modern platforms and has no official remakes. This project reconstructs it from scratch, serving both as a tribute and a learning opportunity in game design and behavior-driven development.

---

## Project Goals

### Recreate the Original Game Experience

- Translate a beloved 3D game into a 2D format while preserving its mechanics, narrative, and atmosphere.

### Learn and Apply Event-Driven Development

- Use RGSS scripting within RPG Maker XP to build interactive events, game logic, and cutscenes.

---

## Tools, Materials & Resources

### Tools

- RPG Maker XP — 2D game engine tailored for classic RPG development.
- Paint.net — Lightweight pixel-art editor for character sprites, tilesets, and animations.

### Materials

- YouTube Gameplay Footage — Primary reference source for scene reconstruction, dialogue, and combat design.

### Resources

- RGSS Documentation — Core scripting reference for building custom behavior logic and UI components.

---

## Design Decision

### 2D Isometric Mapping

- Chose pixel-art representation to fit RPG Maker XP's limitations while still capturing the 3D game's spatial logic.

### Event-Driven Scripting

- Leveraged RPG Maker’s event system and RGSS for scene transitions, dialogue trees, and game state handling.

### Animation Fidelity

- Developed custom animations to reflect original boss behavior, physics, and special effects using RGSS scripting.

---

## Features

### Core Gameplay Loop

- Faithful recreation of exploration, story events, puzzles, and boss fights.

### Enhanced Narrative Structure

- Improved pacing, user interaction, and dialogue branching with cleaner progression logic.

### Custom Sprite Assets

- Hand-drawn pixel-art recreations of characters, environments, and transitions.

---

## Block Diagram

```plaintext
                                 ┌─────────────────────────┐
                                 │     Player Input Loop   │
                                 └────────────┬────────────┘
                                              ↓
                            ┌────────────────────────────────┐
                            │ RPG Maker XP Event Engine Loop │
                            └────────────┬─────────────┬─────┘
                                         ↓             ↓
                             ┌────────────────┐  ┌──────────────┐
                             │   Scene Logic  │  │ Dialogue Tree│
                             └────────────────┘  └──────────────┘
                                       ↓
                             ┌────────────────────┐
                             │   Cutscene Manager │
                             └─────────┬──────────┘
                                       ↓
                             ┌────────────────────┐
                             │    Battle Engine   │
                             └────────────────────┘
							 
```

---

## Functional Overview

- This game uses a combination of RGSS scripting and RPG Maker XP’s event system to manage player actions, transitions, and in-game logic. Scenes are initiated via event triggers and scripted with precise control over timing, animations, and conditions.

---

## Challenges & Solutions

### 3D-to-2D Spatial Design

- Preserved gameplay logic and spatial navigation by carefully studying and mapping each 3D scene into a functional 2D environment.

### Boss AI Recreation

- Without access to original code, recreated AI patterns using frame-by-frame video analysis and scripted behavior trees.

---

## Lessons Learned

### Game Design Insights

- Built a deeper understanding of scene sequencing, user control flow, and modular event handling.

### Technical Proficiency

- Gained experience working with RGSS for scripting game mechanics, custom UI, and behavior-driven development cycles.

---

## Project Structure

```plaintext
root/
├── License/
│   ├── LICENSE.md
│   │
│   └── NOTICE.md
│
├── .gitattributes
│
├── .gitignore
│
├── README.md
│
├── Data/
│   └── .rxdata Files #Game data
│
├── Fonts/
│   └── .ttf Files #Game fonts
│
├── Graphics/
│   └── .png Files #Game graphics
│
├── Plugins/
│   └── .rb Files #Ruby plugins
│
├── Scripts/
│   └── .rb Files #Ruby game code
│
├── RGSS104E.dll
│
├── knownpoint.bmp
│
├── mkxp.json
│
├── selpoint.bmp
│
├── soundfont.sf2
│
├── x64-msvcrt-ruby310.dll
│
└── zlib1.dll

```

---

## Future Enhancements

- Introduce a fully custom inventory and turn-based combat system using RGSS
- Add multiple narrative paths with side quests and unique endings
- Create a launcher for cross-platform distribution
- Explore web deployment via HTML5 or Emulation
