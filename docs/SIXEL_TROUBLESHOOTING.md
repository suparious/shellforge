# Sixel Detection Troubleshooting

## The GNOME Terminal + XTerm Issue

If you're seeing this in the detection test:
```
XTERM_VERSION: XTerm(398)
GNOME_TERMINAL_SERVICE: :1.181
```

This means you have both GNOME Terminal and XTerm installed, but you're likely running the test from within GNOME Terminal (which doesn't support Sixel).

### Solution

You need to run XTerm directly with Sixel support enabled:

1. **Quick Launch Script**:
   ```bash
   ./scripts/launch-xterm-sixel.sh
   ```

2. **Manual Launch**:
   ```bash
   xterm -ti vt340 -e bash
   ```

3. **From your desktop environment**:
   - Open your application launcher
   - Search for "XTerm"
   - Right-click and "Edit Application"
   - Add `-ti vt340` to the command

### Why This Happens

- GNOME Terminal sets `GNOME_TERMINAL_SERVICE` in the environment
- When you launch xterm from within GNOME Terminal, it inherits this variable
- The old detection saw this and incorrectly assumed no Sixel support
- The new detection checks for `XTERM_VERSION` to identify real xterm

### Verification

Once in xterm with `-ti vt340`, run:
```bash
./tests/test-sixel-detection.sh
```

You should see:
- DA1 query returns a response with `;4` (Sixel support)
- img2sixel produces actual Sixel output
- Test images display correctly

### Common Terminal Configurations

| Terminal | Sixel Support | Launch Command |
|----------|--------------|----------------|
| xterm | ✅ Yes* | `xterm -ti vt340` |
| GNOME Terminal | ❌ No | N/A |
| mlterm | ✅ Yes | `mlterm` |
| WezTerm | ✅ Yes | `wezterm` |
| foot | ✅ Yes | `foot` |
| kitty | ❌ No** | N/A |
| alacritty | ❌ No | N/A |

\* Requires `-ti vt340` or similar option  
\** Kitty has its own graphics protocol, not Sixel

### Still Having Issues?

1. **Check XTerm Compilation**:
   ```bash
   xterm -version
   ```
   Some distributions compile xterm without Sixel support.

2. **Try mlterm**:
   ```bash
   sudo apt-get install mlterm
   mlterm
   ```
   mlterm has Sixel enabled by default.

3. **Enable Debug Mode**:
   ```bash
   SHELLFORGE_VERBOSE=true ./shellforge help
   ```
   This will show detailed detection information.

### Testing Without ShellForge

To test if your terminal supports Sixel independently:

1. **Create a test image**:
   ```bash
   convert -size 100x100 xc:red test.png
   ```

2. **Try to display it**:
   ```bash
   img2sixel test.png
   ```

3. **What to expect**:
   - **Sixel works**: You'll see a red square
   - **No Sixel**: You'll see escape codes like `^[Pq...`

### Environment Variable Reference

| Variable | Set By | Meaning |
|----------|--------|---------|
| `XTERM_VERSION` | XTerm | You're in real xterm |
| `GNOME_TERMINAL_SERVICE` | GNOME Terminal | GNOME Terminal is running |
| `VTE_VERSION` | VTE-based terminals | Using VTE library (no Sixel) |
| `TERM_PROGRAM` | Various | Terminal application name |
| `MLTERM` | mlterm | You're in mlterm |
