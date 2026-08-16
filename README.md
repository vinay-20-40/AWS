## Installation

### Prerequisites
- Mainframe environment with CICS, VSAM, and JCL support
- Optional: DB2, IMS DB, and MQ for extended features
- File transfer capability between local environment and mainframe (sftp, scp, or ftp)
- **New**: Run the data transfer validator before uploading (see below)

### Data Transfer Best Practices (Critical)
The project ships mixed **ASCII** (in `app/data/ASCII/`) and **EBCDIC** (in `app/data/EBCDIC/`) data files. Using text mode on EBCDIC files corrupts packed decimals, binary fields, and record boundaries.

**Always**:
1. Run `./app/data/validate_transfer.sh app/data` before any upload.
2. Transfer all EBCDIC files in **BINARY** mode.
3. See [CARDDEMO_ISSUES.md](CARDDEMO_ISSUES.md#data-file-handling-fixed-prevention) for the full checklist, examples, and troubleshooting.

### Installation Steps

1. **Prepare Your Environment**
   - Clone this repository to your local development environment
   - Ensure you have appropriate access to your mainframe environment
   - Run the validator: `app/data/validate_transfer.sh`

2. **Create Mainframe Datasets**
   - Define a High Level Qualifier (HLQ) for your datasets
   - Create the following datasets with the specified formats:

     | HLQ    | Name          | Format | Length |
     | :----- | :------------ | :----- | -----: |
     | AWS.M2 | CARDDEMO.JCL  | FB     |     80 |
     | AWS.M2 | CARDDEMO.PROC | FB     |     80 |
     | AWS.M2 | CARDDEMO.CBL  | FB     |     80 |
     | AWS.M2 | CARDDEMO.CPY  | FB     |     80 |
     | AWS.M2 | CARDDEMO.BMS  | FB     |     80 |
     | AWS.M2 | CARDDEMO.ASM  | FB     |     80 |
     | AWS.M2 | CARDDEMO.MACLIB| FB    |     80 |

3. **Upload Source Code**
   - Upload the application source folders (`app/bms`, `app/cbl`, `app/cpy`, etc.) from the repository to your mainframe
   - Use your preferred file transfer tool
   - Source code is ASCII — text mode is fine

4. **Upload Sample Data**
   - Transfer files from the `app/data/` folder (both ASCII/ and EBCDIC/ subdirs)
   - **Run the validator first** (it will tell you the correct mode for each file)
   - Use binary transfer mode for all EBCDIC files to preserve data integrity
   - Create the following datasets:

     | Dataset name                      | Description                                  | Copybook     | Format | Length |
     | :---------------------------------| :------------------------------------------- | :----------- | :----- | -----: |
     | AWS.M2.CARDDEMO.USRSEC.PS         | User Security file                           | CSUSR01Y     | FB     |     80 |
     | AWS.M2.CARDDEMO.ACCTDATA.PS       | Account Data                                 | CVACT01Y     | FB     |    300 |
     | AWS.M2.CARDDEMO.CARDDATA.PS       | Card Data                                    | CVACT02Y     | FB     |    150 |
     | AWS.M2.CARDDEMO.CUSTDATA.PS       | Customer Data                                | CVCUS01Y     | FB     |    500 |
     | AWS.M2.CARDDEMO.CARDXREF.PS       | Customer Account Card Cross reference        | CVACT03Y     | FB     |     50 |
     | AWS.M2.CARDDEMO.DALYTRAN.PS.INIT  | Transaction database initialization record   | CVTRA06Y     | FB     |    350 |
     | AWS.M2.CARDDEMO.DALYTRAN.PS       | Transaction data for posting                 | CVTRA06Y     | FB     |    350 |
     | AWS.M2.CARDDEMO.TRANSACT.VSAM.KSDS| Online transaction data                      | CVTRA05Y     | FB     |    350 |
     | AWS.M2.CARDDEMO.DISCGRP.PS        | Disclosure Groups                            | CVTRA02Y     | FB     |     50 |
     | AWS.M2.CARDDEMO.TRANCATG.PS       | Transaction Category Types                   | CVTRA04Y     | FB     |     60 |
     | AWS.M2.CARDDEMO.TRANTYPE.PS       | Transaction Types                            | CVTRA03Y     | FB     |     60 |
     | AWS.M2.CARDDEMO.TCATBALF.PS       | Transaction Category Balance                 | CVTRA01Y     | FB     |     50 |

5. **Initialize the Environment**
   - Execute the following JCLs in sequence (see "Running Batch Jobs" for full order):

     | Jobname  | Purpose                                           | Optional Module |
     | :------- | :------------------------------------------------ |:--------------- |
     | DUSRSECJ | Sets up user security VSAM file                   |                 |
     | CLOSEFIL | Closes files opened by CICS                       |                 |
     | ACCTFILE | Loads Account database using sample data          |                 |
     | ... (full list in Running Batch Jobs section) | | |

6. **Compile the Programs**
   - Use your standard mainframe compilation procedures
   - Sample JCLs are provided in the `samples/jcl/` folder to assist with compilation

7. **Configure CICS Resources**
   - Option 1 (Preferred): Use the DFHCSDUP JCL with the CSD file in the `app/csd/` folder
   - Option 2: Use CEDA transaction to manually define resources (examples below)

8. **Install and Load Resources**
   - Install the resources in your CICS region and execute NEWCOPY for maps/programs.

See [CARDDEMO_ISSUES.md](CARDDEMO_ISSUES.md) for the latest status on data handling and other notes.
