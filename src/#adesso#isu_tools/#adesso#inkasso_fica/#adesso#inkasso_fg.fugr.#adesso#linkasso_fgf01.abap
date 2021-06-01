*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LINKASSO_FGF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_CUSTOMIZING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_customizing .

  IF gt_inkasso_cust IS INITIAL.
    SELECT * FROM /adesso/ink_cust INTO TABLE gt_inkasso_cust.
  ENDIF.

  IF gt_nfhf IS INITIAL.

    SELECT * FROM /adesso/ink_nfhf INTO TABLE gt_nfhf.

    LOOP AT gt_nfhf INTO gs_nfhf
         WHERE schlr = const_marked.

      CLEAR gs_hvorg.
      gs_hvorg-option = 'EQ'.
      gs_hvorg-sign   = 'I'.
      gs_hvorg-low    = gs_nfhf-hvorg.
      APPEND gs_hvorg TO gr_hvorg.

    ENDLOOP.

  ENDIF.

  SELECT SINGLE * FROM /adesso/inkbirth INTO gs_inkasso_birth.

  REFRESH: gt_bgus.
  REFRESH: gr_lockr.

  SELECT * FROM /adesso/ink_bgus
         INTO TABLE gt_bgus
         WHERE bname = sy-uname.

  IF gt_bgus[] IS NOT INITIAL.
    SELECT * FROM /adesso/ink_bgsb
           INTO TABLE gt_bgsb
           FOR ALL ENTRIES IN gt_bgus
           WHERE begru = gt_bgus-begru
           AND   activ = 'X'.

    LOOP AT gt_bgsb INTO gs_bgsb.
      CLEAR gs_lockr.
      gs_lockr-option = 'EQ'.
      gs_lockr-sign   = 'I'.
      gs_lockr-low    = gs_bgsb-value.
      APPEND gs_lockr TO gr_lockr.
    ENDLOOP.

  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_FIELDS_FROM_VK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_WA_OUT  text
*----------------------------------------------------------------------*
FORM get_fields_from_vk  CHANGING ls_out STRUCTURE /adesso/inkasso_out.

  DATA: ls_fkkvkp    TYPE fkkvkp,
        ls_dfkklocks TYPE dfkklocks.


* Kaufm. regionalstrukturgruppe
  SELECT SINGLE * FROM fkkvkp INTO ls_fkkvkp
    WHERE vkont = ls_out-vkont
      AND gpart = ls_out-gpart.

  MOVE ls_fkkvkp-regiogr_ca_b TO ls_out-regiogr_ca_b.

* Mahnsperre im VK
  CLEAR ls_dfkklocks.
  SELECT * FROM dfkklocks INTO ls_dfkklocks
    WHERE lotyp = '06'
      AND proid = '01'
      AND fdate LE sy-datum
      AND tdate GE sy-datum
      AND gpart = ls_out-gpart
      AND vkont = ls_out-vkont.

    MOVE ls_dfkklocks-lockr TO ls_out-lockr.
    EXIT.
  ENDSELECT.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_STATUS_ICON
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM set_status_icon  USING    fp_agsta
                               fp_status.

  CASE fp_agsta.

    WHEN ' '.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_LED_GREEN'
          info                  = TEXT-a00
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '01'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_RELEASE'
          info                  = TEXT-a01
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '02'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_PROPRIETARY'
          info                  = TEXT-a02
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '03'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_TRANSFER'
          info                  = TEXT-a03
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '04'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_RELATION'
          info                  = TEXT-a04
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '05'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_STORNO'
          info                  = TEXT-a05
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '06'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_WF_WORKITEM_OL'
          info                  = TEXT-a06
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '07'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_WF_WORKITEM_OL'
          info                  = TEXT-a07
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '08'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_WF_WORKITEM_OL'
          info                  = TEXT-a08
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '09'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_SYSTEM_UNDO'
          info                  = TEXT-a09
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '10'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_PAYMENT'
          info                  = TEXT-a10
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '11'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_MONEY'
          info                  = TEXT-a11
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '12'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_STATUS_BOOKED'
          info                  = TEXT-a12
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '13'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_STATUS_PARTLY_BOOKED'
          info                  = TEXT-a13
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '20'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_STATUS_REVERSE'
          info                  = TEXT-a20
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '30'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_ALLOW'
          info                  = TEXT-a30
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '31'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_REJECT'
          info                  = TEXT-a31
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '32'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_REJECT'
          info                  = TEXT-a32
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '97'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_AVAILABILITY_CHECK'
          info                  = TEXT-a97
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '98'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_DISPLAY'
          info                  = TEXT-a98
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '99'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_SET_STATE'
          info                  = TEXT-a99
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

* Sonderfall Ausgleich vor Abgabe
    WHEN 'VA'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_POSITIVE'
*         TEXT                  = ' '
          info                  = TEXT-024
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


* Hier auch für Info vom InkDL
* Status für Ankauf
    WHEN 'A'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_CONVERT'
*         TEXT                  = ' '
          info                  = TEXT-aia
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

* Status für Erneute Bearbeitung
    WHEN 'B'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_LAYOUT_CONTROL'
*         TEXT                  = ' '
          info                  = TEXT-aeb
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


* Status für Abbruch SEG
    WHEN 'C'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_FAILURE'
*         TEXT                  = ' '
          info                  = TEXT-aic
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

* Status für Info InkDl
    WHEN 'I'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_HINT'
*         TEXT                  = ' '
          info                  = TEXT-aii
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


* Hier auch Status Ausbuchungsmonitor
* Status Vormerkung Ausbuchung
    WHEN 'W01'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_SET_STATE'
*         TEXT                  = ' '
          info                  = TEXT-w01
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

    WHEN 'W02'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_ACTION_FAULT'
*         TEXT                  = ' '
          info                  = TEXT-w02
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

* Status Übergabe an Amor --> Bereit zur Genehmigung
    WHEN 'W10'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_COPY_OBJECT'
*         TEXT                  = ' '
          info                  = TEXT-w10
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

* Status Genehmigung 1
    WHEN 'W11'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_INSERT_ROW'
*         TEXT                  = ' '
          info                  = TEXT-w11
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

* Status Genehmigt
    WHEN 'W12'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_INSERT_MULTIPLE_LINES'
*         TEXT                  = ' '
          info                  = TEXT-w12
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

* Status Ablehnung
    WHEN 'W13'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_DELETE_ROW'
*         TEXT                  = ' '
          info                  = TEXT-w13
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

* Status Ausgebucht
    WHEN 'W20'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_STATUS_REVERSE'
*         TEXT                  = ' '
          info                  = TEXT-w20
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

    WHEN 'DOCU'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_TEXT_ACT'
          info                  = TEXT-doc
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'NODOCU'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_TEXT_INA'
          info                  = TEXT-doc
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.


* Status zur Bearbeitung gesperrt
    WHEN 'L'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_LOCKED'
*         TEXT                  = ' '
          info                  = TEXT-014
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CLEAR_CI_COLFILE
*&---------------------------------------------------------------------*
FORM clear_ci_colfile  USING fs_fkkcolfile STRUCTURE fkkcolfile.

  CLEAR: fs_fkkcolfile-zzanrede.
  CLEAR: fs_fkkcolfile-zzname_gp1.
  CLEAR: fs_fkkcolfile-zzname_gp2.
  CLEAR: fs_fkkcolfile-zzname_gp3.
  CLEAR: fs_fkkcolfile-zzname_gp4.
  CLEAR: fs_fkkcolfile-zzpost_code1gp.
  CLEAR: fs_fkkcolfile-zzcity1gp.
  CLEAR: fs_fkkcolfile-zzcity2gp.
  CLEAR: fs_fkkcolfile-zzstreetgp.
  CLEAR: fs_fkkcolfile-zzhouse_num1gp.
  CLEAR: fs_fkkcolfile-zzhouse_num2gp.
  CLEAR: fs_fkkcolfile-zzland.
  CLEAR: fs_fkkcolfile-zztel1.
  CLEAR: fs_fkkcolfile-zztel2.
  CLEAR: fs_fkkcolfile-zzfax1.
  CLEAR: fs_fkkcolfile-zzfax2.
  CLEAR: fs_fkkcolfile-zzsmtp.
  CLEAR: fs_fkkcolfile-zzbirthdt.
  CLEAR: fs_fkkcolfile-zzbankl.
  CLEAR: fs_fkkcolfile-zzbankn.
  CLEAR: fs_fkkcolfile-zziban.
  CLEAR: fs_fkkcolfile-zzswift.
  CLEAR: fs_fkkcolfile-zzbanka.
  CLEAR: fs_fkkcolfile-zzkoinh.
  CLEAR: fs_fkkcolfile-zzkofiz_sd.
  CLEAR: fs_fkkcolfile-zzvertrag.
  CLEAR: fs_fkkcolfile-zzpost_code1vs.
  CLEAR: fs_fkkcolfile-zzcity1vs.
  CLEAR: fs_fkkcolfile-zzcity2vs.
  CLEAR: fs_fkkcolfile-zzstreetvs.
  CLEAR: fs_fkkcolfile-zzhouse_num1vs.
  CLEAR: fs_fkkcolfile-zzhouse_num2vs.
  CLEAR: fs_fkkcolfile-zzabrzu.
  CLEAR: fs_fkkcolfile-zzabrzo.
  CLEAR: fs_fkkcolfile-zztvorgtxt.
  CLEAR: fs_fkkcolfile-zzart.
  CLEAR: fs_fkkcolfile-zzbldat.
  CLEAR: fs_fkkcolfile-zzeinzdat.
  CLEAR: fs_fkkcolfile-zzspartxt.
  CLEAR: fs_fkkcolfile-zzfaellig.
  CLEAR: fs_fkkcolfile-zzrechnung.
  CLEAR: fs_fkkcolfile-zzausdt.
  CLEAR: fs_fkkcolfile-zzfreetext.
  CLEAR: fs_fkkcolfile-zzmobil.
  CLEAR: fs_fkkcolfile-zzunbverz.
  CLEAR: fs_fkkcolfile-zzminderj.
  CLEAR: fs_fkkcolfile-zzerbenhaft.
  CLEAR: fs_fkkcolfile-zzbetreuung.
  CLEAR: fs_fkkcolfile-zzinsolvenz.
  CLEAR: fs_fkkcolfile-zzname_cogp.
  CLEAR: fs_fkkcolfile-zzname_re.
  CLEAR: fs_fkkcolfile-zzname_core.
  CLEAR: fs_fkkcolfile-zzstreet_re.
  CLEAR: fs_fkkcolfile-zzcity_re.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_INTVERM
*&---------------------------------------------------------------------*
FORM get_intverm  TABLES ft_textt STRUCTURE tline
                  USING  ff_vkont
                         ff_gpart.

  DATA: lt_cust    TYPE TABLE OF /adesso/ink_cust.  "Customizing allgemein
  DATA: ls_cust    TYPE /adesso/ink_cust.
  DATA: lv_object  TYPE /adesso/inkasso_value.
  DATA: lv_id      TYPE /adesso/inkasso_value.

  DATA: lt_thead   TYPE TABLE OF thead,
        ls_thead   TYPE thead,
        lv_pattern TYPE char30,
        lv_select  TYPE char30,
        ls_stxh    TYPE stxh,
        lt_stxh    TYPE STANDARD TABLE OF stxh,
        lt_texte   TYPE text_lh,
        ls_texte   TYPE itclh,
        ls_lines   TYPE tline,
*        lt_text    TYPE catsxt_longtext_itab,
*        ls_text    TYPE txline,
*        ls_line    TYPE tline,
        lv_date    TYPE char10,
        lv_time    TYPE char8.


  SELECT * FROM /adesso/ink_cust
         INTO TABLE lt_cust
         WHERE inkasso_option = 'INTVERM'.

  CLEAR ls_cust.
  READ TABLE lt_cust INTO ls_cust
    WITH KEY inkasso_option = 'INTVERM'
             inkasso_field  = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE ls_cust-inkasso_value TO lv_object.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR ls_cust.
  READ TABLE lt_cust INTO ls_cust
    WITH KEY inkasso_option = 'INTVERM'
             inkasso_field  = 'TDID'.

  IF sy-subrc = 0.
    MOVE ls_cust-inkasso_value TO lv_id.
  ELSE.
    EXIT.
  ENDIF.

  CONCATENATE ff_gpart '_' ff_vkont '_' INTO lv_pattern.
  CONCATENATE lv_pattern '%' INTO lv_select.

  CLEAR lt_stxh.
  SELECT * FROM stxh INTO TABLE lt_stxh
    WHERE tdobject = lv_object
      AND tdname LIKE lv_select
      AND tdid     = lv_id
      AND tdspras  = sy-langu.

  SORT lt_stxh BY tdname DESCENDING.
  READ TABLE lt_stxh INTO ls_stxh INDEX 1.
  CHECK sy-subrc = 0.

  MOVE-CORRESPONDING ls_stxh TO ls_thead.
  APPEND ls_thead TO lt_thead.

*  LOOP AT lt_stxh INTO ls_stxh.
*    MOVE-CORRESPONDING ls_stxh TO ls_thead.
*    APPEND ls_thead TO lt_thead.
*    CLEAR ls_thead.
*  ENDLOOP.

  CALL FUNCTION 'READ_TEXT_TABLE'
* EXPORTING
*   CLIENT_SPECIFIED              = ' '
*   ARCHIVE_HANDLE                = 0
*   LOCAL_CAT                     = ' '
    IMPORTING
      text_table              = lt_texte
*     ERROR_TABLE             =
    TABLES
      text_headers            = lt_thead
    EXCEPTIONS
      wrong_access_to_archive = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  SORT lt_texte BY header-tdname DESCENDING.

  LOOP AT lt_texte INTO ls_texte.

*         Datum Formatieren
    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal            = ls_texte-header-tdfdate
      IMPORTING
        date_external            = lv_date
      EXCEPTIONS
        date_internal_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

*   Zeit umformatieren
*   Textheader erstellen
*   Textheader nicht ausgeben
*    CONCATENATE ls_texte-header-tdftime(2)
*                ':'
*                ls_texte-header-tdftime+2(2)
*                ':'
*                ls_texte-header-tdftime+4(2)
*                 INTO lv_time.
*
*    CLEAR ls_lines.
*    ls_lines-tdformat = '/'.
*    CONCATENATE ls_texte-header-tdfuser
*                lv_date
*                lv_time
*                INTO ls_lines-tdline
*                SEPARATED BY space.
*
*    APPEND ls_lines TO ft_textt.

*   Textezeilen einlesen
    CLEAR ls_lines.
    LOOP AT ls_texte-lines INTO ls_lines.
      AT FIRST.
        ls_lines-tdformat = '/'.
      ENDAT.
      APPEND ls_lines TO ft_textt.
      ls_lines-tdformat = '='.
    ENDLOOP.
    APPEND INITIAL LINE TO ft_textt.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_PAYM_INK
*&---------------------------------------------------------------------*
FORM check_paym_ink  USING  fs_collp_ip STRUCTURE fkkcollp_ip
                            ff_lfdnr
                            ff_opbelzahlung.

  DATA: ls_inkasso_cust TYPE /adesso/ink_cust.
  DATA: lv_iban         TYPE iban.
  DATA: ls_dfkkcollh    TYPE dfkkcollh.
  DATA: ls_dfkkcoll     TYPE dfkkcoll.
  DATA: ls_dd07v        TYPE dd07v.
  DATA: lv_domval       TYPE domvalue_l.
  DATA: lv_agsta        TYPE agsta_kk.

  CLEAR ls_inkasso_cust.
  SELECT SINGLE * FROM /adesso/ink_cust INTO ls_inkasso_cust
       WHERE inkasso_option   = 'ZAHLUNG'
       AND   inkasso_category = 'INKGP'
       AND   inkasso_field    = 'IBAN'.

  IF sy-subrc = 0.
    MOVE ls_inkasso_cust-inkasso_value TO lv_iban.
  ENDIF.

  CHECK lv_iban = fs_collp_ip-zzibanzahlung.

* Wenn IBAN vom Inkasso-Büro ändern Status in DFKKCOLLH
  SELECT SINGLE * FROM dfkkcollh INTO ls_dfkkcollh
         WHERE opbel = fs_collp_ip-opbel
         AND   inkps = fs_collp_ip-inkps
         and   lfdnr = ff_lfdnr
         AND   augbl = ff_opbelzahlung.

  IF sy-subrc = 0.
    CHECK ls_dfkkcollh-agsta BETWEEN '10' AND '11'.
    fs_collp_ip-postyp = '6'.
    lv_agsta = ls_dfkkcollh-agsta.
    CASE ls_dfkkcollh-agsta.
      WHEN '10'.
        ls_dfkkcollh-agsta    = '03'.
        ls_dfkkcollh-agsta_or = '03'.
        MODIFY dfkkcollh FROM ls_dfkkcollh.
      WHEN '11'.
        ls_dfkkcollh-agsta    = '04'.
        ls_dfkkcollh-agsta_or = '04'.
        MODIFY dfkkcollh FROM ls_dfkkcollh.
    ENDCASE.

    lv_domval = ls_dfkkcollh-agsta.
    CALL FUNCTION 'DDUT_DOMVALUE_TEXT_GET'
      EXPORTING
        name          = 'AGSTA_KK'
        value         = lv_domval
        langu         = sy-langu
      IMPORTING
        dd07v_wa      = ls_dd07v
      EXCEPTIONS
        not_found     = 1
        illegal_input = 2
        OTHERS        = 3.

    IF sy-subrc <> 0.
* Implement suitable error handling here
    ELSE.
      fs_collp_ip-txtvw = ls_dd07v-ddtext.
    ENDIF.

*   Und ändern Status in DFKKCOLL
    SELECT SINGLE * FROM dfkkcoll INTO ls_dfkkcoll
           WHERE opbel = fs_collp_ip-opbel
           AND   inkps = fs_collp_ip-inkps
           AND   agsta = lv_agsta.

    IF sy-subrc = 0.
      CHECK ls_dfkkcoll-agsta BETWEEN '10' AND '11'.
      CASE ls_dfkkcoll-agsta.
        WHEN '10'.
          ls_dfkkcoll-agsta = '03'.
          MODIFY dfkkcoll FROM ls_dfkkcoll.
        WHEN '11'.
          ls_dfkkcoll-agsta = '04'.
          MODIFY dfkkcoll FROM ls_dfkkcoll.
      ENDCASE.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_ICON_TEXT
*&---------------------------------------------------------------------*
FORM create_icon_text  USING ff_icon
                             ff_text
                       CHANGING ff_field.


  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name                  = ff_icon
      info                  = ff_text
    IMPORTING
      result                = ff_field
    EXCEPTIONS
      icon_not_found        = 1
      outputfield_too_short = 2
      OTHERS                = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
