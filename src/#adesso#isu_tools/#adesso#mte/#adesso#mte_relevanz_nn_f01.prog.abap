*&---------------------------------------------------------------------*
*&  Include           /ADESSO/MTE_RELEVANZ_NN_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GET_RELEVANT_INVOICE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_relevant_invoice .

  SELECT * FROM tinv_inv_head INTO TABLE it_head

*    Berücksichtigung von NN-Rechnungen vor 01.09.2012
*     WHERE date_of_receipt GE '20120901'

      WHERE  invoice_type = '101'
      AND    ext_receiver = '9903242000005'.

  LOOP AT it_head INTO wa_head.
    mac_add_relevanz 'INVOICE' wa_head-int_inv_no.
  ENDLOOP.

ENDFORM.                    " GET_RELEVANT_INVOICE

*&---------------------------------------------------------------------*
*&      Form  UPDATE_RELTAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_reltab .

  SORT irel.
  DELETE ADJACENT DUPLICATES FROM irel COMPARING ALL FIELDS.

  INSERT /adesso/mte_rel FROM TABLE irel.

ENDFORM.                    " UPDATE_RELTAB

*&---------------------------------------------------------------------*
*&      Form  PROTOKOLL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM protokoll .

  WRITE : / 'Objekt', 44 'Anzahl'.
  LOOP AT irel INTO wrel.
    AT NEW object.
      WRITE : / wrel-object.
    ENDAT.
    ADD 1 TO objcount.
    AT END OF object.
      WRITE : 40 objcount.
      CLEAR objcount.
    ENDAT.
  ENDLOOP.

ENDFORM.                    " PROTOKOLL
