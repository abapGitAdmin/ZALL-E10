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
REPORT ZBB_TESTPROGRAMM.

DATA: gv_Number1 TYPE i,
      gv_Number2 TYPE i.

gv_Number1 = 5.
gv_Number2 = 3.

CONSTANTS gc_Constant1 TYPE i VALUE 10.

ADD gc_Constant1 TO gv_Number1.
WRITE: gv_Number1, /
       gv_Number2.

gv_Number2 = gv_Number1 mod gc_Constant1.
WRITE gv_Number2.

gv_Number2 = gv_Number1 ** 2.
WRITE / gv_Number2.


DATA: gv_String1 TYPE String,
      gv_String2 TYPE String,
      gv_Char1 TYPE c.

gv_Char1 = 'b'.
ULINE.
WRITE: gv_Char1.

gv_String1 = 'Benedikt'.
gv_String2 = 'Brune'.

*CONCATENATE gv_String1 gv_String2 INTO gv_String1 SEPARATED BY ' '. "alter Befehl
gv_String1 = |{ gv_String1 } { gv_String2 }|.
ULINE.
WRITE: 'Vollständiger Name:', /
        gv_String1.
ULINE.

FIND 'ene' IN gv_String1.
IF sy-subrc = 0.
WRITE |Es wurde "ene" gefunden in, { gv_String1 }!|.
ENDIF.

ULINE.

REPLACE 'Benedikt' IN gv_String1 WITH 'Max'.

IF sy-subrc = 0.
WRITE gv_String1.
ENDIF.

ULINE.

SPLIT gv_String1 AT ' ' INTO gv_String1 gv_String2.
WRITE: 'Vorname', gv_String1, / 'Nachname', gv_String2.

ULINE.

CONCATENATE gv_String1 gv_String2 INTO gv_String1 SEPARATED BY '      '.
CONDENSE gv_String1.
WRITE gv_String1.

ULINE.

TRANSLATE gv_String1 TO UPPER CASE.
WRITE gv_String1.
