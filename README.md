# Molecule1: Interactive 3D and VR Molecule Builder

Molecule1 is a Godot 4 project that lets users explore and build molecular structures in an immersive first-person or VR environment. 3D raycasting enables grabbing, rotating and merging atoms or whole molecules. A lightweight Python backend converts between Z-matrix and Cartesian formats so molecules can be loaded, displayed and exported easily.

## Purpose & Objectives
- **Interactive Visualization**: inspect molecules from any angle and manipulate them in real time.
- **VR Support**: dual‑controller mode for spatially intuitive grabbing and bonding.
- **Data Conversion**: accurate XYZ↔Z‑matrix conversion via embedded Python.
- **Scalability Goal**: maintain smooth frame rates (>60 FPS) with dozens of atoms while keeping memory use modest.
- **Extensibility**: serve as a base for advanced chemistry simulations and VR teaching aids.

## Architecture
```
Start Menu → World Scene
       |                ↘
       |                  Player (Camera.gd)
DocumentManager ──▶ EntityManager ──▶ Molecule Nodes
       │                   │
       └─ Python gc.py ◀── Z‑matrix/XYZ files
```
- **Scenes**: `Scenes/` contains the main world, player rig, menus and visual effects. `test_main_scene.tscn` ties everything together.
- **Scripts**: `Scripts/` hosts GDScript modules:
  - `world.gd` orchestrates gameplay, pause logic and merging of grabbed objects.
  - `Camera.gd` controls first‑person movement and object grabbing.
  - `DocumentManager.gd` opens file dialogs, validates Z‑matrix/XYZ text and executes `gc.py` for conversions.
  - `EntityManager.gd` builds molecule meshes, collision shapes and aura highlights from parsed data.
  - Menu scripts manage the start and pause menus, camera animations and background music.
- **Python Backend**: `gc.py` and `gcutil.py` implement XYZ↔Z‑matrix conversion using NumPy; Godot spawns this script with OS.execute and parses its output.
- **Assets**: `Materials/` and `Textures/` supply skyboxes, icons and floor materials. `Scenes/atom.tscn` defines individual atoms used for molecule construction.

## Installation
1. Install **Godot 4.x** (GL renderer; tested with features `4.3`).
2. Ensure **Python 3** with NumPy is available in your PATH.
3. Clone the repository and install Python requirements:
```bash
pip install -r requirements.txt
```
4. Optional: set `PYTHON` environment variable if your Python executable is not simply `python`.

## Usage
### Running the Simulator
```bash
# Launch from the project directory
godot --path .
```
When the main menu appears, press **Start** to enter the world. Use WASD to move, mouse to look, and left‑click to grab atoms. Press **Esc** for the pause menu.

### Converting Molecule Files
```bash
# Convert XYZ file to Z-matrix
python gc.py -xyz sample.xyz > sample.zmat
# Convert Z-matrix back to XYZ
python gc.py -zmat sample.zmat > sample.xyz
```
The script prints the converted coordinates to stdout. Use `--rvar`, `--avar` or `--dvar` to output variables instead of numeric values.

## Outputs
- **Saved Molecules**: exported as `<name>.xyz` and `<name>.zmat` via the pause menu.
- **Temporary Files**: `user://temp_xyz.xyz` or `user://temp_zmat.zmat` created during conversions.
- **Game Logs**: Godot standard output for debugging; ensure to capture when running headless.

## Development
- Run the Python unit tests (if added later) with:
```bash
pytest
```
- Follow standard GDScript formatting; `gdformat` can be used for linting.
- Create pull requests against `main` with descriptive messages and ensure the simulator launches without errors.

## Project Status & Roadmap
**Alpha** — core gameplay works but bonding rules and advanced VR interactions are minimal. Planned tasks:
- Differentiate single/double/triple bonds visually.
- Improve VR grabbing accuracy and haptic feedback.
- Optimize dynamic loading of large molecules.

## License
No license is currently included. We recommend adopting the MIT License for broad reuse.
