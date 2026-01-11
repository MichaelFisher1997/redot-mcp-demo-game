# Neon Pong - Production Mini-Game

A fully-featured single-player Pong game with AI opponent, neon aesthetic, and complete game system.

## Features Implemented

### Core Systems (High Priority)
✅ **Game State Management** - Complete state machine with game flow control
✅ **Scene Management** - Smooth transitions between all game scenes
✅ **Main Menu** - Animated title with difficulty selection
✅ **Pause Menu** - ESC key handling with resume/restart/quit
✅ **Game Over Screen** - Stats display with high score tracking

### Enhanced Features (Medium Priority)
✅ **Particle Effects** - Visual feedback on paddle hits and wall bounces
✅ **Screen Shake** - Impact-based camera shake on collisions
✅ **Sound Effects System** - Complete audio manager with placeholder sounds
✅ **Difficulty Selection** - Easy/Medium/Hard with different AI behaviors
✅ **High Score Persistence** - Saves best score to file

### Visual Polish (Low Priority)
✅ **Animated Backgrounds** - Pulsing neon background effect
✅ **AI Difficulty Variations** - Three difficulty tiers with different speeds
✅ **Typography & UI** - Styled buttons, labels, and game elements

## Project Structure

```
autoload/
├── GameState.gd          # Game state & settings singleton
├── SceneManager.gd       # Scene transition system
└── SoundManager.gd       # Audio effects manager

scenes/
├── MainMenu.tscn          # Main menu with animated title
├── PauseMenu.tscn          # Pause overlay
├── GameOver.tscn          # End game screen
├── Main.tscn              # Game scene
├── paddle.tscn            # Player paddle prefab
├── ai_paddle.tscn         # AI paddle prefab
├── ball.tscn              # Ball with physics
└── CollisionParticles.tscn  # Particle effects

scripts/
├── main_menu.gd           # Menu logic
├── pause_menu.gd           # Pause handling
├── game_over.gd            # Game over display
├── main.gd                 # Game controller
├── paddle.gd               # Paddle movement
├── ai_paddle.gd            # AI behavior
├── ball.gd                 # Ball physics & collision
└── particles.gd             # Particle effects
```

## Game Controls

- **W** - Move paddle up
- **S** - Move paddle down
- **ESC** - Pause/Resume game

## Difficulty Levels

| Difficulty | AI Speed | Reaction | Ball Speed |
|-----------|-----------|-----------|-------------|
| Easy     | 250       | 0.2s      | 250         |
| Medium   | 350       | 0.1s      | 300         |
| Hard     | 450       | 0.05s     | 350         |

## Technical Features

- **State Machine**: Main Menu → Playing → Paused → Game Over
- **Scene Transitions**: Smooth fade-in/fade-out effects
- **Progressive Difficulty**: Ball speeds up during rallies
- **Collision Detection**: Area2D-based with proper layer/mask setup
- **Particle System**: GPU-accelerated particle effects on impacts
- **Screen Shake**: Decay-based shake with intensity control
- **High Score System**: Persistent save to user directory

## Audio System

Sound manager supports:
- Paddle hit sounds
- Wall bounce sounds  
- Score notification sounds
- Win/Game Over sounds

*Note: Sound files need to be added to `res://sounds/` directory*

## Visual Design

### Color Scheme (Neon Theme)
- **Background**: Dark Navy (0.05, 0.05, 0.1) with pulse animation
- **Player Paddle**: Cyan (0.0, 1.0, 1.0)
- **AI Paddle**: Magenta (1.0, 0.0, 1.0)
- **Ball**: Yellow (1.0, 1.0, 0.0)
- **Center Line**: Grey (0.5, 0.5, 0.5, 0.3) dashed

### Effects
- Particle bursts on collisions
- Screen shake on impacts
- Animated background pulse
- Smooth scene transitions
- Pulsing UI elements

## Future Enhancements (Optional)

The following features were not implemented but can be added:

❌ **Settings Menu** - Volume controls, fullscreen, key rebinding
❌ **Gamepad Support** - Controller input for paddle movement
❌ **Additional Sound Files** - Actual .wav/.ogg files for audio

## How to Play

1. Launch game with Redot Engine
2. Select difficulty in main menu
3. Press PLAY to start
4. Use W/S to move your paddle (left, cyan)
5. Defeat the AI paddle (right, magenta)
6. First to 10 points wins
7. ESC to pause anytime
8. Press SPACE or click to resume

## Project Requirements

- **Redot Engine**: 26.1 or higher
- **Target Platform**: Desktop (Linux/Mac/Windows)
- **Window Size**: 800x600
- **Aspect Ratio**: 4:3
- **FPS**: 60 target

## Credits

Built with ❤️ using Redot Engine 26.1

Production-ready Pong game with complete game system, polished UI, and engaging gameplay mechanics.
