class ZCL_IDXGL_PRI_SHEET_DB_ACCESS definition
  public
  inheriting from /IDXGL/CL_PRI_SHEET_DB_ACCESS
  create public .

public section.

  methods CHECK_PRI_SHEET_EXISTS_DATE
    importing
      !IV_SENDER type SERVICE_PROV_SEND
      !IV_RECEIVER type SERVICE_PROV_RECEIVE
      !IV_VAL_START_DATE type /IDXGL/DE_PRI_VAL_START_DATE
    returning
      value(RV_IS_EXIST) type FLAG .
  methods GET_LATEST_PRI_SHEET_DATE
    importing
      !IV_SENDER type SERVICE_PROV_SEND
      !IV_RECEIVER type SERVICE_PROV_RECEIVE
      !IV_VAL_START_DATE type /IDXGL/DE_PRI_VAL_START_DATE
      !IV_POS_PRICE_KEY_GROUP type /IDXGL/DE_POS_PRICE_KEY_GROUP optional
    returning
      value(RT_PRI_SHEET) type /IDXGL/T_PRI_SHEET .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IDXGL_PRI_SHEET_DB_ACCESS IMPLEMENTATION.


  METHOD check_pri_sheet_exists_date.
    DATA ls_pri_sheet TYPE /idxgl/pri_sheet ##NEEDED.

    SELECT * INTO ls_pri_sheet
      FROM /idxgl/pri_sheet
      UP TO 1 ROWS
      WHERE sender         = iv_sender
        AND receiver       = iv_receiver
        AND val_start_date = iv_val_start_date.
    ENDSELECT.

    IF sy-subrc = 0.
      rv_is_exist = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD get_latest_pri_sheet_date.

    DATA: lt_pri_sheet TYPE TABLE OF /idxgl/pri_sheet.

    CLEAR rt_pri_sheet.

    IF iv_pos_price_key_group IS NOT SUPPLIED.

      SELECT * FROM /idxgl/pri_sheet INTO TABLE @lt_pri_sheet
       WHERE sender              = @iv_sender
         AND receiver            = @iv_receiver
         AND val_start_date     <= @iv_val_start_date
       ORDER BY val_start_date DESCENDING.

    ELSE.

      SELECT * FROM /idxgl/pri_sheet INTO TABLE @lt_pri_sheet
        WHERE sender              = @iv_sender
          AND receiver            = @iv_receiver
          AND pos_price_key_group = @iv_pos_price_key_group
          AND val_start_date     <= @iv_val_start_date
        ORDER BY val_start_date DESCENDING.

    ENDIF.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    "alle Preisblätter zum aktuellsten Startdatum ermitteln
    READ TABLE lt_pri_sheet ASSIGNING FIELD-SYMBOL(<ls_pri_sheet>) INDEX 1.
    DELETE lt_pri_sheet WHERE val_start_date <> <ls_pri_sheet>-val_start_date.

    DATA: lt_previous_document_ident TYPE TABLE OF /idxgc/de_ref_no.
    LOOP AT lt_pri_sheet ASSIGNING <ls_pri_sheet> WHERE NOT previous_document_ident IS INITIAL.
      APPEND <ls_pri_sheet>-previous_document_ident TO lt_previous_document_ident.
    ENDLOOP.

    SORT lt_previous_document_ident.
    DELETE ADJACENT DUPLICATES FROM lt_previous_document_ident.


    LOOP AT lt_pri_sheet ASSIGNING <ls_pri_sheet>.
      READ TABLE lt_previous_document_ident WITH TABLE KEY table_line = <ls_pri_sheet>-document_ident TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        APPEND <ls_pri_sheet> TO rt_pri_sheet.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
