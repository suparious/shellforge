#!/usr/bin/env bash
# ShellForge Image Renderer Library
# Provides Sixel and ASCII fallback image rendering capabilities
# Supports graceful degradation and respects NO_GRAPHICS flag

# Image rendering capabilities (cached for performance)
IMAGE_RENDERER_INITIALIZED=false
CAN_RENDER_SIXEL=false
CAN_RENDER_ASCII=false
CAN_RENDER_ANY=false
IMAGE_RENDER_METHOD=""
SIXEL_TOOL=""
ASCII_TOOL=""
SVG_CONVERTER=""

# Tool paths (cached after first detection)
IMG2SIXEL_PATH=""
CHAFA_PATH=""
JP2A_PATH=""
RSVG_CONVERT_PATH=""

# Terminal capabilities
TERMINAL_SUPPORTS_SIXEL=false

# Debug print function (uses verbose flag)
debug_print() {
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "[DEBUG] $*" >&2
    fi
}

# Initialize the image renderer and detect capabilities
init_image_renderer() {
    # Skip if already initialized or graphics disabled
    if [[ "${IMAGE_RENDERER_INITIALIZED}" == "true" ]] || [[ "${NO_GRAPHICS:-false}" == "true" ]]; then
        return 0
    fi
    
    IMAGE_RENDERER_INITIALIZED=true
    
    # Detect terminal Sixel support
    detect_sixel_terminal
    
    # Detect available tools
    detect_image_tools
    
    # Determine rendering capabilities
    if [[ "${TERMINAL_SUPPORTS_SIXEL}" == "true" ]] && [[ -n "${SIXEL_TOOL}" ]]; then
        CAN_RENDER_SIXEL=true
        IMAGE_RENDER_METHOD="sixel"
        CAN_RENDER_ANY=true
    elif [[ -n "${ASCII_TOOL}" ]]; then
        CAN_RENDER_ASCII=true
        IMAGE_RENDER_METHOD="ascii"
        CAN_RENDER_ANY=true
    fi
    
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        debug_print "Image renderer initialized:"
        debug_print "  Terminal supports Sixel: ${TERMINAL_SUPPORTS_SIXEL}"
        debug_print "  Can render Sixel: ${CAN_RENDER_SIXEL}"
        debug_print "  Can render ASCII: ${CAN_RENDER_ASCII}"
        debug_print "  Render method: ${IMAGE_RENDER_METHOD:-none}"
        debug_print "  Sixel tool: ${SIXEL_TOOL:-none}"
        debug_print "  ASCII tool: ${ASCII_TOOL:-none}"
    fi
}

# Detect if terminal supports Sixel graphics
detect_sixel_terminal() {
    TERMINAL_SUPPORTS_SIXEL=false
    
    # Skip detection if not in a terminal
    if [[ ! -t 1 ]] || [[ ! -t 0 ]]; then
        debug_print "Not running in a terminal, Sixel disabled"
        return 1
    fi
    
    # Method 1: Check for known terminals that DON'T support Sixel
    if is_known_non_sixel_terminal; then
        debug_print "Known non-Sixel terminal detected"
        return 1
    fi
    
    # Method 2: Check for known terminals that DO support Sixel
    if is_known_sixel_terminal; then
        debug_print "Known Sixel terminal detected"
        TERMINAL_SUPPORTS_SIXEL=true
        return 0
    fi
    
    # Method 3: Query terminal using Device Attributes (DA1)
    if detect_sixel_via_da1; then
        debug_print "Sixel detected via DA1 query"
        TERMINAL_SUPPORTS_SIXEL=true
        return 0
    fi
    
    # Method 4: Try actual Sixel rendering test (most reliable but invasive)
    if detect_sixel_via_render_test; then
        debug_print "Sixel detected via render test"
        TERMINAL_SUPPORTS_SIXEL=true
        return 0
    fi
    
    debug_print "No Sixel support detected"
    return 1
}

# Check if terminal is known NOT to support Sixel
is_known_non_sixel_terminal() {
    # Special case: Check if we're actually in xterm despite GNOME environment vars
    # XTerm sets XTERM_VERSION when it's the actual terminal
    if [[ -n "${XTERM_VERSION:-}" ]] && [[ "${TERM:-}" == xterm* ]]; then
        debug_print "XTerm detected via XTERM_VERSION, ignoring GNOME environment"
        return 1  # Not a non-sixel terminal, let other checks determine
    fi
    
    # Check VTE-based terminals (GNOME Terminal, Terminator, etc.)
    if [[ -n "${VTE_VERSION:-}" ]]; then
        debug_print "VTE-based terminal detected (no Sixel support)"
        return 0
    fi
    
    # Check TERM_PROGRAM for known non-Sixel terminals
    case "${TERM_PROGRAM:-}" in
        "GNOME Terminal"|"gnome-terminal"|Terminal|konsole)
            return 0
            ;;
    esac
    
    # Check for specific terminal emulators via environment
    # But only if we're not in xterm (which inherits parent environment)
    if [[ "${TERM:-}" != xterm* ]]; then
        if [[ -n "${GNOME_TERMINAL_SERVICE:-}" ]] || [[ -n "${KONSOLE_VERSION:-}" ]]; then
            return 0
        fi
    fi
    
    return 1
}

# Check if terminal is known to support Sixel
is_known_sixel_terminal() {
    # Check for mlterm
    if [[ -n "${MLTERM:-}" ]] || [[ "${TERM:-}" == mlterm* ]]; then
        return 0
    fi
    
    # Check TERM_PROGRAM for known Sixel terminals
    case "${TERM_PROGRAM:-}" in
        WezTerm|mintty|iTerm.app)
            return 0
            ;;
    esac
    
    # Check for foot terminal
    if [[ "${TERM:-}" == "foot"* ]]; then
        return 0
    fi
    
    # Check for specific sixel-enabled TERM values
    case "${TERM:-}" in
        xterm-sixel|sixel*|yaft*)
            return 0
            ;;
    esac
    
    return 1
}

# Detect Sixel using Device Attributes query
detect_sixel_via_da1() {
    # Skip if no img2sixel (we need it anyway for rendering)
    if ! command -v img2sixel &>/dev/null; then
        return 1
    fi
    
    # Save terminal settings
    local old_settings
    old_settings=$(stty -g 2>/dev/null) || return 1
    
    # Clear any pending input
    read -t 0.1 -n 10000 2>/dev/null || true
    
    # Set terminal to raw mode but with specific settings
    stty raw -echo min 0 time 0 2>/dev/null || {
        stty "$old_settings" 2>/dev/null
        return 1
    }
    
    # Send DA1 query (ESC [ c) to stdout
    printf '\033[c'
    
    # Give terminal time to process and respond
    sleep 0.2
    
    # Read response
    local response=""
    local char
    local count=0
    local max_chars=100
    
    while (( count < max_chars )); do
        if IFS= read -r -n1 char 2>/dev/null; then
            response+="$char"
            ((count++))
            # Check if we got the terminating character
            if [[ "$char" == "c" ]]; then
                break
            fi
        else
            # No more data
            break
        fi
    done
    
    # Restore terminal settings
    stty "$old_settings" 2>/dev/null || true
    
    # Clear any remaining input
    read -t 0.1 -n 10000 2>/dev/null || true
    
    debug_print "DA1 response: ${response//[[:cntrl:]]/_}"
    
    # Check if response contains ;4; or ;4c (indicates Sixel support)
    if [[ "$response" == *";4;"* ]] || [[ "$response" == *";4c"* ]]; then
        return 0
    fi
    
    return 1
}

# Detect Sixel by trying to render a minimal image
detect_sixel_via_render_test() {
    # Skip if no img2sixel
    if ! command -v img2sixel &>/dev/null; then
        return 1
    fi
    
    # For xterm, we need special handling
    if [[ "${TERM:-}" == xterm* ]]; then
        # xterm requires -ti vt340 or similar option to support Sixel
        # Try to check if xterm has Sixel support enabled by checking
        # the XTERM_VERSION environment variable (if available)
        if [[ -n "${XTERM_VERSION:-}" ]]; then
            debug_print "XTerm version: ${XTERM_VERSION}"
        fi
        
        # Create a tiny test file
        local test_img=$(mktemp "${TMPDIR:-/tmp}/sixel_test_XXXXXX.png")
        
        # Create a 1x1 pixel PNG using printf (minimal PNG)
        printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\x0f\x00\x00\x01\x01\x00\x05\x00\x00\x00\x00IEND\xaeB`\x82' > "$test_img"
        
        # Try to render it and capture any error
        local output
        if output=$("${IMG2SIXEL_PATH:-img2sixel}" -w 1 -h 1 "$test_img" 2>&1); then
            # Check if output contains actual Sixel data (starts with ESC P)
            if [[ "$output" == $'\033P'* ]] || [[ "$output" == $'\x1bP'* ]]; then
                rm -f "$test_img"
                return 0
            fi
        fi
        
        rm -f "$test_img"
        return 1
    fi
    
    # For other terminals, we can be less cautious
    # Create a minimal test Sixel sequence
    local test_sixel=$'\033Pq#0;2;0;0;0#0!1~-\033\\'
    
    # Try to output it and see if the terminal accepts it
    # This is less reliable but worth trying
    if printf '%s' "$test_sixel" 2>&1 | grep -q -E "(Unknown|not recognized|invalid)" 2>/dev/null; then
        return 1
    fi
    
    # If we got here without errors, cautiously assume it worked
    return 0
}

# Detect available image rendering tools
detect_image_tools() {
    # Detect Sixel tools
    if command -v img2sixel &>/dev/null; then
        IMG2SIXEL_PATH=$(command -v img2sixel)
        SIXEL_TOOL="img2sixel"
    fi
    
    # Detect ASCII art tools (in order of preference)
    if command -v chafa &>/dev/null; then
        CHAFA_PATH=$(command -v chafa)
        ASCII_TOOL="chafa"
    elif command -v jp2a &>/dev/null; then
        JP2A_PATH=$(command -v jp2a)
        ASCII_TOOL="jp2a"
    fi
    
    # Detect SVG converter
    if command -v rsvg-convert &>/dev/null; then
        RSVG_CONVERT_PATH=$(command -v rsvg-convert)
        SVG_CONVERTER="rsvg-convert"
    fi
}

# Check if we can render images at all
can_render_images() {
    # Initialize if needed
    if [[ "${IMAGE_RENDERER_INITIALIZED}" != "true" ]]; then
        init_image_renderer
    fi
    
    # Check if graphics are disabled
    if [[ "${NO_GRAPHICS:-false}" == "true" ]]; then
        return 1
    fi
    
    # Return success if we can render anything
    [[ "${CAN_RENDER_ANY}" == "true" ]]
}

# Convert SVG to PNG if needed and possible
convert_svg_to_png() {
    local svg_path="$1"
    local png_path="${2:-}"
    
    # Generate temporary file if no output path specified
    if [[ -z "$png_path" ]]; then
        png_path=$(mktemp "${TMPDIR:-/tmp}/shellforge_image_XXXXXX.png")
    fi
    
    # Check if we have rsvg-convert
    if [[ -z "${SVG_CONVERTER}" ]]; then
        return 1
    fi
    
    # Convert the SVG
    if "${RSVG_CONVERT_PATH}" -o "$png_path" "$svg_path" 2>/dev/null; then
        echo "$png_path"
        return 0
    else
        # Clean up on failure
        [[ -f "$png_path" ]] && rm -f "$png_path"
        return 1
    fi
}

# Render an image using the best available method
render_image() {
    local image_path="$1"
    local max_width="${2:-80}"
    local max_height="${3:-24}"
    local fallback_text="${4:-[Image]}"
    
    # Check if graphics are disabled
    if [[ "${NO_GRAPHICS:-false}" == "true" ]]; then
        echo "$fallback_text"
        return 0
    fi
    
    # Initialize if needed
    if [[ "${IMAGE_RENDERER_INITIALIZED}" != "true" ]]; then
        init_image_renderer
    fi
    
    # Check if file exists
    if [[ ! -f "$image_path" ]]; then
        if [[ "${VERBOSE:-false}" == "true" ]]; then
            debug_print "Image file not found: $image_path"
        fi
        echo "$fallback_text"
        return 1
    fi
    
    # Handle SVG files
    local render_path="$image_path"
    local temp_png=""
    if [[ "$image_path" == *.svg ]] || [[ "$image_path" == *.SVG ]]; then
        if [[ -n "${SVG_CONVERTER}" ]]; then
            temp_png=$(convert_svg_to_png "$image_path")
            if [[ -n "$temp_png" ]]; then
                render_path="$temp_png"
            else
                echo "$fallback_text"
                return 1
            fi
        else
            if [[ "${VERBOSE:-false}" == "true" ]]; then
                debug_print "SVG converter (rsvg-convert) not found"
            fi
            echo "$fallback_text"
            return 1
        fi
    fi
    
    # Render based on available method
    case "${IMAGE_RENDER_METHOD}" in
        sixel)
            render_image_sixel "$render_path" "$max_width" "$max_height"
            ;;
        ascii)
            render_image_ascii "$render_path" "$max_width" "$max_height"
            ;;
        *)
            echo "$fallback_text"
            ;;
    esac
    
    # Clean up temporary file if created
    if [[ -n "$temp_png" ]] && [[ -f "$temp_png" ]]; then
        rm -f "$temp_png"
    fi
}

# Render image using Sixel
render_image_sixel() {
    local image_path="$1"
    local max_width="${2:-80}"
    local max_height="${3:-24}"
    
    # Calculate pixel dimensions (assuming 8x16 character cells)
    local width_px=$((max_width * 8))
    local height_px=$((max_height * 16))
    
    # Render with img2sixel
    "${IMG2SIXEL_PATH}" \
        --width="$width_px" \
        --height="$height_px" \
        "$image_path" 2>/dev/null || echo "[Image]"
}

# Render image using ASCII art
render_image_ascii() {
    local image_path="$1"
    local max_width="${2:-80}"
    local max_height="${3:-24}"
    
    case "${ASCII_TOOL}" in
        chafa)
            "${CHAFA_PATH}" \
                --size="${max_width}x${max_height}" \
                --symbols=block+border+space \
                "$image_path" 2>/dev/null || echo "[Image]"
            ;;
        jp2a)
            "${JP2A_PATH}" \
                --width="$max_width" \
                --height="$max_height" \
                "$image_path" 2>/dev/null || echo "[Image]"
            ;;
        *)
            echo "[Image]"
            ;;
    esac
}

# Render the ShellForge logo if available
render_shellforge_logo() {
    local logo_path="${SHELLFORGE_LOGO_PATH:-}"
    local fallback="🔥 ShellForge"
    
    # If no logo path is set, just return the fallback
    if [[ -z "$logo_path" ]] || [[ ! -f "$logo_path" ]]; then
        echo "$fallback"
        return 0
    fi
    
    # Try to render the logo
    render_image "$logo_path" 40 8 "$fallback"
}

# Display image rendering capabilities (for debugging/info)
show_image_capabilities() {
    init_image_renderer
    
    print_section "Image Rendering Capabilities" "$CYAN"
    
    # Terminal information
    print_status "info" "Terminal Environment:"
    print_list "$BLUE" "  TERM: ${TERM:-unknown}"
    [[ -n "${TERM_PROGRAM:-}" ]] && print_list "$BLUE" "  TERM_PROGRAM: ${TERM_PROGRAM}"
    [[ -n "${VTE_VERSION:-}" ]] && print_list "$BLUE" "  VTE_VERSION: ${VTE_VERSION}"
    [[ -n "${XTERM_VERSION:-}" ]] && print_list "$BLUE" "  XTERM_VERSION: ${XTERM_VERSION}"
    [[ -n "${MLTERM:-}" ]] && print_list "$BLUE" "  MLTERM: ${MLTERM}"
    echo ""
    
    # Terminal support
    if [[ "${TERMINAL_SUPPORTS_SIXEL}" == "true" ]]; then
        print_status "success" "Terminal supports Sixel graphics"
    else
        print_status "info" "Terminal does not support Sixel graphics"
    fi
    
    # Available tools
    print_status "info" "Available rendering tools:"
    if [[ -n "${SIXEL_TOOL}" ]]; then
        print_list "$GREEN" "  img2sixel: ${IMG2SIXEL_PATH}"
    fi
    if [[ -n "${ASCII_TOOL}" ]]; then
        case "${ASCII_TOOL}" in
            chafa)
                print_list "$GREEN" "  chafa: ${CHAFA_PATH}"
                ;;
            jp2a)
                print_list "$GREEN" "  jp2a: ${JP2A_PATH}"
                ;;
        esac
    fi
    if [[ -n "${SVG_CONVERTER}" ]]; then
        print_list "$GREEN" "  rsvg-convert: ${RSVG_CONVERT_PATH}"
    fi
    
    # Rendering method
    if [[ -n "${IMAGE_RENDER_METHOD}" ]]; then
        print_status "success" "Selected rendering method: ${IMAGE_RENDER_METHOD}"
    else
        print_status "warning" "No image rendering available"
    fi
}
