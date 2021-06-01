*----------------------------------------------------------------------*
***INCLUDE LZ_INKASSO_FGF02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_SACHKONTO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0172   text
*      -->P_0173   text
*      -->P_LC_MAIN_TRANS  text
*      -->P_0175   text
*      -->P_LC_COMP_CODE  text
*      -->P_0177   text
*      <--P_LS_BAPIDFKKOP_TEMP_G_L_ACCT  text
*----------------------------------------------------------------------*
FORM get_sachkonto  USING    fv_buber
                             fv_kofiz
                             fv_hvorg
                             fv_tvorg
                             fv_bukrs
                             fv_ktopl
                    CHANGING cv_hkont.

  DATA: lv_tfk033d TYPE tfk033d.

  lv_tfk033d-applk = 'R'.
  lv_tfk033d-buber = fv_buber.
  lv_tfk033d-ktopl = fv_ktopl.
  lv_tfk033d-key01 = fv_bukrs.
  lv_tfk033d-key03 = fv_kofiz.
  lv_tfk033d-key04 = fv_hvorg.
  lv_tfk033d-key05 = fv_tvorg.

* Kontenfindung: Lesen der Kontenfindungstabellen
  call function 'FKK_ACCOUNT_DETERMINE'
    exporting
      i_tfk033d                 = lv_tfk033d
*     I_DO_NOT_USE_BUFFER       = ' '
*     I_ONLY_SIMULATION         = ' '
*     I_NO_DETAILED_MSG         = ' '
    importing
      e_tfk033d                 = lv_tfk033d
    exceptions
      error_in_input_data       = 1
      nothing_found             = 2
      others                    = 3  .

if sy-subrc = 0.
  cv_hkont = lv_tfk033d-fun01.
  endif.

ENDFORM.
*
*&---------------------------------------------------------------------*
*&      Form  get_fikey
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->S_RFK00-BLART  text
*      <--S_RFK00-FIKEY  text
*----------------------------------------------------------------------*
FORM get_fikey USING    blart
               CHANGING fikey.

  DATA: f_fikey   TYPE fkkko-fikey,
        f_fikey_d TYPE fkkko-fikey,
        f_num(3)  TYPE n,
        f_xclos   TYPE dfkksumc-xclos.

  CLEAR  fikey.

  DO 999 TIMES.                         "bis zu 100 mögliche Abstimmschlüssel
    f_fikey(2)   = blart.
    f_fikey+2(2) = sy-datum+2(2).
    f_fikey+4(4) = sy-datum+4(4).
    f_fikey+8(1) = '-'.
    f_fikey+9(3) = f_num.

    SELECT SINGLE fikey xclos
      INTO (f_fikey_d, f_xclos)
      FROM dfkksumc
      WHERE fikey  = f_fikey.

    IF sy-subrc <> 0.                   "Anlegen Abstimmschlüssel oder beenden der Schleife

* FIKEY für die folgenden Buchungen reservieren
      CALL FUNCTION 'FKK_FIKEY_OPEN'
        EXPORTING
          i_fikey = f_fikey.
      EXIT.
    ENDIF.
    IF f_xclos = 'X'.
      ADD 1 TO f_num.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.

* FIKEY prüfen, ob er verwendet werden darf
  CALL FUNCTION 'FKK_FIKEY_CHECK'
    EXPORTING
      i_fikey                = f_fikey
      i_open_without_dialog  = 'X'
      i_non_existing_allowed = 'X'.

  fikey = f_fikey.
ENDFORM.                    " GET_FIKEY
* GET_FIKEY
.
