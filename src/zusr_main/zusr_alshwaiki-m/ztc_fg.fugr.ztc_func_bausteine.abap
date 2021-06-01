FUNCTION ztc_func_bausteine .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT1) TYPE  I
*"     REFERENCE(INPUT2)
*"  EXPORTING
*"     REFERENCE(AUSGABE) TYPE  I
*"  EXCEPTIONS
*"      ZTC_EXCEP
*"----------------------------------------------------------------------
*  FUNCTION ztc_func_bausteine.
  IF input2 = 0.
    RAISE ztc_ausnahme.
  ELSE.
    ausgabe = input1 / input2.
  ENDIF.



ENDFUNCTION.
