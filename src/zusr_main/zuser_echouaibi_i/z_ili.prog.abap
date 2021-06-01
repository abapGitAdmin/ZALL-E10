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
REPORT Z_ILI.

SELECTION-SCREEN : BEGIN OF BLOCK b4 WITH FRAME TITLE text-t04.

SELECTION-SCREEN: BEGIN OF LINE.

SELECTION-SCREEN: POSITION 30, COMMENT 1(15) text-m01 FOR FIELD s_matnr.

PARAMETER: s_matnr TYPE mara-matnr.

SELECTION-SCREEN: POSITION 60, COMMENT 40(15) text-m03.

PARAMETER: r_matnr TYPE mara-matnr.


SELECTION-SCREEN : END OF LINE.

SELECTION-SCREEN : END OF BLOCK b4.
