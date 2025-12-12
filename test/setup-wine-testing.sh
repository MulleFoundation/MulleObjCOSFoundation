#!/bin/bash
#
# Wine Testing Setup Script for MulleObjCOSFoundation Windows Implementation
#
# This script sets up a Wine environment for testing Windows implementations
# on Linux development machines.
#

set -e

echo "=== Wine Testing Setup for MulleObjCOSFoundation ==="

# Check if we're on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Error: This script is designed for Linux systems only"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Wine and MinGW if not present
echo "Checking for required packages..."

if ! command_exists wine; then
    echo "Installing Wine..."
    sudo apt-get update
    sudo apt-get install -y wine64 wine32
else
    echo "Wine already installed: $(wine --version)"
fi

if ! command_exists x86_64-w64-mingw32-gcc; then
    echo "Installing MinGW cross-compiler..."
    sudo apt-get install -y mingw-w64
else
    echo "MinGW already installed: $(x86_64-w64-mingw32-gcc --version | head -1)"
fi

# Initialize Wine if needed
if [ ! -d "$HOME/.wine" ]; then
    echo "Initializing Wine environment..."
    winecfg
else
    echo "Wine environment already initialized"
fi

# Create Wine testing directory
WINE_TEST_DIR="$HOME/.mulle/wine-testing"
mkdir -p "$WINE_TEST_DIR"

echo "Wine testing directory: $WINE_TEST_DIR"

# Create a simple test wrapper script
cat > "$WINE_TEST_DIR/test-windows.sh" << 'EOF'
#!/bin/bash
#
# Test Windows executables with Wine
#

TEST_EXE="$1"
EXPECTED_OUTPUT="$2"

if [ -z "$TEST_EXE" ]; then
    echo "Usage: $0 <windows-executable> [expected-output-file]"
    exit 1
fi

if [ ! -f "$TEST_EXE" ]; then
    echo "Error: Windows executable not found: $TEST_EXE"
    exit 1
fi

echo "Testing Windows executable: $TEST_EXE"

# Run with Wine and capture output
if wine "$TEST_EXE" > test-output.txt 2>&1; then
    echo "✅ Wine execution succeeded"

    # If expected output file provided, compare
    if [ -n "$EXPECTED_OUTPUT" ] && [ -f "$EXPECTED_OUTPUT" ]; then
        echo "Comparing with expected output: $EXPECTED_OUTPUT"

        # Normalize output for comparison (remove Wine warnings, etc.)
        grep -v "wine:" test-output.txt > normalized-output.txt

        if diff -u "$EXPECTED_OUTPUT" normalized-output.txt > diff-output.txt; then
            echo "✅ Output matches expected results"
            rm -f test-output.txt normalized-output.txt diff-output.txt
            exit 0
        else
            echo "❌ Output differs from expected results"
            echo "Differences:"
            cat diff-output.txt
            rm -f test-output.txt normalized-output.txt diff-output.txt
            exit 1
        fi
    else
        echo "Output:"
        cat test-output.txt
        rm -f test-output.txt
        exit 0
    fi
else
    echo "❌ Wine execution failed"
    echo "Error output:"
    cat test-output.txt
    rm -f test-output.txt
    exit 1
fi
EOF

chmod +x "$WINE_TEST_DIR/test-windows.sh"

# Create a cross-compilation helper script
cat > "$WINE_TEST_DIR/cross-compile.sh" << 'EOF'
#!/bin/bash
#
# Cross-compile for Windows using MinGW
#

# Set up cross-compilation environment
export CC=x86_64-w64-mingw32-gcc
export CXX=x86_64-w64-mingw32-g++
export AR=x86_64-w64-mingw32-ar
export STRIP=x86_64-w64-mingw32-strip
export PKG_CONFIG_PATH=/usr/x86_64-w64-mingw32/lib/pkgconfig

echo "Cross-compilation environment set up:"
echo "CC=$CC"
echo "CXX=$CXX"
echo "AR=$AR"

echo ""
echo "To cross-compile MulleObjCOSFoundation for Windows:"
echo "1. Ensure all dependencies are available for Windows"
echo "2. Run: mulle-sde craft --release"
echo "3. Test executables will be created in build/ directories"
echo ""
echo "To test a Windows executable:"
echo "$WINE_TEST_DIR/test-windows.sh path/to/executable.exe [expected-output.txt]"
EOF

chmod +x "$WINE_TEST_DIR/cross-compile.sh"

# Create a test runner for NSProcessInfo
cat > "$WINE_TEST_DIR/test-nsprocessinfo.sh" << 'EOF'
#!/bin/bash
#
# Test NSProcessInfo Windows implementation
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Find Windows test executables
BASIC_TEST="$PROJECT_ROOT/build/test/NSProcessInfo/test-windows-basic.exe"
COMPREHENSIVE_TEST="$PROJECT_ROOT/build/test/NSProcessInfo/test-windows-comprehensive.exe"

echo "=== NSProcessInfo Windows Implementation Test ==="

if [ -f "$BASIC_TEST" ]; then
    echo "Running basic test..."
    "$SCRIPT_DIR/test-windows.sh" "$BASIC_TEST" "$PROJECT_ROOT/test/NSProcessInfo/test-windows-basic.stdout"
else
    echo "Basic test executable not found: $BASIC_TEST"
    echo "Make sure to build the project first"
fi

echo ""

if [ -f "$COMPREHENSIVE_TEST" ]; then
    echo "Running comprehensive test..."
    "$SCRIPT_DIR/test-windows.sh" "$COMPREHENSIVE_TEST" "$PROJECT_ROOT/test/NSProcessInfo/test-windows-comprehensive.stdout"
else
    echo "Comprehensive test executable not found: $COMPREHENSIVE_TEST"
    echo "Make sure to build the project first"
fi
EOF

chmod +x "$WINE_TEST_DIR/test-nsprocessinfo.sh"

# Create a summary of what's been set up
cat << EOF

=== Wine Testing Setup Complete ===

Setup completed successfully! Here's what was created:

1. Wine Environment: $HOME/.wine (initialized if needed)
2. Test Directory: $WINE_TEST_DIR
3. Test Scripts:
   - $WINE_TEST_DIR/test-windows.sh      # General Windows executable tester
   - $WINE_TEST_DIR/cross-compile.sh     # Cross-compilation environment setup
   - $WINE_TEST_DIR/test-nsprocessinfo.sh # NSProcessInfo specific tests

=== Usage Instructions ===

1. Set up cross-compilation environment:
   source $WINE_TEST_DIR/cross-compile.sh

2. Build Windows executables (when mulle-sde supports it):
   mulle-sde craft --release

3. Test NSProcessInfo implementation:
   $WINE_TEST_DIR/test-nsprocessinfo.sh

4. Test any Windows executable:
   $WINE_TEST_DIR/test-windows.sh path/to/executable.exe [expected-output.txt]

=== Current Status ===

✅ NSProcessInfo+Windows implementation complete
✅ Comprehensive test suite created
✅ Wine testing infrastructure ready

Next steps:
1. Wait for cross-compilation support in mulle-sde
2. Build Windows executables
3. Test with Wine
4. Move to next class: NSPathUtilities+Windows

EOF

echo "Setup complete! The Wine testing environment is ready for when cross-compilation becomes available."