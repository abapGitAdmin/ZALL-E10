*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTD_EJVL_DOWN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mtd_ejvl_down.

DATA: iejvl TYPE TABLE OF ejvl WITH HEADER LINE,
      unix_file LIKE temfd-path.

PARAMETERS: exp_path LIKE temfd-path
            DEFAULT '/rkudat/rkustd/isu/evuit/525e/',
            file(30) TYPE c  DEFAULT 'EJVL'.



START-OF-SELECTION.

  SELECT * INTO TABLE iejvl
           FROM ejvl.

  CONCATENATE exp_path file INTO unix_file.

  OPEN DATASET unix_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

  LOOP AT iejvl.
    TRANSFER iejvl TO unix_file.
  ENDLOOP.

  CLOSE DATASET unix_file.
