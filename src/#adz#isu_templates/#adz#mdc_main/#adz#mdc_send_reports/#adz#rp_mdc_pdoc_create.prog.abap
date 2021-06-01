************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P                                 Datum: 09.08.2019
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

REPORT /adz/rp_mdc_pdoc_create.

DATA: gv_ext_ui      TYPE ext_ui,
      gs_selection   TYPE /adz/s_mdc_sel,
      gr_custom_cont TYPE REF TO cl_gui_custom_container,
      gr_mdc_cntr    TYPE REF TO /adz/cl_mdc_cntr,
      ok_code        TYPE sy-ucomm.

INCLUDE /adz/rp_mdc_pdoc_create_module.

SELECTION-SCREEN BEGIN OF BLOCK hdr WITH FRAME TITLE TEXT-t01.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_rb1  RADIOBUTTON GROUP g1 MODIF ID id1 DEFAULT 'X' USER-COMMAND chng.
SELECTION-SCREEN COMMENT 6(60) TEXT-t10 FOR FIELD p_rb1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_rb3  RADIOBUTTON GROUP g1 MODIF ID id1.
SELECTION-SCREEN COMMENT 6(60) TEXT-t12 FOR FIELD p_rb3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_rb4  RADIOBUTTON GROUP g1 MODIF ID id1.
SELECTION-SCREEN COMMENT 6(60) TEXT-t13 FOR FIELD p_rb4.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_rb2  RADIOBUTTON GROUP g1 MODIF ID id1.
SELECTION-SCREEN COMMENT 6(60) TEXT-t11 FOR FIELD p_rb2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_rb5  RADIOBUTTON GROUP g1 MODIF ID id1.
SELECTION-SCREEN COMMENT 6(60) TEXT-t14 FOR FIELD p_rb5.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_rb6  RADIOBUTTON GROUP g1 MODIF ID id1.
SELECTION-SCREEN COMMENT 6(60) TEXT-t15 FOR FIELD p_rb6.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK hdr.


SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE TEXT-t02.
SELECT-OPTIONS: s_extui FOR gv_ext_ui MODIF ID id1.
PARAMETERS: p_kydt TYPE /idxgc/de_keydate DEFAULT sy-datum MODIF ID id1,
            p_mtr  TYPE /adz/de_mdc_msgtransreason MODIF ID id1.
SELECTION-SCREEN END OF BLOCK sel.


AT SELECTION-SCREEN OUTPUT.

  TRY.
      IF /adz/cl_mdc_customizing=>get_own_intcode(  ) <> /adz/if_mdc_co=>gc_intcode-dso_01.
        MESSAGE TEXT-e01 TYPE 'A'.
      ENDIF.
    CATCH /idxgc/cx_general.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDTRY.

* MSB der MaLo
  IF p_rb1 = abap_true.
    p_kydt = sy-datum.
    LOOP AT SCREEN.
      CLEAR: p_mtr.
      IF screen-name = 'P_MTR'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Stammdateloop
  IF p_rb2 = abap_true.
    p_kydt = sy-datum.
    LOOP AT SCREEN.
      CLEAR: p_mtr.
      IF screen-name = 'P_MTR'.
        screen-input = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Lokationsbündel
  IF p_rb3 = abap_true.
    p_kydt = sy-datum.
    LOOP AT SCREEN.
      CLEAR: p_mtr.
      IF screen-name = 'P_MTR'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Bil. rel. SD-Änderung
  IF p_rb4 = abap_true.
    p_kydt = sy-datum.
    LOOP AT SCREEN.
      CLEAR: p_mtr.
      IF screen-name = 'P_MTR'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Beendigung Aggregationsverantwortung
  IF p_rb5 = abap_true.
    p_mtr = 'E03'.
    p_kydt = sy-datum.
    LOOP AT SCREEN.
      IF screen-name = 'P_MTR'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

*  Marktzusammenlegung
  IF p_rb6 = abap_true.
    p_mtr = 'E03'.
    p_kydt = '20211001'.
    LOOP AT SCREEN.
      IF screen-name = 'P_MTR'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.


START-OF-SELECTION.
  gs_selection-rb1 = p_rb1.
  gs_selection-rb2 = p_rb2.
  gs_selection-rb3 = p_rb3.
  gs_selection-rb4 = p_rb4.
  gs_selection-rb5 = p_rb5.
  gs_selection-rb6 = p_rb6.
  gs_selection-ext_ui = s_extui[].
  gs_selection-keydate = p_kydt.
  gs_selection-msgtransreason = p_mtr.
  CALL SCREEN 0100.
