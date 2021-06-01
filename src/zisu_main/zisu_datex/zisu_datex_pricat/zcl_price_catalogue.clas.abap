class ZCL_PRICE_CATALOGUE definition
  public
  final
  create public .

public section.

  constants AC_PRICE_CLASS_MME type ZMOSB_DE_PRICE_CLASS value 'Z25' ##NO_TEXT.
  constants AC_PRICE_CLASS_WAND type ZMOSB_DE_PRICE_CLASS value 'Z26' ##NO_TEXT.
  constants AC_PRICE_CLASS_STEU type ZMOSB_DE_PRICE_CLASS value 'Z27' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !IV_COMPANY_CODE type BUKRS_PR
      !IV_KEYDATE type DATUM .
  methods GET_PRICE_KEY_GROUP
    importing
      !IV_PRICE_CLASS type ZMOSB_DE_PRICE_CLASS
      !IV_PRICE_CLASS_ADD type ZMOSB_DE_PRICE_CLASS_ADD optional
    returning
      value(RV_PRICE_KEY_GROUP) type /IDXGL/DE_POS_PRICE_KEY_GROUP .
protected section.

  data AS_MOSB_PRICAT type ZMOSB_PRICAT .
  data AS_MOSB_PRICAT_VER type ZMOSB_PRICAT_VER .
private section.
ENDCLASS.



CLASS ZCL_PRICE_CATALOGUE IMPLEMENTATION.


  METHOD constructor.
    SELECT SINGLE * FROM zmosb_pricat INTO as_mosb_pricat WHERE company_code = iv_company_code.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM zmosb_pricat_ver INTO as_mosb_pricat_ver WHERE price_catalogue_id  = as_mosb_pricat-price_catalogue_id
                                                                    AND val_start_date     <= iv_keydate
                                                                    AND val_end_date       >= iv_keydate.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD get_price_key_group.

    rv_price_key_group = as_mosb_pricat_ver-price_catalogue_id && '-' &&
                         as_mosb_pricat_ver-pricat_version && '-' &&
                         iv_price_class.

    IF NOT iv_price_class_add IS INITIAL.
      rv_price_key_group = rv_price_key_group && '-' && iv_price_class_add.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
