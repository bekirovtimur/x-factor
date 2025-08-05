#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting update process from: $PROJECT_ROOT"
echo "Looking for scripts in: $PROJECT_ROOT/scripts"

if [ ! -d "$PROJECT_ROOT/scripts" ]; then
    echo "Error: scripts directory not found at $PROJECT_ROOT/scripts"
    exit 1
fi

executed_count=0
failed_count=0

script_files=$(find "$PROJECT_ROOT/scripts" -name "*.sh" -type f | sort)

for script_file in $script_files; do
    relative_path="${script_file#$PROJECT_ROOT/}"
    
    echo "----------------------------------------"
    echo "Executing: $relative_path"
    echo "----------------------------------------"
    
    if [ ! -x "$script_file" ]; then
        echo "Making $relative_path executable..."
        chmod +x "$script_file"
    fi
    
    if (cd "$PROJECT_ROOT" && "$script_file"); then
        echo "✅ Successfully executed: $relative_path"
        ((executed_count++))
    else
        echo "❌ Failed to execute: $relative_path"
        ((failed_count++))
    fi
    
    echo ""
done

echo "========================================"
echo "Update process completed!"
echo "Successfully executed: $executed_count scripts"
echo "Failed: $failed_count scripts"
echo "========================================"

# if [ $failed_count -gt 0 ]; then
#     exit 1
# fi
