# Neon Pong

A single-player Pong game with AI opponent, neon aesthetic, and progressive difficulty.

## Features
- Single-player vs AI
- Progressive difficulty (ball speeds up over time)
- Neon color scheme
- Score tracking (first to 10 wins)
- Clean, modular code

## Controls
- **W** - Move paddle up
- **S** - Move paddle down

## How to Play
1. Run the game with Redot Engine
2. Use W/S to control your paddle (left side, cyan)
3. The AI controls the right paddle (magenta)
4. Hit the ball past the AI paddle to score
5. First to 10 points wins

## Game Mechanics
- Ball speed increases gradually during rallies
- AI has a reaction delay to make it beatable
- Ball angle changes based on where it hits the paddle
- Ball bounces off top and bottom walls

## Neon Color Scheme
- Background: Dark navy
- Player Paddle: Cyan
- AI Paddle: Magenta  
- Ball: Yellow
- Score labels: White
- Center line: Grey (semi-transparent)

## Project Structure
```
res://Main.tscn              # Root game scene
res://scenes/paddle.tscn     # Player paddle scene
res://scenes/ai_paddle.tscn  # AI paddle scene
res://scenes/ball.tscn       # Ball scene
res://scripts/main.gd        # Game controller
res://scripts/paddle.gd      # Paddle movement logic
res://scripts/ai_paddle.gd   # AI behavior
res://scripts/ball.gd        # Ball physics
```

## Credits

Built with ❤️ using Redot Engine 26.1

Production-ready Pong game with complete game system, polished UI, and engaging gameplay mechanics.

This project was built using the **Redot MCP Tool** with **OpenCode AI**.
