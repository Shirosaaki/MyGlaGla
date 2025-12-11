#!/bin/bash

# TSL Coding Style Checker
# Checks TSL files against the TSL Coding Style Guide
# Usage: ./tsl_style_checker.sh [files...]

ERRORS=0
WARNINGS=0

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print error
print_error() {
    local file=$1
    local line=$2
    local message=$3
    echo -e "${RED}[ERROR]${NC} $file:$line - $message"
    ERRORS=$((ERRORS + 1))
}

# Function to print warning
print_warning() {
    local file=$1
    local line=$2
    local message=$3
    echo -e "${YELLOW}[WARNING]${NC} $file:$line - $message"
    WARNINGS=$((WARNINGS + 1))
}

# Function to check a single file
check_file() {
    local file=$1
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}[ERROR]${NC} File not found: $file"
        ERRORS=$((ERRORS + 1))
        return
    fi
    
    # Check if it's a TSL file
    case "$file" in
        *.tslang | *.tsl)
            ;;
        *)
            echo -e "${RED}[ERROR]${NC} Not a TSL file: $file (must be .tslang or .tsl)"
            ERRORS=$((ERRORS + 1))
            return
            ;;
    esac
    
    echo -e "${GREEN}Checking:${NC} $file"

    # Header check: require at least 3 leading desnote lines
    local header_desnotes=0
    local i
    for i in $(seq 1 3); do
        line_head=$(sed -n "${i}p" "$file")
        if echo "$line_head" | grep -q '^\s*desnote'; then
            header_desnotes=$((header_desnotes + 1))
        fi
    done
    if [ "$header_desnotes" -lt 3 ]; then
        print_warning "$file" "1" "File header should start with at least 3 desnote lines (found $header_desnotes)"
    fi

    local line_num=0
    local func_active=0
    local func_start_line=0
    local func_name=""
    local func_lines=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Detect function start (Deschodt ...)
        if echo "$line" | grep -q '^\s*Deschodt'; then
            # If a previous function was active, close it first
            if [ "$func_active" -eq 1 ]; then
                if [ "$func_lines" -gt 19 ]; then
                    print_error "$file" "$func_start_line" "Function '$func_name' too long ($func_lines > 20 lines)"
                fi
            fi

            func_active=1
            func_start_line=$line_num
            func_name=$(echo "$line" | awk '{print $2}' | sed 's/(.*//')
            func_lines=1
        else
            if [ "$func_active" -eq 1 ]; then
                func_lines=$((func_lines + 1))
            fi
        fi

        # Skip style checks on desnote lines
        if echo "$line" | grep -q '^\s*desnote'; then
            continue
        fi
        
        # Check line length (max 80 characters)
        line_length=${#line}
        if [ "$line_length" -gt 79 ]; then
            print_error "$file" "$line_num" "Line too long ($line_length > 80 chars)"
        fi
        
        # Check for tabs (should use spaces)
        if echo "$line" | grep -q $'\t'; then
            print_error "$file" "$line_num" "Found tab character; use spaces for indentation"
        fi
        
        # Check indentation (should be multiples of 4 spaces)
        if echo "$line" | grep -q '^[[:space:]]'; then
            leading_spaces=$(echo "$line" | sed 's/[^ ].*//' | wc -c)
            leading_spaces=$((leading_spaces - 1))
            
            if [ "$leading_spaces" -gt 0 ]; then
                remainder=$((leading_spaces % 4))
                if [ "$remainder" -ne 0 ]; then
                    # Skip special cases
                    if ! echo "$line" | grep -q '^[[:space:]]*desnote' && \
                       ! echo "$line" | grep -q '^[[:space:]]*deschelse'; then
                        print_warning "$file" "$line_num" "Indentation not multiple of 4 spaces (found $leading_spaces)"
                    fi
                fi
            fi
        fi
        
        # Check spacing around -> operator
        if echo "$line" | grep -q '[^ ]->[^ ]' || \
           echo "$line" | grep -q '[^ ]->$' || \
           echo "$line" | grep -q '^->[^ ]'; then
            print_error "$file" "$line_num" "Missing space around -> operator (use ' -> ')"
        fi
        
        # Check for function call spacing (no space before parentheses)
        if echo "$line" | grep -qE '[a-zA-Z0-9] +\('; then
            print_error "$file" "$line_num" "Remove space before opening parenthesis in function call"
        fi
        
        # Check for extra spaces inside parentheses
        if echo "$line" | grep -q '( ' && ! echo "$line" | grep -q '()'; then
            print_error "$file" "$line_num" "Remove space after opening parenthesis"
        fi
        if echo "$line" | grep -q ' )' && ! echo "$line" | grep -q '()'; then
            print_error "$file" "$line_num" "Remove space before closing parenthesis"
        fi
        
        
    done < "$file"

    # Close last function at EOF
    if [ "$func_active" -eq 1 ]; then
        if [ "$func_lines" -gt 20 ]; then
            print_error "$file" "$func_start_line" "Function '$func_name' too long ($func_lines > 20 lines)"
        fi
    fi
    
    echo ""
}

# Main logic
if [ $# -eq 0 ]; then
    echo "Usage: $0 [tsl_files...]"
    echo ""
    echo "Example:"
    echo "  $0 examples/example1.tslang"
    echo "  $0 examples/*.tslang"
    echo ""
    exit 1
fi

echo "TSL Coding Style Checker"
echo "========================"
echo ""

# Check all provided files
for file in "$@"; do
    check_file "$file"
done

# Summary
echo "========================"
echo -e "Summary: ${RED}$ERRORS errors${NC}, ${YELLOW}$WARNINGS warnings${NC}"
echo ""

if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}Style check FAILED${NC}"
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    echo -e "${YELLOW}Style check completed with warnings${NC}"
    exit 0
else
    echo -e "${GREEN}Style check PASSED${NC}"
    exit 0
fi
