FUNCTION Z_EXCEPTION.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(INT1) TYPE  I
*"     VALUE(INT2) TYPE  I
*"  EXPORTING
*"     VALUE(RESULT) TYPE  I
*"  EXCEPTIONS
*"      LOESE_EXCEP
*"----------------------------------------------------------------------


  IF int1 = 0.

 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
            raising loese_excep.

    else.

      result = int1 + int2.



  ENDIF.





ENDFUNCTION.
