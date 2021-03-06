FUNCTION /ADESSO/EA_GET_COMMENT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_SWITCHNUM) TYPE  EIDESWTMSGDATA-SWITCHNUM
*"     REFERENCE(I_MSGDATANUM) TYPE  EIDESWTMSGDATA-MSGDATANUM
*"  EXPORTING
*"     REFERENCE(E_KZ_COMMENT) TYPE  REGEN-KENNZX
*"     REFERENCE(E_COMMENTTXT) TYPE  EIDESWTMSGDATACO-COMMENTTXT
*"----------------------------------------------------------------------

*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_SWITCHNUM) TYPE  EIDESWTMSGDATA-SWITCHNUM
*"     REFERENCE(I_MSGDATANUM) TYPE  EIDESWTMSGDATA-MSGDATANUM
*"  EXPORTING
*"     REFERENCE(E_KZ_COMMENT) TYPE  REGEN-KENNZX
*"     REFERENCE(E_COMMENTTXT) TYPE  EIDESWTMSGDATACO-COMMENTTXT
*"----------------------------------------------------------------------

 DATA: PD_COMMENTNUM TYPE EIDESWTMSGDATACO-COMMENTNUM.
 DATA: PD_COMMENTTXT TYPE EIDESWTMSGDATACO-COMMENTTXT.

 SELECT COMMENTTXT FROM EIDESWTMSGDATACO
   INTO PD_COMMENTTXT UP TO 1 ROWS
   WHERE SWITCHNUM = I_SWITCHNUM
   AND MSGDATANUM = I_MSGDATANUM.
 ENDSELECT.

 IF SY-SUBRC = 0.
   MOVE PD_COMMENTTXT TO E_COMMENTTXT.
   E_KZ_COMMENT = 'X'.
 ENDIF.

ENDFUNCTION.
