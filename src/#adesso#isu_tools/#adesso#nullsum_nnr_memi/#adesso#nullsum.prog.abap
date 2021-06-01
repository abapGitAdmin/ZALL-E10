*&---------------------------------------------------------------------*
*& Report /ADESSO/NULLSUM_NNR
*&---------------------------------------------------------------------*
*& In loving memory of Peter Nuss (1963 - 2019)
*&---------------------------------------------------------------------*
REPORT /adesso/nullsum.

TYPE-POOLS: abap.

TYPES: BEGIN OF ty_auswertung,
         einzbel          TYPE dfkkthi-opbel,
         einzbelop        TYPE dfkkthi-opupk,
         min_opupk        TYPE dfkkthi-opupk,
         thinr            TYPE dfkkthi-thinr,
         bukrs            TYPE dfkkthi-bukrs,
         vkont            TYPE dfkkthi-vkont,
         senid            TYPE dfkkthi-senid,
         recid            TYPE dfkkthi-recid,
         a_vkont          TYPE dfkkop-vkont,
         aggropbel        TYPE dfkkop-opbel,
         aggropupk        TYPE dfkkop-opupk,
         betrw            TYPE dfkkthi-betrw,
         int_crossrefno   TYPE ecrossrefno-int_crossrefno,
         crossrefno       TYPE ecrossrefno-crossrefno,
         crn_rev          TYPE ecrossrefno-crn_rev,
         budat            TYPE dfkkop-budat,
         kennz(1)         TYPE c,
         streinzbel       TYPE dfkkthi-opbel,
         streinzbelop     TYPE dfkkthi-opupk,
         straggrbel       TYPE dfkkop-opbel,
         straggrbelop     TYPE dfkkop-opupk,
*         augbel         TYPE dfkkop-opbel,                 "Nuss 10.2018
**        f_status       TYPE c LENGTH 50,                  "Nuss 10.2018
         stateinzbel      TYPE /idxmm/memidoc-doc_status,     "Nuss 07.2018
         aggrbelanz(5)    TYPE n,                           "Nuss 10.2018-2
         straggrbelanz(5) TYPE n,                           "Nuss 10.2018-2
         gruppkz(15)      TYPE c,                           "Nuss 10.2018-2
         endavis          TYPE tinv_inv_doc-int_inv_doc_no, "Nuss 10.2018-2
         uebavis          TYPE tinv_inv_doc-int_inv_doc_no,     "Nuss 11.2018
         strstatus        TYPE /idxmm/memidoc-doc_status,     "Nuss 07.2018
         memi(1)          TYPE c,                             "Nuss 07.2018
         sel(1)           TYPE c,                             "Nuss 07.2018
         nullavis         TYPE tinv_inv_doc-int_inv_doc_no,   "Nuss 07.2018
         pr_state(4)      TYPE c,                             "Nuss 10.2018
         msb(1)           TYPE c,                             "Nuss 10.2018
       END OF ty_auswertung.

TYPES: BEGIN OF ty_bdc,
         program  TYPE bdcdata-program,
         dynpro   TYPE bdcdata-dynpro,
         dynbegin TYPE bdcdata-dynbegin,
         fnam     TYPE bdcdata-fnam,
         fval     TYPE bdcdata-fval,
       END OF ty_bdc.

TYPES: BEGIN OF ty_tinv_inv_line_a,
         int_inv_doc_no TYPE tinv_inv_line_a-int_inv_doc_no,
         invoice_date   TYPE tinv_inv_doc-invoice_date,
       END OF ty_tinv_inv_line_a.

** --> Nuss 07.2018
TYPES: BEGIN OF ty_auswertung_memi,
         einzbel          TYPE /idxmm/memidoc-doc_id,
         stateinzbel      TYPE /idxmm/memidoc-doc_status,
         bukrs            TYPE /idxmm/memidoc-company_code,
         vkont            TYPE /idxmm/memidoc-suppl_contr_acct,
         senid            TYPE /idxmm/memidoc-dist_sp,
         recid            TYPE /idxmm/memidoc-suppl_sp,
         a_vkont          TYPE dfkkop-vkont,
         aggropbel        TYPE dfkkop-opbel,
         aggropupk        TYPE dfkkop-opupk,
         betrw            TYPE /idxmm/memidoc-gross_amount,
         crossrefno       TYPE /idxmm/memidoc-crossrefno,
         budat            TYPE dfkkop-budat,
         streinzbel       TYPE /idxmm/memidoc-doc_id,
         strstatus        TYPE /idxmm/memidoc-doc_status,
         crn_rev          TYPE /idxmm/memidoc-crossrefno,
         straggrbel       TYPE dfkkop-opbel,
         straggrbelop     TYPE dfkkop-opupk,
         aggrbelanz(4)    TYPE n,                           "Nuss 10.2018-2
         straggrbelanz(4) TYPE n,                           "Nuss 10.2018-2
         gruppkz(15)      TYPE c,                           "Nuss 10.2018-2
         endavis          TYPE tinv_inv_doc-int_inv_doc_no, "Nuss 10.2018-2
         uebavis          TYPE tinv_inv_doc-int_inv_doc_no,     "Nuss 11.2018
*         augbel       TYPE dfkkop-opbel,                       "Nuss 10.2018
*         status       TYPE c LENGTH 50,                        "Nuss 10.2018
         kennz(1)         TYPE c,
         memi(1)          TYPE c,
         nullavis         TYPE tinv_inv_doc-int_inv_doc_no,  "Nuss 07.2018
       END OF ty_auswertung_memi.
** <-- Nuss 07.2018

** --> Nuss 10.2018
TYPES: BEGIN OF ty_auswertung_msb,
         einzbel      TYPE  dfkkinvdoc_h-invdocno,
         bukrs        TYPE dfkkinvdoc_h-bukrs,
         vkont        TYPE dfkkinvdoc_h-vkont,
         senid        TYPE dfkkinvdoc_h-/mosb/mo_sp,
         recid        TYPE dfkkinvdoc_h-/mosb/lead_sup,
         a_vkont      TYPE dfkkop-vkont,
         aggropbel    TYPE dfkkop-opbel,
         aggropupk    TYPE dfkkop-opupk,
         betrw        TYPE dfkkinvdoc_h-total_amt,
         crossrefno   TYPE dfkkinvdoc_h-/mosb/inv_doc_ident,
         budat        TYPE dfkkop-budat,
         streinzbel   TYPE dfkkinvdoc_h-invdocno,
         crn_rev      TYPE dfkkinvdoc_h-/mosb/inv_doc_ident,
         straggrbel   TYPE dfkkop-opbel,
         straggrbelop TYPE dfkkop-opupk,
         kennz(1)     TYPE c,
         msb(1)       TYPE c,
       END OF ty_auswertung_msb.
** Nuss 10.2018


DATA: lv_streinzbel   TYPE dfkkthi-opbel,
      lv_streinzbelop TYPE dfkkthi-opupk,
      lv_straggrbel   TYPE dfkkop-opbel,
      lv_straggrbelop TYPE dfkkop-opupk,
      lv_stornobeleg  TYPE dfkkko-storb,     "Nuss 20.06.2013
      lv_tabix        TYPE sy-tabix,
      lv_betrw        TYPE dfkkop-betrw,     "Summe Beträge aus verteilten Positionen
      lv_betrwn       TYPE dfkkop-betrw,     "Summe Beträge aus verteilten neg. Positionen
      lv_betrwan      TYPE dfkkop-betrw,     "Zu verteilende Summe als neg. Betrag
      lv_betrwr       TYPE dfkkop-betrw,     "zu verteilender Restbetrag
      lv_betrwrn      TYPE dfkkop-betrw.     "zu verteilender neg. Restbetrag

DATA: lv_vkont     TYPE dfkkop-vkont,
      lv_stat_orig TYPE /idxmm/memidoc-doc_status,
      lv_stat_stor TYPE /idxmm/memidoc-doc_status,
      lv_budat     TYPE dfkkop-budat,
      lv_fikey     TYPE dfkkko-fikey,     " Abstimmschlüssel: KPMAJJJJMMTT
      lv_date(8)   TYPE c,
      lv_nr(2)     TYPE n VALUE '01'.

DATA: ls_auswertung       TYPE ty_auswertung,
      ls_auswertung_memi  TYPE ty_auswertung_memi,   "Nuss 07.2018
      ls_memidoc          TYPE /idxmm/memidoc,       "Nuss 07.2018
      ls_auswertung_msb   TYPE ty_auswertung_msb,    "Nuss 10.2018
      ls_dfkkinvbill_h    TYPE dfkkinvbill_h,        "Nuss 10.2018
      ls_dfkkinvbill_h2   TYPE dfkkinvbill_h,        "Nuss 10.2018
      ls_dfkkinvdoc_h     TYPE dfkkinvdoc_h,         "Nuss 10.2018
      ls_auswertung_aggr  TYPE ty_auswertung,        "Nuss 10.2018-2
      ls_bdc              TYPE ty_bdc,
      ls_tinv_inv_line_a  TYPE ty_tinv_inv_line_a,
      ls_tinv_inv_line_a2 TYPE ty_tinv_inv_line_a.

DATA: lt_auswertung      TYPE STANDARD TABLE OF ty_auswertung,
      lt_auswertung_memi TYPE STANDARD TABLE OF ty_auswertung_memi,    "Nuss 07.2018
      lt_auswertung_msb  TYPE STANDARD TABLE OF ty_auswertung_msb,     "Nuss 10.2018
      lt_bdc             TYPE STANDARD TABLE OF ty_bdc.

DATA: ls_fkkko   TYPE fkkko,
      ls_seltab  TYPE iseltab,
      lt_seltab  TYPE TABLE OF iseltab,
      ls_fkkcl   TYPE fkkcl,
      lt_fkkcl   TYPE TABLE OF fkkcl,
      lt_fkkcl_d TYPE TABLE OF fkkcl,
      lt_fkkcl_b TYPE TABLE OF fkkcl,
      lv_flag    TYPE c LENGTH 1,
      lv_docnum  TYPE fkkko-opbel,
      lt_custkpf TYPE TABLE OF /adesso/cust_kpf,
      ls_custkpf TYPE /adesso/cust_kpf,
      ls_dfkkop  TYPE dfkkop.                        "Nuss 11.2018

DATA: s_fkkeposc  TYPE fkkeposc,
      s_fkkeposs1 TYPE fkkeposs1,
      t_fkkeposs1 LIKE TABLE OF s_fkkeposs1.

DATA: f_service_prov TYPE service_prov.

DATA: BEGIN OF ls_eplot,
        opbel TYPE dfkkop-opbel,
        opupk TYPE dfkkop-opupk,
        bukrs TYPE dfkkop-bukrs,
        vkont TYPE dfkkop-vkont,
        tvorg TYPE dfkkop-tvorg,
        budat TYPE dfkkop-budat,
        betrw TYPE dfkkop-betrw,
      END OF ls_eplot.

DATA: lt_eplot LIKE TABLE OF ls_eplot.

** --> Nuss 01.07.2013
FIELD-SYMBOLS: <lf_fkkcl> TYPE fkkcl.
FIELD-SYMBOLS: <lf_fkkcl_b> TYPE fkkcl.
TYPES: BEGIN OF ty_hilf,
         opbel TYPE dfkkthi-opbel,
         betrw TYPE dfkkthi-betrw,
       END OF ty_hilf.
DATA: lt_hilf TYPE STANDARD TABLE OF ty_hilf,
      ls_hilf TYPE ty_hilf.
** <-- Nuss 01.07.2013


*--> Maxim Schmidt 22.04.2012 auskommentiert, da die Konstanten durch die Customizingtabelle /EVUIT/CUST_KPF ersetzt wurde
*CONSTANTS: CONST_WAERS TYPE DFKKOP-WAERS VALUE 'EUR',
*           CONST_AUGRD TYPE DFKKOP-AUGRD VALUE '08', "08=Kontenpflege
*           CONST_BLART TYPE DFKKOP-BLART VALUE 'SB', "KP=Kontenpflege
*           CONST_HERKF TYPE DFKKKO-HERKF VALUE '03', "03=Kontenpflege
*           CONST_ABST(2) TYPE C          VALUE 'KN'. "Präfix Abstimmschlüssel KN= Kontenpflege Nullsummen
*<-- Maxim Schmidt 22.04.2012 auskommentiert, da die Konstanten durch die Customizingtabelle /EVUIT/CUST_KPF ersetzt wurde

* Data ALV-Grid
TYPE-POOLS: slis.

DATA: lv_programm TYPE sy-repid,
      gt_fieldcat TYPE slis_t_fieldcat_alv,
      ls_fieldcat TYPE LINE OF slis_t_fieldcat_alv,
      gs_layout   TYPE slis_layout_alv,
      g_status    TYPE slis_formname VALUE 'STATUS_STANDARD'.     "Nuss 07.2018

* --> Nuss 07.2018
DATA: gs_head  TYPE tinv_inv_head,
      gs_linea TYPE tinv_inv_line_a,
      gt_linea TYPE STANDARD TABLE OF tinv_inv_line_a,
      gs_doc   TYPE tinv_inv_doc,
      gs_proc  TYPE tinv_inv_docproc.
* <-- Nuss 07.2018

* --> Nuss 10.2018-2
DATA: gv_aggropbel_help TYPE opbel_kk,
      gv_lfdnr(6)       TYPE n,
      gv_aggranz        TYPE i,
      gv_straggranz     TYPE i,
      gv_gruppkz(15)    TYPE c,
      gv_helpavis       TYPE inv_int_inv_doc_no,
      gv_changed        TYPE flag.

* <-- Nuss 10.2018-2

*-----------------------------------------------------------------------
* Selectionscreen
*-----------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.

SELECT-OPTIONS: so_vkont FOR lv_vkont OBLIGATORY.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
PARAMETERS: cbens AS CHECKBOX DEFAULT 'X'.
*PARAMETERS: cbepl AS CHECKBOX.                                                  "Nuss 10.2018
PARAMETERS: cbvns AS CHECKBOX USER-COMMAND dummy.
SELECT-OPTIONS: so_cpuds FOR lv_budat MODIF ID a." OBLIGATORY.  "Nuss 02.07.2013 geändert
SELECTION-SCREEN END OF BLOCK b02.

* --> Nuss 09.2018
*SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-b03.
*PARAMETERS: cbsaa AS CHECKBOX.
*SELECTION-SCREEN END OF BLOCK b03.
* <-- Nuss 09.2018
PARAMETERS: p_count TYPE int4 DEFAULT 999.

SELECTION-SCREEN END OF BLOCK b01.

* --> Kasdorf 08.2020

SELECTION-SCREEN BEGIN OF BLOCK b06 WITH FRAME TITLE TEXT-b06.
PARAMETERS: cnnabea AS CHECKBOX DEFAULT 'X'. "Beendete Zahlungsavise ignorieren
SELECTION-SCREEN END OF BLOCK b06.
* <-- Kasdorf 08.2020

* --> Kasdorf 04.2020
SELECTION-SCREEN BEGIN OF BLOCK b05 WITH FRAME TITLE TEXT-b05.

SELECT-OPTIONS: so_stato FOR lv_stat_orig OBLIGATORY.
PARAMETERS: cmmmarev AS CHECKBOX. "Reklamationen auf Storno ignorieren (E)
PARAMETERS: cmmmabea AS CHECKBOX DEFAULT 'X'. "Beendete Zahlungsavise ignorieren
SELECTION-SCREEN END OF BLOCK b05.
* <-- Kasdorf 04.2020

* --> Kasdorf 08.2020
SELECTION-SCREEN BEGIN OF BLOCK b07 WITH FRAME TITLE TEXT-b07.
PARAMETERS: cmsbbea AS CHECKBOX DEFAULT 'X'. "Beendete Zahlungsavise ignorieren
SELECTION-SCREEN END OF BLOCK b07.
* <-- Kasdorf 08.2020

* --> Nian 09.07.2019
SELECTION-SCREEN BEGIN OF BLOCK b04 WITH FRAME TITLE TEXT-b04.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: cbatch AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(60) TEXT-cba FOR FIELD cbatch.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b04.
* <-- Nian 09.07.2019

*-----------------------------------------------------------------------
* AT SELECTION-SCREEN
*-----------------------------------------------------------------------
AT SELECTION-SCREEN  OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 EQ 'A'.
      IF cbvns EQ abap_true.
*        screen-input  = 1.         "Nuss 02.07.2013
        screen-active  = 1.         "Nuss 02.07.2013
      ELSE.
*        screen-input  = 0.        "Nuss 02.07.2013
        screen-active = 0.         "Nuss 02.07.2013
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN.

* --> Nuss 10.2018
*  IF cbens IS INITIAL AND cbvns IS INITIAL AND cbepl IS INITIAL.
*    MESSAGE e000(e4) WITH 'Bitte eindeutige, voraussichtliche oder EPLOT Nullsummen selektieren.'.
*  ENDIF.
  IF cbens IS INITIAL AND cbvns IS INITIAL.
    MESSAGE e000(e4) WITH 'Bitte eindeutige und / oder voraussichtliche '  'Nullsummen selektieren.'.
  ENDIF.
* <-- Nuss 10.2018

** --> Nuss 02.07.2013
** Meldung, wenn kein Datum eingegeben ist und Datumsfeld aktiv ist
AT SELECTION-SCREEN ON BLOCK b02.
  IF cbvns EQ abap_true. "IS NOT INITIAL.
    IF so_cpuds IS INITIAL.
      LOOP AT SCREEN.
        IF screen-group1 = 'A'.
          IF screen-active = '1'.
            SET CURSOR FIELD 'SO_CPUDS-LOW'.
            MESSAGE e000(e4) WITH 'Bitte Datum eingeben'.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
** <--. NUss 02.07.2013


* --> Kasdorf 04.2020
INITIALIZATION.

  so_stato-sign = 'I'.
  so_stato-option = 'EQ'.
  so_stato-low = '60'.
  APPEND so_stato.
  so_stato-low = '70'.
  APPEND so_stato.
  so_stato-low = '71'.
  APPEND so_stato.
  so_stato-low = '76'.
  APPEND so_stato.
* <-- Kasdorf 04.2020

*-----------------------------------------------------------------------
* START-OF-SELECTION
*-----------------------------------------------------------------------
START-OF-SELECTION.


*--> Nuss 09.2018
*  IF cbsaa = 'X'.
*    PERFORM ausgleichsbuchung.
*  ELSEIF cbens = 'X' AND cbvns = ' '.
* <-- Nuss 09.2018
  IF cbens = 'X' AND cbvns = ' '.
    PERFORM eindeutige_nullsummen.
  ELSEIF cbens = ' ' AND cbvns = 'X'.
    PERFORM voraussichtliche_nullsummen.
  ELSEIF cbens = 'X' AND cbvns = 'X'.
    PERFORM eind_vor_nullsummen.
  ENDIF.
  PERFORM aufbau_auswertung.             "Nuss 10.2018-2
*  IF cbepl = 'X' AND cbsaa IS INITIAL.  "Nuss 09.2018
* --> Nuss 10.2018
*  IF cbepl = 'X'.                        "Nuss 09.2018
*    PERFORM eplot_buchungen.
*  ENDIF.
* <-- Nuss 10.2018

* --> Nian 09.07.2019
  IF NOT cbatch IS INITIAL AND sy-batch IS NOT INITIAL.
* --> Nullavis Direkt analegen bei Batchverarbeitung
    PERFORM create_nullavis.
  ELSE.
* <-- Nian 09.07.2019
*-----------------------------------------------------------------------
* Vorbereitung ALV-Grid
*-----------------------------------------------------------------------

*Feldkatalog erstellen
    PERFORM fieldcat_build USING gt_fieldcat[].

*Layout erstellen
    PERFORM layout_build USING gs_layout.

*ALV-Grid anzeigen
    PERFORM display_alv.

* --> Nian 09.07.2019
  ENDIF.
* <-- Nian 09.07.2019

*-----------------------------------------------------------------------
* END-OF-SELECTION
*-----------------------------------------------------------------------
END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  EINDEUTIGE_NULLSUMMEN
*&---------------------------------------------------------------------*
FORM eindeutige_nullsummen.

*  SELECT DISTINCT b~opbel b~opupk b~thinr b~bukrs b~vkont b~senid b~recid a~vkont a~opbel a~opupk  b~betrw c~int_crossrefno c~crossrefno c~crn_rev a~budat
*    INTO TABLE lt_auswertung                          ##too_many_itab_fields
*    FROM dfkkop AS a INNER JOIN dfkkthi AS b
*    ON b~bcbln = a~opbel
*    INNER JOIN ecrossrefno AS c
*    ON c~int_crossrefno = b~crsrf
*    WHERE a~vkont IN so_vkont
*    AND a~augst = ' '
*    AND b~storn = 'X'
*    AND a~pymet = ' '.

  SELECT DISTINCT b~opbel MAX( b~opupk ) MIN( b~opupk ) AS min_opupk b~thinr b~bukrs b~vkont b~senid b~recid a~vkont a~opbel a~opupk  SUM( b~betrw ) c~int_crossrefno c~crossrefno c~crn_rev a~budat
    INTO TABLE lt_auswertung                          ##too_many_itab_fields
    FROM dfkkop AS a INNER JOIN dfkkthi AS b
    ON b~bcbln = a~opbel
    INNER JOIN ecrossrefno AS c
    ON c~int_crossrefno = b~crsrf
    WHERE a~vkont IN so_vkont
    AND a~augst = ' '
    AND b~storn = 'X'
    AND a~pymet = ' '
    GROUP BY b~opbel b~thinr b~bukrs b~vkont b~senid b~recid a~vkont a~opbel a~opupk c~int_crossrefno c~crossrefno c~crn_rev a~budat.
  "    HAVING b~opupk = MAX( b~opupk )

  DELETE lt_auswertung WHERE betrw = 0.

  LOOP AT lt_auswertung INTO ls_auswertung.

    lv_tabix = sy-tabix.

    SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a
      FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
      ON b~int_inv_doc_no = a~int_inv_doc_no
      WHERE a~own_invoice_no = ls_auswertung-crossrefno
      AND b~invoice_type = '004'. "Reklamationsavis (Eingang)

    IF sy-subrc = 0.

      IF cnnabea IS INITIAL.
        SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a2
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE a~own_invoice_no = ls_auswertung-crossrefno
        AND b~invoice_type = '002' "Zahlungsavis (Eingang)
        AND b~invoice_date > ls_tinv_inv_line_a-invoice_date.
      ELSE.
        SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a2
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE a~own_invoice_no = ls_auswertung-crossrefno
        AND b~invoice_type = '002' "Zahlungsavis (Eingang)
        AND b~invoice_date > ls_tinv_inv_line_a-invoice_date
        AND b~inv_doc_status NE '08'. "Beendete Zahlungsavise ignorieren
      ENDIF.

      IF sy-subrc NE 0.

        CLEAR ls_tinv_inv_line_a.

        IF cnnabea IS INITIAL.
          SELECT SINGLE int_inv_doc_no INTO ls_tinv_inv_line_a
          FROM tinv_inv_line_a
          WHERE own_invoice_no = ls_auswertung-crn_rev.
        ELSE.
          SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a2
          FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
          WHERE a~own_invoice_no = ls_auswertung-crn_rev
          AND b~inv_doc_status NE '08'. "Beendete Zahlungsavise ignorieren
        ENDIF.

        IF sy-subrc NE 0.

          ls_auswertung-kennz = 'E'.

          SELECT SINGLE a~opbel a~opupk b~opbel b~opupk
            INTO (lv_streinzbel, lv_streinzbelop, lv_straggrbel, lv_straggrbelop)
            FROM dfkkthi AS a INNER JOIN dfkkop AS b
            ON b~opbel = a~bcbln
            WHERE crsrf = ls_auswertung-int_crossrefno
            AND a~stidc = 'X'
            AND b~augst = ' '
            AND b~pymet = ' '.

          IF NOT sy-subrc = 0.
            DELETE lt_auswertung INDEX lv_tabix.
            CONTINUE.                                  "Nuss 11.2018
          ENDIF.

**   --> Nuss 20.06.2013
**   Der Storno zum Einzelbeleg steht in der Tabelle DFKKKO
          SELECT SINGLE storb FROM dfkkko INTO lv_stornobeleg
              WHERE opbel = ls_auswertung-einzbel.
*          ls_auswertung-streinzbel = lv_streinzbel.
          ls_auswertung-streinzbel = lv_stornobeleg.
**     <-- Nuss 20.06.2013
          ls_auswertung-streinzbelop = lv_streinzbelop.
          ls_auswertung-straggrbel = lv_straggrbel.
          ls_auswertung-straggrbelop = lv_straggrbelop.

          MODIFY lt_auswertung INDEX lv_tabix FROM ls_auswertung TRANSPORTING kennz streinzbel streinzbelop straggrbel straggrbelop.

        ELSE.
          DELETE lt_auswertung INDEX lv_tabix.
        ENDIF.

      ELSE.
*       --> Nuss 10.2018-2
        CLEAR gv_changed.
*      --> Nuss 11.2018
        PERFORM nnr_ueberf_eind CHANGING ls_auswertung
                                         gv_changed.
        IF gv_changed IS NOT INITIAL.
          MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING  kennz streinzbel streinzbelop straggrbel straggrbelop uebavis.
        ELSE.
*       <-- Nuss 11.2018
          PERFORM endavis_nnr_eind CHANGING ls_auswertung
                                            gv_changed.
          IF gv_changed IS INITIAL.
*       <-- Nuss 10.2018-2
            DELETE lt_auswertung INDEX lv_tabix.
            CLEAR lv_tabix.
            CLEAR ls_tinv_inv_line_a.
* --> Nuss 10.2018-2
          ELSE.
            MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING  kennz streinzbel streinzbelop straggrbel straggrbelop endavis.
          ENDIF.
** <-- Nuss 10.2018-2
        ENDIF.                    "Nuss 11.2018
      ENDIF.
    ELSE.
      DELETE lt_auswertung INDEX lv_tabix.
      CLEAR lv_tabix.
      CLEAR ls_tinv_inv_line_a.
    ENDIF.


    CLEAR ls_auswertung.

  ENDLOOP.


* --> Nuss 07.2018
  SELECT DISTINCT b~doc_id  b~doc_status b~company_code b~suppl_contr_acct b~dist_sp b~suppl_sp a~vkont a~opbel a~opupk  b~gross_amount
                  b~crossrefno  a~budat b~reversal_doc_id
                 INTO TABLE lt_auswertung_memi                          ##too_many_itab_fields
                 FROM dfkkop AS a INNER JOIN /idxmm/memidoc AS b
                 ON b~ci_fica_doc_no = a~opbel
                 WHERE a~vkont IN so_vkont
                 AND a~augst = ' '
*                 AND b~doc_status IN ( '60', '70' )           "Nuss 11.2018
*                 AND b~doc_status IN ( '60', '70', '71', '76'  )     "Nuss 11.2018
                 AND b~doc_status IN so_stato "Kasdorf 04.2020
                 AND b~reversal = 'X'
                 AND a~pymet = ' '.

  DELETE lt_auswertung_memi WHERE betrw = 0.

* Jetzt den Stornobeleg aus der /IDXMM/MEMIDOC lesen.
  LOOP AT lt_auswertung_memi INTO ls_auswertung_memi.

    lv_tabix = sy-tabix.

    CLEAR ls_memidoc.
    SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc
      WHERE doc_id = ls_auswertung_memi-streinzbel.

*   Die CROSSREFNO zum Stornobeleg lesen
    IF sy-subrc = 0.
      IF ls_memidoc-crossrefno IS NOT INITIAL.
        ls_auswertung_memi-crn_rev = ls_memidoc-crossrefno.
        ls_auswertung_memi-strstatus = ls_memidoc-doc_status.
        MODIFY lt_auswertung_memi INDEX lv_tabix FROM ls_auswertung_memi TRANSPORTING crn_rev strstatus.
      ELSE.
        DELETE lt_auswertung_memi INDEX lv_tabix.
      ENDIF.
    ELSE.
      DELETE lt_auswertung_memi INDEX lv_tabix.
    ENDIF.

  ENDLOOP.


  LOOP AT lt_auswertung_memi INTO ls_auswertung_memi.

    lv_tabix = sy-tabix.

*  Ist zum Originalbeleg eine Eintrag in der TINV_INV_LINE_A zu einem
*  Reklamationsavis vorhanden?
    SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a
    FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
    ON b~int_inv_doc_no = a~int_inv_doc_no
    WHERE a~own_invoice_no = ls_auswertung_memi-crossrefno
    AND b~invoice_type = '008'. "Reklamationsavis für Memi

    IF sy-subrc = 0.

      IF cmmmabea IS INITIAL.
        SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a2
         FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
         ON b~int_inv_doc_no = a~int_inv_doc_no
         WHERE a~own_invoice_no = ls_auswertung_memi-crossrefno
         AND b~invoice_type = '007' "Zahlungsavis für Memi
         AND b~invoice_date > ls_tinv_inv_line_a-invoice_date.
      ELSE.
        SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a2
          FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
          WHERE a~own_invoice_no = ls_auswertung_memi-crossrefno
          AND b~invoice_type = '007' "Zahlungsavis für Memi
          AND b~invoice_date > ls_tinv_inv_line_a-invoice_date
          AND b~inv_doc_status NE '08'.
      ENDIF.

      IF sy-subrc NE 0.

        CLEAR ls_tinv_inv_line_a.

*        SELECT SINGLE int_inv_doc_no INTO ls_tinv_inv_line_a
*            FROM tinv_inv_line_a
*            WHERE own_invoice_no = ls_auswertung_memi-crn_rev.

* --> Kasdorf 04.2020
        IF ( CMMMAREV IS INITIAL ) AND ( cmmmabea IS INITIAL ).
          SELECT SINGLE int_inv_doc_no INTO ls_tinv_inv_line_a
          FROM tinv_inv_line_a
          WHERE own_invoice_no = ls_auswertung_memi-crn_rev.
        ELSEIF ( CMMMAREV IS NOT INITIAL ) AND ( cmmmabea IS NOT INITIAL ).
          SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
          FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
            ON b~int_inv_doc_no = a~int_inv_doc_no
          WHERE a~own_invoice_no = ls_auswertung_memi-crn_rev
            AND b~invoice_type NE '008'
          AND b~inv_doc_status NE '08'.
        ELSEIF ( CMMMAREV IS NOT INITIAL ) AND ( cmmmabea IS INITIAL ).
          SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
          FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
          WHERE a~own_invoice_no = ls_auswertung_memi-crn_rev
            AND b~invoice_type NE '008'.
        ELSEIF ( CMMMAREV IS INITIAL ) AND ( cmmmabea IS NOT INITIAL ).
          SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
          FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
          WHERE a~own_invoice_no = ls_auswertung_memi-crn_rev
          AND b~inv_doc_status NE '08'.
        ENDIF.
* <-- Kasdorf 04.2020

        IF sy-subrc NE 0.

          ls_auswertung_memi-kennz = 'E'.

*          SELECT SINGLE a~opbel a~opupk b~opbel b~opupk
*            INTO (lv_streinzbel, lv_streinzbelop, lv_straggrbel, lv_straggrbelop)
*            FROM dfkkthi AS a INNER JOIN dfkkop AS b
*            ON b~opbel = a~bcbln
*            WHERE crsrf = ls_auswertung-int_crossrefno
*            AND a~stidc = 'X'
*            AND b~augst = ' '
*            AND b~pymet = ' '.

          SELECT SINGLE a~opbel a~opupk INTO (lv_straggrbel, lv_straggrbelop)
             FROM dfkkop AS a INNER JOIN /idxmm/memidoc AS b
                ON b~ci_fica_doc_no = a~opbel
                  WHERE b~doc_id = ls_auswertung_memi-streinzbel.

          IF NOT sy-subrc = 0.
            DELETE lt_auswertung_memi INDEX lv_tabix.
          ELSE.
            ls_auswertung_memi-straggrbel = lv_straggrbel.
            ls_auswertung_memi-straggrbelop = lv_straggrbelop.
          ENDIF.

***   --> Nuss 20.06.2013
***   Der Storno zum Einzelbeleg steht in der Tabelle DFKKKO
*          SELECT SINGLE storb FROM dfkkko INTO lv_stornobeleg
*              WHERE opbel = ls_auswertung-einzbel.
**          ls_auswertung-streinzbel = lv_streinzbel.
*          ls_auswertung-streinzbel = lv_stornobeleg.
***     <-- Nuss 20.06.2013
*          ls_auswertung-streinzbelop = lv_streinzbelop.
*          ls_auswertung-straggrbel = lv_straggrbel.
*          ls_auswertung-straggrbelop = lv_straggrbelop.
*
          MODIFY lt_auswertung_memi INDEX lv_tabix FROM ls_auswertung_memi TRANSPORTING kennz straggrbel straggrbelop.

        ELSE.
          DELETE lt_auswertung_memi INDEX lv_tabix.
        ENDIF.




      ELSE.

* <-- Nuss 10.2018-2
        CLEAR gv_changed.
** --> Nuss 11.2018
        PERFORM memi_ueberf_eind CHANGING ls_auswertung_memi
                                          gv_changed.
        IF gv_changed IS NOT INITIAL.
          MODIFY lt_auswertung_memi FROM ls_auswertung_memi TRANSPORTING kennz straggrbel straggrbelop uebavis.
        ELSE.
** <-- Nuss 11.2018
          PERFORM endavis_memi_eind CHANGING ls_auswertung_memi
                                             gv_changed.
          IF gv_changed IS INITIAL.
*  <-- Nuss 10.2018-2
            DELETE lt_auswertung_memi INDEX lv_tabix.
            CLEAR lv_tabix.
            CLEAR ls_tinv_inv_line_a.

* --> Nuss 10.2018-2
          ELSE.
            MODIFY lt_auswertung_memi FROM ls_auswertung_memi TRANSPORTING kennz straggrbel straggrbelop endavis.
          ENDIF.
* <-- Nuss 10.2018-2
        ENDIF.                                       "Nuss 11.2018
      ENDIF.

*   Nein? Dann ist die Zeile nicht relevant
    ELSE.
      DELETE lt_auswertung_memi    INDEX lv_tabix.
      CLEAR lv_tabix.
      CLEAR ls_tinv_inv_line_a.
    ENDIF.

    CLEAR ls_auswertung_memi.

  ENDLOOP.

  LOOP AT lt_auswertung_memi INTO ls_auswertung_memi.
    MOVE-CORRESPONDING ls_auswertung_memi TO ls_auswertung.
    CLEAR ls_auswertung-vkont.                                     "Nuss 09.2018
    ls_auswertung-memi = 'X'.
    APPEND ls_auswertung TO lt_auswertung.
    CLEAR ls_auswertung.
  ENDLOOP.

** --> Nuss 10.2018

  SELECT DISTINCT b~invdocno c~bukrs b~vkont b~/mosb/mo_sp b~/mosb/lead_sup
                  a~vkont c~opbel a~opupk c~betrw d~/mosb/inv_doc_ident
                  a~budat
             FROM dfkkinvbill_h AS b INNER JOIN dfkkinvdoc_i AS c
                ON b~invdocno = c~invdocno
             INNER JOIN dfkkinvdoc_h AS d
                ON d~invdocno = c~invdocno
             INNER JOIN dfkkop AS a
                 ON c~opbel = a~opbel
       INTO TABLE lt_auswertung_msb
          WHERE a~vkont IN so_vkont
            AND a~augst = ' '
            AND a~pymet = ' '
            AND b~revreason NE ' '
            AND c~itemtype = 'YMOS'
            AND d~/mosb/inv_doc_ident NE ' '.

  DELETE lt_auswertung_msb WHERE betrw = 0.

* Stornobeleg holen
  LOOP AT lt_auswertung_msb INTO ls_auswertung_msb.

    lv_tabix = sy-tabix.

    CLEAR ls_dfkkinvbill_h.
    SELECT SINGLE * FROM dfkkinvbill_h INTO ls_dfkkinvbill_h
      WHERE invdocno = ls_auswertung_msb-einzbel.
    CLEAR ls_dfkkinvbill_h2.
    SELECT SINGLE * FROM dfkkinvbill_h INTO ls_dfkkinvbill_h2
      WHERE billdocno = ls_dfkkinvbill_h-reversaldoc.
    CLEAR ls_dfkkinvdoc_h.
    SELECT SINGLE * FROM dfkkinvdoc_h INTO ls_dfkkinvdoc_h
      WHERE invdocno = ls_dfkkinvbill_h2-invdocno.
    ls_auswertung_msb-streinzbel =  ls_dfkkinvdoc_h-invdocno.
    ls_auswertung_msb-crn_rev = ls_dfkkinvdoc_h-/mosb/inv_doc_ident.

    IF ls_auswertung_msb-streinzbel IS INITIAL OR
       ls_auswertung_msb-crn_rev IS INITIAL.
      DELETE lt_auswertung_msb INDEX lv_tabix.
    ELSE.
      MODIFY lt_auswertung_msb INDEX lv_tabix FROM ls_auswertung_msb TRANSPORTING streinzbel crn_rev.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_auswertung_msb INTO ls_auswertung_msb.


    lv_tabix = sy-tabix.

*  Ist zum Originalbeleg eine Eintrag in der TINV_INV_LINE_A zu einem
*  Reklamationsavis vorhanden?
    SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a
    FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
    ON b~int_inv_doc_no = a~int_inv_doc_no
    WHERE a~own_invoice_no = ls_auswertung_msb-crossrefno
    AND b~invoice_type = '013'. "Reklamationsavis für MSB

    IF sy-subrc = 0.

      IF cmsbbea IS INITIAL.
        SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a2
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE a~own_invoice_no = ls_auswertung_msb-crossrefno
        AND b~invoice_type = '012' "Zahlungsavis für Msb
        AND b~invoice_date > ls_tinv_inv_line_a-invoice_date.
      ELSE.
        SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a2
          FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
          WHERE a~own_invoice_no = ls_auswertung_msb-crossrefno
          AND b~invoice_type = '012' "Zahlungsavis für Msb
          AND b~invoice_date > ls_tinv_inv_line_a-invoice_date
          AND b~inv_doc_status NE '08'.
      ENDIF.


      IF sy-subrc NE 0.

        CLEAR ls_tinv_inv_line_a.

        IF cmsbbea IS INITIAL.
          SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a2
          FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
          WHERE a~own_invoice_no = ls_auswertung_msb-crn_rev
          AND b~invoice_date > ls_tinv_inv_line_a-invoice_date.
        ELSE.
          SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a2
            FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
            ON b~int_inv_doc_no = a~int_inv_doc_no
            WHERE a~own_invoice_no = ls_auswertung_msb-crn_rev
            AND b~invoice_date > ls_tinv_inv_line_a-invoice_date
            AND b~inv_doc_status NE '08'.
        ENDIF.

        IF sy-subrc NE 0.

          ls_auswertung_msb-kennz = 'E'.

          SELECT SINGLE a~opbel a~opupk INTO (lv_straggrbel, lv_straggrbelop)
            FROM dfkkop AS a INNER JOIN dfkkinvdoc_i AS b
              ON b~opbel = a~opbel
            INNER JOIN dfkkinvdoc_h AS c
              ON c~invdocno = b~invdocno
            WHERE b~invdocno = ls_auswertung_msb-streinzbel.

          IF NOT sy-subrc = 0.
            DELETE lt_auswertung_msb INDEX lv_tabix.
          ELSE.
            ls_auswertung_msb-straggrbel = lv_straggrbel.
            ls_auswertung_msb-straggrbelop = lv_straggrbelop.
          ENDIF.

          MODIFY lt_auswertung_msb INDEX lv_tabix FROM ls_auswertung_msb TRANSPORTING kennz straggrbel straggrbelop.

        ELSE.
          DELETE lt_auswertung_msb INDEX lv_tabix.
        ENDIF.

      ELSE.
        DELETE lt_auswertung_msb INDEX lv_tabix.
        CLEAR lv_tabix.
        CLEAR ls_tinv_inv_line_a.
      ENDIF.


*   Nein? Dann ist die Zeile nicht relevant
    ELSE.
      DELETE lt_auswertung_msb    INDEX lv_tabix.
      CLEAR lv_tabix.
      CLEAR ls_tinv_inv_line_a.
    ENDIF.

    CLEAR ls_auswertung_msb.

  ENDLOOP.

  LOOP AT lt_auswertung_msb INTO ls_auswertung_msb.
    MOVE-CORRESPONDING ls_auswertung_msb TO ls_auswertung.
    CLEAR ls_auswertung-vkont.
    ls_auswertung-msb = 'X'.
    APPEND ls_auswertung TO lt_auswertung.
    CLEAR ls_auswertung.
  ENDLOOP.

** <-- Nuss 10.2018


ENDFORM.                 " Eindeutige Nullsummen

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD
*&---------------------------------------------------------------------*
FORM fieldcat_build USING lt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

*--> Nuss 07.2018
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SEL'.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-input = 'X'.
  ls_fieldcat-checkbox = 'X'.
  ls_fieldcat-seltext_s = 'Selektion'.
  ls_fieldcat-seltext_m = 'Selektion'.
  ls_fieldcat-seltext_l = 'Selektion'.
  APPEND ls_fieldcat TO lt_fieldcat.
* <-- Nuss 07.2018

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'KENNZ'.
  ls_fieldcat-ref_fieldname = 'CANCEL'.
  ls_fieldcat-ref_tabname   = 'ECROSSREFNO'.
  APPEND ls_fieldcat TO lt_fieldcat.

* --> Nuss 07.2018
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MEMI'.
  ls_fieldcat-seltext_s = 'MEMI'.
  APPEND ls_fieldcat TO lt_fieldcat.
* <-- Nuss 07.2018

* --> Nuss 10.2018
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MSB'.
  ls_fieldcat-seltext_s = 'MSB'.
  APPEND ls_fieldcat TO lt_fieldcat.
* <-- Nuss 10.2018

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'BUKRS'.
  ls_fieldcat-ref_fieldname = 'BUKRS'.
  ls_fieldcat-ref_tabname   = 'DFKKTHI'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'A_VKONT'.
  ls_fieldcat-ref_fieldname = 'VKONT'.
  ls_fieldcat-ref_tabname   = 'DFKKOP'.
  ls_fieldcat-seltext_s     = 'Aggr.VetrKonto'.
  ls_fieldcat-seltext_m     = 'Aggr.VetrKonto'.
  ls_fieldcat-ddictxt       = 'M'.
  ls_fieldcat-hotspot       = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'VKONT'.
  ls_fieldcat-ref_fieldname = 'VKONT'.
  ls_fieldcat-ref_tabname   = 'DFKKTHI'.
  ls_fieldcat-seltext_s     = 'EinzelvetrKonto'.
  ls_fieldcat-seltext_m     = 'EinzelvetrKonto'.
  ls_fieldcat-ddictxt       = 'M'.
  ls_fieldcat-hotspot       = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'EINZBEL'.
  ls_fieldcat-ref_fieldname = 'OPBEL'.
  ls_fieldcat-ref_tabname   = 'DFKKTHI'.
  ls_fieldcat-seltext_s     = 'Einzel.Bel'.
  ls_fieldcat-seltext_m     = 'Einzelbeleg'.
  ls_fieldcat-ddictxt       = 'M'.
  ls_fieldcat-hotspot       = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'EINZBELOP'.
  ls_fieldcat-ref_fieldname = 'OPUPK'.
  ls_fieldcat-ref_tabname   = 'DFKKTHI'.
  APPEND ls_fieldcat TO lt_fieldcat.

* --> Nuss 07.2018
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STATEINZBEL'.
  ls_fieldcat-ref_fieldname = 'DOC_STATUS'.
  ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
  ls_fieldcat-seltext_s = 'StatusEinz'.
  APPEND ls_fieldcat TO lt_fieldcat.
* <-- Nuss 07.2018

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'THINR'.
  ls_fieldcat-ref_fieldname = 'THINR'.
  ls_fieldcat-ref_tabname   = 'DFKKTHI'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'BETRW'.
  ls_fieldcat-ref_fieldname = 'BETRW'.
  ls_fieldcat-ref_tabname   = 'DFKKTHI'.
  ls_fieldcat-seltext_s     = 'Betrag'.
  ls_fieldcat-seltext_m     = 'Betrag'.
  ls_fieldcat-seltext_l     = 'Betrag'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'AGGROPBEL'.
  ls_fieldcat-ref_fieldname = 'OPBEL'.
  ls_fieldcat-ref_tabname   = 'DFKKOP'.
  ls_fieldcat-seltext_s     = 'aggr.Bel'.
  ls_fieldcat-seltext_m     = 'aggr. Beleg'.
  ls_fieldcat-seltext_l     = 'aggregierter Beleg'.
  ls_fieldcat-ddictxt       = 'M'.
  ls_fieldcat-hotspot       = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

* --> Nuss 10.2018-2
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AGGRBELANZ'.
  ls_fieldcat-seltext_s = 'Anz.Pos'.
  ls_fieldcat-seltext_m = 'Anzahl Einz.Pos.'.
  ls_fieldcat-seltext_l = 'Anzahl Einzelpositionen'.
  APPEND ls_fieldcat TO lt_fieldcat.
* <-- Nuss 10.2018-2

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'BUDAT'.
  ls_fieldcat-ref_fieldname = 'BUDAT'.
  ls_fieldcat-ref_tabname   = 'DFKKOP'.
  ls_fieldcat-seltext_s     = 'Erf.D aggr.Storno'.
  ls_fieldcat-seltext_m     = 'Erf.D aggr.Storno'.
  ls_fieldcat-seltext_l     = 'Erf.D aggr.Storno'.
  APPEND ls_fieldcat TO lt_fieldcat.

*  CLEAR LS_FIELDCAT.
*  LS_FIELDCAT-FIELDNAME     = 'AGGROPUPK'.
*  LS_FIELDCAT-REF_FIELDNAME = 'OPUPK'.
*  LS_FIELDCAT-REF_TABNAME   = 'DFKKOP'.
*  APPEND LS_FIELDCAT TO LT_FIELDCAT.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'STREINZBEL'.
  ls_fieldcat-ref_fieldname = 'OPBEL'.
  ls_fieldcat-ref_tabname   = 'DFKKTHI'.
  ls_fieldcat-seltext_s     = 'Stor.Beleg'.
  ls_fieldcat-seltext_m     = 'Storno Einzel.Bel'.
  ls_fieldcat-seltext_l     = 'Storno Einzel.Bel'.
  ls_fieldcat-ddictxt       = 'M'.
  ls_fieldcat-hotspot       = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'STREINZBELOP'.
  ls_fieldcat-ref_fieldname = 'OPUPK'.
  ls_fieldcat-ref_tabname   = 'DFKKTHI'.
  APPEND ls_fieldcat TO lt_fieldcat.

* --> Nuss 07.2018
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STRSTATUS'.
  ls_fieldcat-ref_fieldname = 'DOC_STATUS'.
  ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
  ls_fieldcat-seltext_s = 'StrnStatus'.
  APPEND ls_fieldcat TO lt_fieldcat.
* <-- NUss 07.2018

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'STRAGGRBEL'.
  ls_fieldcat-ref_fieldname = 'OPBEL'.
  ls_fieldcat-ref_tabname   = 'DFKKOP'.
  ls_fieldcat-seltext_s     = 'St.aggr.Bel'.
  ls_fieldcat-seltext_m     = 'Storno aggr.Beleg'.
  ls_fieldcat-seltext_l     = 'Storno aggr.Beleg'.
  ls_fieldcat-ddictxt       = 'M'.
  ls_fieldcat-hotspot       = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

* --> nuss 10.2018-2
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STRAGGRBELANZ'.
  ls_fieldcat-seltext_s = 'Anz.Pos'.
  ls_fieldcat-seltext_m = 'Anzahl Einz.Pos.'.
  ls_fieldcat-seltext_l = 'Anzahl Einzelpositionen'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'GRUPPKZ'.
  ls_fieldcat-seltext_s = 'Grupp.kz'.
  ls_fieldcat-seltext_m = 'Gruppierungskz.'.
  ls_fieldcat-seltext_l = 'Gruppierungskennzeichen'.
  APPEND ls_fieldcat TO lt_fieldcat.
* <-- Nuss 10.2018-2

*  CLEAR LS_FIELDCAT.
*  LS_FIELDCAT-FIELDNAME     = 'STRAGGRBELOP'.
*  LS_FIELDCAT-REF_FIELDNAME = 'OPUPK'.
*  LS_FIELDCAT-REF_TABNAME   = 'DFKKOP'.
*  APPEND LS_FIELDCAT TO LT_FIELDCAT.

* --> nuss 10.2018
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname     = 'AUGBEL'.
*  ls_fieldcat-ref_fieldname = 'OPBEL'.
*  ls_fieldcat-ref_tabname   = 'DFKKOP'.
*  ls_fieldcat-seltext_s     = 'ausg.Bel'.
*  ls_fieldcat-seltext_m     = 'Ausgleichsbel.'.
*  ls_fieldcat-seltext_l     = 'Ausgleichsbeleg'.
*  ls_fieldcat-ddictxt       = 'M'.
*  ls_fieldcat-hotspot       = 'X'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname     = 'F_STATUS'.
*  ls_fieldcat-seltext_s     = 'Status'.
*  ls_fieldcat-ddictxt       = 'S'.
*  ls_fieldcat-icon          = 'X'.
*  ls_fieldcat-outputlen     = '4'.
*  APPEND ls_fieldcat TO lt_fieldcat.
* <-- Nuss 10.2018

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'INT_CROSSREFNO'.
  ls_fieldcat-ref_fieldname = 'INT_CROSSREFNO'.
  ls_fieldcat-ref_tabname   = 'ECROSSREFNO'.
  ls_fieldcat-no_out        = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'SENID'.
  ls_fieldcat-ref_fieldname = 'SENID'.
  ls_fieldcat-ref_tabname   = 'DFKKTHI'.
  ls_fieldcat-seltext_s     = 'Netz'.
  ls_fieldcat-seltext_m     = 'Netzbetreiber'.
  ls_fieldcat-ddictxt       = 'M'.
  ls_fieldcat-hotspot       = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'RECID'.
  ls_fieldcat-ref_fieldname = 'RECID'.
  ls_fieldcat-ref_tabname   = 'DFKKTHI'.
  ls_fieldcat-seltext_s     = 'Lieferant'.
  ls_fieldcat-seltext_m     = 'Lieferant'.
  ls_fieldcat-ddictxt       = 'M'.
  ls_fieldcat-hotspot       = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'CROSSREFNO'.
  ls_fieldcat-ref_fieldname = 'CROSSREFNO'.
  ls_fieldcat-ref_tabname   = 'ECROSSREFNO'.
  ls_fieldcat-seltext_s     = 'Orig. PRN'.
  ls_fieldcat-seltext_m     = 'Original PRN'.
  ls_fieldcat-seltext_l     = 'Original PRN'.
  ls_fieldcat-ddictxt       = 'M'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'CRN_REV'.
  ls_fieldcat-ref_fieldname = 'CRN_REV'.
  ls_fieldcat-ref_tabname   = 'ECROSSREFNO'.
  ls_fieldcat-seltext_s     = 'Storno PRN'.
  ls_fieldcat-seltext_m     = 'Storno PRN'.
  ls_fieldcat-seltext_l     = 'Storno PRN'.
  ls_fieldcat-ddictxt       = 'M'.
  APPEND ls_fieldcat TO lt_fieldcat.

* --> Nuss 07.2018
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NULLAVIS'.
  ls_fieldcat-ref_fieldname = 'INT_INV_DOC_NO'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-seltext_s = 'Nullavis'.
  ls_fieldcat-seltext_m = 'Nullsummenavis'.
  ls_fieldcat-seltext_l = 'Nullsummenavis'.
  ls_fieldcat-ddictxt   = 'M'.
  APPEND ls_fieldcat TO lt_fieldcat.
* <-- Nuss 07.2018

* --> Nuss 10.2018
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'PR_STATE'.
  ls_fieldcat-icon        = 'X'.
  ls_fieldcat-seltext_s   = 'Pr.Status'.
  ls_fieldcat-seltext_m   = 'Pr.Status'.
  ls_fieldcat-seltext_l   = 'Prozessstatus'.
  APPEND ls_fieldcat TO lt_fieldcat.
* <-- Nuss 10.2018

* --> Nuss 10.2018-2
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ENDAVIS'.
  ls_fieldcat-ref_fieldname = 'INT_INV_DOC_NO'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-seltext_s = 'Avis beendet'.
  ls_fieldcat-seltext_m = 'beendetes Nulls.Avis'.
  ls_fieldcat-seltext_l = 'beendetes Nullsummenavis'.
  APPEND ls_fieldcat TO lt_fieldcat.
* <-- Nuss 10.2018-2

* --> Nuss 11.2018
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'UEBAVIS'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-seltext_s = 'Avis überf.'.
  ls_fieldcat-seltext_m = 'überf. Nulls.Avis'.
  ls_fieldcat-seltext_l = 'überführtes Nullsummenavis'.
  APPEND ls_fieldcat TO lt_fieldcat.
* <-- Nuss 11.2018

ENDFORM.                  " Aufbau ALV-Feldkatalog

*&---------------------------------------------------------------------*
*&      Form  LAYOUT_BUILD
*&---------------------------------------------------------------------*
FORM layout_build  USING ls_layout TYPE slis_layout_alv.

  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = 'X'.

ENDFORM.                    " Aufbau ALV-Layout

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM display_alv .

  lv_programm = sy-repid.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = lv_programm
      i_callback_pf_status_set = g_status                  "Nuss 07.2018
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat
    TABLES
      t_outtab                 = lt_auswertung
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " DISPLAY_ALV

*&---------------------------------------------------------------------*
*&      Form  VORRAUSSICHTLICHE_NULLSUMMEN
*&---------------------------------------------------------------------*
FORM voraussichtliche_nullsummen .

  SELECT DISTINCT b~opbel MAX( b~opupk ) MIN( b~opupk ) AS min_opupk b~thinr b~bukrs b~vkont b~senid b~recid a~vkont a~opbel a~opupk  SUM( b~betrw ) c~int_crossrefno c~crossrefno c~crn_rev a~budat
    INTO TABLE lt_auswertung                          ##too_many_itab_fields
    FROM dfkkop AS a INNER JOIN dfkkthi AS b
    ON b~bcbln = a~opbel
    INNER JOIN ecrossrefno AS c
    ON c~int_crossrefno = b~crsrf
    WHERE a~vkont IN so_vkont
    AND a~augst = ' '
    AND b~storn = 'X'
    AND a~pymet = ' '
    GROUP BY b~opbel b~thinr b~bukrs b~vkont b~senid b~recid a~vkont a~opbel a~opupk c~int_crossrefno c~crossrefno c~crn_rev a~budat.
  "    HAVING b~opupk = MAX( b~opupk )

  DELETE lt_auswertung WHERE betrw = 0.

  LOOP AT lt_auswertung INTO ls_auswertung.

    lv_tabix = sy-tabix.

    IF cnnabea IS INITIAL.
      SELECT SINGLE int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a
        WHERE own_invoice_no = ls_auswertung-crossrefno.
    ELSE.
      SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE a~own_invoice_no = ls_auswertung-crossrefno
       AND b~inv_doc_status NE '08'. "Beendete Avise ignorieren
    ENDIF.

    IF sy-subrc NE 0.

      CLEAR ls_tinv_inv_line_a.

      IF cnnabea IS INITIAL.
        SELECT SINGLE int_inv_doc_no INTO ls_tinv_inv_line_a
          FROM tinv_inv_line_a
          WHERE own_invoice_no = ls_auswertung-crn_rev.
      ELSE.
        SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
          FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
          WHERE a~own_invoice_no = ls_auswertung-crn_rev
         AND b~inv_doc_status NE '08'. "Beendete Avise ignorieren
      ENDIF.

      IF sy-subrc NE 0.

        ls_auswertung-kennz = 'V'.

        SELECT SINGLE a~opbel a~opupk b~opbel b~opupk
        INTO (lv_streinzbel, lv_streinzbelop, lv_straggrbel, lv_straggrbelop)
        FROM dfkkthi AS a INNER JOIN dfkkop AS b
        ON b~opbel = a~bcbln
        WHERE a~crsrf = ls_auswertung-int_crossrefno
        AND a~stidc = 'X'
        AND b~augst = ' '
        AND b~pymet = ' '.

        IF NOT sy-subrc = 0.
          DELETE lt_auswertung INDEX lv_tabix.
          CONTINUE.                                    "Nuss 10.2018-2
        ENDIF.

**      Das Buchungsdatum bei den voraussichtlichen Nullsummen ist das
**      Erfassungsdatum des Stornobeleges
        SELECT cpudt
          FROM dfkkko
          INTO ls_auswertung-budat
          WHERE opbel = lv_straggrbel
          AND   cpudt IN so_cpuds.
        ENDSELECT.

        IF NOT ls_auswertung-budat IN so_cpuds.
          DELETE lt_auswertung INDEX lv_tabix.
          CLEAR lv_tabix.
          CLEAR ls_tinv_inv_line_a.
        ELSE.

**   --> Nuss 20.06.2013
**   Der Storno zum Einzelbeleg steht in der Tabelle DFKKKO
          SELECT SINGLE storb FROM dfkkko INTO lv_stornobeleg
              WHERE opbel = ls_auswertung-einzbel.
*          ls_auswertung-streinzbel = lv_streinzbel.
          ls_auswertung-streinzbel = lv_stornobeleg.
**     <-- Nuss 20.06.2013
          ls_auswertung-streinzbelop = lv_streinzbelop.
          ls_auswertung-straggrbel = lv_straggrbel.
          ls_auswertung-straggrbelop = lv_straggrbelop.

**      --> Nuss 20.06.2013

*        MODIFY lt_auswertung INDEX lv_tabix FROM ls_auswertung TRANSPORTING kennz streinzbel streinzbelop straggrbel straggrbelop.
          MODIFY lt_auswertung INDEX lv_tabix FROM ls_auswertung TRANSPORTING budat kennz streinzbel streinzbelop straggrbel straggrbelop.
**     <-- Nuss 20.06.2013

        ENDIF.

      ELSE.
        DELETE lt_auswertung INDEX lv_tabix.
        CLEAR lv_tabix.
        CLEAR ls_tinv_inv_line_a.

      ENDIF.

    ELSE.
* --> Nuss 10.2018-2
      CLEAR gv_changed.
* --> Nuss 11.2018
      PERFORM nnr_ueberf_vor CHANGING ls_auswertung
                                      gv_changed.

      IF gv_changed IS NOT INITIAL.
        MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING budat kennz streinzbel streinzbelop straggrbel straggrbelop uebavis.
      ELSE.
* <-- Nuss 11.2018
        PERFORM endavis_nnr_vor CHANGING ls_auswertung
                                 gv_changed.
        IF gv_changed IS INITIAL.
* <-- Nuss 10.2018-2
          DELETE lt_auswertung INDEX lv_tabix.
          CLEAR lv_tabix.
          CLEAR ls_tinv_inv_line_a.
*  --> Nuss 10.2018-2
        ELSE.
          MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING budat kennz streinzbel streinzbelop straggrbel straggrbelop endavis.
        ENDIF.
*  <-- Nuss 10.2018-2
      ENDIF.                 "Nuss 11.2018
    ENDIF.

    CLEAR ls_auswertung.

  ENDLOOP.

* --> Nuss 07.2018

  SELECT DISTINCT b~doc_id b~doc_status b~company_code b~suppl_contr_acct b~dist_sp b~suppl_sp a~vkont a~opbel a~opupk  b~gross_amount
                  b~crossrefno  a~budat b~reversal_doc_id
                 INTO TABLE lt_auswertung_memi                          ##too_many_itab_fields
                 FROM dfkkop AS a INNER JOIN /idxmm/memidoc AS b
                 ON b~ci_fica_doc_no = a~opbel
                 WHERE a~vkont IN so_vkont
                 AND a~augst = ' '
*                 AND b~doc_status IN ( '60', '70' )           "Nuss 11.2018
*                 AND b~doc_status IN ( '60', '70', '71', '76'  )     "Nuss 11.2018
                 AND b~doc_status IN so_stato "Kasdorf 04.2020
                 AND b~reversal = 'X'
                 AND a~pymet = ' '.


* Jetzt den Stornobeleg aus der /IDXMM/MEMIDOC lesen.
  LOOP AT lt_auswertung_memi INTO ls_auswertung_memi.

    lv_tabix = sy-tabix.

    CLEAR ls_memidoc.
    SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc
      WHERE doc_id = ls_auswertung_memi-streinzbel.

*   Die CROSSREFNO zum Stornobeleg lesen
    IF sy-subrc = 0.
      IF ls_memidoc-crossrefno IS NOT INITIAL.
        ls_auswertung_memi-crn_rev = ls_memidoc-crossrefno.
        ls_auswertung_memi-strstatus = ls_memidoc-doc_status.
        MODIFY lt_auswertung_memi INDEX lv_tabix FROM ls_auswertung_memi TRANSPORTING crn_rev strstatus.
      ELSE.
        DELETE lt_auswertung_memi INDEX lv_tabix.
      ENDIF.
    ENDIF.

  ENDLOOP.

  LOOP AT lt_auswertung_memi INTO ls_auswertung_memi.

    lv_tabix = sy-tabix.

    IF cmmmabea IS INITIAL.
      SELECT SINGLE int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a
        WHERE own_invoice_no = ls_auswertung_memi-crossrefno.
    ELSE.
      SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE a~own_invoice_no = ls_auswertung_memi-crossrefno
       AND b~inv_doc_status NE '08'. "Beendete Avise ignorieren
    ENDIF.

* --> Kasdorf 04.2020

    IF sy-subrc NE 0.

      CLEAR ls_tinv_inv_line_a.


* --> Kasdorf 04.2020
      IF ( CMMMAREV IS INITIAL ) AND ( cmmmabea IS INITIAL ).
        SELECT SINGLE int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a
        WHERE own_invoice_no = ls_auswertung_memi-crn_rev.
      ELSEIF ( CMMMAREV IS NOT INITIAL ) AND ( cmmmabea IS NOT INITIAL ).
        SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE a~own_invoice_no = ls_auswertung_memi-crn_rev
          AND b~invoice_type NE '008'
        AND b~inv_doc_status NE '08'.
      ELSEIF ( CMMMAREV IS NOT INITIAL ) AND ( cmmmabea IS INITIAL ).
        SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE a~own_invoice_no = ls_auswertung_memi-crn_rev
        AND b~invoice_type NE '008'.
      ELSEIF ( CMMMAREV IS INITIAL ) AND ( cmmmabea IS NOT INITIAL ).
        SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE a~own_invoice_no = ls_auswertung_memi-crn_rev
        AND b~inv_doc_status NE '08'.
      ENDIF.
* <-- Kasdorf 04.2020

      IF sy-subrc NE 0.

        ls_auswertung_memi-kennz = 'V'.

        SELECT SINGLE a~opbel a~opupk INTO (lv_straggrbel, lv_straggrbelop)
           FROM dfkkop AS a INNER JOIN /idxmm/memidoc AS b
              ON b~ci_fica_doc_no = a~opbel
                WHERE b~doc_id = ls_auswertung_memi-streinzbel.

        IF NOT sy-subrc = 0.
          DELETE lt_auswertung_memi INDEX lv_tabix.
        ENDIF.

**      Das Buchungsdatum bei den voraussichtlichen Nullsummen ist das
**      Erfassungsdatum des Stornobeleges
        SELECT cpudt
          FROM dfkkko
          INTO ls_auswertung_memi-budat
          WHERE opbel = lv_straggrbel
          AND   cpudt IN so_cpuds.
        ENDSELECT.

        IF NOT ls_auswertung_memi-budat IN so_cpuds.
          DELETE lt_auswertung_memi INDEX lv_tabix.
          CLEAR lv_tabix.
          CLEAR ls_tinv_inv_line_a.
        ELSE.

          ls_auswertung_memi-straggrbel = lv_straggrbel.
          ls_auswertung_memi-straggrbelop = lv_straggrbelop.

***   Der Storno zum Einzelbeleg steht in der Tabelle DFKKKO
*          SELECT SINGLE storb FROM dfkkko INTO lv_stornobeleg
*              WHERE opbel = ls_auswertung-einzbel.
**          ls_auswertung-streinzbel = lv_streinzbel.
*          ls_auswertung-streinzbel = lv_stornobeleg.
***     <-- Nuss 20.06.2013
*          ls_auswertung-streinzbelop = lv_streinzbelop.
*          ls_auswertung-straggrbel = lv_straggrbel.
*          ls_auswertung-straggrbelop = lv_straggrbelop.

**      --> Nuss 20.06.2013

          MODIFY lt_auswertung_memi INDEX lv_tabix FROM ls_auswertung_memi TRANSPORTING budat kennz  straggrbel straggrbelop.


        ENDIF.

      ELSE.
        DELETE lt_auswertung_memi INDEX lv_tabix.
        CLEAR lv_tabix.
        CLEAR ls_tinv_inv_line_a.

      ENDIF.


    ELSE.

*   --> Nuss 10.2018-2
      CLEAR gv_changed.
*   --> Nuss 11.2018
      PERFORM memi_ueberf_vor CHANGING ls_auswertung_memi
                                       gv_changed.
      IF gv_changed IS NOT INITIAL.
        MODIFY lt_auswertung_memi FROM ls_auswertung_memi TRANSPORTING budat kennz straggrbel straggrbelop uebavis.
      ELSE.
*   <-- Nuss 11.2018
        PERFORM endavis_memi_vor CHANGING ls_auswertung_memi
                                      gv_changed.
        IF gv_changed IS INITIAL.
* <-- Nuss 10.2018-2
          DELETE lt_auswertung_memi INDEX lv_tabix.
          CLEAR lv_tabix.
          CLEAR ls_tinv_inv_line_a.
*    --> Nuss 10.2018-2
        ELSE.

          MODIFY lt_auswertung_memi INDEX lv_tabix FROM ls_auswertung_memi TRANSPORTING budat kennz  straggrbel straggrbelop endavis.

        ENDIF.
*     <-- Nuss 10.2018
      ENDIF.                      "Nuss 11.2018
      CLEAR ls_auswertung_memi.

    ENDIF.

  ENDLOOP.

  LOOP AT lt_auswertung_memi INTO ls_auswertung_memi.
    MOVE-CORRESPONDING ls_auswertung_memi TO ls_auswertung.
    CLEAR ls_auswertung-vkont.                                    "Nuss 09.2018
    ls_auswertung-memi = 'X'.
    APPEND ls_auswertung TO lt_auswertung.
    CLEAR ls_auswertung.
  ENDLOOP.


** --> Nuss 10.2018
  SELECT DISTINCT b~invdocno c~bukrs b~vkont b~/mosb/mo_sp b~/mosb/lead_sup
                  a~vkont c~opbel a~opupk c~betrw d~/mosb/inv_doc_ident
                  a~budat
             FROM dfkkinvbill_h AS b INNER JOIN dfkkinvdoc_i AS c
                ON b~invdocno = c~invdocno
             INNER JOIN dfkkinvdoc_h AS d
                ON d~invdocno = c~invdocno
             INNER JOIN dfkkop AS a
                 ON c~opbel = a~opbel
       INTO TABLE lt_auswertung_msb
          WHERE a~vkont IN so_vkont
            AND a~augst = ' '
            AND a~pymet = ' '
            AND b~revreason NE ' '
            AND c~itemtype = 'YMOS'
            AND d~/mosb/inv_doc_ident NE ' '.


  DELETE lt_auswertung_msb WHERE betrw = 0.


* Stornobeleg holen
  LOOP AT lt_auswertung_msb INTO ls_auswertung_msb.

    lv_tabix = sy-tabix.

    CLEAR ls_dfkkinvbill_h.
    SELECT SINGLE * FROM dfkkinvbill_h INTO ls_dfkkinvbill_h
      WHERE invdocno = ls_auswertung_msb-einzbel.
    CLEAR ls_dfkkinvbill_h2.
    SELECT SINGLE * FROM dfkkinvbill_h INTO ls_dfkkinvbill_h2
      WHERE billdocno = ls_dfkkinvbill_h-reversaldoc.
    CLEAR ls_dfkkinvdoc_h.
    SELECT SINGLE * FROM dfkkinvdoc_h INTO ls_dfkkinvdoc_h
      WHERE invdocno = ls_dfkkinvbill_h2-invdocno.
    ls_auswertung_msb-streinzbel =  ls_dfkkinvdoc_h-invdocno.
    ls_auswertung_msb-crn_rev = ls_dfkkinvdoc_h-/mosb/inv_doc_ident.

    IF ls_auswertung_msb-streinzbel IS INITIAL OR
       ls_auswertung_msb-crn_rev IS INITIAL.
      DELETE lt_auswertung_msb INDEX lv_tabix.
    ELSE.
      MODIFY lt_auswertung_msb INDEX lv_tabix FROM ls_auswertung_msb TRANSPORTING streinzbel crn_rev.
    ENDIF.

  ENDLOOP.

  LOOP AT lt_auswertung_msb INTO ls_auswertung_msb.

    lv_tabix = sy-tabix.

    CLEAR ls_tinv_inv_line_a.

    IF cmsbbea IS INITIAL.
      SELECT SINGLE int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a
        WHERE own_invoice_no = ls_auswertung_msb-crossrefno.
    ELSE.
      SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE a~own_invoice_no = ls_auswertung_msb-crossrefno
       AND b~inv_doc_status NE '08'. "Beendete Avise ignorieren
    ENDIF.

    IF sy-subrc NE 0.

      CLEAR ls_tinv_inv_line_a.

      IF cmsbbea IS INITIAL.
        SELECT SINGLE int_inv_doc_no INTO ls_tinv_inv_line_a
          FROM tinv_inv_line_a
          WHERE own_invoice_no = ls_auswertung_msb-crn_rev.
      ELSE.
        SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
          FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
          WHERE a~own_invoice_no = ls_auswertung_msb-crn_rev
         AND b~inv_doc_status NE '08'. "Beendete Avise ignorieren
      ENDIF.

      IF sy-subrc NE 0.

        ls_auswertung_msb-kennz = 'V'.

        SELECT SINGLE a~opbel a~opupk INTO (lv_straggrbel, lv_straggrbelop)
          FROM dfkkop AS a INNER JOIN dfkkinvdoc_i AS b
            ON b~opbel = a~opbel
          INNER JOIN dfkkinvdoc_h AS c
            ON c~invdocno = b~invdocno
          WHERE b~invdocno = ls_auswertung_msb-streinzbel.

        IF NOT sy-subrc = 0.
          DELETE lt_auswertung_msb INDEX lv_tabix.
        ENDIF.

**      Das Buchungsdatum bei den voraussichtlichen Nullsummen ist das
**      Erfassungsdatum des Stornobeleges
        SELECT cpudt
          FROM dfkkko
          INTO ls_auswertung_msb-budat
          WHERE opbel = lv_straggrbel
          AND   cpudt IN so_cpuds.
        ENDSELECT.

        IF NOT ls_auswertung_msb-budat IN so_cpuds.
          DELETE lt_auswertung_msb INDEX lv_tabix.
          CLEAR lv_tabix.
          CLEAR ls_tinv_inv_line_a.
        ELSE.

          ls_auswertung_msb-straggrbel = lv_straggrbel.
          ls_auswertung_msb-straggrbelop = lv_straggrbelop.

          MODIFY lt_auswertung_msb INDEX lv_tabix FROM ls_auswertung_msb TRANSPORTING budat kennz  straggrbel straggrbelop.

        ENDIF.


      ELSE.
        DELETE lt_auswertung_msb INDEX lv_tabix.
        CLEAR lv_tabix.
        CLEAR ls_tinv_inv_line_a.
      ENDIF.

    ELSE.
      DELETE lt_auswertung_msb INDEX lv_tabix.
      CLEAR lv_tabix.
      CLEAR ls_tinv_inv_line_a.
    ENDIF.

    CLEAR ls_auswertung_msb.

  ENDLOOP.

  LOOP AT lt_auswertung_msb INTO ls_auswertung_msb.
    MOVE-CORRESPONDING ls_auswertung_msb TO ls_auswertung.
    CLEAR ls_auswertung-vkont.
    ls_auswertung-msb = 'X'.
    APPEND ls_auswertung TO lt_auswertung.
    CLEAR ls_auswertung.
  ENDLOOP.


* <-- Nuss 10.2018


ENDFORM.                    " Voraussichtliche Nullsummen

*&---------------------------------------------------------------------*
*&      Form  EIND_VOR_NULLSUMMEN
*&---------------------------------------------------------------------*
FORM eind_vor_nullsummen .

  SELECT DISTINCT b~opbel MAX( b~opupk ) MIN( b~opupk ) AS min_opupk b~thinr b~bukrs b~vkont b~senid b~recid a~vkont a~opbel a~opupk  SUM( b~betrw ) c~int_crossrefno c~crossrefno c~crn_rev a~budat
    INTO TABLE lt_auswertung                          ##too_many_itab_fields
    FROM dfkkop AS a INNER JOIN dfkkthi AS b
    ON b~bcbln = a~opbel
    INNER JOIN ecrossrefno AS c
    ON c~int_crossrefno = b~crsrf
    WHERE a~vkont IN so_vkont
    AND a~augst = ' '
    AND b~storn = 'X'
    AND a~pymet = ' '
    GROUP BY b~opbel b~thinr b~bukrs b~vkont b~senid b~recid a~vkont a~opbel a~opupk c~int_crossrefno c~crossrefno c~crn_rev a~budat.
  "    HAVING b~opupk = MAX( b~opupk )


  DELETE lt_auswertung WHERE betrw = 0.

  LOOP AT lt_auswertung INTO ls_auswertung.

    lv_tabix = sy-tabix.
    CLEAR ls_tinv_inv_line_a.

    IF cnnabea IS INITIAL.
      SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a
       FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
       ON b~int_inv_doc_no = a~int_inv_doc_no
       WHERE a~own_invoice_no = ls_auswertung-crossrefno
       AND b~invoice_type = '004'. "Reklamationsavis (Eingang)
    ELSE.
      SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE a~own_invoice_no = ls_auswertung-crossrefno
        AND b~invoice_type = '004' "Reklamationsavis (Eingang)
        AND b~inv_doc_status NE '008'.
    ENDIF.

    IF sy-subrc NE 0.
      CLEAR ls_tinv_inv_line_a.

      IF cnnabea IS INITIAL.
        SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a
          FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
          WHERE  ( a~own_invoice_no = ls_auswertung-crossrefno OR a~own_invoice_no = ls_auswertung-crn_rev ).
      ELSE.
        SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a
          FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
          WHERE  ( a~own_invoice_no = ls_auswertung-crossrefno OR a~own_invoice_no = ls_auswertung-crn_rev )
          AND b~inv_doc_status NE '08'.
      ENDIF.

      IF sy-subrc NE 0.
        ls_auswertung-kennz = 'V'.

        SELECT SINGLE a~opbel a~opupk b~opbel b~opupk
        INTO (lv_streinzbel, lv_streinzbelop, lv_straggrbel, lv_straggrbelop)
        FROM dfkkthi AS a INNER JOIN dfkkop AS b
        ON b~opbel = a~bcbln
        WHERE a~crsrf = ls_auswertung-int_crossrefno
        AND a~stidc = 'X'
        AND b~augst = ' '
        AND b~pymet = ' '.

        IF NOT sy-subrc = 0.
          DELETE lt_auswertung INDEX lv_tabix.
          CONTINUE.                                        "Nuss 10.2018-2
        ENDIF.

**      Das Buchungsdatum bei den voraussichtlichen Nullsummen ist das
**      Erfassungsdatum des Stornobeleges
        SELECT cpudt
          FROM dfkkko
          INTO ls_auswertung-budat
          WHERE opbel = lv_straggrbel
          AND   cpudt IN so_cpuds.
        ENDSELECT.

        IF NOT ls_auswertung-budat IN so_cpuds.
          DELETE lt_auswertung INDEX lv_tabix.
          CLEAR lv_tabix.
          CLEAR ls_tinv_inv_line_a.
        ELSE.

**   --> Nuss 20.06.2013
**   Der Storno zum Einzelbeleg steht in der Tabelle DFKKKO
          SELECT SINGLE storb FROM dfkkko INTO lv_stornobeleg
              WHERE opbel = ls_auswertung-einzbel.
*          ls_auswertung-streinzbel = lv_streinzbel.
          ls_auswertung-streinzbel = lv_stornobeleg.
**     <-- Nuss 20.06.2013
          ls_auswertung-streinzbelop = lv_streinzbelop.
          ls_auswertung-straggrbel = lv_straggrbel.
          ls_auswertung-straggrbelop = lv_straggrbelop.

**      --> Nuss 20.06.2013

*        MODIFY lt_auswertung INDEX lv_tabix FROM ls_auswertung TRANSPORTING kennz streinzbel streinzbelop straggrbel straggrbelop.
          MODIFY lt_auswertung INDEX lv_tabix FROM ls_auswertung TRANSPORTING budat kennz streinzbel streinzbelop straggrbel straggrbelop.
**     <-- Nuss 20.06.2013

        ENDIF.

      ELSE.
* --> nuss 10.2018-2
        CLEAR gv_changed.
* --> Nuss 11.2018
        PERFORM nnr_ueberf_vor CHANGING ls_auswertung
                                        gv_changed.

        IF gv_changed IS NOT INITIAL.
          MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING budat kennz streinzbel streinzbelop straggrbel straggrbelop uebavis.
        ELSE.
* <-- Nuss 11.2018
          PERFORM endavis_nnr_vor CHANGING ls_auswertung
                                   gv_changed.
          IF gv_changed IS INITIAL.
* <-- Nuss 10.2018-2
            DELETE lt_auswertung INDEX lv_tabix.
            CLEAR lv_tabix.
            CLEAR ls_tinv_inv_line_a.
*  --> Nuss 10.2018-2
          ELSE.
            MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING budat kennz streinzbel streinzbelop straggrbel straggrbelop endavis.
          ENDIF.
*  <-- Nuss 10.2018-2
        ENDIF.                       "Nuss 11.2018
      ENDIF.


    ELSEIF sy-subrc = 0.

      CLEAR ls_tinv_inv_line_a2.

      IF cnnabea IS INITIAL.
        SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a2
         FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
         ON b~int_inv_doc_no = a~int_inv_doc_no
         WHERE a~own_invoice_no = ls_auswertung-crossrefno
         AND b~invoice_date > ls_tinv_inv_line_a-invoice_date
         AND b~invoice_type = '002'. "Reklamationsavis (Eingang)
      ELSE.
        SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a2
          FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
          WHERE a~own_invoice_no = ls_auswertung-crossrefno
          AND b~invoice_date > ls_tinv_inv_line_a-invoice_date
          AND b~invoice_type = '002' "Reklamationsavis (Eingang)
          AND b~inv_doc_status NE '08'.
      ENDIF.

      IF sy-subrc NE 0.

        CLEAR ls_tinv_inv_line_a2.

        IF cnnabea IS INITIAL.
          SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a
           FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
           ON b~int_inv_doc_no = a~int_inv_doc_no
           WHERE a~own_invoice_no = ls_auswertung-crn_rev.
        ELSE.
          SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a
            FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
            ON b~int_inv_doc_no = a~int_inv_doc_no
            WHERE a~own_invoice_no = ls_auswertung-crn_rev
            AND b~inv_doc_status NE '08'.
        ENDIF.

        IF sy-subrc NE 0.

          ls_auswertung-kennz = 'E'.

          SELECT SINGLE a~opbel a~opupk b~opbel b~opupk
            INTO (lv_streinzbel, lv_streinzbelop, lv_straggrbel, lv_straggrbelop)
            FROM dfkkthi AS a INNER JOIN dfkkop AS b
            ON b~opbel = a~bcbln
            WHERE crsrf = ls_auswertung-int_crossrefno
            AND a~stidc = 'X'
            AND b~augst = ' '
            AND b~pymet = ' '.

          IF NOT sy-subrc = 0.
            DELETE lt_auswertung INDEX lv_tabix.
            CONTINUE.                                "Nuss 11.2018
          ENDIF.

**   --> Nuss 20.06.2013
**   Der Storno zum Einzelbeleg steht in der Tabelle DFKKKO
          SELECT SINGLE storb FROM dfkkko INTO lv_stornobeleg
              WHERE opbel = ls_auswertung-einzbel.
*          ls_auswertung-streinzbel = lv_streinzbel.
          ls_auswertung-streinzbel = lv_stornobeleg.
**     <-- Nuss 20.06.2013
          ls_auswertung-streinzbelop = lv_streinzbelop.
          ls_auswertung-straggrbel = lv_straggrbel.
          ls_auswertung-straggrbelop = lv_straggrbelop.

          MODIFY lt_auswertung INDEX lv_tabix FROM ls_auswertung TRANSPORTING kennz streinzbel streinzbelop straggrbel straggrbelop.

        ELSE.
          DELETE lt_auswertung INDEX lv_tabix.
          CLEAR lv_tabix.
          CLEAR ls_tinv_inv_line_a.
        ENDIF.
      ELSE.
*       --> Nuss 10.2018-2
        CLEAR gv_changed.
*      --> Nuss 11.2018
        PERFORM nnr_ueberf_eind CHANGING ls_auswertung
                                         gv_changed.
        IF gv_changed IS NOT INITIAL.
          MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING  kennz streinzbel streinzbelop straggrbel straggrbelop uebavis.
        ELSE.
*       <-- Nuss 11.2018
          PERFORM endavis_nnr_eind CHANGING ls_auswertung
                                            gv_changed.
          IF gv_changed IS INITIAL.
*       <-- Nuss 10.2018-2
            DELETE lt_auswertung INDEX lv_tabix.
            CLEAR lv_tabix.
            CLEAR ls_tinv_inv_line_a.
* --> Nuss 10.2018-2
          ELSE.
            MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING  kennz streinzbel streinzbelop straggrbel straggrbelop endavis.
          ENDIF.
** <-- Nuss 10.2018-2
        ENDIF.                "Nuss 11.2018

      ENDIF.

    ENDIF.

    CLEAR ls_auswertung.

  ENDLOOP.

* --> Nuss 07.2018

  SELECT DISTINCT b~doc_id  b~doc_status b~company_code b~suppl_contr_acct b~dist_sp b~suppl_sp a~vkont a~opbel a~opupk  b~gross_amount
                  b~crossrefno  a~budat b~reversal_doc_id
                 INTO TABLE lt_auswertung_memi                          ##too_many_itab_fields
                 FROM dfkkop AS a INNER JOIN /idxmm/memidoc AS b
                 ON b~ci_fica_doc_no = a~opbel
                 WHERE a~vkont IN so_vkont
                 AND a~augst = ' '
*                 AND b~doc_status IN ( '60', '70' )           "Nuss 11.2018
*                 AND b~doc_status IN ( '60', '70', '71', '76'  )     "Nuss 11.2018
                 AND b~doc_status IN so_stato "Kasdorf 04.2020
                 AND b~reversal = 'X'
                 AND a~pymet = ' '.

  DELETE lt_auswertung_memi WHERE betrw = 0.

* Jetzt den Stornobeleg aus der /IDXMM/MEMIDOC lesen.
  LOOP AT lt_auswertung_memi INTO ls_auswertung_memi.

    lv_tabix = sy-tabix.

    CLEAR ls_memidoc.
    SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc
      WHERE doc_id = ls_auswertung_memi-streinzbel.

*   Die CROSSREFNO zum Stornobeleg lesen
    IF sy-subrc = 0.
      IF ls_memidoc-crossrefno IS NOT INITIAL.
        ls_auswertung_memi-crn_rev = ls_memidoc-crossrefno.
        ls_auswertung_memi-strstatus = ls_memidoc-doc_status.
        MODIFY lt_auswertung_memi INDEX lv_tabix FROM ls_auswertung_memi TRANSPORTING crn_rev strstatus.
      ELSE.
        DELETE lt_auswertung_memi INDEX lv_tabix.
      ENDIF.
    ENDIF.

  ENDLOOP.

  LOOP AT lt_auswertung_memi INTO ls_auswertung_memi.

    CLEAR ls_tinv_inv_line_a.

    lv_tabix = sy-tabix.

    IF cmmmabea IS INITIAL.
      SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a
      FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
      ON b~int_inv_doc_no = a~int_inv_doc_no
      WHERE a~own_invoice_no = ls_auswertung_memi-crossrefno
      AND b~invoice_type = '008'. "Reklamationsavis für Memi)
    ELSE.
      SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a
      FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
      ON b~int_inv_doc_no = a~int_inv_doc_no
      WHERE a~own_invoice_no = ls_auswertung_memi-crossrefno
      AND b~invoice_type = '008' "Reklamationsavis für Memi)
      AND b~inv_doc_status NE '08'.
    ENDIF.

    IF sy-subrc NE 0.
      CLEAR ls_tinv_inv_line_a.

      IF ( CMMMAREV IS INITIAL ) AND ( cmmmabea IS INITIAL ).
        SELECT SINGLE int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a
        WHERE ( own_invoice_no = ls_auswertung_memi-crn_rev OR
              own_invoice_no = ls_auswertung_memi-crossrefno ).
      ELSEIF ( CMMMAREV IS NOT INITIAL ) AND ( cmmmabea IS INITIAL ).
        SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE ( a~own_invoice_no = ls_auswertung_memi-crn_rev OR
                a~own_invoice_no = ls_auswertung_memi-crossrefno )
          AND b~invoice_type NE '008'.
      ELSEIF ( CMMMAREV IS INITIAL ) AND ( cmmmabea IS NOT INITIAL ).
        SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE ( a~own_invoice_no = ls_auswertung_memi-crn_rev OR
            a~own_invoice_no = ls_auswertung_memi-crossrefno )
        AND b~inv_doc_status NE '08'.
      ELSEIF ( CMMMAREV IS NOT INITIAL ) AND ( cmmmabea IS NOT INITIAL ).
        SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE ( a~own_invoice_no = ls_auswertung_memi-crn_rev OR
        a~own_invoice_no = ls_auswertung_memi-crossrefno )
        AND b~inv_doc_status NE '08'
        AND b~invoice_type NE '008'.
      ENDIF.
* <-- Kasdorf 04.202

      IF sy-subrc NE 0.

        ls_auswertung_memi-kennz = 'V'.

        SELECT SINGLE a~opbel a~opupk INTO (lv_straggrbel, lv_straggrbelop)
           FROM dfkkop AS a INNER JOIN /idxmm/memidoc AS b
              ON b~ci_fica_doc_no = a~opbel
                WHERE b~doc_id = ls_auswertung_memi-streinzbel.

        IF NOT sy-subrc = 0.
          DELETE lt_auswertung_memi INDEX lv_tabix.
        ENDIF.

**      Das Buchungsdatum bei den voraussichtlichen Nullsummen ist das
**      Erfassungsdatum des Stornobeleges
        SELECT cpudt
          FROM dfkkko
          INTO ls_auswertung_memi-budat
          WHERE opbel = lv_straggrbel
          AND   cpudt IN so_cpuds.
        ENDSELECT.

        IF NOT ls_auswertung_memi-budat IN so_cpuds.
          DELETE lt_auswertung_memi INDEX lv_tabix.
          CLEAR lv_tabix.
          CLEAR ls_tinv_inv_line_a.
        ELSE.

          ls_auswertung_memi-straggrbel = lv_straggrbel.
          ls_auswertung_memi-straggrbelop = lv_straggrbelop.

          MODIFY lt_auswertung_memi INDEX lv_tabix FROM ls_auswertung_memi TRANSPORTING budat kennz  straggrbel straggrbelop.
        ENDIF.

      ELSE.
*   --> Nuss 10.2018-2
        CLEAR gv_changed.
*   --> Nuss 11.2018
        PERFORM memi_ueberf_vor CHANGING ls_auswertung_memi
                                         gv_changed.
        IF gv_changed IS NOT INITIAL.
          MODIFY lt_auswertung_memi FROM ls_auswertung_memi TRANSPORTING budat kennz straggrbel straggrbelop uebavis.
        ELSE.
*   <-- Nuss 11.2018
          PERFORM endavis_memi_vor CHANGING ls_auswertung_memi
                                        gv_changed.
          IF gv_changed IS INITIAL.
* <-- Nuss 10.2018-2
            DELETE lt_auswertung_memi INDEX lv_tabix.
            CLEAR lv_tabix.
            CLEAR ls_tinv_inv_line_a.
*    --> Nuss 10.2018-2
          ELSE.

            MODIFY lt_auswertung_memi INDEX lv_tabix FROM ls_auswertung_memi TRANSPORTING budat kennz  straggrbel straggrbelop endavis.

          ENDIF.
*     <-- Nuss 10.2018
        ENDIF.                   "Nuss 11.2018

      ENDIF.


    ELSEIF sy-subrc = 0.

      CLEAR ls_tinv_inv_line_a2.

      IF cmmmabea IS INITIAL.
        SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a2
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE a~own_invoice_no = ls_auswertung_memi-crossrefno
        AND b~invoice_date > ls_tinv_inv_line_a-invoice_date
        AND b~invoice_type = '007'. "Reklamationsavis für Memi)
      ELSE.
        SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a2
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE a~own_invoice_no = ls_auswertung_memi-crossrefno
        AND b~invoice_type = '007' "Reklamationsavis für Memi)
        AND b~invoice_date > ls_tinv_inv_line_a-invoice_date
        AND b~inv_doc_status NE '08'.
      ENDIF.

      IF sy-subrc NE 0.

        CLEAR ls_tinv_inv_line_a.

        SELECT SINGLE int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a
        WHERE own_invoice_no = ls_auswertung_memi-crn_rev.

        IF cmmmabea IS INITIAL.
          SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a
          FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
          WHERE a~own_invoice_no = ls_auswertung_memi-crn_rev.
        ELSE.
          SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a
          FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
          WHERE a~own_invoice_no = ls_auswertung_memi-crn_rev
          AND b~inv_doc_status NE '08'.
        ENDIF.

        IF sy-subrc NE 0.

          ls_auswertung_memi-kennz = 'E'.

          SELECT SINGLE a~opbel a~opupk INTO (lv_straggrbel, lv_straggrbelop)
             FROM dfkkop AS a INNER JOIN /idxmm/memidoc AS b
                ON b~ci_fica_doc_no = a~opbel
                  WHERE b~doc_id = ls_auswertung_memi-streinzbel.

          IF NOT sy-subrc = 0.
            DELETE lt_auswertung_memi INDEX lv_tabix.
          ELSE.
            ls_auswertung_memi-straggrbel = lv_straggrbel.
            ls_auswertung_memi-straggrbelop = lv_straggrbelop.
          ENDIF.

***   --> Nuss 20.06.2013
***   Der Storno zum Einzelbeleg steht in der Tabelle DFKKKO
*          SELECT SINGLE storb FROM dfkkko INTO lv_stornobeleg
*              WHERE opbel = ls_auswertung-einzbel.
**          ls_auswertung-streinzbel = lv_streinzbel.
*          ls_auswertung-streinzbel = lv_stornobeleg.
***     <-- Nuss 20.06.2013
*          ls_auswertung-streinzbelop = lv_streinzbelop.
*          ls_auswertung-straggrbel = lv_straggrbel.
*          ls_auswertung-straggrbelop = lv_straggrbelop.

          MODIFY lt_auswertung_memi INDEX lv_tabix FROM ls_auswertung_memi TRANSPORTING kennz straggrbel straggrbelop.

        ELSE.
          DELETE lt_auswertung_memi INDEX lv_tabix.
        ENDIF.

      ELSE.
* <-- Nuss 10.2018-2
        CLEAR gv_changed.
** --> Nuss 11.2018
        PERFORM memi_ueberf_eind CHANGING ls_auswertung_memi
                                          gv_changed.
        IF gv_changed IS NOT INITIAL.
          MODIFY lt_auswertung_memi FROM ls_auswertung_memi TRANSPORTING kennz straggrbel straggrbelop uebavis.
        ELSE.
** <-- Nuss 11.2018
          PERFORM endavis_memi_eind CHANGING ls_auswertung_memi
                                             gv_changed.
          IF gv_changed IS INITIAL.
*  <-- Nuss 10.2018-2
            DELETE lt_auswertung_memi INDEX lv_tabix.
            CLEAR lv_tabix.
            CLEAR ls_tinv_inv_line_a.

* --> Nuss 10.2018-2
          ELSE.
            MODIFY lt_auswertung_memi FROM ls_auswertung_memi TRANSPORTING kennz straggrbel straggrbelop endavis.
          ENDIF.
* <-- Nuss 10.2018-2
        ENDIF.
      ENDIF.                              "Nuss 10.2018

    ELSE.
      DELETE lt_auswertung_memi INDEX lv_tabix.
      CLEAR lv_tabix.
      CLEAR ls_tinv_inv_line_a.
    ENDIF.

  ENDLOOP.

  LOOP AT lt_auswertung_memi INTO ls_auswertung_memi.
    MOVE-CORRESPONDING ls_auswertung_memi TO ls_auswertung.
    CLEAR ls_auswertung-vkont.                                   "Nuss 09.2018
    ls_auswertung-memi = 'X'.
    APPEND ls_auswertung TO lt_auswertung.
    CLEAR ls_auswertung.
  ENDLOOP.

  CLEAR ls_auswertung_memi.

  SELECT DISTINCT b~invdocno c~bukrs b~vkont b~/mosb/mo_sp b~/mosb/lead_sup
                  a~vkont c~opbel a~opupk c~betrw d~/mosb/inv_doc_ident
                  a~budat
             FROM dfkkinvbill_h AS b INNER JOIN dfkkinvdoc_i AS c
                ON b~invdocno = c~invdocno
             INNER JOIN dfkkinvdoc_h AS d
                ON d~invdocno = c~invdocno
             INNER JOIN dfkkop AS a
                 ON c~opbel = a~opbel
       INTO TABLE lt_auswertung_msb
          WHERE a~vkont IN so_vkont
            AND a~augst = ' '
            AND a~pymet = ' '
            AND b~revreason NE ' '
            AND c~itemtype = 'YMOS'
            AND d~/mosb/inv_doc_ident NE ' '.

  DELETE lt_auswertung_msb WHERE betrw = 0.

* Stornobeleg holen
  LOOP AT lt_auswertung_msb INTO ls_auswertung_msb.

    lv_tabix = sy-tabix.

    CLEAR ls_dfkkinvbill_h.
    SELECT SINGLE * FROM dfkkinvbill_h INTO ls_dfkkinvbill_h
      WHERE invdocno = ls_auswertung_msb-einzbel.
    CLEAR ls_dfkkinvbill_h2.
    SELECT SINGLE * FROM dfkkinvbill_h INTO ls_dfkkinvbill_h2
      WHERE billdocno = ls_dfkkinvbill_h-reversaldoc.
    CLEAR ls_dfkkinvdoc_h.
    SELECT SINGLE * FROM dfkkinvdoc_h INTO ls_dfkkinvdoc_h
      WHERE invdocno = ls_dfkkinvbill_h2-invdocno.
    ls_auswertung_msb-streinzbel =  ls_dfkkinvdoc_h-invdocno.
    ls_auswertung_msb-crn_rev = ls_dfkkinvdoc_h-/mosb/inv_doc_ident.

    IF ls_auswertung_msb-streinzbel IS INITIAL OR
       ls_auswertung_msb-crn_rev IS INITIAL.
      DELETE lt_auswertung_msb INDEX lv_tabix.
    ELSE.
      MODIFY lt_auswertung_msb INDEX lv_tabix FROM ls_auswertung_msb TRANSPORTING streinzbel crn_rev.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_auswertung_msb INTO ls_auswertung_msb.

    CLEAR ls_tinv_inv_line_a.

    lv_tabix = sy-tabix.

    IF cmsbbea IS INITIAL.
      SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
       FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
       ON b~int_inv_doc_no = a~int_inv_doc_no
       WHERE a~own_invoice_no = ls_auswertung_msb-crossrefno
       AND b~invoice_type = '013'. "Reklamationsavis für MSB
    ELSE.
      SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE a~own_invoice_no = ls_auswertung_msb-crossrefno
        AND b~invoice_type = '013' "Reklamationsavis für MSB
        AND  b~inv_doc_status NE '08'.
    ENDIF.

    IF sy-subrc NE 0.
      CLEAR ls_tinv_inv_line_a.

      IF cmsbbea IS INITIAL.
        SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE ( own_invoice_no = ls_auswertung_msb-crn_rev OR
                own_invoice_no = ls_auswertung_msb-crossrefno ).
      ELSE.
        SELECT SINGLE a~int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE ( own_invoice_no = ls_auswertung_msb-crn_rev OR
                own_invoice_no = ls_auswertung_msb-crossrefno )
          AND b~inv_doc_status NE '08'.
      ENDIF.

      IF sy-subrc NE 0.

        ls_auswertung_msb-kennz = 'V'.

        SELECT SINGLE a~opbel a~opupk INTO (lv_straggrbel, lv_straggrbelop)
          FROM dfkkop AS a INNER JOIN dfkkinvdoc_i AS b
            ON b~opbel = a~opbel
          INNER JOIN dfkkinvdoc_h AS c
            ON c~invdocno = b~invdocno
          WHERE b~invdocno = ls_auswertung_msb-streinzbel.

        IF NOT sy-subrc = 0.
          DELETE lt_auswertung_memi INDEX lv_tabix.
        ENDIF.

**      Das Buchungsdatum bei den voraussichtlichen Nullsummen ist das
**      Erfassungsdatum des Stornobeleges
        SELECT cpudt
          FROM dfkkko
          INTO ls_auswertung_msb-budat
          WHERE opbel = lv_straggrbel
          AND   cpudt IN so_cpuds.
        ENDSELECT.

        IF NOT ls_auswertung_msb-budat IN so_cpuds.
          DELETE lt_auswertung_msb INDEX lv_tabix.
          CLEAR lv_tabix.
          CLEAR ls_tinv_inv_line_a.
        ELSE.

          ls_auswertung_msb-straggrbel = lv_straggrbel.
          ls_auswertung_msb-straggrbelop = lv_straggrbelop.

          MODIFY lt_auswertung_msb INDEX lv_tabix FROM ls_auswertung_msb TRANSPORTING budat kennz  straggrbel straggrbelop.
        ENDIF.
*
      ELSE.
        DELETE lt_auswertung_msb INDEX lv_tabix.
        CLEAR lv_tabix.
        CLEAR ls_tinv_inv_line_a.
      ENDIF.


    ELSEIF sy-subrc = 0.

      CLEAR ls_tinv_inv_line_a2.

      IF cmsbbea IS INITIAL.
        SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a2
         FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
         ON b~int_inv_doc_no = a~int_inv_doc_no
         WHERE a~own_invoice_no = ls_auswertung_msb-crossrefno
         AND b~invoice_type = '011' "Zahlungsavis für MSB
         AND b~invoice_date > ls_tinv_inv_line_a-invoice_date.
      ELSE.
        SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a2
        FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
        ON b~int_inv_doc_no = a~int_inv_doc_no
        WHERE a~own_invoice_no = ls_auswertung_msb-crossrefno
        AND b~invoice_type = '011' "Zahlungsavis für MSB
        AND b~invoice_date > ls_tinv_inv_line_a-invoice_date
        AND b~inv_doc_status NE '08'.
      ENDIF.

      IF sy-subrc NE 0.

        CLEAR ls_tinv_inv_line_a.

        SELECT SINGLE int_inv_doc_no INTO ls_tinv_inv_line_a
        FROM tinv_inv_line_a
        WHERE own_invoice_no = ls_auswertung_msb-crn_rev.

        IF cmsbbea IS INITIAL.
          SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a
           FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
           ON b~int_inv_doc_no = a~int_inv_doc_no
           WHERE a~own_invoice_no = ls_auswertung_msb-crn_rev.
        ELSE.
          SELECT SINGLE a~int_inv_doc_no b~invoice_date INTO ls_tinv_inv_line_a
          FROM tinv_inv_line_a AS a INNER JOIN tinv_inv_doc AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
          WHERE a~own_invoice_no = ls_auswertung_msb-crn_rev
          AND b~inv_doc_status NE '08'.
        ENDIF.

        IF sy-subrc NE 0.

          ls_auswertung_msb-kennz = 'E'.

          SELECT SINGLE a~opbel a~opupk INTO (lv_straggrbel, lv_straggrbelop)
            FROM dfkkop AS a INNER JOIN dfkkinvdoc_i AS b
              ON b~opbel = a~opbel
            INNER JOIN dfkkinvdoc_h AS c
              ON c~invdocno = b~invdocno
            WHERE b~invdocno = ls_auswertung_msb-streinzbel.

          IF NOT sy-subrc = 0.
            DELETE lt_auswertung_msb INDEX lv_tabix.
          ELSE.
            ls_auswertung_msb-straggrbel = lv_straggrbel.
            ls_auswertung_msb-straggrbelop = lv_straggrbelop.
          ENDIF.

          MODIFY lt_auswertung_msb INDEX lv_tabix FROM ls_auswertung_msb TRANSPORTING kennz straggrbel straggrbelop.
*
        ELSE.
          DELETE lt_auswertung_msb INDEX lv_tabix.
        ENDIF.

      ELSE.
        DELETE lt_auswertung_msb INDEX lv_tabix.
        CLEAR lv_tabix.
        CLEAR ls_tinv_inv_line_a.
      ENDIF.

    ELSE.
      DELETE lt_auswertung_msb INDEX lv_tabix.
      CLEAR lv_tabix.
      CLEAR ls_tinv_inv_line_a.
    ENDIF.

  ENDLOOP.

  LOOP AT lt_auswertung_msb INTO ls_auswertung_msb.
    MOVE-CORRESPONDING ls_auswertung_msb TO ls_auswertung.
    CLEAR ls_auswertung-vkont.
    ls_auswertung-msb = 'X'.
    APPEND ls_auswertung TO lt_auswertung.
    CLEAR ls_auswertung.
  ENDLOOP.
* <-- Nuss 10.2018

ENDFORM.                    " Eindeutige und voraussichtliche Nullsummen

* --> Nuss 09.2018
**&---------------------------------------------------------------------*
**&      Form  AUSGLEICHSBUCHUNG
**&---------------------------------------------------------------------*
*FORM ausgleichsbuchung .
*
*  SELECT SINGLE *
*          INTO ls_custkpf
*          FROM /adesso/cust_kpf.
*
*
*  IF  cbens = 'X' AND cbvns = ' '.
*    PERFORM eindeutige_nullsummen.
*  ELSEIF  cbens = ' ' AND cbvns = 'X'.
*    PERFORM voraussichtliche_nullsummen.
*  ELSEIF cbens = 'X' AND cbvns = 'X'.
*    PERFORM eind_vor_nullsummen.
*  ENDIF.
*
*  IF cbepl = 'X'.
*    PERFORM eplot_buchungen.
*  ENDIF.
*
*  lv_budat = sy-datum.
*  MOVE lv_budat TO lv_date.
*  CONCATENATE ls_custkpf-abst lv_nr lv_date INTO lv_fikey.
*
*  CLEAR:  ls_fkkcl,
*          lt_fkkcl.
*
*  LOOP AT lt_auswertung INTO ls_auswertung.
*
*    CLEAR:  ls_seltab,
*            lt_seltab,
*            lt_seltab[],
*            lt_fkkcl_b,
*            lt_fkkcl_b[].
*
*    IF ls_auswertung-aggropbel IS INITIAL OR ls_auswertung-straggrbel IS INITIAL.
*      CONTINUE.
*    ENDIF.
*
*    ls_seltab-selnr = '0001'.
*    ls_seltab-selfn = 'OPBEL'.
*    ls_seltab-selcu = ls_auswertung-aggropbel.
*    APPEND ls_seltab TO lt_seltab.
*
*    ls_seltab-selnr = '0002'.
*    ls_seltab-selfn = 'OPBEL'.
*    ls_seltab-selcu = ls_auswertung-straggrbel.
*    APPEND ls_seltab TO lt_seltab.
*
*    CALL FUNCTION 'FKK_OPEN_ITEM_SELECT'
*      EXPORTING
*        i_applk        = 'R'
*        i_continue     = ' '
*        i_payment_date = sy-datum
*      TABLES
*        t_seltab       = lt_seltab
*        t_fkkcl        = lt_fkkcl.
*
** ls_auswertung-betrw <-- Betrag des stornierten Einzelbelegs, Ausgleichsbetrag zum aggr. Beleg
** lv_betrwr           <-- Restbetrag der noch bis zum Ausgleich des aggr. Einzelbelegs zum stornierten Einzelbeleg fehlt
** lv_betrw            <-- Summe aller Teilpositionen des aggr. Belegs zum stornierten Einzelbeleg, die bereits im Ausgleichsvorschlag sind
*
** lv_betrwan          <-- Betrag des Stornos zum stornierten Einzelbeleg, Ausgleichsbetrag zum aggr. Beleg des Stornos
** lv_betrwrn          <-- Restbetrag der noch bis zum Ausgleich des aggr. Einzelbelegs zum Einzelbeleg des Stornos fehlt
** lv_betrwn           <-- Summe aller Teilpositionen des aggr. Belegs zum Einzelbeleg des Stornos, die bereits im Ausgleichsvorschlag sind
*
*** --> Nuss 01.07.2013
*** Wenn der Betrag für den aggr. Beleg kleiner als Null ist, werden die Beträge (BETRW) für die
*** Auswertungs-ITAB, sowie für den Aggr. Beleg und den aggr. Stornobeleg mit -1 multipliziert.
*** Die involvierten Belege und die Beträge werden in eine Hilfstabelle geschrieben
*    CLEAR: lt_hilf,ls_hilf.
*    IF ls_auswertung-betrw LT 0.
*      ls_auswertung-betrw = ls_auswertung-betrw * -1.
*      LOOP AT lt_fkkcl ASSIGNING <lf_fkkcl>.
*        IF <lf_fkkcl>-opbel = ls_auswertung-aggropbel.
*          MULTIPLY <lf_fkkcl>-betrw BY -1.
*          ls_hilf-opbel = ls_auswertung-aggropbel.
*          ls_hilf-betrw = <lf_fkkcl>-betrw.
*          APPEND ls_hilf TO lt_hilf.
*          CLEAR ls_hilf.
*        ENDIF.
*        IF <lf_fkkcl>-opbel = ls_auswertung-straggrbel.
*          MULTIPLY <lf_fkkcl>-betrw BY -1.
*          ls_hilf-opbel = ls_auswertung-straggrbel.
*          ls_hilf-betrw = <lf_fkkcl>-betrw.
*          APPEND ls_hilf TO lt_hilf.
*          CLEAR ls_hilf.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
***  <-- Nuss 01.07.2013
*
*    lv_betrwan = ls_auswertung-betrw * -1.
*    CLEAR:  lv_betrw,
*            lv_betrwn,
*            lt_fkkcl_d,
*            lt_fkkcl_d[].
*
** Der original Beleg muß als erstes bearbeitet werden.
*    IF ls_auswertung-straggrbel LT ls_auswertung-aggropbel.
*      SORT lt_fkkcl BY opbel ASCENDING.
*    ELSE.
*      SORT lt_fkkcl BY opbel DESCENDING.
*    ENDIF.
*
*    LOOP AT lt_fkkcl INTO ls_fkkcl.
*
*      lv_betrwr = ls_auswertung-betrw - lv_betrw.             "Restbetrag ist gleich Sollbetrag abzüglich bereits aktivierter Teilpositionen
*      lv_betrwrn = lv_betrwan - lv_betrwn.                    "Restbetrag ist gleich Sollbetrag abzüglich bereits aktivierter Teilpositionen (Storno)
*
*      IF ls_fkkcl-opbel = ls_auswertung-straggrbel.           " Wenn offener Posten ist gleich aggr. Beleg des Stornos
*
*        IF NOT lv_betrwn LT lv_betrwan.                       " Wenn Summe aus Positionen die bereits im Ausgleichsvorschlag sind
*          " kleiner sind als Ausgleichshöhe Sollbetrag (in diesem Fall Storno, umgekehrtes Vorzeichen)
*          " Wenn Bedingung zutrifft, wird die Position in den Ausgleich mit aufgenommen
*          ls_fkkcl-xaktp = 'X'.
**          LS_FKKCL-AUGRD                = CONST_AUGRD.
**          LS_FKKCL-AUGWA                = CONST_WAERS.
*
*          ls_fkkcl-augrd                = ls_custkpf-augrd.
*          ls_fkkcl-augwa                = ls_custkpf-waers.
*
*          IF lv_betrwrn LE ls_fkkcl-betrw.                    " Wenn Restbetrag mit Betrag aus Teilposition noch nicht erreicht,...
*            " dann Ausgleich über vollen Betrag der Teilposition
*            lv_betrwn = lv_betrwn + ls_fkkcl-betrw.           " Fortschreibung des bereits für den Ausgleich aktivierter Positionen
*            ls_fkkcl-augbw                = ls_fkkcl-betrw.
*            ls_fkkcl-augbh                = ls_fkkcl-betrw.
*          ELSE.                                               " ansonsten Ausgleich über Restbetrag ermittelt über Sollbetrag abzüglich bereits aktivierter
*            ls_fkkcl-augbw = lv_betrwan - lv_betrwn.
*            ls_fkkcl-augbh = lv_betrwan - lv_betrwn.
*            lv_betrwn = lv_betrwan.                           " Sollbetrag ist erreicht für Ausgleich aggr. Beleg des Stornos
*          ENDIF.
*          APPEND ls_fkkcl TO lt_fkkcl_d.                      " Teilpositionen des aggr. Belegs zum Storno für den Ausgleich
*        ENDIF.
*
*        MODIFY lt_fkkcl INDEX sy-tabix FROM ls_fkkcl.
*      ELSEIF ls_fkkcl-opbel = ls_auswertung-aggropbel.        " Wenn offener Posten ist gleich aggr. Beleg des stornierten Belegs
*
*        IF NOT lv_betrw GT ls_auswertung-betrw.               " Wenn Summe aus Positionen die bereits im Ausgleichsvorschlag sind
*          " kleiner sind als Ausgleichshöhe Sollbetrag
*          " Wenn Bedingung zutrifft, wird die Position in den Ausgleich mit aufgenommen
*          ls_fkkcl-xaktp = 'X'.
*          ls_fkkcl-augrd                = ls_custkpf-augrd.
*          ls_fkkcl-augwa                = ls_custkpf-waers.
*
*          IF lv_betrwr GE ls_fkkcl-betrw.                     " Wenn Restbetrag mit Betrag aus Teilposition noch nicht erreicht,...
*            " dann Ausgleich über vollen Betrag der Teilposition
*            lv_betrw = lv_betrw + ls_fkkcl-betrw.             " Fortschreibung des bereits für den Ausgleich aktivierter Positionen
*
*            ls_fkkcl-augbw                = ls_fkkcl-betrw.
*            ls_fkkcl-augbh                = ls_fkkcl-betrw.
*          ELSE.                                               " ansonsten Ausgleich über Restbetrag ermittelt über Sollbetrag abzüglich bereits aktivierter
*            ls_fkkcl-augbw = ls_auswertung-betrw - lv_betrw.
*            ls_fkkcl-augbh = ls_auswertung-betrw - lv_betrw.
*            lv_betrw = ls_auswertung-betrw.                   " Sollbetrag ist erreicht für Ausgleich aggr. Beleg des Stornos
*          ENDIF.
*          APPEND ls_fkkcl TO lt_fkkcl_d.                      " Teilpositionen des aggr. Belegs zum stornierten Beleg für den Ausgleich
*        ENDIF.
*        MODIFY lt_fkkcl INDEX sy-tabix FROM ls_fkkcl.
*      ENDIF.
*    ENDLOOP.
*
*    IF ls_auswertung-kennz = 'A'.
*      APPEND LINES OF lt_fkkcl_d TO lt_fkkcl_b.
*
*    ELSE.
*
*      IF ( lv_betrwn = lv_betrwan ) AND ( lv_betrw = ls_auswertung-betrw ).  " Der Ausgleichsvorschlag wird nur vorgenommen, wenn der Ausgleichsbetrag
*        " sowohl für den aggr. Beleg als auch für den aggr. Stornobeleg erreicht ist
*        APPEND LINES OF lt_fkkcl_d TO lt_fkkcl_b.
*      ENDIF.
*
*    ENDIF.
*
*** --> Nuss 01.07.2013
*** Die oben gemachten Umkehrungen des Vorzeichens wieder Rückgängig machen
*    IF lt_hilf[] IS NOT INITIAL.
*      MULTIPLY ls_auswertung-betrw BY -1.
*      LOOP AT lt_hilf INTO ls_hilf.
*        LOOP AT lt_fkkcl ASSIGNING <lf_fkkcl>
*           WHERE opbel = ls_hilf-opbel
*             AND betrw = ls_hilf-betrw.
*          MULTIPLY <lf_fkkcl>-betrw BY -1.
*          MULTIPLY <lf_fkkcl>-augbw BY -1.
*          MULTIPLY <lf_fkkcl>-augbh BY -1.
*        ENDLOOP.
*
*        LOOP AT lt_fkkcl_b  ASSIGNING <lf_fkkcl_b>
*             WHERE opbel = ls_hilf-opbel
*             AND betrw = ls_hilf-betrw.
*          MULTIPLY <lf_fkkcl_b>-betrw BY -1.
*          MULTIPLY <lf_fkkcl_b>-augbw BY -1.
*          MULTIPLY <lf_fkkcl_b>-augbh BY -1.
*        ENDLOOP.
*      ENDLOOP.
*
*    ENDIF.
*** <-- Nuss 01.07.2013
*
*
*    "Abstimmschlüssel generieren.
*    DO.
*      CALL FUNCTION 'FKK_FIKEY_CHECK'
*        EXPORTING
*          i_fikey                = lv_fikey
*          i_open_on_request      = 'X'
*          i_open_without_dialog  = 'X'
*          i_non_existing_allowed = 'X'
*        EXCEPTIONS
*          error_message          = 99
*          OTHERS                 = 99.
*
*      IF sy-subrc = '0'.
*        EXIT.
*      ELSE.
*        lv_nr = lv_nr + 1.
*        CONCATENATE ls_custkpf-abst lv_nr lv_date INTO lv_fikey.
*      ENDIF.
*    ENDDO.
*
*    ls_fkkko-herkf  = ls_custkpf-herkf.
*    ls_fkkko-applk  = 'R'.
*    ls_fkkko-blart  = ls_custkpf-blart.
*    ls_fkkko-waers  = ls_custkpf-waers.
*    ls_fkkko-bldat  = lv_budat.
*    ls_fkkko-budat  = lv_budat.
*    ls_fkkko-wwert  = lv_budat.
*    ls_fkkko-fikey  = lv_fikey.
*
*    IF NOT lt_fkkcl_b IS INITIAL.
*      CALL FUNCTION 'FKK_CREATE_DOC_AND_CLEAR'
*        EXPORTING
*          i_fkkko       = ls_fkkko
*          i_update_task = 'X'
*        IMPORTING
*          e_opbel       = lv_docnum
*        TABLES
*          t_fkkcl       = lt_fkkcl_b.
*
*      IF sy-subrc = 0.
*        COMMIT WORK AND WAIT.
*        ls_auswertung-augbel = lv_docnum.
*        ls_auswertung-f_status = '@5B\Q Ausgleich gebucht@'.
*        MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING augbel f_status.
**        EXIT.
*      ENDIF.
*    ELSE.
*      ls_auswertung-f_status = '@5C\Q Ausgleich nicht möglich@'.
*      MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING f_status.
*    ENDIF.
*
*  ENDLOOP.
*
*ENDFORM.                    " Ausgleichsbuchung
* <-- Nuss 09.2018

*&---------------------------------------------------------------------*
* ALV-GRID-USER_COMMAND
*&---------------------------------------------------------------------*
FORM user_command USING i_ucomm
                     i_selfield TYPE slis_selfield.
* --> Nuss 07.2018
* Daten im ALV aktualisieren (wichtig für das Selektionsfeld)
  DATA: rev_alv TYPE REF TO cl_gui_alv_grid.

* --> Nuss 10.2018
  DATA: rspar_tab  TYPE TABLE OF rsparams,
        rspar_line LIKE LINE OF rspar_tab.
* <-- Nuss 10.2018

* --> Nuss 10.2018-2
  DATA: lv_gruppkz      LIKE ls_auswertung-gruppkz,
        lv_gruppkz_help LIKE ls_auswertung-gruppkz,
        lv_zaehler      TYPE i.


  i_selfield-refresh = 'X'.

  i_selfield-row_stable = 'X'.
  i_selfield-col_stable = 'X'.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = rev_alv.

  rev_alv->check_changed_data( ).


  READ TABLE lt_auswertung INTO ls_auswertung
        INDEX i_selfield-tabindex.


  IF i_ucomm = 'NULLAVIS'.

    LOOP AT lt_auswertung INTO ls_auswertung
      WHERE sel IS NOT INITIAL.

      IF ls_auswertung-memi = 'X'.
        CHECK ls_auswertung-nullavis IS INITIAL.

        PERFORM nullsummenavis_memi.

** --> Nuss 10.2018
      ELSEIF ls_auswertung-msb = 'X'.
        CHECK ls_auswertung-nullavis IS INITIAL.

        PERFORM nullsummenavis_msb.
**  <-- Nuss 10.2018

      ELSE.
        CHECK ls_auswertung-nullavis IS INITIAL.

        PERFORM nullsummenavis.


      ENDIF.

      MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING nullavis.

    ENDLOOP.

** --> nuss 10.2018-2
  ELSEIF i_ucomm = 'AGGRAVIS'.

    LOOP AT lt_auswertung INTO ls_auswertung
      WHERE sel IS NOT INITIAL
      AND ( aggrbelanz GT p_count OR
            straggrbelanz GT p_count ).

      MOVE ls_auswertung-gruppkz TO lv_gruppkz.

      IF lv_gruppkz NE lv_gruppkz_help.
** MEMI-Belege
        IF ls_auswertung-memi = 'X'.

          LOOP AT lt_auswertung INTO ls_auswertung_aggr
            WHERE gruppkz = lv_gruppkz.
            IF ls_auswertung_aggr-sel IS INITIAL.

              MESSAGE i000(e4) WITH
              'Gruppierungsmerkmal'
              lv_gruppkz
              'Es wurden nicht alle Belege markiert'.
              EXIT.

            ENDIF.
          ENDLOOP.

          PERFORM aggravis_memi USING lv_gruppkz.


          LOOP AT lt_auswertung INTO ls_auswertung_aggr
            WHERE gruppkz = lv_gruppkz.

            ls_auswertung_aggr-nullavis = gv_helpavis.

            MODIFY lt_auswertung FROM ls_auswertung_aggr TRANSPORTING nullavis.

          ENDLOOP.
** MSB - Da gibt es keine Aggregierten Nullsummenavise
        ELSEIF ls_auswertung-msb = 'X'.
*        Do Nothing, da gibt es immer nur eine Zeile

**      NNR
        ELSE.
** --> Nuss 10.2018-3
          LOOP AT lt_auswertung INTO ls_auswertung_aggr
            WHERE gruppkz = lv_gruppkz.
            IF ls_auswertung_aggr-sel IS INITIAL.

              MESSAGE i000(e4) WITH
              'Gruppierungsmerkmal'
              lv_gruppkz
              'Es wurden nicht alle Belege markiert'.
              EXIT.

            ENDIF.
          ENDLOOP.

          PERFORM aggravis USING lv_gruppkz.

          LOOP AT lt_auswertung INTO ls_auswertung_aggr
            WHERE gruppkz = lv_gruppkz.

            ls_auswertung_aggr-nullavis = gv_helpavis.

            MODIFY lt_auswertung FROM ls_auswertung_aggr TRANSPORTING nullavis.

          ENDLOOP.
** <-- Nuss 10.2018-3


        ENDIF.
        lv_gruppkz_help = ls_auswertung-gruppkz.
      ENDIF.

    ENDLOOP.
** <-- Nuss 10.2018-2


* --> Nuss 09.2018
  ELSEIF i_ucomm = 'MARK_ALL'.
    LOOP AT lt_auswertung INTO ls_auswertung.

      ls_auswertung-sel = 'X'.

      MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING sel.
    ENDLOOP.

  ELSEIF i_ucomm = 'DEL_MARK'.

    LOOP AT lt_auswertung INTO ls_auswertung.

      ls_auswertung-sel = ''.

      MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING sel.
    ENDLOOP.
* <-- Nuss 09.2018

** --> Nuss 10.2018
  ELSEIF i_ucomm = 'PROCESS'.

    PERFORM process.

** <-- Nuss 10.2018


  ELSE.
* <-- Nuss 07.2018
    CASE i_ucomm.
      WHEN '&IC1'.  "bei Klick

        READ TABLE lt_auswertung INTO ls_auswertung
              INDEX i_selfield-tabindex.


        IF i_selfield-fieldname = 'A_VKONT'.

          IF ls_auswertung-msb NE 'X'.                           "Nuss 10.2018

            CLEAR:  s_fkkeposs1,
                    t_fkkeposs1.

            s_fkkeposs1-vkont = ls_auswertung-a_vkont.
            s_fkkeposs1-xawop = 'X'.
            APPEND s_fkkeposs1 TO t_fkkeposs1.

            CALL FUNCTION 'FKK_LINE_ITEMS_WITH_SELECTIONS'
              EXPORTING
                i_fkkeposc = s_fkkeposc
              TABLES
                t_selhead  = t_fkkeposs1.

*        --> Nuss 10.2018
          ELSE.

            SUBMIT /idxgl/rp_acc_bal_mon
              WITH p_ca = ls_auswertung-a_vkont
              AND RETURN.
          ENDIF.
*        <-- Nuss 10.2018

        ELSEIF i_selfield-fieldname = 'VKONT'.
          CHECK ls_auswertung-vkont IS NOT INITIAL.         "Nuss 09.2018
          CALL FUNCTION 'FKK_ACCOUNT_CHANGE'
            EXPORTING
              i_vkont   = ls_auswertung-vkont
              i_ch_mode = '1'.

        ELSEIF i_selfield-fieldname = 'SENID'.
          CLEAR f_service_prov.
          f_service_prov = ls_auswertung-senid.

          CALL FUNCTION 'ISU_S_EDMIDE_SERVPROV_DISPLAY'
            EXPORTING
              x_serviceid = f_service_prov
              x_no_change = 'X'
              x_no_other  = 'X'
              x_first_tab = '00'.

        ELSEIF i_selfield-fieldname = 'RECID'.
          CLEAR f_service_prov.
          f_service_prov = ls_auswertung-recid.

          CALL FUNCTION 'ISU_S_EDMIDE_SERVPROV_DISPLAY'
            EXPORTING
              x_serviceid = f_service_prov
              x_no_change = 'X'
              x_no_other  = 'X'
              x_first_tab = '00'.

        ELSEIF i_selfield-fieldname = 'EINZBEL'.
** --> Nuss 10.2018
*          IF ls_auswertung-memi IS INITIAL.                  "Nuss 07.2018
          IF ls_auswertung-memi IS INITIAL AND ls_auswertung-msb IS INITIAL.
** <-- Nuss 10.2018

** --> Nuss 11.2018
            CLEAR ls_dfkkop.
            SELECT SINGLE * FROM dfkkop INTO ls_dfkkop
              WHERE opbel = ls_auswertung-einzbel
               AND opupk = ls_auswertung-einzbelop.
            IF sy-subrc NE 0.
              MESSAGE e000(e4) WITH 'Einzelbelegposition nicht anzeigbar/vorhanden'.
            ENDIF.
** <-- Nuss 11.2018

            CALL FUNCTION 'FKK_FPE0_START_TRANSACTION'
              EXPORTING
                tcode   = 'FPE3'
                opbel   = ls_auswertung-einzbel
                i_opupk = ls_auswertung-einzbelop
                i_opupw = 0
                i_opupz = 0.
*    --> Nuss 07.2018
*          ELSE.                                      "Nuss 10.2018
          ELSEIF ls_auswertung-memi = 'X'.          "Nuss 10.2018
            SUBMIT /idxmm/rp_document_display
              WITH so_mmdoc-low = ls_auswertung-einzbel
              AND RETURN.
*  --> Nuss 10.2018
          ELSEIF ls_auswertung-msb = 'X'.
            DATA lv_invdocno_kk TYPE invdocno_kk.
            lv_invdocno_kk = i_selfield-value.
            CALL FUNCTION 'FKK_INV_INVDOC_DISP'
              EXPORTING
                x_invdocno = lv_invdocno_kk.
            IF sy-subrc <> 0.
* Implement suitable error handling here
            ENDIF.
* <-- Nuss 10.2018
          ENDIF.
*    <-- Nuss 07.2018

        ELSEIF i_selfield-fieldname = 'AGGROPBEL'.
          CALL FUNCTION 'FKK_FPE0_START_TRANSACTION'
            EXPORTING
              tcode   = 'FPE3'
              opbel   = ls_auswertung-aggropbel
              i_opupk = ls_auswertung-aggropupk
              i_opupw = 0
              i_opupz = 0.

        ELSEIF i_selfield-fieldname = 'STREINZBEL'.
** --> Nuss 10.2018
*          IF ls_auswertung-memi IS INITIAL.                  "Nuss 07.2018
          IF ls_auswertung-memi IS INITIAL AND ls_auswertung-msb IS INITIAL.
** <-- Nuss 10.2018
            CALL FUNCTION 'FKK_FPE0_START_TRANSACTION'
              EXPORTING
                tcode   = 'FPE3'
                opbel   = ls_auswertung-streinzbel
*               i_opupk = ls_auswertung-streinzbelop  "Nuss 20.06.2013
                i_opupw = 0
                i_opupz = 0.
*    --> Nuss 07.2018
*          ELSE.                                      "Nuss 10.2018
          ELSEIF ls_auswertung-memi = 'X'.          "Nuss 10.2018
            SUBMIT /idxmm/rp_document_display
              WITH so_mmdoc-low = ls_auswertung-streinzbel
              AND RETURN.
*  --> Nuss 10.2018
          ELSEIF ls_auswertung-msb = 'X'.
            lv_invdocno_kk = i_selfield-value.
            CALL FUNCTION 'FKK_INV_INVDOC_DISP'
              EXPORTING
                x_invdocno = lv_invdocno_kk.
            IF sy-subrc <> 0.
* Implement suitable error handling here
            ENDIF.
* <-- Nuss 10.2018
          ENDIF.

*    <-- Nuss 07.2018

        ELSEIF i_selfield-fieldname = 'STRAGGRBEL'.
          CALL FUNCTION 'FKK_FPE0_START_TRANSACTION'
            EXPORTING
              tcode   = 'FPE3'
              opbel   = ls_auswertung-straggrbel
              i_opupk = ls_auswertung-straggrbelop
              i_opupw = 0
              i_opupz = 0.

*        ELSEIF i_selfield-fieldname = 'AUGBEL'.
*          IF NOT ls_auswertung-augbel IS INITIAL.
*            CALL FUNCTION 'FKK_LINE_ITEMS_SHOW_CL_ITEMS'
*              EXPORTING
*                i_opbel = ls_auswertung-augbel.
*          ENDIF.

* --> Nuss 07.2018
        ELSEIF i_selfield-fieldname = 'NULLAVIS'.
          IF NOT ls_auswertung-nullavis IS INITIAL.

**     --> Nuss 10.2018
            rspar_line-selname = 'P_INVTP'.
            rspar_line-kind = 'P'.
            rspar_line-sign = 'I'.
            rspar_line-option = 'EQ'.
            CLEAR rspar_line-low.
            APPEND rspar_line TO rspar_tab.

            CLEAR rspar_line.
            rspar_line-selname = 'SE_DOCNR'.
            rspar_line-kind = 'S'.
            rspar_line-sign = 'I'.
            rspar_line-option = 'EQ'.
            rspar_line-low = ls_auswertung-nullavis.
            APPEND rspar_line TO rspar_tab.

            SUBMIT rinv_monitoring
              USING SELECTION-SCREEN '1000'
              WITH SELECTION-TABLE rspar_tab
              AND RETURN.

*            SUBMIT rinv_monitoring
*             WITH se_docnr-low = ls_auswertung-nullavis AND RETURN.
*  <-- Nus 10.2018
          ENDIF.
* --> Nuss 10.2018-2
        ELSEIF i_selfield-fieldname = 'ENDAVIS'.
          IF NOT ls_auswertung-endavis IS INITIAL.

**     --> Nuss 10.2018
            rspar_line-selname = 'P_INVTP'.
            rspar_line-kind = 'P'.
            rspar_line-sign = 'I'.
            rspar_line-option = 'EQ'.
            CLEAR rspar_line-low.
            APPEND rspar_line TO rspar_tab.

            CLEAR rspar_line.
            rspar_line-selname = 'SE_DOCNR'.
            rspar_line-kind = 'S'.
            rspar_line-sign = 'I'.
            rspar_line-option = 'EQ'.
            rspar_line-low = ls_auswertung-endavis.
            APPEND rspar_line TO rspar_tab.

            SUBMIT rinv_monitoring
              USING SELECTION-SCREEN '1000'
              WITH SELECTION-TABLE rspar_tab
              AND RETURN.

          ENDIF.
*  <-- Nuss 10.2018-2

* --> Nuss 11.2018
        ELSEIF i_selfield-fieldname = 'UEBAVIS'.
          IF NOT ls_auswertung-uebavis IS INITIAL.

**     --> Nuss 10.2018
            rspar_line-selname = 'P_INVTP'.
            rspar_line-kind = 'P'.
            rspar_line-sign = 'I'.
            rspar_line-option = 'EQ'.
            CLEAR rspar_line-low.
            APPEND rspar_line TO rspar_tab.

            CLEAR rspar_line.
            rspar_line-selname = 'SE_DOCNR'.
            rspar_line-kind = 'S'.
            rspar_line-sign = 'I'.
            rspar_line-option = 'EQ'.
            rspar_line-low = ls_auswertung-uebavis.
            APPEND rspar_line TO rspar_tab.

            SUBMIT rinv_monitoring
              USING SELECTION-SCREEN '1000'
              WITH SELECTION-TABLE rspar_tab
              AND RETURN.

          ENDIF.
* <-- Nuss 11.2018

* <-- Nuss 07.2018
        ENDIF.
    ENDCASE.

  ENDIF.                                                            "nuss 07.2018
ENDFORM.                    "USER_COMMAND

** --> Nuss 10.2018
**&---------------------------------------------------------------------*
**&      Form  EPLOT_BUCHUNGEN
**&---------------------------------------------------------------------*
*
*FORM eplot_buchungen .
*  SELECT opbel opupk bukrs vkont tvorg budat betrw
*    FROM  dfkkop
*    INTO CORRESPONDING FIELDS OF TABLE lt_eplot
*    WHERE augst NE '9'
*    AND   vkont IN so_vkont
*    AND   hvorg = '4000'
*    AND   tvorg = '0070'.
*
*  LOOP AT lt_eplot INTO ls_eplot
*    WHERE tvorg = '0070'.
*    ls_eplot-betrw = ls_eplot-betrw * -1.
*    SELECT opbel opupk bukrs vkont tvorg budat betrw
*      FROM dfkkop
*      INTO ls_eplot
*      WHERE opbel = ls_eplot
*      AND   augst NE '9'
*      AND   hvorg = '4000'
*      AND   tvorg = '0080'
*      AND   betrw = ls_eplot-betrw.
*    ENDSELECT.
*    IF sy-subrc = 0.
*      APPEND ls_eplot TO lt_eplot.
*    ELSE.
*      DELETE lt_eplot INDEX sy-tabix.
*    ENDIF.
*  ENDLOOP.
*  CLEAR:  ls_eplot,
*          ls_auswertung.
*  IF NOT lt_eplot[] IS INITIAL.
*    LOOP AT lt_eplot INTO ls_eplot
*      WHERE tvorg = '0070'.
*      CLEAR ls_auswertung.
*      ls_auswertung-einzbel       = 'EPLOT'.
*      ls_auswertung-bukrs         = ls_eplot-bukrs.
*      ls_auswertung-a_vkont       = ls_eplot-vkont.
*      ls_auswertung-aggropbel     = ls_eplot-opbel.
*      ls_auswertung-aggropupk     = ls_eplot-opupk.
*      ls_auswertung-betrw         = ls_eplot-betrw.
*      ls_auswertung-budat         = ls_eplot-budat.
*      ls_auswertung-kennz         = 'A'.
*      ls_auswertung-streinzbel    = 'EPLOT'.
*      READ TABLE lt_eplot WITH KEY opbel = ls_eplot-opbel tvorg = '0080'
*        INTO ls_eplot.
*      ls_auswertung-straggrbel    = ls_eplot-opbel.
*      ls_auswertung-straggrbelop  = ls_eplot-opupk.
*      APPEND ls_auswertung TO lt_auswertung.
*    ENDLOOP.
*  ENDIF.
*
*ENDFORM.                    " EPLOT_BUCHUNGEN
* <-- Nuss 10.2018

*-----------------------------------------------------------------------
*    FORM PF_STATUS_SET
*-----------------------------------------------------------------------
*    ........
*-----------------------------------------------------------------------
*    --> extab
*-----------------------------------------------------------------------
FORM status_standard  USING extab TYPE slis_t_extab.

  SET PF-STATUS 'STATUS_STANDARD' EXCLUDING extab.


ENDFORM.                    "status_standard
*&---------------------------------------------------------------------*
*&      Form  NULLSUMMENAVIS_MEMI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM nullsummenavis_memi .

*  DATA: ls_head  TYPE tinv_inv_head,
*        ls_linea TYPE tinv_inv_line_a,
*        lt_linea TYPE STANDARD TABLE OF tinv_inv_line_a,
*        ls_doc   TYPE tinv_inv_doc.

  DATA: lv_sum   TYPE betrw_kk.

  DATA: ls_memi TYPE /idxmm/memidoc.

  DATA: ls_ext_invoice_no TYPE inv_ext_invoice_no. "Nuss 08.2018

  CLEAR: gs_head, gs_doc, gs_linea, gt_linea.

* HEADER
  gs_head-invoice_type = '007'.                       "Zahlunsavis für Memi
  gs_head-inbound_type = '02'.                        "manuelle Eingabe
  gs_head-date_of_receipt = sy-datum.
  gs_head-invoice_status = '01'.                      "Neu
  gs_head-receiver_type = '01'.
  gs_head-int_receiver = ls_auswertung-senid.
  gs_head-sender_type = '01'.
  gs_head-int_sender = ls_auswertung-recid.
  gs_head-nr_of_docs = '1'.

  SELECT SINGLE externalid FROM eservprov INTO gs_head-ext_sender
    WHERE serviceid = gs_head-int_sender.

  SELECT SINGLE externalid FROM eservprov INTO gs_head-ext_receiver
      WHERE serviceid = gs_head-int_receiver.

  gs_head-created_by = sy-uname.
  gs_head-created_on = sy-datum.

* --> Nuss 08.2018
  PERFORM fill_ext_number CHANGING ls_ext_invoice_no.
* <-- Nuss 08.2018


* AVISZEILEN
  CLEAR: ls_memi, gs_linea.
* Erste Zeile
  SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memi
    WHERE doc_id = ls_auswertung-einzbel.

  CHECK ls_memi-crossrefno = ls_auswertung-crossrefno.

  gs_linea-int_inv_line_no = '1'.
  gs_linea-betrw = ls_memi-gross_amount.
  gs_linea-betrw_req = ls_memi-gross_amount.
  gs_linea-currency = ls_memi-currency.
  gs_linea-ext_line_no = '1'.
  gs_linea-line_type = '6'.
  gs_linea-transf_relevant = 'X'.
  gs_linea-own_invoice_no = ls_auswertung-crossrefno.
  gs_linea-ext_invoice_no = ls_ext_invoice_no.                "Nuss 08.2018
  APPEND gs_linea TO gt_linea.

* Zweite Zeile
  CLEAR: ls_memi, gs_linea.
  SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memi
    WHERE doc_id = ls_auswertung-streinzbel.

  CHECK ls_memi-crossrefno = ls_auswertung-crn_rev.

  gs_linea-int_inv_line_no = '2'.
  gs_linea-betrw = ls_memi-gross_amount.
  gs_linea-betrw_req = ls_memi-gross_amount.
  gs_linea-currency = ls_memi-currency.
  gs_linea-ext_line_no = '2'.
  gs_linea-line_type = '6'.
  gs_linea-transf_relevant = 'X'.
  gs_linea-own_invoice_no = ls_auswertung-crn_rev.
  gs_linea-ext_invoice_no = ls_ext_invoice_no.                "Nuss 08.2018
  APPEND gs_linea TO gt_linea.

* Summenzeile.
  CLEAR: lv_sum.
  LOOP AT gt_linea INTO gs_linea.
    lv_sum = lv_sum + gs_linea-betrw.
  ENDLOOP.

* Die Summenzeile wird nicht benötigt, aber die Summe
*  CLEAR gs_linea.
*  gs_linea-int_inv_line_no = '3'.
*  gs_linea-betrw = lv_sum.
*  gs_linea-betrw_req = lv_sum.
*  gs_linea-currency = ls_memi-currency.
*  gs_linea-ext_line_no = '3'.
*  gs_linea-line_type = '7'.
*  APPEND gs_linea TO gt_linea.

* DOC
  CLEAR gs_doc.
  gs_doc-doc_nr = '1'.
  gs_doc-invoice_date = sy-datum.
  gs_doc-doc_type = '012'.
  SELECT SINGLE currency FROM /idxmm/memidoc INTO gs_doc-currency
    WHERE doc_id = ls_auswertung-einzbel.
  gs_doc-inv_doc_status = '01'.
  gs_doc-invoice_type = '007'.
  gs_doc-/idexge/memi_enable = 'X'.
  gs_doc-ext_invoice_no = ls_ext_invoice_no.                "Nuss 08.2018

  gs_doc-created_by = sy-uname.
  gs_doc-created_on = sy-datum.

  gs_doc-/idexge/orig_amount2 = lv_sum.

* DOCPROC
  CLEAR gs_proc.
  gs_proc-process_type = '01'.
  gs_proc-status = '01'.
  gs_proc-process_run_no = '1'.


  PERFORM update.


ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update .

  DATA: ls_number_head TYPE inv_int_inv_no,
        ls_number_doc  TYPE inv_int_inv_doc_no.


  CLEAR: ls_number_head, ls_number_doc.

* Nummer für den HEADER
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'INV_INVNO'
    IMPORTING
      number                  = ls_number_head
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
    EXIT.
  ENDIF.

* Nummer für DOC
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'INV_DOCNO'
    IMPORTING
      number                  = ls_number_doc
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.

  IF sy-subrc <> 0.
* Implement suitable error handling here
    EXIT.
  ENDIF.



* Header-Nummer in die TINV_INV_HEAD einfügen
  gs_head-int_inv_no = ls_number_head.

* DOC um Nummer für DOC und HEADER ergänzen
  gs_doc-int_inv_doc_no = ls_number_doc.
  gs_doc-int_inv_no = ls_number_head.


* In der LINEA die DOC-Nummer eintragen.
  LOOP AT gt_linea INTO gs_linea.
    gs_linea-int_inv_doc_no = ls_number_doc.
    MODIFY gt_linea FROM gs_linea TRANSPORTING int_inv_doc_no.
  ENDLOOP.

* in DOCPROC Aufbau noch die Nummer für DOC eintragen
  gs_proc-int_inv_doc_no = ls_number_doc.

* Aufbau von HEADER
  INSERT tinv_inv_head FROM gs_head.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  CALL FUNCTION 'INV_BW_INVHEAD_DELTA_WRITE'
    EXPORTING
      x_upd_mode = 'I'
      x_inv_head = gs_head.

* Aufbau von DOC
  INSERT tinv_inv_doc FROM gs_doc.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  CALL FUNCTION 'INV_BW_INVDOC_DELTA_WRITE'
    EXPORTING
      x_upd_mode = 'I'
      x_inv_doc  = gs_doc.

    SORT gt_linea BY int_inv_doc_no int_inv_line_no.

  DATA lt_linea LIKE gt_linea.
  DATA ls_prev LIKE LINE OF gt_linea.
  LOOP AT gt_linea INTO DATA(ls_linea).
    IF ls_prev IS INITIAL.
      ls_prev = ls_linea.
    ELSEIF ls_prev-int_inv_doc_no EQ ls_linea-int_inv_doc_no
    AND    ls_prev-int_inv_line_no EQ ls_linea-int_inv_line_no.
      ls_prev-betrw = ls_prev-betrw + ls_linea-betrw.
      ls_prev-betrw_req = ls_prev-betrw_req + ls_linea-betrw_req.
    ELSE.
      APPEND ls_prev TO lt_linea.
      ls_prev = ls_linea.
    ENDIF.
    AT LAST.
      APPEND ls_prev TO lt_linea.
    ENDAT.
  ENDLOOP.

* Aufbau LINE_A
  INSERT tinv_inv_line_a FROM TABLE lt_linea.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  CALL FUNCTION 'INV_BW_INVLINA_DELTA_WRITE'
    EXPORTING
      xt_inv_line_a_insert = lt_linea.

* Aufbau DOCPROC
  INSERT tinv_inv_docproc FROM gs_proc.



  ls_auswertung-nullavis = ls_number_doc.
  gv_helpavis = ls_number_doc.   "Nuss 10.2018-2

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  NULLSUMMENAVIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM nullsummenavis .

  DATA: lv_sum   TYPE betrw_kk.

  DATA: ls_ecrossrefno  TYPE ecrossrefno,
        ls_ecrossrefno2 TYPE ecrossrefno,
        ls_dfkkthi      TYPE dfkkthi,
        lt_dfkkthi      TYPE TABLE OF dfkkthi,
        lv_waehrung     TYPE blwae_kk.                    "Nuss 10.2018-3

  DATA: ls_ext_invoice_no TYPE inv_ext_invoice_no. "Nuss 08.2018

  CLEAR: gs_head, gs_doc, gs_linea, gt_linea.


* HEADER
  gs_head-invoice_type = '002'.                       "Zahlunsavis
  gs_head-inbound_type = '02'.                        "manuelle Eingabe
  gs_head-date_of_receipt = sy-datum.
  gs_head-invoice_status = '01'.                      "Neu
  gs_head-receiver_type = '01'.
  gs_head-int_receiver = ls_auswertung-senid.
  gs_head-sender_type = '01'.
  gs_head-int_sender = ls_auswertung-recid.
  gs_head-nr_of_docs = '1'.

  SELECT SINGLE externalid FROM eservprov INTO gs_head-ext_sender
    WHERE serviceid = gs_head-int_sender.

  SELECT SINGLE externalid FROM eservprov INTO gs_head-ext_receiver
      WHERE serviceid = gs_head-int_receiver.

  gs_head-created_by = sy-uname.
  gs_head-created_on = sy-datum.

* --> Nuss 08.2018
  PERFORM fill_ext_number CHANGING ls_ext_invoice_no.
* <-- Nuss 08.2018

* AVIS-Zeilen
  CLEAR gs_linea.
  CLEAR ls_ecrossrefno.
* ECROSSREFNO zur CROSSREFNO lesen
  SELECT * FROM ecrossrefno INTO ls_ecrossrefno
    WHERE crossrefno = ls_auswertung-crossrefno.
    EXIT.
  ENDSELECT.

* ECROSSREFNO zur Storno-PRN lesen.
  CLEAR ls_ecrossrefno2.
  SELECT * FROM ecrossrefno INTO ls_ecrossrefno2
    WHERE crn_rev = ls_auswertung-crn_rev.
    EXIT.
  ENDSELECT.


* Die beiden müssen Identisch sein.
  IF ls_ecrossrefno2 = ls_ecrossrefno.
    CLEAR: lt_dfkkthi, ls_dfkkthi.
    SELECT * FROM dfkkthi INTO TABLE lt_dfkkthi
      WHERE opbel = ls_auswertung-einzbel
       AND opupk  = ls_auswertung-einzbelop
      AND crsrf  = ls_ecrossrefno-int_crossrefno.
  ELSE.
    EXIT.
  ENDIF.

  LOOP AT lt_dfkkthi INTO ls_dfkkthi.

*  --> Nuss 10.2018-3
    IF lv_waehrung IS INITIAL.
      lv_waehrung = ls_dfkkthi-waers.
    ENDIF.
*  <-- Nuss 10.2018-3

* 1 Aviszeile, das ist der Beleg, der Storniert wurde
    CLEAR: gs_linea.
    IF ls_dfkkthi-storn = 'X'
      AND ls_dfkkthi-stidc = ''.

      gs_linea-int_inv_line_no = '1'.
      gs_linea-betrw = ls_dfkkthi-betrw.
      gs_linea-betrw_req = ls_dfkkthi-betrw.
      gs_linea-currency = ls_dfkkthi-waers.
      gs_linea-ext_line_no = '1'.
      gs_linea-line_type = '6'.
      gs_linea-transf_relevant = 'X'.
      gs_linea-own_invoice_no = ls_auswertung-crossrefno.
      gs_linea-ext_invoice_no = ls_ext_invoice_no.                "Nuss 08.2018
      APPEND gs_linea TO gt_linea.
    ENDIF.

*2. Aviszeile, das ist der Stornobeleg
    CLEAR: gs_linea.
    IF ls_dfkkthi-storn = ''
      AND ls_dfkkthi-stidc = 'X'.

      gs_linea-int_inv_line_no = '2'.
      gs_linea-betrw = ls_dfkkthi-betrw.
      gs_linea-betrw_req = ls_dfkkthi-betrw.
      gs_linea-currency = ls_dfkkthi-waers.
      gs_linea-ext_line_no = '2'.
      gs_linea-line_type = '6'.
      gs_linea-transf_relevant = 'X'.
      gs_linea-own_invoice_no = ls_auswertung-crn_rev.
      gs_linea-ext_invoice_no = ls_ext_invoice_no.                "Nuss 08.2018
      APPEND gs_linea TO gt_linea.
    ENDIF.
  ENDLOOP.

* Summenzeile.
  CLEAR: lv_sum.
  LOOP AT gt_linea INTO gs_linea.
    lv_sum = lv_sum + gs_linea-betrw.
  ENDLOOP.

* Die Summenzeile wird nicht benötigt, aber die Summe
*  CLEAR gs_linea.
*  gs_linea-int_inv_line_no = '3'.
*  gs_linea-betrw = lv_sum.
*  gs_linea-betrw_req = lv_sum.
*  gs_linea-currency = ls_dfkkthi-waers.
*  gs_linea-ext_line_no = '3'.
*  gs_linea-line_type = '7'.
*  APPEND gs_linea TO gt_linea.

* DOC
  CLEAR gs_doc.
  gs_doc-doc_nr = '1'.
  gs_doc-invoice_date = sy-datum.
  gs_doc-doc_type = '004'.
* --> Nuss 10.2018-3
*  SELECT SINGLE currency FROM /idxmm/memidoc INTO gs_doc-currency
*    WHERE doc_id = ls_auswertung-einzbel.
  gs_doc-currency = lv_waehrung.
* <-- Nus 10.2013
  gs_doc-inv_doc_status = '01'.
  gs_doc-invoice_type = '002'.
  gs_doc-/idexge/memi_enable = 'X'.
  gs_doc-ext_invoice_no = ls_ext_invoice_no.                "Nuss 08.2018

  gs_doc-created_by = sy-uname.
  gs_doc-created_on = sy-datum.

  gs_doc-/idexge/orig_amount2 = lv_sum.


* DOCPROC
  CLEAR gs_proc.
  gs_proc-process_type = '01'.
  gs_proc-status = '01'.
  gs_proc-process_run_no = '1'.

  PERFORM update.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_EXT_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_EXT_INVOICE_NO  text
*----------------------------------------------------------------------*
FORM fill_ext_number  CHANGING p_ext_invoice_no.

  DATA: p_ext TYPE inv_ext_invoice_no.
  DATA: prefix   TYPE char20,
        datum    TYPE sy-datum,
        ls_extno TYPE /adesso/ext_no.


  CLEAR p_ext_invoice_no.

  prefix = 'ADESSO_NULLSUM_'.

  SELECT SINGLE * FROM /adesso/ext_no INTO ls_extno
          WHERE prefix = prefix
            AND datum = sy-datum.

* Scon ein Wert drin
  IF sy-subrc EQ 0.
    ADD 1 TO ls_extno-lfdnr.
    CONCATENATE ls_extno-prefix
                ls_extno-datum
                '_'
                ls_extno-lfdnr
                INTO p_ext.
    UPDATE /adesso/ext_no FROM ls_extno.
  ELSE.
    ls_extno-prefix = prefix.
    ls_extno-datum = sy-datum.
    ls_extno-lfdnr = '00001'.
    CONCATENATE ls_extno-prefix
              ls_extno-datum
              '_'
              ls_extno-lfdnr
              INTO p_ext.
    INSERT INTO /adesso/ext_no VALUES ls_extno.

  ENDIF.

  p_ext_invoice_no = p_ext.


ENDFORM.

** --> Nuss 10.2018
*&---------------------------------------------------------------------*
*&      Form  PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process .

  DATA: lt_return     TYPE bapirettab,
        l_proc_type   TYPE inv_process_type,
        l_error       TYPE inv_kennzx,
        lv_b_selected TYPE boolean.

  DATA: icon(4) TYPE c.

  FIELD-SYMBOLS: <it_out> TYPE STANDARD TABLE,
                 <wa_out> TYPE ty_auswertung,
                 <value>.

  ASSIGN lt_auswertung TO <it_out>.

  LOOP AT <it_out> ASSIGNING <wa_out>.


* Zeile muss markiert sein
    ASSIGN COMPONENT 'SEL' OF STRUCTURE <wa_out> TO <value>.
    CHECK <value> IS NOT INITIAL.

* Nullsummenavis muss gefüllt sein.
    ASSIGN COMPONENT 'NULLAVIS' OF STRUCTURE <wa_out> TO <value>.
    CHECK <value> IS NOT INITIAL.

* --> Nuss 10.2018-2
* Nullsummenavis muss neu sein.
    CLEAR gs_doc.
    SELECT SINGLE * FROM tinv_inv_doc INTO gs_doc
      WHERE int_inv_doc_no = <value>.
    IF gs_doc-inv_doc_status NE '01'.
      CONTINUE.
    ENDIF.
* <-- Nuss 10.2018-2

    lv_b_selected = abap_true.

    CLEAR lt_return.
    CLEAR: l_proc_type, l_error.
    CALL METHOD cl_inv_inv_remadv_doc=>process_document
      EXPORTING
        im_doc_number          = <value>
      IMPORTING
        ex_return              = lt_return[]
        ex_exit_process_type   = l_proc_type
        ex_proc_error_occurred = l_error
      EXCEPTIONS
        OTHERS                 = 1.
    .
    IF sy-subrc <> 0.
      icon = icon_led_red.
    ELSE.
      icon = icon_execute_object.
    ENDIF.

    <wa_out>-pr_state = icon.

  ENDLOOP.

  IF lv_b_selected EQ abap_false.
    MESSAGE e000(e4) WITH 'Bitte selektieren Sie einen Datensatz' 'mit einem Nullsummenavis'.
    EXIT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  NULLSUMMENAVIS_MSB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM nullsummenavis_msb .

  DATA: lv_sum   TYPE betrw_kk.

  DATA: ls_ecrossrefno  TYPE ecrossrefno,
        ls_ecrossrefno2 TYPE ecrossrefno,
        ls_dfkkthi      TYPE dfkkthi,
        lt_dfkkthi      TYPE TABLE OF dfkkthi.

  DATA: ls_ext_invoice_no TYPE inv_ext_invoice_no. "Nuss 08.2018

  CLEAR: gs_head, gs_doc, gs_linea, gt_linea.

* HEADER
  gs_head-invoice_type = '012'.                       "Zahlunsavis MSB
  gs_head-inbound_type = '02'.                        "manuelle Eingabe
  gs_head-date_of_receipt = sy-datum.
  gs_head-invoice_status = '01'.                      "Neu
  gs_head-receiver_type = '01'.
  gs_head-int_receiver = ls_auswertung-senid.
  gs_head-sender_type = '01'.
  gs_head-int_sender = ls_auswertung-recid.
  gs_head-nr_of_docs = '1'.

  SELECT SINGLE externalid FROM eservprov INTO gs_head-ext_sender
    WHERE serviceid = gs_head-int_sender.

  SELECT SINGLE externalid FROM eservprov INTO gs_head-ext_receiver
      WHERE serviceid = gs_head-int_receiver.

  gs_head-created_by = sy-uname.
  gs_head-created_on = sy-datum.

  PERFORM fill_ext_number CHANGING ls_ext_invoice_no.

* AVIS-Zeilen
  CLEAR gs_linea.
  CLEAR ls_ecrossrefno.
* ECROSSREFNO zur CROSSREFNO lesen
  SELECT * FROM ecrossrefno INTO ls_ecrossrefno
    WHERE crossrefno = ls_auswertung-crossrefno.
    EXIT.
  ENDSELECT.

* ECROSSREFNO zur Storno-PRN lesen.
  CLEAR ls_ecrossrefno2.
  SELECT * FROM ecrossrefno INTO ls_ecrossrefno2
    WHERE crn_rev = ls_auswertung-crn_rev.
    EXIT.
  ENDSELECT.

* 1.Aviszeile, das ist der Beleg, der storniert wurde
  CLEAR: ls_dfkkinvdoc_h, gs_linea.
  SELECT SINGLE * FROM dfkkinvdoc_h INTO ls_dfkkinvdoc_h
    WHERE invdocno = ls_auswertung-einzbel.

  gs_linea-int_inv_line_no = '1'.
  gs_linea-betrw = ls_dfkkinvdoc_h-total_amt.
  gs_linea-betrw_req = ls_dfkkinvdoc_h-total_amt.
  gs_linea-currency = ls_dfkkinvdoc_h-total_curr.
  gs_linea-ext_line_no = '1'.
  gs_linea-line_type = '6'.
  gs_linea-transf_relevant = 'X'.
  gs_linea-own_invoice_no = ls_auswertung-crossrefno.
  gs_linea-ext_invoice_no = ls_ext_invoice_no.
  APPEND gs_linea TO gt_linea.

* 2. Aviszeile, das ist der Stornobeleg
  CLEAR: ls_dfkkinvdoc_h, gs_linea.
  SELECT SINGLE * FROM dfkkinvdoc_h INTO ls_dfkkinvdoc_h
    WHERE invdocno = ls_auswertung-streinzbel.
  gs_linea-int_inv_line_no = '2'.
  gs_linea-betrw = ls_dfkkinvdoc_h-total_amt.
  gs_linea-betrw_req = ls_dfkkinvdoc_h-total_amt.
  gs_linea-currency = ls_dfkkinvdoc_h-total_curr.
  gs_linea-ext_line_no = '2'.
  gs_linea-line_type = '6'.
  gs_linea-transf_relevant = 'X'.
  gs_linea-own_invoice_no = ls_auswertung-crn_rev.
  gs_linea-ext_invoice_no = ls_ext_invoice_no.
  APPEND gs_linea TO gt_linea.

* Summenzeile.
  CLEAR: lv_sum.
  LOOP AT gt_linea INTO gs_linea.
    lv_sum = lv_sum + gs_linea-betrw.
  ENDLOOP.

* DOC
  CLEAR gs_doc.
  gs_doc-doc_nr = '1'.
  gs_doc-invoice_date = sy-datum.
  gs_doc-doc_type = '020'.
  SELECT SINGLE total_curr FROM dfkkinvdoc_h INTO gs_doc-currency
    WHERE invdocno = ls_auswertung-einzbel.
  gs_doc-inv_doc_status = '01'.
  gs_doc-invoice_type = '012'.
  gs_doc-/idexge/memi_enable = 'X'.
  gs_doc-ext_invoice_no = ls_ext_invoice_no.

  gs_doc-created_by = sy-uname.
  gs_doc-created_on = sy-datum.

  gs_doc-/idexge/orig_amount2 = lv_sum.

* DOCPROC
  CLEAR gs_proc.
  gs_proc-process_type = '01'.
  gs_proc-status = '01'.
  gs_proc-process_run_no = '1'.

  PERFORM update.




ENDFORM.

* --> Nuss 10.2018-2
*&---------------------------------------------------------------------*
*&      Form  AUFBAU_AUSWERTUNG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM aufbau_auswertung .

  SORT lt_auswertung BY a_vkont aggropbel.
  CLEAR: gv_aggropbel_help, gv_lfdnr.
  LOOP AT lt_auswertung INTO ls_auswertung.

* Normale NNR-Rechnungen
    IF ls_auswertung-memi IS INITIAL
       AND ls_auswertung-msb IS INITIAL.
* Anzahl der Einzelbelege zum Aggregierten Beleg
      IF ls_auswertung-aggropbel NE gv_aggropbel_help.
        SELECT COUNT(*) FROM dfkkthi INTO gv_aggranz
          WHERE bcbln = ls_auswertung-aggropbel
          AND burel = 'X'.
* Anzahl der Einzelpositionen zum storno des Aggregierten Belegs
        SELECT COUNT(*) FROM dfkkthi INTO gv_straggranz
          WHERE bcbln = ls_auswertung-straggrbel
          AND burel = 'X'.
* Gruppierungskennzeichen
        ADD 1 TO gv_lfdnr.
        CONCATENATE sy-datum '_' gv_lfdnr
           INTO gv_gruppkz..


        gv_aggropbel_help = ls_auswertung-aggropbel.

      ENDIF.
      MOVE gv_aggranz TO ls_auswertung-aggrbelanz.
      MOVE gv_straggranz TO ls_auswertung-straggrbelanz.
      MOVE gv_gruppkz TO ls_auswertung-gruppkz.


      MODIFY lt_auswertung FROM ls_auswertung
       TRANSPORTING aggrbelanz straggrbelanz gruppkz.

    ELSEIF ls_auswertung-memi = 'X'.
* Anzahl der Einzelbelege zum Aggregierten Beleg
      IF ls_auswertung-aggropbel NE gv_aggropbel_help.
        SELECT COUNT(*) FROM /idxmm/memidoc INTO gv_aggranz
          WHERE ci_fica_doc_no = ls_auswertung-aggropbel
          AND simulation = ''.
* Anzahl der Einzelpositionen zum storno des Aggregierten Belegs
        SELECT COUNT(*) FROM /idxmm/memidoc  INTO gv_straggranz
           WHERE ci_fica_doc_no = ls_auswertung-aggropbel
          AND simulation = ''.
* Gruppierungskennzeichen
        ADD 1 TO gv_lfdnr.
        CONCATENATE sy-datum '_' gv_lfdnr
           INTO gv_gruppkz.

        gv_aggropbel_help = ls_auswertung-aggropbel.

      ENDIF.
      MOVE gv_aggranz TO ls_auswertung-aggrbelanz.
      MOVE gv_straggranz TO ls_auswertung-straggrbelanz.
      MOVE gv_gruppkz TO ls_auswertung-gruppkz.

      MODIFY lt_auswertung FROM ls_auswertung
       TRANSPORTING aggrbelanz straggrbelanz gruppkz.

    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  AGGRAVIS_MEMI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM aggravis_memi USING pv_gruppkz.

  DATA: lv_sum   TYPE betrw_kk.
  DATA: ls_memi TYPE /idxmm/memidoc.
  DATA: ls_ext_invoice_no TYPE inv_ext_invoice_no.
  DATA: lv_counter TYPE inv_int_inv_line_no,
        lv_docs    TYPE i.

  CLEAR: gs_head, gs_doc, gs_linea, gt_linea.

  READ TABLE lt_auswertung INTO ls_auswertung_aggr
    WITH KEY gruppkz = pv_gruppkz.

* HEADER
  gs_head-invoice_type = '007'.                       "Zahlunsavis für Memi
  gs_head-inbound_type = '02'.                        "manuelle Eingabe
  gs_head-date_of_receipt = sy-datum.
  gs_head-invoice_status = '01'.                      "Neu
  gs_head-receiver_type = '01'.
  gs_head-int_receiver = ls_auswertung-senid.
  gs_head-sender_type = '01'.
  gs_head-int_sender = ls_auswertung-recid.

  SELECT SINGLE externalid FROM eservprov INTO gs_head-ext_sender
    WHERE serviceid = gs_head-int_sender.

  SELECT SINGLE externalid FROM eservprov INTO gs_head-ext_receiver
      WHERE serviceid = gs_head-int_receiver.

  gs_head-created_by = sy-uname.
  gs_head-created_on = sy-datum.

* Nr of DOCS wird später eingetragen
  PERFORM fill_ext_number CHANGING ls_ext_invoice_no.

* AVISZEILEN
  CLEAR: lv_docs, lv_counter.
  LOOP AT lt_auswertung INTO ls_auswertung_aggr
    WHERE gruppkz = pv_gruppkz.

    ADD 1 TO lv_docs.
    ADD 1 TO lv_counter.
*  1. Zeile
    SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memi
      WHERE doc_id = ls_auswertung_aggr-einzbel.

    CHECK ls_memi-crossrefno = ls_auswertung_aggr-crossrefno.

    gs_linea-int_inv_line_no = lv_counter.
    gs_linea-betrw = ls_memi-gross_amount.
    gs_linea-betrw_req = ls_memi-gross_amount.
    gs_linea-currency = ls_memi-currency.
    gs_linea-ext_line_no = '1'.
    gs_linea-line_type = '6'.
    gs_linea-transf_relevant = 'X'.
    gs_linea-own_invoice_no = ls_auswertung_aggr-crossrefno.
    gs_linea-ext_invoice_no = ls_ext_invoice_no.
    APPEND gs_linea TO gt_linea.

    ADD 1 TO lv_counter.

* Zweite Zeile
    CLEAR: ls_memi, gs_linea.
    SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memi
      WHERE doc_id = ls_auswertung_aggr-streinzbel.

    CHECK ls_memi-crossrefno = ls_auswertung_aggr-crn_rev.

    gs_linea-int_inv_line_no = lv_counter.
    gs_linea-betrw = ls_memi-gross_amount.
    gs_linea-betrw_req = ls_memi-gross_amount.
    gs_linea-currency = ls_memi-currency.
    gs_linea-ext_line_no = '2'.
    gs_linea-line_type = '6'.
    gs_linea-transf_relevant = 'X'.
    gs_linea-own_invoice_no = ls_auswertung_aggr-crn_rev.
    gs_linea-ext_invoice_no = ls_ext_invoice_no.
    APPEND gs_linea TO gt_linea.

  ENDLOOP.

  gs_head-nr_of_docs = lv_docs.

* Summenzeile.
  CLEAR: lv_sum.
  LOOP AT gt_linea INTO gs_linea.
    lv_sum = lv_sum + gs_linea-betrw.
  ENDLOOP.


* DOC
  CLEAR gs_doc.
  gs_doc-doc_nr = '1'.
  gs_doc-invoice_date = sy-datum.
  gs_doc-doc_type = '012'.
  SELECT SINGLE currency FROM /idxmm/memidoc INTO gs_doc-currency
*    WHERE doc_id = ls_auswertung-einzbel.                            "Nuss 10.2018-3
    WHERE doc_id = ls_auswertung_aggr-einzbel.                        "Nuss 10.2018-3
  gs_doc-inv_doc_status = '01'.
  gs_doc-invoice_type = '007'.
  gs_doc-/idexge/memi_enable = 'X'.
  gs_doc-ext_invoice_no = ls_ext_invoice_no.                "Nuss 08.2018

  gs_doc-created_by = sy-uname.
  gs_doc-created_on = sy-datum.

  gs_doc-/idexge/orig_amount2 = lv_sum.

* DOCPROC
  CLEAR gs_proc.
  gs_proc-process_type = '01'.
  gs_proc-status = '01'.
  gs_proc-process_run_no = '1'.

  CLEAR gv_helpavis.
  PERFORM update.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ENDAVIS_MEMI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_AUSWERTUNG_MEMI  text
*      <--P_GV_CHANGED  text
*----------------------------------------------------------------------*
FORM endavis_memi_vor  CHANGING p_auswertung_memi TYPE ty_auswertung_memi
                            p_changed.

  DATA: ls_doc  TYPE tinv_inv_doc,
        ls_head TYPE tinv_inv_head.

* Lesen des Avises zur TINV_INV_LINE_A
  CLEAR ls_doc.
  SELECT SINGLE * FROM tinv_inv_doc
     INTO ls_doc
     WHERE int_inv_doc_no = ls_tinv_inv_line_a-int_inv_doc_no.

* Belegstatus muss auf "Beendet" stehen und es
* muss ein Zahlungsavis sein (Summe Null)
  CHECK ls_doc-inv_doc_status = '08'.
  CHECK ls_doc-invoice_type = '007'.
  CHECK ls_doc-/idexge/orig_amount2 = 0.

* Den HEADER prüfen, muss auf "Abgeschlossen" stehen
  CLEAR ls_head.
  SELECT SINGLE * FROM tinv_inv_head
    INTO ls_head
    WHERE int_inv_no = ls_doc-int_inv_no.

  CHECK ls_head-invoice_status = '03'.

* Weiterverarbeitung
  SELECT SINGLE a~opbel a~opupk INTO (lv_straggrbel, lv_straggrbelop)
     FROM dfkkop AS a INNER JOIN /idxmm/memidoc AS b
        ON b~ci_fica_doc_no = a~opbel
          WHERE b~doc_id = p_auswertung_memi-streinzbel.

  IF NOT sy-subrc = 0.
    CLEAR p_changed.
    EXIT.
  ENDIF.

**      Das Buchungsdatum bei den voraussichtlichen Nullsummen ist das
**      Erfassungsdatum des Stornobeleges
  SELECT cpudt
    FROM dfkkko
    INTO p_auswertung_memi-budat
    WHERE opbel = lv_straggrbel
    AND   cpudt IN so_cpuds.
  ENDSELECT.

  IF NOT p_auswertung_memi-budat IN so_cpuds.
    CLEAR p_changed.
    EXIT.
  ELSE.

    p_auswertung_memi-memi = 'X'.
    p_auswertung_memi-kennz = 'V'.
    p_auswertung_memi-straggrbel = lv_straggrbel.
    p_auswertung_memi-straggrbelop = lv_straggrbelop.
    p_auswertung_memi-endavis = ls_doc-int_inv_doc_no.

    p_changed = 'X'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ENDAVIS_MEMI_EIND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_AUSWERTUNG_MEMI  text
*      <--P_GV_CHANGED  text
*----------------------------------------------------------------------*
FORM endavis_memi_eind  CHANGING p_auswertung_memi TYPE ty_auswertung_memi
                                 p_changed.

  DATA: ls_doc  TYPE tinv_inv_doc,
        ls_head TYPE tinv_inv_head.

* Lesen des Avises zur TINV_INV_LINE_A2
  CLEAR ls_doc.
  SELECT SINGLE * FROM tinv_inv_doc
     INTO ls_doc
     WHERE int_inv_doc_no = ls_tinv_inv_line_a2-int_inv_doc_no.

* Belegstatus muss auf "Beendet" stehen
  CHECK ls_doc-inv_doc_status = '08'.
  CHECK ls_doc-invoice_type = '007'.
  CHECK ls_doc-/idexge/orig_amount2 = 0.

* Den HEADER prüfen, muss auf "Abgeschlossen" stehen
  CLEAR ls_head.
  SELECT SINGLE * FROM tinv_inv_head
    INTO ls_head
    WHERE int_inv_no = ls_doc-int_inv_no.

  CHECK ls_head-invoice_status = '03'.

* Weiterverarbeitung
  SELECT SINGLE a~opbel a~opupk INTO (lv_straggrbel, lv_straggrbelop)
     FROM dfkkop AS a INNER JOIN /idxmm/memidoc AS b
        ON b~ci_fica_doc_no = a~opbel
          WHERE b~doc_id = p_auswertung_memi-streinzbel.

  IF NOT sy-subrc = 0.
    CLEAR p_changed.
    EXIT.
  ELSE.
    p_auswertung_memi-memi = 'X'.
    p_auswertung_memi-kennz = 'E'.
    p_auswertung_memi-straggrbel = lv_straggrbel.
    p_auswertung_memi-straggrbelop = lv_straggrbelop.
    p_auswertung_memi-endavis = ls_doc-int_inv_doc_no.

    p_changed = 'X'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ENDAVIS_NNR_EIND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_AUSWERTUNG  text
*      <--P_GV_CHANGED  text
*----------------------------------------------------------------------*
FORM endavis_nnr_eind  CHANGING p_auswertung TYPE ty_auswertung
                                p_changed.

  DATA: ls_doc  TYPE tinv_inv_doc,
        ls_head TYPE tinv_inv_head.

* Lesen des Avises zur TINV_INV_LINE_A2
  CLEAR ls_doc.
  SELECT SINGLE * FROM tinv_inv_doc
     INTO ls_doc
     WHERE int_inv_doc_no = ls_tinv_inv_line_a2-int_inv_doc_no.

* Belegstatus muss auf "Beendet" stehen
  CHECK ls_doc-inv_doc_status = '08'.
  CHECK ls_doc-invoice_type = '002'.
  CHECK ls_doc-/idexge/orig_amount2 = 0.

* Den HEADER prüfen, muss auf "Abgeschlossen" stehen
  CLEAR ls_head.
  SELECT SINGLE * FROM tinv_inv_head
    INTO ls_head
    WHERE int_inv_no = ls_doc-int_inv_no.

  CHECK ls_head-invoice_status = '03'.

  SELECT SINGLE a~opbel a~opupk b~opbel b~opupk
    INTO (lv_streinzbel, lv_streinzbelop, lv_straggrbel, lv_straggrbelop)
    FROM dfkkthi AS a INNER JOIN dfkkop AS b
    ON b~opbel = a~bcbln
    WHERE crsrf = p_auswertung-int_crossrefno
    AND a~stidc = 'X'
    AND b~augst = ' '
    AND b~pymet = ' '.

  IF NOT sy-subrc = 0.
    CLEAR p_changed.
    EXIT.
  ENDIF.

**   Der Storno zum Einzelbeleg steht in der Tabelle DFKKKO
  SELECT SINGLE storb FROM dfkkko INTO lv_stornobeleg
      WHERE opbel = p_auswertung-einzbel.

  IF sy-subrc = 0.
    p_auswertung-streinzbel = lv_stornobeleg.
    p_auswertung-streinzbelop = lv_streinzbelop.
    p_auswertung-straggrbel = lv_straggrbel.
    p_auswertung-straggrbelop = lv_straggrbelop.
    p_auswertung-kennz = 'E'.
    p_auswertung-endavis = ls_doc-int_inv_doc_no.

    p_changed = 'X'.
  ELSE.
    CLEAR p_changed.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ENDAVIS_NNR_VOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_AUSWERTUNG  text
*      <--P_GV_CHANGED  text
*----------------------------------------------------------------------*
FORM endavis_nnr_vor  CHANGING p_auswertung TYPE ty_auswertung
                               p_changed.

  DATA: ls_doc  TYPE tinv_inv_doc,
        ls_head TYPE tinv_inv_head.

* Lesen des Avises zur TINV_INV_LINE_A
  CLEAR ls_doc.
  SELECT SINGLE * FROM tinv_inv_doc
     INTO ls_doc
     WHERE int_inv_doc_no = ls_tinv_inv_line_a-int_inv_doc_no.

* Belegstatus muss auf "Beendet" stehen und es
* muss ein Zahlungsavis sein (Summe Null)
  CHECK ls_doc-inv_doc_status = '08'.
  CHECK ls_doc-invoice_type = '002'.
  CHECK ls_doc-/idexge/orig_amount2 = 0.

* Den HEADER prüfen, muss auf "Abgeschlossen" stehen
  CLEAR ls_head.
  SELECT SINGLE * FROM tinv_inv_head
    INTO ls_head
    WHERE int_inv_no = ls_doc-int_inv_no.

  CHECK ls_head-invoice_status = '03'.

* Weiterverabeitung
  SELECT SINGLE a~opbel a~opupk b~opbel b~opupk
  INTO (lv_streinzbel, lv_streinzbelop, lv_straggrbel, lv_straggrbelop)
  FROM dfkkthi AS a INNER JOIN dfkkop AS b
  ON b~opbel = a~bcbln
  WHERE a~crsrf = p_auswertung-int_crossrefno
  AND a~stidc = 'X'
  AND b~augst = ' '
  AND b~pymet = ' '.

  IF NOT sy-subrc = 0.
    CLEAR p_changed.
    EXIT.
  ENDIF.

**      Das Buchungsdatum bei den voraussichtlichen Nullsummen ist das
**      Erfassungsdatum des Stornobeleges
  SELECT cpudt
    FROM dfkkko
    INTO p_auswertung-budat
    WHERE opbel = lv_straggrbel
    AND   cpudt IN so_cpuds.
  ENDSELECT.

  IF NOT p_auswertung-budat IN so_cpuds.
    CLEAR p_changed.
    EXIT.
  ELSE.

**   Der Storno zum Einzelbeleg steht in der Tabelle DFKKKO
    SELECT SINGLE storb FROM dfkkko INTO lv_stornobeleg
        WHERE opbel = ls_auswertung-einzbel.

    CHECK sy-subrc = 0.

    p_auswertung-kennz = 'V'.
    p_auswertung-streinzbel = lv_stornobeleg.
    p_auswertung-streinzbelop = lv_streinzbelop.
    p_auswertung-straggrbel = lv_straggrbel.
    p_auswertung-straggrbelop = lv_straggrbelop.
    p_auswertung-endavis = ls_doc-int_inv_doc_no.

    p_changed = 'X'.

  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AGGRAVIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_GRUPPKZ  text
*----------------------------------------------------------------------*
FORM aggravis  USING    pv_gruppkz.

  DATA: lv_sum   TYPE betrw_kk.
  DATA: ls_ext_invoice_no TYPE inv_ext_invoice_no.
  DATA: lv_counter TYPE inv_int_inv_line_no,
        lv_docs    TYPE i.

  DATA: ls_ecrossrefno  TYPE ecrossrefno,
        ls_ecrossrefno2 TYPE ecrossrefno,
        ls_dfkkthi      TYPE dfkkthi,
        lt_dfkkthi      TYPE TABLE OF dfkkthi,
        lv_waehrung     TYPE blwae_kk.


  CLEAR: gs_head, gs_doc, gs_linea, gt_linea.

  READ TABLE lt_auswertung INTO ls_auswertung_aggr
    WITH KEY gruppkz = pv_gruppkz.

* HEADER
  gs_head-invoice_type = '002'.                       "Zahlunsavis
  gs_head-inbound_type = '02'.                        "manuelle Eingabe
  gs_head-date_of_receipt = sy-datum.
  gs_head-invoice_status = '01'.                      "Neu
  gs_head-receiver_type = '01'.
  gs_head-int_receiver = ls_auswertung-senid.
  gs_head-sender_type = '01'.
  gs_head-int_sender = ls_auswertung-recid.

  SELECT SINGLE externalid FROM eservprov INTO gs_head-ext_sender
    WHERE serviceid = gs_head-int_sender.

  SELECT SINGLE externalid FROM eservprov INTO gs_head-ext_receiver
      WHERE serviceid = gs_head-int_receiver.

  gs_head-created_by = sy-uname.
  gs_head-created_on = sy-datum.

* Nr of DOCS wird später eingetragen
  PERFORM fill_ext_number CHANGING ls_ext_invoice_no.

* AVISZEILEN
  CLEAR: lv_docs, lv_counter.
  LOOP AT lt_auswertung INTO ls_auswertung_aggr
    WHERE gruppkz = pv_gruppkz.

    ADD 1 TO lv_docs.
    ADD 1 TO lv_counter.

**  1. Zeile

* ECROSSREFNO zur CROSSREFNO lesen
    CLEAR ls_ecrossrefno.
    SELECT * FROM ecrossrefno INTO ls_ecrossrefno
      WHERE crossrefno = ls_auswertung_aggr-crossrefno.
      EXIT.
    ENDSELECT.

* ECROSSREFNO zur Storno-PRN lesen.
    CLEAR ls_ecrossrefno2.
    SELECT * FROM ecrossrefno INTO ls_ecrossrefno2
      WHERE crn_rev = ls_auswertung_aggr-crn_rev.
      EXIT.
    ENDSELECT.

* Die beiden müssen Identisch sein.
    IF ls_ecrossrefno2 = ls_ecrossrefno.
      CLEAR: lt_dfkkthi, ls_dfkkthi.
      SELECT * FROM dfkkthi INTO TABLE lt_dfkkthi
        WHERE opbel = ls_auswertung_aggr-einzbel
         AND opupk  = ls_auswertung_aggr-einzbelop
        AND crsrf  = ls_ecrossrefno-int_crossrefno.
    ELSE.
      EXIT.
    ENDIF.

    CLEAR lv_waehrung.
    LOOP AT lt_dfkkthi INTO ls_dfkkthi.

      IF lv_waehrung IS INITIAL.
        lv_waehrung = ls_dfkkthi-waers.
      ENDIF.

* 1 Aviszeile, das ist der Beleg, der Storniert wurde
      CLEAR: gs_linea.
      IF ls_dfkkthi-storn = 'X'
        AND ls_dfkkthi-stidc = ''.

        gs_linea-int_inv_line_no = lv_counter.
        gs_linea-betrw = ls_dfkkthi-betrw.
        gs_linea-betrw_req = ls_dfkkthi-betrw.
        gs_linea-currency = ls_dfkkthi-waers.
        gs_linea-ext_line_no = '1'.
        gs_linea-line_type = '6'.
        gs_linea-transf_relevant = 'X'.
        gs_linea-own_invoice_no = ls_auswertung_aggr-crossrefno.
        gs_linea-ext_invoice_no = ls_ext_invoice_no.                "Nuss 08.2018
        APPEND gs_linea TO gt_linea.
      ENDIF.

*2. Aviszeile, das ist der Stornobeleg
      ADD 1 TO lv_counter.
      CLEAR: gs_linea.
      IF ls_dfkkthi-storn = ''
        AND ls_dfkkthi-stidc = 'X'.

        gs_linea-int_inv_line_no = lv_counter.
        gs_linea-betrw = ls_dfkkthi-betrw.
        gs_linea-betrw_req = ls_dfkkthi-betrw.
        gs_linea-currency = ls_dfkkthi-waers.
        gs_linea-ext_line_no = '2'.
        gs_linea-line_type = '6'.
        gs_linea-transf_relevant = 'X'.
        gs_linea-own_invoice_no = ls_auswertung_aggr-crn_rev.
        gs_linea-ext_invoice_no = ls_ext_invoice_no.                "Nuss 08.2018
        APPEND gs_linea TO gt_linea.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

  gs_head-nr_of_docs = lv_docs.

* Summenzeile.
  CLEAR: lv_sum.
  LOOP AT gt_linea INTO gs_linea.
    lv_sum = lv_sum + gs_linea-betrw.
  ENDLOOP.

* DOC
  CLEAR gs_doc.
  gs_doc-doc_nr = '1'.
  gs_doc-invoice_date = sy-datum.
  gs_doc-doc_type = '004'.
  gs_doc-currency = lv_waehrung.
  gs_doc-inv_doc_status = '01'.
  gs_doc-invoice_type = '002'.
  gs_doc-/idexge/memi_enable = 'X'.
  gs_doc-ext_invoice_no = ls_ext_invoice_no.                "Nuss 08.2018

  gs_doc-created_by = sy-uname.
  gs_doc-created_on = sy-datum.

  gs_doc-/idexge/orig_amount2 = lv_sum.

* DOCPROC
  CLEAR gs_proc.
  gs_proc-process_type = '01'.
  gs_proc-status = '01'.
  gs_proc-process_run_no = '1'.

  CLEAR gv_helpavis.

  PERFORM update.

ENDFORM.

** --> Nuss 11.2018
*&---------------------------------------------------------------------*
*&      Form  MEMI_UEBERF_EIND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_AUSWERTUNG_MEMI  text
*      <--P_CHANGED  text
*----------------------------------------------------------------------*
FORM memi_ueberf_eind  CHANGING p_auswertung_memi TYPE ty_auswertung_memi
                                p_changed.

  DATA: ls_doc    TYPE tinv_inv_doc,
        ls_docref TYPE tinv_inv_docref,
        ls_dfkkko TYPE dfkkko,
        lv_augbl  TYPE augbl_kk.

* Lesen des Avises zur TINV_INV_LINE_A2
  CLEAR ls_doc.
  SELECT SINGLE * FROM tinv_inv_doc
     INTO ls_doc
     WHERE int_inv_doc_no = ls_tinv_inv_line_a2-int_inv_doc_no.

* Belegstatus muss auf "Überführt" stehen
  CHECK ls_doc-inv_doc_status = '13'.
  CHECK ls_doc-invoice_type = '007'.
  CHECK ls_doc-/idexge/orig_amount2 = 0.
  CHECK ls_doc-ext_invoice_no CP 'ADESSO_NULLSUM*'.


  SELECT * FROM tinv_inv_docref INTO ls_docref
    WHERE int_inv_doc_no = ls_doc-int_inv_doc_no
     AND inbound_ref_type = '90'.
    EXIT.
  ENDSELECT.

  CHECK sy-subrc = 0.
  lv_augbl = ls_docref-inbound_ref+1(12).

  CLEAR ls_dfkkko.
  SELECT SINGLE * FROM dfkkko INTO ls_dfkkko
    WHERE opbel = lv_augbl.

  CHECK ls_dfkkko-storb IS NOT INITIAL.

* Weiterverarbeitung
  SELECT SINGLE a~opbel a~opupk INTO (lv_straggrbel, lv_straggrbelop)
     FROM dfkkop AS a INNER JOIN /idxmm/memidoc AS b
        ON b~ci_fica_doc_no = a~opbel
          WHERE b~doc_id = p_auswertung_memi-streinzbel.

  IF sy-subrc = 0.
    p_auswertung_memi-memi = 'X'.
    p_auswertung_memi-kennz = 'E'.
    p_auswertung_memi-straggrbel = lv_straggrbel.
    p_auswertung_memi-straggrbelop = lv_straggrbelop.
    p_auswertung_memi-uebavis = ls_doc-int_inv_doc_no.

    p_changed = 'X'.

  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MEMI_UEBERF_VOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_AUSWERTUNG_MEMI  text
*      <--P_CHANGED  text
*----------------------------------------------------------------------*
FORM memi_ueberf_vor  CHANGING p_auswertung_memi TYPE ty_auswertung_memi
                                p_changed.

  DATA: ls_doc    TYPE tinv_inv_doc,
        ls_docref TYPE tinv_inv_docref,
        ls_dfkkko TYPE dfkkko,
        lv_augbl  TYPE augbl_kk.

* Lesen des Avises zur TINV_INV_LINE_A
  CLEAR ls_doc.
  SELECT SINGLE * FROM tinv_inv_doc
     INTO ls_doc
     WHERE int_inv_doc_no = ls_tinv_inv_line_a-int_inv_doc_no.

* Belegstatus muss auf "Überführt" stehen und es
* muss ein Zahlungsavis sein (Summe Null)
  CHECK ls_doc-inv_doc_status = '13'.
  CHECK ls_doc-invoice_type = '007'.
  CHECK ls_doc-/idexge/orig_amount2 = 0.
  CHECK ls_doc-ext_invoice_no CP 'ADESSO_NULLSUM*'.

  SELECT * FROM tinv_inv_docref INTO ls_docref
    WHERE int_inv_doc_no = ls_doc-int_inv_doc_no
     AND inbound_ref_type = '90'.
    EXIT.
  ENDSELECT.

  CHECK sy-subrc = 0.
  lv_augbl = ls_docref-inbound_ref+1(12).

  CLEAR ls_dfkkko.
  SELECT SINGLE * FROM dfkkko INTO ls_dfkkko
    WHERE opbel = lv_augbl.

  CHECK ls_dfkkko-storb IS NOT INITIAL.

* Weiterverarbeitung
  SELECT SINGLE a~opbel a~opupk INTO (lv_straggrbel, lv_straggrbelop)
     FROM dfkkop AS a INNER JOIN /idxmm/memidoc AS b
        ON b~ci_fica_doc_no = a~opbel
          WHERE b~doc_id = p_auswertung_memi-streinzbel.

  IF NOT sy-subrc = 0.
    CLEAR p_changed.
    EXIT.
  ENDIF.

**      Das Buchungsdatum bei den voraussichtlichen Nullsummen ist das
**      Erfassungsdatum des Stornobeleges
  SELECT cpudt
    FROM dfkkko
    INTO p_auswertung_memi-budat
    WHERE opbel = lv_straggrbel
    AND   cpudt IN so_cpuds.
  ENDSELECT.

  IF NOT p_auswertung_memi-budat IN so_cpuds.
    CLEAR p_changed.
    EXIT.
  ELSE.
    p_auswertung_memi-memi = 'X'.
    p_auswertung_memi-kennz = 'V'.
    p_auswertung_memi-straggrbel = lv_straggrbel.
    p_auswertung_memi-straggrbelop = lv_straggrbelop.
    p_auswertung_memi-uebavis = ls_doc-int_inv_doc_no.

    p_changed = 'X'.
  ENDIF.



ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  NNR_UEBERF_EIND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_AUSWERTUNG_MEMI  text
*      <--P_GV_CHANGED  text
*----------------------------------------------------------------------*
FORM nnr_ueberf_eind  CHANGING p_auswertung TYPE ty_auswertung
                                p_changed.

  DATA: ls_doc    TYPE tinv_inv_doc,
        ls_docref TYPE tinv_inv_docref,
        ls_dfkkko TYPE dfkkko,
        lv_augbl  TYPE augbl_kk.


* Lesen des Avises zur TINV_INV_LINE_A2
  CLEAR ls_doc.
  SELECT SINGLE * FROM tinv_inv_doc
     INTO ls_doc
     WHERE int_inv_doc_no = ls_tinv_inv_line_a2-int_inv_doc_no.

* Belegstatus muss auf "Übeführt" stehen
  CHECK ls_doc-inv_doc_status = '13'.
  CHECK ls_doc-invoice_type = '002'.
  CHECK ls_doc-/idexge/orig_amount2 = 0.
  CHECK ls_doc-ext_invoice_no CP 'ADESSO_NULLSUM*'.

  SELECT * FROM tinv_inv_docref INTO ls_docref
    WHERE int_inv_doc_no = ls_doc-int_inv_doc_no
     AND inbound_ref_type = '90'.
    EXIT.
  ENDSELECT.

  CHECK sy-subrc = 0.
  lv_augbl = ls_docref-inbound_ref+1(12).

  CLEAR ls_dfkkko.
  SELECT SINGLE * FROM dfkkko INTO ls_dfkkko
    WHERE opbel = lv_augbl.

  CHECK ls_dfkkko-storb IS NOT INITIAL.

  SELECT SINGLE a~opbel a~opupk b~opbel b~opupk
    INTO (lv_streinzbel, lv_streinzbelop, lv_straggrbel, lv_straggrbelop)
    FROM dfkkthi AS a INNER JOIN dfkkop AS b
    ON b~opbel = a~bcbln
    WHERE crsrf = p_auswertung-int_crossrefno
    AND a~stidc = 'X'
    AND b~augst = ' '
    AND b~pymet = ' '.

  IF NOT sy-subrc = 0.
    CLEAR p_changed.
    EXIT.
  ENDIF.

**   Der Storno zum Einzelbeleg steht in der Tabelle DFKKKO
  SELECT SINGLE storb FROM dfkkko INTO lv_stornobeleg
      WHERE opbel = p_auswertung-einzbel.

  IF sy-subrc = 0.
    p_auswertung-streinzbel = lv_stornobeleg.
    p_auswertung-streinzbelop = lv_streinzbelop.
    p_auswertung-straggrbel = lv_straggrbel.
    p_auswertung-straggrbelop = lv_straggrbelop.
    p_auswertung-kennz = 'E'.
    p_auswertung-uebavis = ls_doc-int_inv_doc_no.

    p_changed = 'X'.
  ELSE.
    CLEAR p_changed.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  NNR_UEBERF_VOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_AUSWERTUNG  text
*      <--P_GV_CHANGED  text
*----------------------------------------------------------------------*
FORM nnr_ueberf_vor  CHANGING p_auswertung TYPE ty_auswertung
                                p_changed.

  DATA: ls_doc    TYPE tinv_inv_doc,
        ls_docref TYPE tinv_inv_docref,
        ls_dfkkko TYPE dfkkko,
        lv_augbl  TYPE augbl_kk.

* Lesen des Avises zur TINV_INV_LINE_A
  CLEAR ls_doc.
  SELECT SINGLE * FROM tinv_inv_doc
     INTO ls_doc
     WHERE int_inv_doc_no = ls_tinv_inv_line_a-int_inv_doc_no.

* Belegstatus muss auf "Übeführt" stehen
  CHECK ls_doc-inv_doc_status = '13'.
  CHECK ls_doc-invoice_type = '002'.
  CHECK ls_doc-/idexge/orig_amount2 = 0.
  CHECK ls_doc-ext_invoice_no CP 'ADESSO_NULLSUM*'.

  SELECT * FROM tinv_inv_docref INTO ls_docref
    WHERE int_inv_doc_no = ls_doc-int_inv_doc_no
     AND inbound_ref_type = '90'.
    EXIT.
  ENDSELECT.

  CHECK sy-subrc = 0.
  lv_augbl = ls_docref-inbound_ref+1(12).

  CLEAR ls_dfkkko.
  SELECT SINGLE * FROM dfkkko INTO ls_dfkkko
    WHERE opbel = lv_augbl.

  CHECK ls_dfkkko-storb IS NOT INITIAL.

* Weiterverabeitung
  SELECT SINGLE a~opbel a~opupk b~opbel b~opupk
  INTO (lv_streinzbel, lv_streinzbelop, lv_straggrbel, lv_straggrbelop)
  FROM dfkkthi AS a INNER JOIN dfkkop AS b
  ON b~opbel = a~bcbln
  WHERE a~crsrf = p_auswertung-int_crossrefno
  AND a~stidc = 'X'
  AND b~augst = ' '
  AND b~pymet = ' '.

  IF NOT sy-subrc = 0.
    CLEAR p_changed.
    EXIT.
  ENDIF.

**      Das Buchungsdatum bei den voraussichtlichen Nullsummen ist das
**      Erfassungsdatum des Stornobeleges
  SELECT cpudt
    FROM dfkkko
    INTO p_auswertung-budat
    WHERE opbel = lv_straggrbel
    AND   cpudt IN so_cpuds.
  ENDSELECT.

  IF NOT p_auswertung-budat IN so_cpuds.
    CLEAR p_changed.
    EXIT.
  ELSE.

**   Der Storno zum Einzelbeleg steht in der Tabelle DFKKKO
    SELECT SINGLE storb FROM dfkkko INTO lv_stornobeleg
        WHERE opbel = ls_auswertung-einzbel.

    CHECK sy-subrc = 0.

    p_auswertung-kennz = 'V'.
    p_auswertung-streinzbel = lv_stornobeleg.
    p_auswertung-streinzbelop = lv_streinzbelop.
    p_auswertung-straggrbel = lv_straggrbel.
    p_auswertung-straggrbelop = lv_straggrbelop.
    p_auswertung-uebavis = ls_doc-int_inv_doc_no.

    p_changed = 'X'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_NULLAVIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_AUSWERTUNG  text
*----------------------------------------------------------------------*
*# Nian 11.07.2019
*# Nullavis für lt_auswertung anlegen.
FORM create_nullavis.

  DATA: lv_gruppkz             LIKE ls_auswertung-gruppkz,
        lv_gruppkz_help        LIKE ls_auswertung-gruppkz,
        lv_memi_aggravis_count TYPE i,
        lv_nnr_aggravis_count  TYPE i,
        lv_memi_avis_count     TYPE i,
        lv_nnr_avis_count      TYPE i,
        lv_msb_avis_count      TYPE i,
        lv_count               TYPE i.

*# MSB: immer pro Zeile ein Nullavis
  LOOP AT lt_auswertung INTO ls_auswertung WHERE msb = 'X' AND nullavis IS INITIAL.

    PERFORM nullsummenavis_msb.

    MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING nullavis.

    IF ls_auswertung-nullavis IS NOT INITIAL.
      ADD 1 TO lv_msb_avis_count.
    ENDIF.

    CLEAR ls_auswertung.
  ENDLOOP.

*# MEMI und NNR
  LOOP AT lt_auswertung INTO ls_auswertung WHERE msb IS INITIAL AND nullavis IS INITIAL.

    MOVE ls_auswertung-gruppkz TO lv_gruppkz.
*# Anzahl der Belege innerhalb einer Gruppe prüfen
    CLEAR lv_count.
    LOOP AT lt_auswertung ASSIGNING FIELD-SYMBOL(<ls_auswertung>) WHERE gruppkz = lv_gruppkz.
      ADD 1 TO lv_count.
    ENDLOOP.

    IF lv_count GT 999.
*# Wenn Anzahl der Belege größer als 999 => für jede einzelne Zeile ein Nullavis anlegen.
      IF ls_auswertung_memi = 'X'.
*# MEMI
        PERFORM nullsummenavis_memi.

        MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING nullavis.

        IF ls_auswertung-nullavis IS NOT INITIAL.
          ADD 1 TO lv_memi_avis_count.
        ENDIF.

        CLEAR ls_auswertung.

      ELSE.
*# NNR
        PERFORM nullsummenavis.

        MODIFY lt_auswertung FROM ls_auswertung TRANSPORTING nullavis.

        IF ls_auswertung-nullavis IS NOT INITIAL.
          ADD 1 TO lv_nnr_avis_count.
        ENDIF.

        CLEAR ls_auswertung.

      ENDIF.

    ELSE.
*# Wenn Anzahl der Belege kleiner oder gleich 999 => ein aggr.Nullavis anlegen.
      IF lv_gruppkz NE lv_gruppkz_help.
*# MEMI
        IF ls_auswertung-memi = 'X'.

          PERFORM aggravis_memi USING lv_gruppkz.

          LOOP AT lt_auswertung INTO ls_auswertung_aggr
            WHERE gruppkz = lv_gruppkz.

            ls_auswertung_aggr-nullavis = gv_helpavis.

            MODIFY lt_auswertung FROM ls_auswertung_aggr TRANSPORTING nullavis.

          ENDLOOP.

          IF ls_auswertung_aggr-nullavis IS NOT INITIAL.
            ADD 1 TO lv_memi_aggravis_count.
          ENDIF.

*#  NNR
        ELSE.
** --> Nuss 10.2018-3

          PERFORM aggravis USING lv_gruppkz.

          LOOP AT lt_auswertung INTO ls_auswertung_aggr
            WHERE gruppkz = lv_gruppkz.

            ls_auswertung_aggr-nullavis = gv_helpavis.

            MODIFY lt_auswertung FROM ls_auswertung_aggr TRANSPORTING nullavis.

          ENDLOOP.

          IF ls_auswertung_aggr-nullavis IS NOT INITIAL.
            ADD 1 TO lv_nnr_aggravis_count.
          ENDIF.

        ENDIF.

        lv_gruppkz_help = ls_auswertung-gruppkz.

      ENDIF.

    ENDIF.

  ENDLOOP.
*# Statistik:
  IF lv_msb_avis_count IS NOT INITIAL.
    WRITE: lv_msb_avis_count, 'angelegtes Nullavis für MSB:', ls_auswertung-nullavis. WRITE:/.
  ENDIF.
  IF lv_memi_avis_count IS NOT INITIAL.
    WRITE: lv_memi_avis_count, 'angelegtes Nullavis für MEMI:', ls_auswertung-nullavis. WRITE:/.
  ENDIF.
  IF lv_nnr_avis_count IS NOT INITIAL.
    WRITE: lv_nnr_avis_count, 'angelegtes Nullavis für NNR:', ls_auswertung-nullavis. WRITE:/.
  ENDIF.
  IF lv_memi_aggravis_count IS NOT INITIAL.
    WRITE: lv_memi_aggravis_count, 'angelegtes AggrNullavis für MEMI:', ls_auswertung_aggr-nullavis. WRITE:/.
  ENDIF.
  IF lv_nnr_aggravis_count IS NOT INITIAL.
    WRITE: lv_nnr_aggravis_count, 'angelegtes AggrNullavis für NNR:', ls_auswertung_aggr-nullavis. WRITE:/.
  ENDIF.

ENDFORM.
* <-- Nian 11.07.2019
