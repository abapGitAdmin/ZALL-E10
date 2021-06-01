************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT z_ado_check_fuba.

DATA:  lf_bankacc  TYPE C,
       lf_bank_key TYPE KNBK_BF-BKONT,
       lf_bank_country TYPE KNBK_BF-BANKS,
       lf_bank_number TYPE BNKA-BNKLZ,
       lf_iban TYPE iban.

TABLES: lfbk.


*lf_iban = 'DE12500105170648489890'.

SELECT SINGLE * FROM lfbk.

CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
  EXPORTING
    I_BANK_ACCOUNT  = lfbk-bankn
    I_BANK_COUNTRY = lfbk-banks
    I_BANK_NUMBER = ''
    I_BANK_KEY = lfbk-bankl
  IMPORTING
    E_IBAN                   = lf_iban
  EXCEPTIONS
    NO_CONVERSION            = 1
    OTHERS                   = 2
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.
