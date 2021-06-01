*&---------------------------------------------------------------------*
*& Report ZUSR_KERK_TESTPROGRAMM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZUSR_KERK_TESTPROGRAMM.


SELECTION-SCREEN BEGIN OF BLOCK gb_hdr WITH FRAME TITLE text-bk1.
  SELECTION-SCREEN BEGIN OF LINE.


SELECTION-SCREEN COMMENT 1(31) text-t03 FOR FIELD p_pty.
PARAMETERS:
  p_pty         TYPE /idxgc/de_proc_type.


  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK gb_hdr.
