*&---------------------------------------------------------------------*
*& Report  /ADESSO/DISABLE_ENABLE_REGPOL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /ADESSO/DISABLE_ENABLE_REGPOL.

TABLES:  t005.

PARAMETERS: disable AS CHECKBOX,
            enable  AS CHECKBOX.


IF disable EQ 'X' AND
   enable  EQ 'X'.
 MESSAGE  i001(/adesso/mt_n)
               WITH 'Auswahl nicht eindeutig (nur ein Haken setzen)'.
  EXIT.
ENDIF.

IF disable EQ ' ' AND
   enable  EQ ' '.
  MESSAGE  i001(/adesso/mt_n)
                WITH 'Bitte Auswahl überprüfen (nichts angehakt)'.
  EXIT.
ENDIF.


IF disable EQ 'X'. "Prüfung ausschalten
  SELECT * FROM t005 WHERE land1 EQ 'DE'
            AND xregs EQ 'X' .
    CLEAR t005-xregs.
    MODIFY t005.
  ENDSELECT.

  IF sy-subrc EQ 0.
    MESSAGE  i001(/adesso/mt_n) WITH 'Prüfung wurde ausgeschaltet'.
  ELSE.
    MESSAGE  i001(/adesso/mt_n) WITH 'Prüfung ist schon ausgeschaltet'.
  ENDIF.
ENDIF.

IF enable EQ 'X'. "Prüfung ausschalten
  SELECT * FROM t005 WHERE land1 EQ 'DE'
            AND xregs EQ space .
    MOVE 'X' TO t005-xregs.
    MODIFY t005.
  ENDSELECT.

  IF sy-subrc EQ 0.
    MESSAGE  i001(/adesso/mt_n) WITH 'Prüfung wurde eingeschaltet'.
  ELSE.
    MESSAGE  i001(/adesso/mt_n) WITH 'Prüfung ist schon eingeschaltet'.
  ENDIF.
ENDIF.
