
---

# CardFront-Prototype

CardFront-Prototype is a **Triple Triad**-inspired card game prototype built using **PICO-8**. The game aims to capture the core mechanics of Triple Triad while leveraging the simplicity and charm of the PICO-8 platform. The prototype is implemented in **Lua** and designed to work within PICO-8's constraints, including a 128x128 resolution and 16-color palette.

## Table of Contents
1. [Game Overview](#game-overview)
2. [Features](#features)
3. [Setup and Installation](#setup-and-installation)
4. [Gameplay](#gameplay)
    - [Game Mechanics](#game-mechanics)
    - [Controls](#controls)
5. [Development](#development)
    - [Code Structure](#code-structure)
    - [How to Contribute](#how-to-contribute)
6. [Future Enhancements](#future-enhancements)
7. [License](#license)

## Game Overview

The game is a turn-based card game set on a 3x3 grid. Each card has four sides with numbered values, representing the card's power on each side. Players take turns placing cards on the grid, attempting to flip the opponent's cards by having higher values on adjacent sides.

## Features

- **3x3 Grid Gameplay**: Play on a grid with nine slots, filling the board with cards to determine the winner.
- **Card Flipping Mechanic**: Cards flip ownership based on the comparison of adjacent values.
- **Turn-based Play**: Alternate turns between two players.
- **Simple AI for Opponent** (planned): A basic AI to simulate playing against the computer.
- **Pixel Art Visuals**: Retro visuals created using PICO-8's 16-color palette.

## Setup and Installation

To play or develop CardFront-Prototype, you'll need **PICO-8**. Follow these steps:

1. **Download and Install PICO-8**: You can purchase and download PICO-8 from [https://www.lexaloffle.com/pico-8.php](https://www.lexaloffle.com/pico-8.php).
2. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/CardFront-Prototype.git
   ```
3. **Run the Game**:
   - Open PICO-8 and load the `.p8` file from the cloned repository.
   - Use the command `load CardFront-Prototype.p8` in PICO-8, then run the game with the `run` command.

## Gameplay

### Game Mechanics

- **Grid**: The game is played on a 3x3 grid where each cell can hold one card.
- **Card Attributes**:
  - Each card has four numbers representing its power on the top, right, bottom, and left sides.
  - Cards belong to either the player or the opponent.
- **Card Placement**:
  - Players take turns placing a card on an empty grid cell.
  - If the placed card has a higher number than an adjacent card, the adjacent card flips ownership.

### Controls

- **Arrow Keys**: Move the cursor to select a grid cell.
- **Z/X or Confirm Button**: Place a card in the selected grid cell.

## Development

### Code Structure

The codebase is structured as follows:

- **grid.lua**: Manages the 3x3 grid representation and card placement logic.
- **card.lua**: Contains functions for creating and managing card attributes.
- **game.lua**: Implements the main game loop, turn management, and card flipping mechanics.
- **draw.lua**: Handles rendering the grid, cards, and other visual elements on the screen.

### How to Contribute

Contributions are welcome! To get started:

1. **Fork the Repository**.
2. **Create a Branch** for your feature (`git checkout -b feature-name`).
3. **Commit Your Changes** (`git commit -am 'Add new feature'`).
4. **Push to the Branch** (`git push origin feature-name`).
5. **Open a Pull Request**.

Please ensure your code follows the existing style and include comments where necessary.

## Future Enhancements

Planned features include:

- **AI Opponent**: Add a simple AI to play against the player.
- **Card Selection System**: Allow players to choose from a hand of cards before each turn.
- **Win Conditions**: Implement game-ending scenarios and determine the winner based on card control.
- **Advanced Rules**: Add optional rules such as "Same," "Plus," or other variations to increase game depth.
- **Enhanced Graphics and Sound**: Improve the visuals and add sound effects for better feedback.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

---

Feel free to modify this README as your project evolves.
