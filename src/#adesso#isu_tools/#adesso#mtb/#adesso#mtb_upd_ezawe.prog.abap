*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTB_UPD_EZAWE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mtb_upd_ezawe.

TABLES: fkkvk.

DATA: ifkkvkp LIKE TABLE OF fkkvkp WITH HEADER LINE.
DATA: data LIKE bapiisuvkp,
      datat LIKE TABLE OF data,
      datax LIKE bapiisuvkpx.
DATA: return LIKE  bapiret2.

PARAMETERS: ptest AS CHECKBOX DEFAULT 'X'.
PARAMETERS : pezawe LIKE fkkvkp-ezawe.
SELECT-OPTIONS: svkont FOR fkkvk-vkont.

START-OF-SELECTION.

  SELECT * FROM fkkvkp INTO TABLE ifkkvkp WHERE vkont IN svkont.

  LOOP AT ifkkvkp.

    CALL FUNCTION 'BAPI_ISUACCOUNT_GETDETAIL'
      EXPORTING
        contractaccount              = ifkkvkp-vkont
*   PARTNER                      =
*   ONLYACCOUNTHOLDER            =
*   ONLYACTUALNONACCHOLDER       =
* IMPORTING
*   RETURN                       =
      TABLES
        tcontractaccountdata         = datat.
*   TCTRACLOCKDETAIL             =
*   EXTENSIONOUT                 =
    .
    READ TABLE datat INDEX 1 INTO data.
    data-paym_method_in = pezawe.
    datax-paym_method_in = 'X'.

    CALL FUNCTION 'BAPI_ISUACCOUNT_CHANGE'
      EXPORTING
        contractaccount            = ifkkvkp-vkont
        partner                    = ifkkvkp-gpart
*   VALIDDATE                  =
        contractaccountdata        = data
        contractaccountdatax       = datax
        testrun                    = ptest
 IMPORTING
   return                     = return.
* TABLES
*   TCTRACLOCKDETAIL           =
*   EXTENSIONIN                =
*    WRITE: / return-message.
    IF return-message IS INITIAL.
      WRITE : / ifkkvkp-vkont, 'geändert EZAWE neu', pezawe.
    ELSE.
      WRITE : / ifkkvkp-vkont, return-message(132).
    ENDIF.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*     EXPORTING
*       WAIT          =
*     IMPORTING
*       RETURN        =
              .

    WRITE : / ifkkvkp-vkont, 'geändert EZAWE neu', pezawe.

  ENDLOOP.
