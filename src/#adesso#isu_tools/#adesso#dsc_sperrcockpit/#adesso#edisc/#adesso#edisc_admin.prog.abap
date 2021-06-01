*&---------------------------------------------------------------------*
*& Report  /ADESSO/EDISC_ADMIN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  /ADESSO/EDISC_ADMIN.

 TYPE-POOLS: slis, isu05.
 TABLES: ediscdoc, /ADESSO/SPT_EDI1, efkkop.


 DATA: wa_ediscdoc TYPE ediscdoc,
       it_ediscdoc TYPE TABLE OF ediscdoc,
       ld_okcode   TYPE regen-okcode,
       lr_discno   TYPE RANGE OF discno WITH HEADER LINE.


 DATA: h_auto TYPE isu05_discdoc_auto.

 SELECTION-SCREEN BEGIN OF BLOCK s1 WITH FRAME TITLE text-s01.
 SELECT-OPTIONS: s_discno FOR ediscdoc-discno.
 PARAMETERS: p_status TYPE ediscdoc-status OBLIGATORY.

 SELECTION-SCREEN SKIP 1.

 PARAMETERS: p_lart1 RADIOBUTTON GROUP lart DEFAULT 'X',
             p_lart2 RADIOBUTTON GROUP lart,
             p_lart3 RADIOBUTTON GROUP lart,
             p_lart4 RADIOBUTTON GROUP lart.
 SELECTION-SCREEN END OF BLOCK s1.

 START-OF-SELECTION.

* P_LART1	Storno letzter Sperraktion
* P_LART2	Abschluss Sperrbeleg
* P_LART3	Löschen von Sperrbelegen


* alle Sperrbelege lesen
   SELECT * FROM ediscdoc INTO TABLE it_ediscdoc
     WHERE discno    IN s_discno
       AND status    EQ p_status.


   IF NOT p_lart1 IS INITIAL
   OR NOT p_lart2 IS INITIAL.

     CLEAR h_auto.
     h_auto-contr-use-okcode = 'X'.
     h_auto-contr-use-interface = 'X'.

     IF NOT p_lart1 IS INITIAL.
       h_auto-contr-okcode = 'DARKREVERSE'.   " Stornieren von Sperraktionen
     ENDIF.
     IF NOT p_lart2 IS INITIAL.
       h_auto-contr-okcode = 'DARKCOMPL'.     " Abschluss
     ENDIF.

     LOOP AT it_ediscdoc INTO wa_ediscdoc.
* Sperraktion durchführen
       CALL FUNCTION 'ISU_S_DISCDOC_CHANGE'
         EXPORTING
           x_discno           = wa_ediscdoc-discno
           x_upd_online       = 'X'
           x_no_dialog        = 'X'
           x_auto             = h_auto
           x_set_commit_work  = 'X'
         EXCEPTIONS
           not_found          = 1
           foreign_lock       = 2
           not_authorized     = 3
           input_error        = 4
           general_fault      = 5
           object_inv_discdoc = 6
           OTHERS             = 7.
     ENDLOOP.
   ENDIF.

   IF NOT p_lart3 IS INITIAL.
     lr_discno-sign = 'I'.
     lr_discno-option = 'EQ'.
     LOOP AT it_ediscdoc INTO wa_ediscdoc.
       lr_discno-low = wa_ediscdoc-discno.
       APPEND lr_discno.
     ENDLOOP.

     DELETE FROM ediscdoc
     WHERE discno IN lr_discno.

     DELETE FROM ediscact
     WHERE discno IN lr_discno.

     DELETE FROM ediscobj
     WHERE discno IN lr_discno.

     DELETE FROM ediscobjh
     WHERE discno IN lr_discno.

  DELETE FROM ediscpos
  WHERE discno IN lr_discno.

  DELETE FROM ediscremov
  WHERE discno IN lr_discno.
ENDIF.

IF NOT p_lart4 IS INITIAL.

  CHECK sy-mandt EQ '755'.

  DATA: lt_ediscdoc TYPE TABLE OF ediscdoc,
        lt_ediscact TYPE TABLE OF ediscact,
        lt_ediscobj TYPE TABLE OF ediscobj,
        lt_ediscobjh TYPE TABLE OF ediscobjh,
        lt_ediscpos TYPE TABLE OF ediscpos,
        lt_ediscremov TYPE TABLE OF ediscremov.

  SELECT * FROM ediscdoc CLIENT SPECIFIED
    INTO TABLE lt_ediscdoc
    WHERE mandt EQ '255'.
  MODIFY ediscdoc FROM TABLE lt_ediscdoc.


  SELECT * FROM ediscact CLIENT SPECIFIED
    INTO TABLE lt_ediscact
    WHERE mandt EQ '255'.
  MODIFY ediscact FROM TABLE lt_ediscact.


  SELECT * FROM ediscobj CLIENT SPECIFIED
INTO TABLE lt_ediscobj
WHERE mandt EQ '255'.
  MODIFY ediscobj FROM TABLE lt_ediscobj.


  SELECT * FROM ediscobjh CLIENT SPECIFIED
INTO TABLE lt_ediscobjh
WHERE mandt EQ '255'.
  MODIFY ediscobjh FROM TABLE lt_ediscobjh.


  SELECT * FROM ediscpos CLIENT SPECIFIED
INTO TABLE lt_ediscpos
WHERE mandt EQ '255'.
  MODIFY ediscpos FROM TABLE lt_ediscpos.


  SELECT * FROM ediscremov CLIENT SPECIFIED
INTO TABLE lt_ediscremov
WHERE mandt EQ '255'.
  MODIFY ediscremov FROM TABLE lt_ediscremov.


ENDIF.
