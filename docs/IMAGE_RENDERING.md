# ShellForge Image Rendering

ShellForge now includes optional Sixel and ASCII image rendering capabilities for enhanced terminal UI experiences.

## Features

- **Sixel Graphics**: Native terminal image rendering for supported terminals
- **ASCII Fallback**: Automatic fallback to ASCII art using `chafa` or `jp2a`
- **SVG Support**: Automatic conversion of SVG files to raster formats
- **Graceful Degradation**: Never crashes due to missing tools or unsupported terminals
- **Smart Detection**: Uses `infocmp` and terminal capability detection
- **Global Toggle**: `--no-graphics` flag to disable all image rendering

## Supported Terminals

Sixel graphics are supported in:
- `xterm` (with `-ti vt340` option)
- `mlterm`
- `mintty`
- `wezterm`
- `foot`
- iTerm2 (macOS)
- Windows Terminal (with Sixel support enabled)

## Required Tools

### For Sixel Rendering
- `img2sixel` (from libsixel)

### For ASCII Art Fallback
- `chafa` (preferred) - High-quality Unicode/ASCII art
- `jp2a` (alternative) - JPEG to ASCII converter

### For SVG Support
- `rsvg-convert` (from librsvg2)

## Installation

### Ubuntu/Debian
```bash
sudo apt-get install libsixel-bin chafa librsvg2-bin
# Optional: sudo apt-get install jp2a
```

### macOS (Homebrew)
```bash
brew install libsixel chafa librsvg
# Optional: brew install jp2a
```

### Arch Linux
```bash
sudo pacman -S libsixel chafa librsvg
# Optional: sudo pacman -S jp2a
```

## Usage

### Command Line Flag
```bash
# Disable all graphics
shellforge help --no-graphics
```

### Environment Variable
```bash
# Disable graphics for all invocations
export SHELLFORGE_NO_GRAPHICS=true
```

### Custom Logo
Place your custom logo at one of these locations:
- `~/.config/shellforge/logo.png`
- `~/.config/shellforge/logo.svg`
- Set `SHELLFORGE_LOGO_PATH` environment variable

## Testing

Run the test scripts to verify your setup:

```bash
# Test image rendering capabilities
./tests/test-image-rendering.sh

# Interactive demo
./tests/demo-image-rendering.sh
```

## How It Works

### Multi-Stage Sixel Detection

1. **Known Terminal Detection**:
   - **Blacklist**: VTE-based terminals (GNOME Terminal), Konsole, Terminal.app
   - **Whitelist**: mlterm, WezTerm, mintty, foot, iTerm.app
   - Checks environment variables: `VTE_VERSION`, `TERM_PROGRAM`, `MLTERM`, etc.

2. **Device Attributes Query (DA1)**:
   - Sends `ESC[c` query to terminal
   - Parses response for ";4" which indicates Sixel support
   - More reliable than `infocmp` which misses many terminals

3. **Render Test**:
   - Creates a minimal test image
   - Attempts to render with `img2sixel`
   - Checks if output contains valid Sixel data
   - Special handling for xterm (requires `-ti vt340`)

4. **Tool Detection**: 
   - Checks for `img2sixel`, `chafa`, `jp2a`, `rsvg-convert`
   - Caches results for performance

5. **Rendering Decision**: 
   - If Sixel is supported and `img2sixel` is available → Use Sixel
   - Else if `chafa` is available → Use ASCII art
   - Else if `jp2a` is available → Use simple ASCII
   - Else → Display text fallback

6. **SVG Handling**: Automatically converts SVG to PNG if `rsvg-convert` is available

## API

The image rendering module provides these functions:

```bash
# Initialize and detect capabilities
init_image_renderer

# Check if any rendering is possible
can_render_images  # Returns 0 if true, 1 if false

# Render an image with automatic method selection
render_image "path/to/image.png" [max_width] [max_height] [fallback_text]

# Show detected capabilities
show_image_capabilities
```

## Integration

The image renderer is integrated into:
- Banner display (`display_banner`)
- Help command output
- Future: Backup success notifications

## Troubleshooting

### No Sixel Support Detected

**Quick Fix for GNOME Terminal + XTerm users**:
```bash
# You're probably in GNOME Terminal. Launch xterm with Sixel:
./scripts/launch-xterm-sixel.sh
# Or manually:
xterm -ti vt340 -e bash
```

For detailed troubleshooting, see [SIXEL_TROUBLESHOOTING.md](SIXEL_TROUBLESHOOTING.md).

**General Steps**:
1. **Run the detection test**: `./tests/test-sixel-detection.sh`
2. **For xterm**: Must be started with `-ti vt340` or `-ti 340` option
3. **Check terminal environment**:
   - GNOME Terminal and VTE-based terminals do NOT support Sixel
   - Consider switching to a Sixel-capable terminal
4. **Verify img2sixel works**:
   ```bash
   # Create test image
   convert -size 10x10 xc:red test.png
   # Try to display it
   img2sixel test.png
   ```
5. **Enable verbose mode** to see detection details:
   ```bash
   SHELLFORGE_VERBOSE=true ./shellforge help
   ```

### Images Not Displaying
1. Verify tools are installed: `which img2sixel chafa`
2. Check terminal: `echo $TERM`
3. Run capability test: `./tests/test-image-rendering.sh`
4. Try with verbose mode: `SHELLFORGE_VERBOSE=true shellforge help`

### SVG Files Not Working
- Install `rsvg-convert`: `sudo apt-get install librsvg2-bin`
- Verify installation: `which rsvg-convert`

## Performance

- Capability detection is cached per session
- Tool detection happens only once
- Image rendering adds minimal overhead
- ASCII rendering is fast and lightweight

## Future Enhancements

- [ ] Animated loading indicators using Sixel
- [ ] Progress bars with graphical elements
- [ ] Success/error icons as images
- [ ] Backup visualization charts
