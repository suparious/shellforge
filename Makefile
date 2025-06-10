# ShellForge Makefile
# Convenient targets for building, testing, and managing ShellForge

.PHONY: all build clean install test release debug minimal help

# Default target
all: build

# Build release version
build:
	@echo "Building ShellForge..."
	@bash build/build.sh release

# Build debug version with extra information
debug:
	@echo "Building debug version..."
	@bash build/build.sh debug

# Build minimal version without comments
minimal:
	@echo "Building minimal version..."
	@bash build/build.sh minimal

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@bash build/build.sh clean
	@rm -f shellforge

# Install to user's bin directory
install: build
	@echo "Installing ShellForge to ~/bin..."
	@mkdir -p ~/bin
	@cp shellforge ~/bin/
	@chmod +x ~/bin/shellforge
	@echo "✓ Installed to ~/bin/shellforge"

# Run tests
test: build
	@echo "Running tests..."
	@if [ -f test.sh ]; then \
		bash test.sh; \
	else \
		echo "No tests found"; \
	fi

# Create a new release
release: build
	@echo "Creating release..."
	@VERSION=$$(cat VERSION); \
	git add -A; \
	git commit -m "Release v$$VERSION" || true; \
	git tag -a "v$$VERSION" -m "Version $$VERSION"; \
	echo "✓ Tagged release v$$VERSION"
	@echo "Don't forget to push tags: git push --tags"

# Bump version
bump-version:
	@CURRENT=$$(cat VERSION); \
	echo "Current version: $$CURRENT"; \
	read -p "New version: " NEW_VERSION; \
	echo "$$NEW_VERSION" > VERSION; \
	echo "✓ Version bumped to $$NEW_VERSION"

# Development build (watches for changes)
watch:
	@echo "Watching for changes..."
	@while true; do \
		inotifywait -qr -e modify,create,delete src/ 2>/dev/null && \
		make build && \
		echo "✓ Rebuilt at $$(date)"; \
	done

# Show help
help:
	@echo "ShellForge Makefile targets:"
	@echo ""
	@echo "  make              - Build release version (default)"
	@echo "  make build        - Build release version"
	@echo "  make debug        - Build debug version with source markers"
	@echo "  make minimal      - Build minimal version without comments"
	@echo "  make clean        - Remove build artifacts"
	@echo "  make install      - Build and install to ~/bin"
	@echo "  make test         - Run tests"
	@echo "  make release      - Create a tagged release"
	@echo "  make bump-version - Interactively bump version number"
	@echo "  make watch        - Auto-rebuild on source changes (requires inotify-tools)"
	@echo "  make help         - Show this help message"
	@echo ""
	@echo "Build modes:"
	@echo "  release  - Standard build (default)"
	@echo "  debug    - Include source markers and all comments"
	@echo "  minimal  - Strip comments for smaller size"
