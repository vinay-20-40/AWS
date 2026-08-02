#!/bin/bash
# validate_transfer.sh
# Pre-transfer validation helper for CardDemo mixed ASCII/EBCDIC data files.
# Run this locally before uploading to mainframe to avoid corruption.
# Usage: ./validate_transfer.sh [path-to-data-dir]

set -e

DATA_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "=== CardDemo Data Transfer Validator ==="
echo "Directory: $DATA_DIR"
echo "This script helps prevent EBCDIC corruption from text-mode transfers."
echo ""

EBCDIC_PATTERNS=("EBCDIC" ".PS" ".dat" "AWS.M2.CARDDEMO")
ASCII_PATTERNS=("ASCII" ".txt")

validate_file() {
  local file="$1"
  local basename=$(basename "$file")
  local is_ebcdic=0

  # Detect by path/name
  for pat in "${EBCDIC_PATTERNS[@]}"; do
    if echo "$file" | grep -qi "$pat"; then
      is_ebcdic=1
      break
    fi
  done

  # If not clear from name, check for high-bit bytes (typical EBCDIC signature)
  if [ $is_ebcdic -eq 0 ] && [ -f "$file" ]; then
    if head -c 512 "$file" 2>/dev/null | od -tx1 | grep -qE '(\s|^)(c[1-9a-f]|d[0-9a-f]|e[0-9a-f]|f[0-9a-f])'; then
      is_ebcdic=1
    fi
  fi

  if [ $is_ebcdic -eq 1 ]; then
    echo "EBCDIC  : $basename"
    echo "  → MUST use BINARY mode (ftp: 'binary', sftp: -b, scp is binary by default)"
    echo "  Recommended command examples:"
    echo "    sftp -b <(echo 'put \"$file\" \"remote-name\"') user@host"
    echo "    ftp -u user@host (then: binary; put \"$file\")"
    echo "    scp \"$file\" user@host:/path/"
    echo ""
  else
    echo "ASCII   : $basename"
    echo "  → Use TEXT/ASCII mode if line endings matter (ftp: 'ascii')"
    echo ""
  fi
}

echo "Scanning data files..."
if [ -d "$DATA_DIR/EBCDIC" ]; then
  for f in "$DATA_DIR/EBCDIC/"*; do
    [ -f "$f" ] && validate_file "$f"
  done
fi
if [ -d "$DATA_DIR/ASCII" ]; then
  for f in "$DATA_DIR/ASCII/"*; do
    [ -f "$f" ] && validate_file "$f"
  done
fi

echo "=== Validation complete ==="
echo "Always transfer EBCDIC files in BINARY mode to prevent corruption."
echo "See CARDDEMO_ISSUES.md for full checklist."
echo ""
echo "Add this script to your workflow before any upload."
