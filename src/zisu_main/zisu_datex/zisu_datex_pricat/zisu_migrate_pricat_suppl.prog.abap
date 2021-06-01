*&---------------------------------------------------------------------*
*& Report ZISU_MIGRATE_PRICE_CATALOGUE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zisu_migrate_priccat_suppl.

TABLES: zisu_pricat_hdr,
        zisu_pricat_item.

DATA: gt_pricat_hdr  TYPE TABLE OF zisu_pricat_hdr.
*      gt_pricat_item TYPE TABLE OF zisu_pricat_item.
*      gt_zmosb_pricat_ver  TYPE TABLE OF zmosb_pricat_ver,
*      gt_zmosb_pricat_vtxt TYPE TABLE OF zmosb_pcat_v_txt,
*      gt_zmosb_price       TYPE TABLE OF zmosb_price.

DATA: gt_price_sheet TYPE TABLE OF /idxgl/pri_sheet.



SELECTION-SCREEN BEGIN OF BLOCK select1 WITH FRAME TITLE TEXT-001 .
SELECT-OPTIONS: sel_cat FOR zisu_pricat_hdr-seq_number.
SELECTION-SCREEN END OF BLOCK select1.


START-OF-SELECTION.

  SELECT * FROM zisu_pricat_hdr INTO TABLE gt_pricat_hdr WHERE seq_number IN sel_cat.
  IF sy-subrc <> 0.
    WRITE 'Kein entsprechender Preiskatalog gefunden.'.
    RETURN.
  ENDIF.


  DATA: lt_edidd       TYPE TABLE OF edidd,
        ls_idoc_contrl TYPE edidc.


  LOOP AT gt_pricat_hdr ASSIGNING FIELD-SYMBOL(<ls_pricat_hdr>).
    NEW-LINE.


    CLEAR: ls_idoc_contrl.
    CLEAR: lt_edidd.


    CALL FUNCTION 'IDOC_READ_COMPLETELY'
      EXPORTING
        document_number         = <ls_pricat_hdr>-idocno
      IMPORTING
        idoc_control            = ls_idoc_contrl
*       NUMBER_OF_DATA_RECORDS  =
*       NUMBER_OF_STATUS_RECORDS       =
      TABLES
*       INT_EDIDS               =
        int_edidd               = lt_edidd
      EXCEPTIONS
        document_not_exist      = 1
        document_number_invalid = 2
        OTHERS                  = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      CONTINUE.
    ENDIF.


    DATA: ls_idoc_data TYPE edex_idocdata.
    CLEAR ls_idoc_data.

    ls_idoc_data-control = ls_idoc_contrl.
    ls_idoc_data-data    = lt_edidd.


    CALL METHOD zcl_datex_utility=>modify_externalid_inbound
      CHANGING
        cs_idoc_data = ls_idoc_data.


    DATA: lr_pricat_11       TYPE REF TO zcl_pricat_11_cl_migration,
          lr_pricat_11_idxgl TYPE REF TO zcl_pricat_11_idxgl_migration,
          lt_price_sheet     TYPE TABLE OF /idxgl/pri_sheet.



    CLEAR lt_price_sheet.

    IF ls_idoc_contrl-mestyp = '/IDXGC/PRICAT'.
      CREATE OBJECT lr_pricat_11.
      CALL METHOD lr_pricat_11->isu_compr_pricat_in_migration
        EXPORTING
          is_idoc_contrl     = ls_idoc_data-control
          it_idoc_data       = ls_idoc_data-data
        RECEIVING
*         es_idoc_status     =
          rt_idxgl_pri_sheet = lt_price_sheet
        EXCEPTIONS
          error_occurred     = 1
          OTHERS             = 2.
      IF sy-subrc <> 0.
        DATA: lv_text TYPE string.
        WRITE |Verarbeitung von Seq.-nummer { <ls_pricat_hdr>-seq_number } abgebrochen.|.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_text.
        WRITE lv_text.
        CONTINUE.
      ENDIF.

      FREE lr_pricat_11.
    ELSEIF ls_idoc_contrl-mestyp = '/IDXGL/PRICAT'.
      CREATE OBJECT lr_pricat_11_idxgl.
      CALL METHOD lr_pricat_11_idxgl->isu_compr_pricat_in_migration
        EXPORTING
          is_idoc_contrl     = ls_idoc_data-control
          it_idoc_data       = ls_idoc_data-data
        RECEIVING
*         es_idoc_status     =
          rt_idxgl_pri_sheet = lt_price_sheet
        EXCEPTIONS
          error_occurred     = 1
          OTHERS             = 2.
      IF sy-subrc <> 0.
        WRITE |Verarbeitung von Seq.-nummer { <ls_pricat_hdr>-seq_number } abgebrochen.|.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_text.
        WRITE lv_text.

        CONTINUE.
      ENDIF.

      FREE lr_pricat_11_idxgl.
    ENDIF.


    DATA: ls_price_sheet_last LIKE LINE OF lt_price_sheet.
    CLEAR ls_price_sheet_last.

    LOOP AT lt_price_sheet ASSIGNING FIELD-SYMBOL(<ls_price_sheet>).
      <ls_price_sheet>-cr_date                = <ls_pricat_hdr>-erdat.
      <ls_price_sheet>-cr_name                = <ls_pricat_hdr>-ernam.
      <ls_price_sheet>-ch_date                = sy-datum.
      <ls_price_sheet>-ch_time                = sy-uzeit.
      <ls_price_sheet>-ch_name                = sy-uname.

      IF NOT ls_price_sheet_last IS INITIAL.
        IF <ls_price_sheet>-item_id <= ls_price_sheet_last-item_id.
          <ls_price_sheet>-item_id = ls_price_sheet_last-item_id + 1.
        ENDIF.
      ENDIF.
      ls_price_sheet_last = <ls_price_sheet>.
    ENDLOOP.

    MODIFY /idxgl/pri_sheet FROM TABLE lt_price_sheet.

    WRITE |Verarbeitung von Seq.-nummer { <ls_pricat_hdr>-seq_number } abgeschlossen. Es wurden { sy-dbcnt } Zeilen verarbeitet.|.

  ENDLOOP.
