FUNCTION /ADESSO/FI_NEG_REAMADV_CIC.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(TCODE) TYPE  SY-TCODE
*"     VALUE(SKIPFIRST) TYPE  BOOLEAN
*"  TABLES
*"      IN_BDCDATA STRUCTURE  BDCDATA
*"      OUT_MESSTAB STRUCTURE  BDCMSGCOLL
*"  EXCEPTIONS
*"      NO_AUTHORIZATION
*"--------------------------------------------------------------------

  CALL FUNCTION 'CALL_CIC_TRANSACTION'
    EXPORTING
      tcode                  = tcode
      skipfirst              = skipfirst
    TABLES
      in_bdcdata             = in_bdcdata
      out_messtab            = out_messtab
*   EXCEPTIONS
*     NO_AUTHORIZATION       = 1
*     OTHERS                 = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.




ENDFUNCTION.
