const { Document, Packer, Paragraph, HeadingLevel, TextRun, Table, TableRow, TableCell, WidthType, BorderStyle, AlignmentType } = require('docx');
const fs = require('fs');

// Create document
const doc = new Document({
    sections: [{
        properties: {},
        children: [
            // Title
            new Paragraph({
                text: "CardDemo Repository Summary",
                heading: HeadingLevel.TITLE,
                alignment: AlignmentType.CENTER,
            }),
            new Paragraph({
                text: "Mainframe Credit Card Management Test Harness for Modernization",
                heading: HeadingLevel.HEADING_1,
                alignment: AlignmentType.CENTER,
            }),
            new Paragraph({
                text: `Generated: ${new Date().toISOString().split('T')[0]} | Source: https://github.com/vinay-20-40/AWS/tree/main`,
                alignment: AlignmentType.CENTER,
            }),
            new Paragraph({ text: "" }),

            // Executive Summary
            new Paragraph({
                text: "Executive Summary",
                heading: HeadingLevel.HEADING_1,
            }),
            new Paragraph({
                text: "CardDemo is a comprehensive mainframe application simulating a credit card management system. It serves as a realistic, deployable test harness (CICS + VSAM base, with optional Db2/IMS/MQ modules) for AWS and partner technologies. The codebase is intentionally legacy (no go.mod/package.json) and includes diverse coding styles to test discovery, migration, performance testing, service enablement, refactoring, and augmentation strategies. It is not production code.",
            }),
            new Paragraph({ text: "" }),

            // Description
            new Paragraph({
                text: "Description",
                heading: HeadingLevel.HEADING_1,
            }),
            new Paragraph({
                text: "CardDemo provides a practical environment for:",
            }),
            new Paragraph({
                text: "• Application discovery and analysis\n• Migration assessment and planning\n• Modernization strategy development\n• Performance testing and system augmentation\n• Service enablement and extraction\n• Test creation and automation",
                bullet: { level: 0 },
            }),
            new Paragraph({
                text: "The application intentionally incorporates varied coding styles and patterns (including complex copybooks with REDEFINES, OCCURS, and OCCURS DEPENDING ON) to exercise analysis, transformation, and migration tooling across mainframe paradigms.",
            }),
            new Paragraph({ text: "" }),

            // Technologies
            new Paragraph({
                text: "Technologies",
                heading: HeadingLevel.HEADING_1,
            }),
            new Paragraph({
                text: "Core Technologies",
                heading: HeadingLevel.HEADING_2,
            }),
            new Paragraph({
                text: "• COBOL (primary language)\n• CICS (transaction processing)\n• VSAM (KSDS with AIX)\n• JCL (batch processing)\n• RACF (security)\n• ASSEMBLER (MVSWAIT timer, COBDATFT date utility)",
            }),
            new Paragraph({
                text: "Optional Technologies",
                heading: HeadingLevel.HEADING_2,
            }),
            new Paragraph({
                text: "• Db2 (relational, with cursors, stored procedures, dynamic SQL in roadmap)\n• IMS DB (hierarchical)\n• MQ (messaging, async patterns)\n• Advanced data formats (COMP, COMP-3, zoned decimal, signed/unsigned)\n• Dataset types (VSAM ESDS/RRDS, GDG, PDS)\n• Record formats (VB, FBA, etc.)\n• JCL utilities (FTP, TXT2PDF, LOAD/UNLOAD, internal reader)",
            }),
            new Paragraph({ text: "" }),

            // Optional Features
            new Paragraph({
                text: "Optional Features",
                heading: HeadingLevel.HEADING_1,
            }),
            new Paragraph({
                text: "1. Credit Card Authorizations (IMS, DB2, MQ): authorization requests via MQ, IMS customer lookup, DB2 logging, pending auth summary/details, batch purge.\n2. Transaction Type Management (DB2): CRUD via CICS and batch, demonstrates cursors/SQL.\n3. Account Extractions (MQ + VSAM): CDRD (system date), CDRA (account details) via MQ.\n4. Enhanced JCL Utilities: FTP/SFTP, PDF conversion, DB2/IMS load/unload.",
            }),
            new Paragraph({ text: "" }),

            // Installation
            new Paragraph({
                text: "Installation",
                heading: HeadingLevel.HEADING_1,
            }),
            new Paragraph({
                text: "Prerequisites: Mainframe with CICS/VSAM/JCL; optional Db2/IMS/MQ; file transfer (binary for EBCDIC data).",
            }),
            new Paragraph({
                text: "Key Steps (condensed from README):",
            }),
            new Paragraph({
                text: "1. Clone repo and define HLQ datasets (JCL/PROC/CBL/CPY/BMS/ASM/MACLIB).\n2. Upload sources and EBCDIC sample data (USRSEC, ACCTDATA, CARDDATA, CUSTDATA, CARDXREF, TRAN files, etc.).\n3. Run initialization JCL sequence (DUSRSECJ, ACCTFILE, CARDFILE, CUSTFILE, XREFFILE, CREADB21, TRANFILE, OPENFIL, DEFGDGB, etc.).\n4. Compile (sample JCLs provided), configure CICS resources (DFHCSDUP or CEDA), install with CEDA/CECI/NEWCOPY.\n5. Access: CC00 transaction (ADMIN001/PASSWORD or USER0001/PASSWORD).",
            }),
            new Paragraph({
                text: "Full detailed tables, JCL lists, and diagrams are in the repo root README.md and app/ subdirectories.",
            }),
            new Paragraph({ text: "" }),

            // Application Details
            new Paragraph({
                text: "Application Details",
                heading: HeadingLevel.HEADING_1,
            }),
            new Paragraph({
                text: "User Types: Regular users (standard card management) and Admin users (user/transaction management).",
            }),
            new Paragraph({
                text: "User Functions: View/update accounts, manage cards, view/add/process transactions, reports, bill payments, pending authorizations (optional).",
            }),
            new Paragraph({
                text: "Admin Functions: User CRUD; transaction type management (DB2 optional).",
            }),
            new Paragraph({ text: "" }),

            // Technical Highlights
            new Paragraph({
                text: "Technical Highlights",
                heading: HeadingLevel.HEADING_1,
            }),
            new Paragraph({
                text: "• Realistic test harness, not production code.\n• Extensive inventory of online (CICS transactions like CC00, CM00, CAVW, CAUP, CT00–CT02, CR00, CB00, admin screens) and batch components.\n• Diagrams for data model, flows, auth, screens.\n• Scripts for local/remote compile, batch execution, markers for verification.\n• Sample runtimes (Micro Focus, UniKix).",
            }),
            new Paragraph({ text: "" }),

            // Support, Roadmap, Contributing, License, Status
            new Paragraph({
                text: "Support",
                heading: HeadingLevel.HEADING_2,
            }),
            new Paragraph({
                text: "Raise issues in the GitHub repository. Maintainers respond as availability permits.",
            }),

            new Paragraph({
                text: "Roadmap",
                heading: HeadingLevel.HEADING_2,
            }),
            new Paragraph({
                text: "• Additional DB syntax (DB2 Rewards with stored procedures/functions/dynamic SQL; IMS DC).\n• Integration enhancements (FTP/SFTP, web services, distributed transaction exposure).",
            }),

            new Paragraph({
                text: "Contributing",
                heading: HeadingLevel.HEADING_2,
            }),
            new Paragraph({
                text: "Implement changes with tests; submit PRs with clear descriptions. Issues and enhancements welcomed to grow this community resource.",
            }),

            new Paragraph({
                text: "License",
                heading: HeadingLevel.HEADING_2,
            }),
            new Paragraph({
                text: "Apache 2.0 – intended as a community resource for mainframe modernization learning and tooling validation.",
            }),

            new Paragraph({
                text: "Project Status",
                heading: HeadingLevel.HEADING_2,
            }),
            new Paragraph({
                text: "Enhanced with optional IMS-DB2-MQ authorization, DB2 transaction management, MQ/VSAM extractions, expanded data/copybook support, and comprehensive JCL/utilities. Actively positioned for broader modernization scenario testing.",
            }),
            new Paragraph({ text: "" }),

            // Footer
            new Paragraph({
                text: "This document was auto-generated from the live repository contents (README.md and supporting files) using Node.js + docx. Full details, source code, diagrams, JCLs, and sample data reside in the GitHub repo.",
                alignment: AlignmentType.CENTER,
            }),
        ],
    }],
});

// Generate and write file
Packer.toBuffer(doc).then((buffer) => {
    fs.writeFileSync("carddemo-repo-summary.docx", buffer);
    console.log("Successfully generated carddemo-repo-summary.docx");
}).catch((err) => {
    console.error("Error generating DOCX:", err);
});
