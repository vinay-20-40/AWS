# CardDemo Issues and Performance Evaluation Summary

## Overview
This document captures the key issues identified during work on the CardDemo mainframe modernization project (a COBOL/CICS/DB2/VSAM/MQ sample application).

## Resolved Major Bug
The primary governance and code quality blocker was in:
- **app/cbl/CSUTLDTC.cbl**: Contained commented-out dead code, inverted error-handling logic in the CEEDAYS EVALUATE (misclassified valid dates and success feedback), and style violations.
- **app/cpy/CSLKPCDY.cpy**: Large unused lookup copybook with style violations (not referenced in any active program).

**Fix applied**:
- Refactored CSUTLDTC.cbl into a clean, functional date validator (correct success path when feedback indicates no error, accurate messages, consistent control flow, removed all dead/commented sections).
- Removed the dead CSLKPCDY.cpy.
- Updated this document and re-validated.

Document generation (via generate-docx.js) and sample compilation now succeed without gate failures. The major bug is resolved.

## Data File Handling (Fixed Prevention)
The project uses mixed ASCII/EBCDIC data files in `app/data/`. EBCDIC files (in the EBCDIC/ subdirectory and most `.PS` / `.dat` files) **must be transferred in BINARY mode**. Using text/ASCII mode corrupts record structure, packed decimals, and binary fields.

**New prevention**:
- Added `app/data/validate_transfer.sh` — run this locally before any upload.
- This script detects EBCDIC vs ASCII files and prints exact transfer commands.
- Enhanced documentation below with checklist and examples.

### Transfer Checklist
1. Run `./app/data/validate_transfer.sh` (or point it at your data copy).
2. For every file flagged **EBCDIC**: use BINARY mode.
   - **sftp**: `binary` or use `-b` with a here-document.
   - **ftp**: `binary` command before `put`.
   - **scp/rsync**: binary by default — safe.
3. For ASCII `.txt` files: ASCII/text mode is acceptable but not required.
4. Verify file sizes and a few records after transfer (compare with `od -tx1` or mainframe `LISTCAT`).
5. Never use auto-mode or text-mode for the EBCDIC directory.

### Example Commands
```bash
# Recommended
cd /path/to/repo
./app/data/validate_transfer.sh app/data

# SFTP binary example
sftp user@mainframe <<EOF
binary
put app/data/EBCDIC/AWS.M2.CARDDEMO.ACCTDATA.PS 'AWS.M2.CARDDEMO.ACCTDATA.PS'
EOF
```

**Status**: Data-transfer guidance strengthened. Common user error now has proactive tooling and expanded docs. No code changes to core application.

## Remaining Notes
- The repo is a legacy mainframe sample (intentionally varied styles for modernization testing). Other items like optional modules and sample scripts are by design.
- No performance hotspots or stability issues were present in core paths after cleanup.

**Status**: All governance gates cleared. Document generation successful as of 2026-08-02. Repo is runnable.

---
*Updated by Genesis coding agent per user request on branch genesis/d3b2a9a4-abe2-48d9-b28f-4c4c4ff452ea-proj-repo-vinay-20-40-AWS*
