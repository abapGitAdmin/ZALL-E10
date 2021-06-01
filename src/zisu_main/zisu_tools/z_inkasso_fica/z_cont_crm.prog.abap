*&---------------------------------------------------------------------*
*& Report  Z_CONT_CRM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT z_cont_crm.

DATA: lt_contacts  TYPE STANDARD TABLE OF zscmx_contacts,
      lt_documents TYPE STANDARD TABLE OF zscmx_documents,
      lv_gpart     TYPE gpart_kk,
      lv_gp        TYPE char70.

DATA go_alv TYPE REF TO cl_salv_table.
DATA go_functions TYPE REF TO cl_salv_functions_list.
DATA go_columns TYPE REF TO cl_salv_columns_table.
DATA go_display TYPE REF TO cl_salv_display_settings.

DATA 	gt_feldkatalog TYPE slis_t_fieldcat_alv.
DATA 	gs_feldkatalog LIKE LINE OF gt_feldkatalog.
DATA 	gs_layout TYPE slis_layout_alv.
DATA 	gv_repid TYPE syrepid.
DATA 	gs_aktuelle_zeile  LIKE LINE OF lt_contacts.

DATA: it_string_components LIKE swastrtab OCCURS 0 WITH HEADER LINE.

TYPES: BEGIN OF int_text,
        text(72) TYPE c,
      END OF int_text.

DATA: itab_text TYPE TABLE OF int_text WITH HEADER LINE.




SELECTION-SCREEN: BEGIN OF BLOCK prog WITH FRAME TITLE text-001.
SELECT-OPTIONS s_gp FOR lv_gpart OBLIGATORY.
*APPEND s_gp.
SELECTION-SCREEN: END OF BLOCK prog.

FIELD-SYMBOLS: <fs_contacts> TYPE zscmx_contacts.

*lv_gpart = '0154571116'.

START-OF-SELECTION.

  lv_gpart = s_gp-low.

END-OF-SELECTION.

  CONCATENATE 'Kontakte' lv_gpart INTO lv_gp SEPARATED BY space.

  CASE sy-sysid.
    WHEN 'EMC'.
      CALL FUNCTION 'Z_CMX_CUSTOMER_CONTACT'
        DESTINATION 'CRDCLNT010'
*   DESTINATION 'CRECLNT010'
        EXPORTING
          iv_partner            = lv_gpart
        IMPORTING
          et_contacts           = lt_contacts
          et_documents          = lt_documents
        EXCEPTIONS
          communication_failure = 1
          system_failure        = 2.
    WHEN 'EMD'.
      CALL FUNCTION 'Z_CMX_CUSTOMER_CONTACT'
        DESTINATION 'CRDCLNT010'
*   DESTINATION 'CRECLNT010'
        EXPORTING
          iv_partner            = lv_gpart
        IMPORTING
          et_contacts           = lt_contacts
          et_documents          = lt_documents
        EXCEPTIONS
          communication_failure = 1
          system_failure        = 2.
    WHEN 'EME'.
      CALL FUNCTION 'Z_CMX_CUSTOMER_CONTACT'
*      DESTINATION 'CRDCLNT010'
        DESTINATION 'CRECLNT010'
        EXPORTING
          iv_partner            = lv_gpart
        IMPORTING
          et_contacts           = lt_contacts
          et_documents          = lt_documents
        EXCEPTIONS
          communication_failure = 1
          system_failure        = 2.
    WHEN OTHERS.
      CALL FUNCTION 'Z_CMX_CUSTOMER_CONTACT'
        DESTINATION 'CRDCLNT010'
*   DESTINATION 'CRECLNT010'
        EXPORTING
          iv_partner            = lv_gpart
        IMPORTING
          et_contacts           = lt_contacts
          et_documents          = lt_documents
        EXCEPTIONS
          communication_failure = 1
          system_failure        = 2.
  ENDCASE.



*-----------------------------------------------------------------------
* Beginn ALV-Ausgabe
*-----------------------------------------------------------------------
* Kopieren Sie diesen Block an das Endes des Verarbeitungsblocks
* des ABAP-Programms
*-----------------------------------------------------------------------
* Layout bestimmen.
  PERFORM layout_allg_build USING gs_layout.

* Daten als ALV-Liste anzeigen.
  PERFORM alv_anzeigen.

*-----------------------------------------------------------------------
* Ende ALV-Ausgabe
*-----------------------------------------------------------------------


*-----------------------------------------------------------------------
* Unterprogramm fuer Ausgabe der ALV-Liste
*-----------------------------------------------------------------------
FORM alv_anzeigen.

  gv_repid = sy-repid.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = gv_repid
      i_callback_user_command = 'REAKTION_AUF_DOPPELKLICK'
      i_grid_title            = lv_gp
      i_structure_name        = 'zscmx_contacts'
      is_layout               = gs_layout
    TABLES
      t_outtab                = lt_contacts.
  IF sy-subrc <> 0.
  ENDIF.
ENDFORM."alv_anzeigen.

*---------------------------------------------------------------------
* Unterprogramm fuer Layoutangaben
*---------------------------------------------------------------------

FORM layout_allg_build USING ls_layout TYPE slis_layout_alv.
  ls_layout-zebra ='X'.
  ls_layout-colwidth_optimize ='X'.
ENDFORM. "layout_allg_build.

*---------------------------------------------------------------------
* Unterprogramm fuer Reaktion auf Doppelklick
*---------------------------------------------------------------------

FORM reaktion_auf_doppelklick USING i_ucomm
    i_selfield TYPE slis_selfield.

  CLEAR it_string_components.
  CLEAR itab_text.
  REFRESH itab_text.

  CASE i_ucomm.
    WHEN '&IC1'. "bei Doppelklick
      READ TABLE lt_contacts INTO gs_aktuelle_zeile
        INDEX i_selfield-tabindex.


      CALL FUNCTION 'SWA_STRING_SPLIT'
        EXPORTING
          input_string         = gs_aktuelle_zeile-note
          max_component_length = 72
*         TERMINATING_SEPARATORS             =
*         OPENING_SEPARATORS   =
        TABLES
          string_components    = it_string_components
* EXCEPTIONS
*         MAX_COMPONENT_LENGTH_INVALID       = 1
*         OTHERS               = 2
        .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      LOOP AT it_string_components.
        itab_text-text = it_string_components-str.
        APPEND itab_text.
      ENDLOOP.

      CALL FUNCTION 'TERM_CONTROL_EDIT'
        EXPORTING
          TITEL                = 'Kontaktnotiz anzeigen'
*         LANGU                =
        TABLES
          textlines            = itab_text
        EXCEPTIONS
         USER_CANCELLED       = 1
         OTHERS               = 2
                .

IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.







  ENDCASE.
ENDFORM. "REAKTION_AUF_DOPPELKLICK
