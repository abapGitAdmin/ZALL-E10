FUNCTION /ADZ/REKLAMATIONSVORSCHLAG.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INT_INV_DOC_NO) TYPE  INV_INT_INV_DOC_NO
*"     REFERENCE(RSTGR) TYPE  RSTGR
*"     REFERENCE(RSTGV) TYPE  MSGNR
*"     REFERENCE(NODISP) TYPE  XFELD OPTIONAL
*"  EXPORTING
*"     REFERENCE(ACCPT) TYPE  OK
*"     REFERENCE(TEXT) TYPE  /IDEXGE/REJ_NOTI_TXT
*"     REFERENCE(FORALL) TYPE  XFELD
*"--------------------------------------------------------------------

"ToDO
DINT_INV_DOC_NO = int_inv_doc_no.
drstgr = rstgr.
SELECT SINGLE text FROM /adz/rektexte into dfreetext1 WHERE msgnr = rstgv.
if nodisp = ''.
CALL SCREEN 9001 STARTING AT 10 10 .
ACCPT = OK.
ELSE.
ACCPT = 'ACCPT'.
ENDIF.
TEXT = dfreetext1.
forall = dforall.

ENDFUNCTION.
