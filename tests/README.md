# ShellForge Tests

This directory contains test scripts and demos for ShellForge functionality.

## Test Scripts

### Core Tests
- `test.sh` - Main test runner that executes all tests
- `test-build-fix.sh` - Tests for build system fixes
- `test-color-fix.sh` - Tests for color output functionality
- `test-dynamic-help.sh` - Tests for dynamic help system
- `test-smart-config.sh` - Tests for smart config filtering features
- `test-help-fix.sh` - Verifies help command works in various environments
- `test-help-debug.sh` - Debug tool for diagnosing help command issues

### Demo Scripts
- `demo-env-display.sh` - Demonstrates environment detection and display
- `demo-help.sh` - Demonstrates the help system output

## Running Tests

From the project root:

```bash
# Run all tests
make test

# Or directly
bash tests/test.sh

# Run individual test
bash tests/test-smart-config.sh
```

## Writing New Tests

When adding new features, please include corresponding tests:

1. Create a new test file: `test-<feature-name>.sh`
2. Follow the existing test pattern:
   - Clear test descriptions
   - Isolated test cases
   - Cleanup after tests
   - Success/failure reporting

3. Add your test to the main `test.sh` runner if needed

## Test Guidelines

- Tests should be idempotent (can run multiple times safely)
- Tests should clean up after themselves
- Use descriptive test names
- Check both success and failure cases
- Test edge cases and error conditions
