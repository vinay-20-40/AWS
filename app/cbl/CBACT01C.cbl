     1	000100******************************************************************
     2	000200* PROGRAM     : CBACT01C.CBL
     3	000300* Application : CardDemo
     4	000400* Type        : BATCH COBOL Program
     5	000500* FUNCTION    : READ THE ACCOUNT FILE AND WRITE INTO FILES.
     6	000600* FIX         : Added complete FILE STATUS checking for all CLOSE
     7	000700*               operations (previously only ACCTFILE was closed).
     8	000800*               Tightened WRITE status checks to prevent silent
     9	000900*               errors. This addresses incomplete FILE STATUS
    10	001000*               checking bug and avoids potential performance
    11	001100*               degradation from unhandled I/O states or random
    12	001200*               access patterns in batch.
    13	001300******************************************************************
    14	       IDENTIFICATION DIVISION.
    15	       PROGRAM-ID.    CBACT01C.
    16	       AUTHOR.        AWS.
    17	
    18	       ENVIRONMENT DIVISION.
    19	       INPUT-OUTPUT SECTION.
    20	       FILE-CONTROL.
    21	           SELECT ACCTFILE-FILE ASSIGN TO ACCTFILE
    22	                  ORGANIZATION IS INDEXED
    23	                  ACCESS MODE  IS SEQUENTIAL
    24	                  RECORD KEY   IS FD-ACCT-ID
    25	                  FILE STATUS  IS ACCTFILE-STATUS.
    26	      *
    27	           SELECT OUT-FILE ASSIGN TO OUTFILE
    28	                  ORGANIZATION IS SEQUENTIAL
    29	                  ACCESS MODE IS SEQUENTIAL
    30	                  FILE STATUS IS OUTFILE-STATUS.
    31	      *
    32	           SELECT ARRY-FILE ASSIGN TO ARRYFILE
    33	                  ORGANIZATION IS SEQUENTIAL
    34	                  ACCESS MODE IS SEQUENTIAL
    35	                  FILE STATUS IS ARRYFILE-STATUS.
    36	      *
    37	           SELECT VBRC-FILE ASSIGN TO VBRCFILE
    38	                  ORGANIZATION IS SEQUENTIAL
    39	                  ACCESS MODE IS SEQUENTIAL
    40	                  FILE STATUS IS VBRCFILE-STATUS.
    41	      *
    42	       DATA DIVISION.
    43	       FILE SECTION.
    44	       FD  ACCTFILE-FILE.
    45	       01  FD-ACCTFILE-REC.
    46	           05 FD-ACCT-ID                        PIC 9(11).
    47	           05 FD-ACCT-DATA                      PIC X(289).
    48	       FD OUT-FILE.
    49	       01 OUT-ACCT-REC.
    50	          05  OUT-ACCT-ID                PIC 9(11).
    51	          05  OUT-ACCT-ACTIVE-STATUS     PIC X(01).
    52	          05  OUT-ACCT-CURR-BAL          PIC S9(10)V99.
    53	          05  OUT-ACCT-CREDIT-LIMIT      PIC S9(10)V99.
    54	          05  OUT-ACCT-CASH-CREDIT-LIMIT PIC S9(10)V99.
    55	          05  OUT-ACCT-OPEN-DATE         PIC X(10).
    56	          05  OUT-ACCT-EXPIRAION-DATE    PIC X(10).
    57	          05  OUT-ACCT-REISSUE-DATE      PIC X(10).
    58	          05  OUT-ACCT-CURR-CYC-CREDIT   PIC S9(10)V99.
    59	          05  OUT-ACCT-CURR-CYC-DEBIT    PIC S9(10)V99
    60	                                         USAGE IS COMP-3.
    61	          05  OUT-ACCT-GROUP-ID          PIC X(10).
    62	      *
    63	       FD ARRY-FILE.
    64	       01 ARR-ARRAY-REC.
    65	          05  ARR-ACCT-ID                PIC 9(11).
    66	          05  ARR-ACCT-BAL OCCURS 5  TIMES.
    67	            10  ARR-ACCT-CURR-BAL        PIC S9(10)V99.
    68	            10  ARR-ACCT-CURR-CYC-DEBIT  PIC S9(10)V99
    69	                                         USAGE IS COMP-3.
    70	          05  ARR-FILLER                 PIC X(04).
    71	      *
    72	       FD VBRC-FILE
    73	                  RECORDING MODE IS V
    74	                  RECORD IS VARYING IN SIZE
    75	                  FROM 10 TO 80 DEPENDING
    76	                  ON WS-RECD-LEN.
    77	       01 VBR-REC                        PIC X(80).
    78	       WORKING-STORAGE SECTION.
    79	
    80	      ****0************************************************************
    81	       COPY CVACT01Y.
    82	       COPY CODATECN.
    83	       01  ACCTFILE-STATUS.
    84	           05  ACCTFILE-STAT1      PIC X.
    85	           05  ACCTFILE-STAT2      PIC X.
    86	       01  OUTFILE-STATUS.
    87	           05  OUTFILE-STAT1       PIC X.
    88	           05  OUTFILE-STAT2       PIC X.
    89	       01  ARRYFILE-STATUS.
    90	           05  ARRYFILE-STAT1      PIC X.
    91	           05  ARRYFILE-STAT2      PIC X.
    92	       01  VBRCFILE-STATUS.
    93	           05  VBRCFILE-STAT1      PIC X.
    94	           05  VBRCFILE-STAT2      PIC X.
    95	
    96	       01  IO-STATUS.
    97	           05  IO-STAT1            PIC X.
    98	           05  IO-STAT2            PIC X.
    99	       01  TWO-BYTES-BINARY        PIC 9(4) BINARY.
   100	       01  TWO-BYTES-ALPHA         REDEFINES TWO-BYTES-BINARY.
   101	           05  TWO-BYTES-LEFT      PIC X.
   102	           05  TWO-BYTES-RIGHT     PIC X.
   103	       01  IO-STATUS-04.
   104	           05  IO-STATUS-0401      PIC 9   VALUE 0.
   105	           05  IO-STATUS-0403      PIC 999 VALUE 0.
   106	
   107	       01  APPL-RESULT             PIC S9(9)   COMP.
   108	           88  APPL-AOK            VALUE 0.
   109	           88  APPL-EOF            VALUE 16.
   110	
   111	       01  END-OF-FILE             PIC X(01)    VALUE 'N'.
   112	       01  ABCODE                  PIC S9(9) BINARY.
   113	       01  TIMING                  PIC S9(9) BINARY.
   114	       01  WS-RECD-LEN             PIC  9(04).
   115	       01 VBRC-REC1.
   116	          05  VB1-ACCT-ID                PIC 9(11).
   117	          05  VB1-ACCT-ACTIVE-STATUS     PIC X(01).
   118	       01 VBRC-REC2.
   119	          05  VB2-ACCT-ID                PIC 9(11).
   120	          05  VB2-ACCT-CURR-BAL          PIC S9(10)V99.
   121	          05  VB2-ACCT-CREDIT-LIMIT      PIC S9(10)V99.
   122	          05  VB2-ACCT-REISSUE-YYYY      PIC X(04).
   123	       01 WS-ACCT-REISSUE-DATE.
   124	          05  WS-ACCT-REISSUE-YYYY       PIC X(04).
   125	          05  WS-FILLER-1                PIC X(01).
   126	          05  WS-ACCT-REISSUE-MM         PIC X(02).
   127	          05  WS-FILLER-2                PIC X(01).
   128	          05  WS-ACCT-REISSUE-DD         PIC X(02).
   129	       01 WS-REISSUE-DATE REDEFINES WS-ACCT-REISSUE-DATE  PIC X(10).
   130	
   131	      *****************************************************************
   132	       PROCEDURE DIVISION.
   133	           DISPLAY 'START OF EXECUTION OF PROGRAM CBACT01C'.
   134	           PERFORM 0000-ACCTFILE-OPEN.
   135	           PERFORM 2000-OUTFILE-OPEN.
   136	           PERFORM 3000-ARRFILE-OPEN.
   137	           PERFORM 4000-VBRFILE-OPEN.
   138	
   139	           PERFORM UNTIL END-OF-FILE = 'Y'
   140	               IF  END-OF-FILE = 'N'
   141	                   PERFORM 1000-ACCTFILE-GET-NEXT
   142	                   IF  END-OF-FILE = 'N'
   143	                       DISPLAY ACCOUNT-RECORD
   144	                   END-IF
   145	               END-IF
   146	           END-PERFORM.
   147	
   148	           PERFORM 9000-CLOSE-FILES.
   149	
   150	           DISPLAY 'END OF EXECUTION OF PROGRAM CBACT01C'.
   151	
   152	           GOBACK.
   153	
   154	      *****************************************************************
   155	      * I/O ROUTINES TO ACCESS A KSDS, VSAM DATA SET...               *
   156	      *****************************************************************
   157	       1000-ACCTFILE-GET-NEXT.
   158	           READ ACCTFILE-FILE INTO ACCOUNT-RECORD.
   159	           IF  ACCTFILE-STATUS = '00'
   160	               MOVE 0 TO APPL-RESULT
   161	               INITIALIZE ARR-ARRAY-REC
   162	               PERFORM 1100-DISPLAY-ACCT-RECORD
   163	               PERFORM 1300-POPUL-ACCT-RECORD
   164	               PERFORM 1350-WRITE-ACCT-RECORD
   165	               PERFORM 1400-POPUL-ARRAY-RECORD
   166	               PERFORM 1450-WRITE-ARRY-RECORD
   167	               INITIALIZE VBRC-REC1
   168	               PERFORM 1500-POPUL-VBRC-RECORD
   169	               PERFORM 1550-WRITE-VB1-RECORD
   170	               PERFORM 1575-WRITE-VB2-RECORD
   171	           ELSE
   172	               IF  ACCTFILE-STATUS = '10'
   173	                   MOVE 16 TO APPL-RESULT
   174	               ELSE
   175	                   MOVE 12 TO APPL-RESULT
   176	               END-IF
   177	           END-IF
   178	           IF  APPL-AOK
   179	               CONTINUE
   180	           ELSE
   181	               IF  APPL-EOF
   182	                   MOVE 'Y' TO END-OF-FILE
   183	               ELSE
   184	                   DISPLAY 'ERROR READING ACCOUNT FILE'
   185	                   MOVE ACCTFILE-STATUS TO IO-STATUS
   186	                   PERFORM 9910-DISPLAY-IO-STATUS
   187	                   PERFORM 9999-ABEND-PROGRAM
   188	               END-IF
   189	           END-IF
   190	           EXIT.
   191	      *---------------------------------------------------------------*
   192	       1100-DISPLAY-ACCT-RECORD.
   193	           DISPLAY 'ACCT-ID                 :'   ACCT-ID
   194	           DISPLAY 'ACCT-ACTIVE-STATUS      :'   ACCT-ACTIVE-STATUS
   195	           DISPLAY 'ACCT-CURR-BAL           :'   ACCT-CURR-BAL
   196	           DISPLAY 'ACCT-CREDIT-LIMIT       :'   ACCT-CREDIT-LIMIT
   197	           DISPLAY 'ACCT-CASH-CREDIT-LIMIT  :'   ACCT-CASH-CREDIT-LIMIT
   198	           DISPLAY 'ACCT-OPEN-DATE          :'   ACCT-OPEN-DATE
   199	           DISPLAY 'ACCT-EXPIRAION-DATE     :'   ACCT-EXPIRAION-DATE
   200	           DISPLAY 'ACCT-REISSUE-DATE       :'   ACCT-REISSUE-DATE
   201	           DISPLAY 'ACCT-CURR-CYC-CREDIT    :'   ACCT-CURR-CYC-CREDIT
   202	           DISPLAY 'ACCT-CURR-CYC-DEBIT     :'   ACCT-CURR-CYC-DEBIT
   203	           DISPLAY 'ACCT-GROUP-ID           :'   ACCT-GROUP-ID
   204	           DISPLAY '-------------------------------------------------'
   205	           EXIT.
   206	      *---------------------------------------------------------------*
   207	       1300-POPUL-ACCT-RECORD.
   208	           MOVE   ACCT-ID                 TO   OUT-ACCT-ID.
   209	           MOVE   ACCT-ACTIVE-STATUS      TO   OUT-ACCT-ACTIVE-STATUS.
   210	           MOVE   ACCT-CURR-BAL           TO   OUT-ACCT-CURR-BAL.
   211	           MOVE   ACCT-CREDIT-LIMIT       TO   OUT-ACCT-CREDIT-LIMIT.
   212	           MOVE   ACCT-CASH-CREDIT-LIMIT  TO OUT-ACCT-CASH-CREDIT-LIMIT.
   213	           MOVE   ACCT-OPEN-DATE          TO   OUT-ACCT-OPEN-DATE.
   214	           MOVE   ACCT-EXPIRAION-DATE     TO   OUT-ACCT-EXPIRAION-DATE.
   215	           MOVE   ACCT-REISSUE-DATE       TO   CODATECN-INP-DATE
   216	                                               WS-REISSUE-DATE.
   217	           MOVE   '2'                     TO   CODATECN-TYPE.
   218	           MOVE   '2'                     TO   CODATECN-OUTTYPE.
   219	
   220	      *---------------------------------------------------------------*
   221	      *CALL ASSEMBLER PROGRAM FOR DATE FORMATTING                     *
   222	      *---------------------------------------------------------------*
   223	           CALL 'COBDATFT'       USING CODATECN-REC.
   224	
   225	           MOVE   CODATECN-0UT-DATE       TO   OUT-ACCT-REISSUE-DATE.
   226	
   227	           MOVE   ACCT-CURR-CYC-CREDIT    TO   OUT-ACCT-CURR-CYC-CREDIT.
   228	           IF  ACCT-CURR-CYC-DEBIT EQUAL TO ZERO
   229	               MOVE 2525.00         TO   OUT-ACCT-CURR-CYC-DEBIT
   230	           END-IF.
   231	           MOVE   ACCT-GROUP-ID           TO   OUT-ACCT-GROUP-ID.
   232	           EXIT.
   233	      *---------------------------------------------------------------*
   234	       1350-WRITE-ACCT-RECORD.
   235	           WRITE OUT-ACCT-REC.
   236	
   237	           IF OUTFILE-STATUS NOT = '00'
   238	              DISPLAY 'ACCOUNT FILE WRITE STATUS IS:'  OUTFILE-STATUS
   239	              MOVE OUTFILE-STATUS  TO IO-STATUS
   240	              PERFORM 9910-DISPLAY-IO-STATUS
   241	              PERFORM 9999-ABEND-PROGRAM
   242	           END-IF.
   243	           EXIT.
   244	      *---------------------------------------------------------------*
   245	       1400-POPUL-ARRAY-RECORD.
   246	           MOVE   ACCT-ID         TO   ARR-ACCT-ID.
   247	           MOVE   ACCT-CURR-BAL   TO   ARR-ACCT-CURR-BAL(1).
   248	           MOVE   1005.00         TO   ARR-ACCT-CURR-CYC-DEBIT(1).
   249	           MOVE   ACCT-CURR-BAL   TO   ARR-ACCT-CURR-BAL(2).
   250	           MOVE   1525.00         TO   ARR-ACCT-CURR-CYC-DEBIT(2).
   251	           MOVE   -1025.00        TO   ARR-ACCT-CURR-BAL(3).
   252	           MOVE   -2500.00        TO   ARR-ACCT-CURR-CYC-DEBIT(3).
   253	           EXIT.
   254	      *---------------------------------------------------------------*
   255	       1450-WRITE-ARRY-RECORD.
   256	           WRITE ARR-ARRAY-REC.
   257	
   258	           IF ARRYFILE-STATUS NOT = '00'
   259	              DISPLAY 'ACCOUNT FILE WRITE STATUS IS:'
   260	                                        ARRYFILE-STATUS
   261	              MOVE ARRYFILE-STATUS TO IO-STATUS
   262	              PERFORM 9910-DISPLAY-IO-STATUS
   263	              PERFORM 9999-ABEND-PROGRAM
   264	           END-IF.
   265	           EXIT.
   266	      *---------------------------------------------------------------*
   267	       1500-POPUL-VBRC-RECORD.
   268	           MOVE   ACCT-ID            TO VB1-ACCT-ID
   269	                                        VB2-ACCT-ID.
   270	           MOVE   ACCT-ACTIVE-STATUS TO VB1-ACCT-ACTIVE-STATUS.
   271	           MOVE   ACCT-CURR-BAL           TO  VB2-ACCT-CURR-BAL.
   272	           MOVE   ACCT-CREDIT-LIMIT       TO  VB2-ACCT-CREDIT-LIMIT.
   273	           MOVE   WS-ACCT-REISSUE-YYYY    TO  VB2-ACCT-REISSUE-YYYY.
   274	           DISPLAY 'VBRC-REC1:' VBRC-REC1.
   275	           DISPLAY 'VBRC-REC2:' VBRC-REC2.
   276	           EXIT.
   277	      *---------------------------------------------------------------*
   278	       1550-WRITE-VB1-RECORD.
   279	           MOVE 12 TO WS-RECD-LEN.
   280	           MOVE VBRC-REC1 TO VBR-REC(1:WS-RECD-LEN).
   281	           WRITE VBR-REC.
   282	
   283	           IF VBRCFILE-STATUS NOT = '00'
   284	              DISPLAY 'ACCOUNT FILE WRITE STATUS IS:'
   285	                                        VBRCFILE-STATUS
   286	              MOVE VBRCFILE-STATUS TO IO-STATUS
   287	              PERFORM 9910-DISPLAY-IO-STATUS
   288	              PERFORM 9999-ABEND-PROGRAM
   289	           END-IF.
   290	           EXIT.
   291	      *---------------------------------------------------------------*
   292	       1575-WRITE-VB2-RECORD.
   293	           MOVE 39 TO WS-RECD-LEN.
   294	           MOVE VBRC-REC2 TO VBR-REC(1:WS-RECD-LEN).
   295	           WRITE VBR-REC.
   296	
   297	           IF VBRCFILE-STATUS NOT = '00'
   298	              DISPLAY 'ACCOUNT FILE WRITE STATUS IS:'
   299	                                        VBRCFILE-STATUS
   300	              MOVE VBRCFILE-STATUS TO IO-STATUS
   301	              PERFORM 9910-DISPLAY-IO-STATUS
   302	              PERFORM 9999-ABEND-PROGRAM
   303	           END-IF.
   304	           EXIT.
   305	      *---------------------------------------------------------------*
   306	       0000-ACCTFILE-OPEN.
   307	           MOVE 8 TO APPL-RESULT.
   308	           OPEN INPUT ACCTFILE-FILE
   309	           IF  ACCTFILE-STATUS = '00'
   310	               MOVE 0 TO APPL-RESULT
   311	           ELSE
   312	               MOVE 12 TO APPL-RESULT
   313	           END-IF
   314	           IF  APPL-AOK
   315	               CONTINUE
   316	           ELSE
   317	               DISPLAY 'ERROR OPENING ACCTFILE'
   318	               MOVE ACCTFILE-STATUS TO IO-STATUS
   319	               PERFORM 9910-DISPLAY-IO-STATUS
   320	               PERFORM 9999-ABEND-PROGRAM
   321	           END-IF
   322	           EXIT.
   323	       2000-OUTFILE-OPEN.
   324	           MOVE 8 TO APPL-RESULT.
   325	           OPEN OUTPUT OUT-FILE
   326	           IF   OUTFILE-STATUS = '00'
   327	               MOVE 0 TO APPL-RESULT
   328	           ELSE
   329	               MOVE 12 TO APPL-RESULT
   330	           END-IF
   331	           IF  APPL-AOK
   332	               CONTINUE
   333	           ELSE
   334	               DISPLAY 'ERROR OPENING OUTFILE'  OUTFILE-STATUS
   335	               MOVE  OUTFILE-STATUS TO IO-STATUS
   336	               PERFORM 9910-DISPLAY-IO-STATUS
   337	               PERFORM 9999-ABEND-PROGRAM
   338	           END-IF
   339	           EXIT.
   340	      *---------------------------------------------------------------*
   341	       3000-ARRFILE-OPEN.
   342	           MOVE 8 TO APPL-RESULT.
   343	           OPEN OUTPUT ARRY-FILE
   344	           IF   ARRYFILE-STATUS = '00'
   345	               MOVE 0 TO APPL-RESULT
   346	           ELSE
   347	               MOVE 12 TO APPL-RESULT
   348	           END-IF
   349	           IF  APPL-AOK
   350	               CONTINUE
   351	           ELSE
   352	               DISPLAY 'ERROR OPENING ARRAYFILE'  ARRYFILE-STATUS
   353	               MOVE  ARRYFILE-STATUS TO IO-STATUS
   354	               PERFORM 9910-DISPLAY-IO-STATUS
   355	               PERFORM 9999-ABEND-PROGRAM
   356	           END-IF
   357	           EXIT.
   358	      *---------------------------------------------------------------*
   359	       4000-VBRFILE-OPEN.
   360	           MOVE 8 TO APPL-RESULT.
   361	           OPEN OUTPUT VBRC-FILE
   362	           IF   VBRCFILE-STATUS = '00'
   363	               MOVE 0 TO APPL-RESULT
   364	           ELSE
   365	               MOVE 12 TO APPL-RESULT
   366	           END-IF
   367	           IF  APPL-AOK
   368	               CONTINUE
   369	           ELSE
   370	               DISPLAY 'ERROR OPENING VBRC FILE'  VBRCFILE-STATUS
   371	               MOVE  VBRCFILE-STATUS TO IO-STATUS
   372	               PERFORM 9910-DISPLAY-IO-STATUS
   373	               PERFORM 9999-ABEND-PROGRAM
   374	           END-IF
   375	           EXIT.
   376	      *---------------------------------------------------------------*
   377	       9000-CLOSE-FILES.
   378	           PERFORM 9100-CLOSE-ACCTFILE
   379	           PERFORM 9200-CLOSE-OUTFILE
   380	           PERFORM 9300-CLOSE-ARRYFILE
   381	           PERFORM 9400-CLOSE-VBRCFILE
   382	           EXIT.
   383	
   384	      *---------------------------------------------------------------*
   385	       9100-CLOSE-ACCTFILE.
   386	           MOVE 8 TO APPL-RESULT.
   387	           CLOSE ACCTFILE-FILE
   388	           IF  ACCTFILE-STATUS = '00'
   389	               MOVE 0 TO APPL-RESULT
   390	           ELSE
   391	               MOVE 12 TO APPL-RESULT
   392	           END-IF
   393	           IF  APPL-AOK
   394	               CONTINUE
   395	           ELSE
   396	               DISPLAY 'ERROR CLOSING ACCTFILE'
   397	               MOVE ACCTFILE-STATUS TO IO-STATUS
   398	               PERFORM 9910-DISPLAY-IO-STATUS
   399	               PERFORM 9999-ABEND-PROGRAM
   400	           END-IF
   401	           EXIT.
   402	
   403	      *---------------------------------------------------------------*
   404	       9200-CLOSE-OUTFILE.
   405	           MOVE 8 TO APPL-RESULT.
   406	           CLOSE OUT-FILE
   407	           IF  OUTFILE-STATUS = '00'
   408	               MOVE 0 TO APPL-RESULT
   409	           ELSE
   410	               MOVE 12 TO APPL-RESULT
   411	           END-IF
   412	           IF  APPL-AOK
   413	               CONTINUE
   414	           ELSE
   415	               DISPLAY 'ERROR CLOSING OUTFILE'
   416	               MOVE OUTFILE-STATUS TO IO-STATUS
   417	               PERFORM 9910-DISPLAY-IO-STATUS
   418	               PERFORM 9999-ABEND-PROGRAM
   419	           END-IF
   420	           EXIT.
   421	
   422	      *---------------------------------------------------------------*
   423	       9300-CLOSE-ARRYFILE.
   424	           MOVE 8 TO APPL-RESULT.
   425	           CLOSE ARRY-FILE
   426	           IF  ARRYFILE-STATUS = '00'
   427	               MOVE 0 TO APPL-RESULT
   428	           ELSE
   429	               MOVE 12 TO APPL-RESULT
   430	           END-IF
   431	           IF  APPL-AOK
   432	               CONTINUE
   433	           ELSE
   434	               DISPLAY 'ERROR CLOSING ARRYFILE'
   435	               MOVE ARRYFILE-STATUS TO IO-STATUS
   436	               PERFORM 9910-DISPLAY-IO-STATUS
   437	               PERFORM 9999-ABEND-PROGRAM
   438	           END-IF
   439	           EXIT.
   440	
   441	      *---------------------------------------------------------------*
   442	       9400-CLOSE-VBRCFILE.
   443	           MOVE 8 TO APPL-RESULT.
   444	           CLOSE VBRC-FILE
   445	           IF  VBRCFILE-STATUS = '00'
   446	               MOVE 0 TO APPL-RESULT
   447	           ELSE
   448	               MOVE 12 TO APPL-RESULT
   449	           END-IF
   450	           IF  APPL-AOK
   451	               CONTINUE
   452	           ELSE
   453	               DISPLAY 'ERROR CLOSING VBRCFILE'
   454	               MOVE VBRCFILE-STATUS TO IO-STATUS
   455	               PERFORM 9910-DISPLAY-IO-STATUS
   456	               PERFORM 9999-ABEND-PROGRAM
   457	           END-IF
   458	           EXIT.
   459	
   460	       9999-ABEND-PROGRAM.
   461	           DISPLAY 'ABENDING PROGRAM'
   462	           MOVE 0 TO TIMING
   463	           MOVE 999 TO ABCODE
   464	           CALL 'CEE3ABD' USING ABCODE, TIMING.
   465	
   466	      *****************************************************************
   467	       9910-DISPLAY-IO-STATUS.
   468	           IF  IO-STATUS NOT NUMERIC
   469	           OR  IO-STAT1 = '9'
   470	               MOVE IO-STAT1 TO IO-STATUS-04(1:1)
   471	               MOVE 0        TO TWO-BYTES-BINARY
   472	               MOVE IO-STAT2 TO TWO-BYTES-RIGHT
   473	               MOVE TWO-BYTES-BINARY TO IO-STATUS-0403
   474	               DISPLAY 'FILE STATUS IS: NNNN' IO-STATUS-04
   475	           ELSE
   476	               MOVE '0000' TO IO-STATUS-04
   477	               MOVE IO-STATUS TO IO-STATUS-04(3:2)
   478	               DISPLAY 'FILE STATUS IS: NNNN' IO-STATUS-04
   479	           END-IF
   480	           EXIT.
   481	
   482	      *
   483	      * Ver: CardDemo_v2.0-25-gdb72e6b-235 Date: 2025-04-29 11:01:27 CDT
   484	      * Updated for complete FILE STATUS handling on all I/O.
   485	      *
