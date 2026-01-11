# OpenCode AI - Neon Pong Development Guide

This repository contains a Redot/Godot 4+ game built with GDScript. Follow these guidelines when contributing.

## Project Overview

Neon Pong is a single-player arcade game with AI opponent, featuring:
- State machine architecture with scene transitions
- Three difficulty levels with progressive AI
- Particle effects and screen shake
- High score persistence
- Complete game flow (menu → play → pause → game over)

**Engine**: Redot 26.1+ (Godot 4-compatible)
**Runtime**: GDScript 2.0+ (no build step, interpreted by engine)
**Language**: GDScript (Python-like syntax, Godot's native language)

---

## Build & Test Commands

### Running the Game

```bash
# Run the game (uses Redot MCP tools)
redot_project_config run

# Alternative: Direct engine execution
redot run
```

### Testing

This project uses **manual testing** through the engine - no automated test framework is configured.

**Test Procedure**:
1. Run game with `redot_project_config run`
2. Test main menu navigation (difficulty button, play, quit)
3. Start game and verify controls (W/S for paddle movement)
4. Test pause functionality (ESC key, resume/restart/quit)
5. Play complete game, verify game over screen
6. Check high score persistence (restart game, verify high score displays)
7. Test all difficulty levels (Easy/Medium/Hard)
8. Verify particle effects appear on collisions
9. Verify screen shake on paddle hits and wall bounces
10. Test scene transitions between all states

**Debug Output**:
- Print statements throughout code provide debug feedback
- Check console for state changes, difficulty updates, collision events
- Verify autoload singletons initialize correctly

### Linting

No formal linter is configured. Follow manual code review guidelines below.

---

## Code Style Guidelines

### File Organization

```
autoload/           # Singleton scripts (global state & managers)
scenes/             # Scene files (.tscn) and scene-specific scripts
scripts/             # Reusable component scripts (inherited from scenes/)
res://sounds/       # Audio assets (not included - placeholder system)
res://themes/       # UI themes and styles
```

**Naming Convention**:
- **Autoloads**: PascalCase (e.g., `GameState`, `SceneManager`)
- **Scenes**: PascalCase (e.g., `MainMenu.tscn`, `PauseMenu.tscn`)
- **Scripts**: snake_case (e.g., `main_menu.gd`, `pause_menu.gd`)
- **Resources**: PascalCase (e.g., `CollisionParticles.tscn`)
- **Classes**: PascalCase (e.g., `class_name Manager`, `extends Node2D`)

### Imports & Dependencies

```gdscript
# Standard Godot imports (rarely needed for built-in types)
# No explicit imports for Node, Area2D, ColorRect, etc.

# Resource imports when needed:
var particles_scene: PackedScene = load("res://scenes/CollisionParticles.tscn")
var audio_stream: AudioStream = load("res://sounds/hit_paddle.wav")
```

**Rules**:
- Do not import built-in Godot types - they're available globally
- Load external resources (`PackedScene`, `AudioStream`) at runtime or in `_ready()`
- Use `ResourceLoader.exists()` to check for resource availability before loading
- Use `user://` path prefix for save files (cross-platform user directory)

### Formatting

**Indentation**: TAB characters (Godot/Redot standard, convert spaces to tabs)

**Line Length**: No strict limit, but keep lines under 100 chars when readable

**Spacing**:
```gdscript
# Space around operators
velocity.x = -velocity.x
current_speed = min(current_speed + SPEED_INCREMENT * delta, MAX_SPEED)

# Space after commas in function definitions
func setup_neon_colors():

# No space before colon in type annotations
var player_score: int = 0

# Space after colon in dictionary accesses
DIFFICULTY_SETTINGS[difficulty]
```

**Brace Style**:
```gdscript
func _ready():
    # Indented body with tabs
    setup_neon_colors()

# Always use braces, even for single-line blocks
if GameState.current_state != GameState.GameState.PLAYING:
    return
```

### Type Annotations

**Required for all variables** (enforced by GDScript 2.0+):

```gdscript
var current_state: GameState = GameState.MAIN_MENU
var player_score: int = 0
var shake_intensity: float = 0.0
var winner: String = ""
var audio_players = {}

# Dictionary types
const DIFFICULTY_SETTINGS = {
    "easy": { ... },
    "medium": { ... },
    "hard": { ... }
}

# Return types
func get_difficulty_settings() -> Dictionary:
    return DIFFICULTY_SETTINGS[difficulty]

func linear_to_db(linear: float) -> float:
    return 20.0 * log(linear) / log(10.0)
```

**Type Inference**:
- Variables must have explicit types (`int`, `float`, `String`, `bool`, `Node`, etc.)
- Use `-> Type` for function return types
- Use `:` for parameter types

### Naming Conventions

**Variables**: snake_case
```gdscript
var player_score: int = 0
var shake_intensity: float = 0.0
var current_speed: float = INITIAL_SPEED
```

**Constants**: UPPER_SNAKE_CASE
```gdscript
const TRANSITION_DURATION = 0.5
const SHAKE_DECAY: float = 10.0
const WIN_SCORE: int = 10
const SAVE_FILE_PATH = "user://neon_pong_save.dat"
```

**Functions**: snake_case
```gdscript
func _ready():
func setup_neon_colors():
func _on_state_changed(new_state: GameState):
func apply_screen_shake(delta: float):
```

**Signals**: snake_case with parameters
```gdscript
signal state_changed(new_state)
signal score_changed(player_score, ai_score)
signal game_over(winner)
```

**Enums**: PascalCase with values in UPPER_SNAKE_CASE
```gdscript
enum GameState {
    MAIN_MENU,
    PLAYING,
    PAUSED,
    GAME_OVER
}

enum Sound {
    HIT_PADDLE,
    HIT_WALL,
    SCORE,
    WIN,
    GAME_OVER
}
```

**Nodes/Paths**: PascalCase (scene tree traversal uses `$` and `get_node()`)
```gdscript
@onready var pause_menu = $PauseMenu
@onready var player_paddle = $PlayerPaddle
ball.get_node("PaddleVisual").color
```

### Signal-Based Architecture

This project uses extensive signal patterns for loose coupling:

```gdscript
# Define signals
signal state_changed(new_state)
signal score_changed(player_score, ai_score)
signal paddle_hit(type)

# Connect signals
GameState.state_changed.connect(_on_state_changed)
ball.paddle_hit.connect(_on_paddle_hit)
area_entered.connect(_on_area_entered)

# Emit signals
state_changed.emit(new_state)
score_changed.emit(player_score, ai_score)
```

**Signal Best Practices**:
- Use signals for cross-component communication
- Connect in `_ready()` to ensure components are initialized
- Use descriptive parameter names
- Connect before emitting to avoid missing events
- Disconnect if needed (not typically required for scene lifecycle)

### Error Handling

**Current Pattern**: Minimal error handling with fallback behavior

```gdscript
# File access with null checks
var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
if file:
    file.store_32(high_score)
    file.close()
# No else branch - silent failure

# Resource existence checks
if ResourceLoader.exists("res://scenes/CollisionParticles.tscn"):
    particles_scene = load("res://scenes/CollisionParticles.tscn")
# No else branch - skip feature if unavailable

# Dictionary existence checks
if audio_players.has(sound):
    var player = audio_players[sound]
    player.play()
# No else branch - print placeholder message

# Clamping values for safety
volume = clamp(new_volume, 0.0, 1.0)
position.y = clamp(position.y, paddle_height / 2, viewport_height - paddle_height / 2)
```

**Guidelines**:
- Always check `FileAccess.open()` return value before use
- Always check `ResourceLoader.exists()` before loading
- Use `if dictionary.has(key)` before access
- Use `clamp()` for numeric bounds checking
- Print fallback behavior to console for missing resources
- Do not use assertions - handle failures gracefully

### Scene Node References

Use `@onready` annotation for scene tree child references:

```gdscript
@onready var pause_menu = $PauseMenu
@onready var ball = $Ball
@onready var player_paddle = $PlayerPaddle

# Deferred initialization
func _ready():
    setup_neon_colors()
    _apply_difficulty_settings()
```

**Rules**:
- Use `@onready` instead of `get_node()` in variable declarations
- `@onready` nodes are automatically initialized after scene is ready
- Use `get_node()` only for dynamic lookups or cross-scene access
- Prefer `$NodeName` over `get_node("NodeName")` when possible

### Autoload Singletons

**Purpose**: Global managers accessible from any script

```gdscript
# GameState - State machine and game settings
GameState.set_state(GameState.GameState.PAUSED)
GameState.add_score(true)
GameState.get_difficulty_settings()

# SceneManager - Scene transitions
SceneManager.goto_scene("res://Main.tscn")

# SoundManager - Audio system
SoundManager.play(SoundManager.Sound.HIT_PADDLE)
SoundManager.set_volume(0.8)
```

**Autoload Setup**:
- Scripts in `autoload/` directory
- Added via project configuration (or `project.godot` `[autoload]` section)
- Automatically loaded at game start
- Accessible as global nodes (no import needed)
- **Never** instantiate singleton scripts manually

### GDScript-Specific Patterns

**Await/Async**:
```gdscript
func goto_scene(scene_path: String, delay: float = 0.0):
    if delay > 0:
        await get_tree().create_timer(delay).timeout
    
    # Load scene (async operation)
    get_tree().change_scene_to_file(scene_path)
    
    # Wait for tween to complete
    await tween.finished
```

**Coroutines with Timer**:
```gdscript
func _emit_particles(type: String):
    var particles = particles_scene.instantiate()
    get_parent().add_child(particles)
    particles.emit_at(position, type)
    await particles.tree_exited  # Wait for cleanup
    particles.queue_free()
```

**Godot Lifecycle Methods** (order of execution):
1. `_enter_tree()` - Node enters scene tree
2. `_ready()` - Node and all children are ready (use this!)
3. `_process(delta)` - Called every frame
4. `_physics_process(delta)` - Called every physics frame
5. `_input(event)` - Called for input events
6. `_exit_tree()` - Node leaves scene tree

**Always** use `_ready()` for initialization over `_enter_tree()` unless node tree structure matters.

### Color & Visual System

**Neon Theme Constants**:
```gdscript
const NEON_COLORS = {
    background = Color(0.05, 0.05, 0.1, 1.0),
    player = Color(0.0, 1.0, 1.0, 1.0),
    ai = Color(1.0, 0.0, 1.0, 1.0),
    ball = Color(1.0, 1.0, 0.0, 1.0)
}

# Access with named keys
$Background.color = NEON_COLORS.background
player_paddle.get_node("PaddleVisual").color = NEON_COLORS.player
```

**Built-in Colors**: Use `Color.NAME` for standard colors (e.g., `Color.RED`, `Color.WHITE`, `Color.BLACK`)

### Scene Files (.tscn)

**Format**: Godot text scene format (human-readable, version-controlled)

**Key Patterns**:
```tscn
[gd_scene load_steps=N format=3]

[ext_resource type="Script" path="res://script.gd" id="X_name"]
[ext_resource type="PackedScene" path="res://scene.tscn" id="Y_scene"]

[sub_resource type="Type" id="Z_resource"]

[node name="NodeName" type="NodeType" parent="."]
property = value
script = ExtResource("X_name")

[node name="ChildNode" type="ChildType" parent="."]
```

**Do Not** hand-edit scene files for layout - use the Redot editor.

### Collision Detection (Area2D)

```gdscript
# Setup collision layers/masks
collision_layer = 1  # Ball is on layer 1
collision_mask = 2    # Ball detects layer 2 (paddles)

# Area2D must be monitorable to be detected
monitorable = true  # Required for other Area2D to detect
monitoring = true   # Required to emit area_entered signals

# Connect signals
area_entered.connect(_on_area_entered)

# Check groups in collision handler
func _on_area_entered(area: Area2D):
    if area.is_in_group("paddles"):
        # Handle paddle collision
```

**Collision Layers**: Use bit values (1, 2, 4, 8, 16, 32...) for up to 32 layers

### Tween Animation System

```gdscript
# Create tween
tween = create_tween()

# Optional: Parallel tweens
tween.set_parallel(true)

# Animate properties
tween.tween_property(object, "property_name", target_value, duration)

# Wait for completion
await tween.finished

# Clean up
if tween:
    tween.kill()
```

### Print Debugging

```gdscript
# Development debugging
print("Ball ready - monitoring: ", monitoring, " monitorable: ", monitorable)
print("Hit paddle! Position: ", position)
print("Difficulty changed to: ", difficulty)

# Remove print statements before production release
# Or wrap in debug guard:
if OS.is_debug_build():
    print("Debug: ", debug_message)
```

### Comment Style

**No comments added** to codebase as per strict style guideline. If adding, use:

```gdscript
# Single-line comment
# Brief explanation of why code exists

# Multi-line comment (rare, prefer code clarity)
# This function handles the screen shake effect
# by applying random offset and decaying over time
```

**Prefer** self-documenting code over comments:
- Use descriptive variable names: `shake_intensity` not `s`
- Use descriptive function names: `_apply_screen_shake()` not `_update()`
- Use enums for meaningful values: `GameState.PLAYING` not `1`

---

## Project-Specific Patterns

### Game State Machine

```gdscript
# State enum
enum GameState {
    MAIN_MENU,
    PLAYING,
    PAUSED,
    GAME_OVER
}

# State management in GameState singleton
GameState.set_state(GameState.GameState.PLAYING)

# Listen for state changes
GameState.state_changed.connect(_on_state_changed)

# Guard code based on state
if GameState.current_state != GameState.GameState.PLAYING:
    return
```

### Scene Transitions

```gdscript
# SceneManager handles fade in/out
SceneManager.goto_scene("res://Main.tscn")
SceneManager.goto_scene("res://GameOver.tscn", delay=0.5)

# Connect to transition signals if needed
SceneManager.transition_started.connect(_on_transition_start)
```

### AI Difficulty System

```gdscript
# Settings dictionary per difficulty
const DIFFICULTY_SETTINGS = {
    "easy": { "ai_speed": 250.0, ... },
    "medium": { "ai_speed": 350.0, ... },
    "hard": { "ai_speed": 450.0, ... }
}

# Apply settings in game scene
var settings = GameState.get_difficulty_settings()
ball.INITIAL_SPEED = settings.ball_initial_speed
ai_paddle.AI_SPEED = settings.ai_speed
```

### Particle System

```gdscript
# Load scene once in _ready()
if ResourceLoader.exists("res://scenes/CollisionParticles.tscn"):
    particles_scene = load("res://scenes/CollisionParticles.tscn")

# Instantiate and emit
var particles = particles_scene.instantiate()
get_parent().add_child(particles)
particles.emit_at(position, type)
await particles.tree_exited
particles.queue_free()
```

---

## Common Pitfalls & Solutions

### ❌ Wrong: Using spaces for indentation
```gdscript
    var speed = 100  # Causes indentation errors
```
### ✅ Right: Use tabs
```gdscript
	var speed = 100
```

### ❌ Wrong: Implicit type inference
```gdscript
var score = 0  # Missing type annotation
```
### ✅ Right: Explicit types
```gdscript
var score: int = 0
```

### ❌ Wrong: Importing built-in types
```gdscript
from godot import Node, Area2D  # Not needed
```
### ✅ Right: No imports needed
```gdscript
extends Node2D  # Built-in types available globally
```

### ❌ Wrong: Instantiating autoloads
```gdscript
var game_state = GameState.new()  # Wrong!
```
### ✅ Right: Use autoload directly
```gdscript
GameState.set_state(GameState.GameState.PLAYING)  # Correct
```

### ❌ Wrong: Missing collision properties
```gdscript
# Area2D won't detect other Area2D without these
monitorable = true  # Required
monitoring = true   # Required
collision_layer = 1
collision_mask = 2
```
### ✅ Right: Full collision setup
```gdscript
extends Area2D
collision_layer = 1
collision_mask = 2
monitorable = true
monitoring = true

func _ready():
    area_entered.connect(_on_area_entered)
```

### ❌ Wrong: Scene tree access in _ready()
```gdscript
func _ready():
    $NodeThatDoesntExist.property = value  # Crash!
```
### ✅ Right: Use @onready
```gdscript
@onready var node = $NodeThatDoesntExist
func _ready():
    # Safe access - auto-initializes if exists
```

---

## Testing Checklist

Before submitting code, verify:

- [ ] Game runs without crashes in Redot Editor
- [ ] All scenes load correctly
- [ ] Autoloads initialize (check console)
- [ ] Input controls work (W/S, ESC)
- [ ] Collision detection works (ball bounces off paddles/walls)
- [ ] Scene transitions smooth (no visual glitches)
- [ ] State machine flows correctly (menu → game → pause → game over → menu)
- [ ] High score saves and loads
- [ ] Difficulty changes affect gameplay
- [ ] Particle effects appear
- [ ] Screen shake triggers correctly
- [ ] No print statements left in production (or guarded by debug check)
- [ ] All variables have type annotations
- [ ] No unused imports or variables
- [ ] Signal connections verified (no unhandled events)

---

## Summary

This codebase follows Redot/Godot 4+ best practices with:
- ✅ GDScript 2.0+ typed variables
- ✅ Signal-based loose coupling
- ✅ Autoload singleton pattern
- ✅ Scene-based game architecture
- ✅ Area2D collision system
- ✅ Tween animations
- ✅ Resource loading with existence checks
- ✅ TAB indentation throughout

**When contributing**, maintain these patterns and ensure new code integrates cleanly with the existing architecture. Test thoroughly before merging.
