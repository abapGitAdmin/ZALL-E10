class ZCX_AGC_MASTERDATA definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional .
  class-methods RAISE_EXCEPTION_FROM_MSG
    importing
      !IR_PREVIOUS type ref to CX_ROOT optional
      !IV_MSGID type SYMSGID optional
      !IV_MSGNO type SYMSGNO optional
      !IV_MSGV1 type SYMSGV optional
      !IV_MSGV2 type SYMSGV optional
      !IV_MSGV3 type SYMSGV optional
      !IV_MSGV4 type SYMSGV optional
      !IS_TEXTID type SCX_T100KEY optional
    raising
      ZCX_AGC_MASTERDATA .
protected section.
private section.
ENDCLASS.



CLASS ZCX_AGC_MASTERDATA IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.


  METHOD raise_exception_from_msg.

    DATA: ls_textid TYPE scx_t100key.

    IF is_textid IS INITIAL.
      ls_textid-msgid = iv_msgid.
      ls_textid-msgno = iv_msgno.
    ELSE.
      ls_textid = is_textid.
    ENDIF.

    IF ls_textid-attr1 IS INITIAL.
      ls_textid-attr1 = iv_msgv1.
      ls_textid-attr2 = iv_msgv2.
      ls_textid-attr3 = iv_msgv3.
      ls_textid-attr4 = iv_msgv4.
    ENDIF.

    IF iv_msgid IS INITIAL AND
       iv_msgno IS INITIAL AND
       iv_msgv1 IS INITIAL AND
       iv_msgv2 IS INITIAL AND
       iv_msgv3 IS INITIAL AND
       iv_msgv4 IS INITIAL.
      ls_textid-msgid = sy-msgid.
      ls_textid-msgno = sy-msgno.
      ls_textid-attr1 = sy-msgv1.
      ls_textid-attr2 = sy-msgv2.
      ls_textid-attr3 = sy-msgv3.
      ls_textid-attr4 = sy-msgv4.
    ENDIF.

    RAISE EXCEPTION TYPE zcx_agc_masterdata
      EXPORTING
        previous = ir_previous
        textid   = ls_textid.


  ENDMETHOD.
ENDCLASS.
