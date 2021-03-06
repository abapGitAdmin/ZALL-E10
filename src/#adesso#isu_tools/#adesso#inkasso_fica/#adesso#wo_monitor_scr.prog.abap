*&---------------------------------------------------------------------*
*&  Include           /ADESSO/WO_MONITOR_SCR
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE TEXT-b01.
SELECT-OPTIONS: so_gpart FOR /adesso/wo_mon-gpart.
SELECT-OPTIONS: so_vkont FOR /adesso/wo_mon-vkont.
SELECTION-SCREEN SKIP.
SELECT-OPTIONS: so_abgrd FOR tfk048a-abgrd.
SELECT-OPTIONS: so_woigd FOR /adesso/wo_mon-woigd.

SELECTION-SCREEN ULINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(25) FOR FIELD p_intwo.
SELECTION-SCREEN POSITION 33.
PARAMETERS: p_intwo AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(25) FOR FIELD p_selwo.
SELECTION-SCREEN POSITION 33.
PARAMETERS: p_selwo AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK sel.

SELECTION-SCREEN BEGIN OF BLOCK proc WITH FRAME TITLE TEXT-b05.

SELECT-OPTIONS: so_abdat FOR /adesso/wo_mon-abdat.
SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK req WITH FRAME TITLE TEXT-b03.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_vorm   AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(25) FOR FIELD p_vorm.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_look   AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(25) FOR FIELD p_look.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_frei1   AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(25) FOR FIELD p_frei1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_frei2   AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(25) FOR FIELD p_frei2.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_decl  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(25) FOR FIELD p_decl.
SELECTION-SCREEN POSITION 31.
PARAMETERS: p_opwo  AS CHECKBOX.
SELECTION-SCREEN COMMENT 40(30) FOR FIELD p_opwo.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK req.


SELECTION-SCREEN BEGIN OF BLOCK ink WITH FRAME TITLE TEXT-b04.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_ilook   AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(25) FOR FIELD p_ilook.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_iready  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(25) FOR FIELD p_iready.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_ifrei1   AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(25) FOR FIELD p_ifrei1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_ifrei2   AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(25) FOR FIELD p_ifrei2.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_idecl  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(25) FOR FIELD p_idecl.
SELECTION-SCREEN POSITION 31.
PARAMETERS: p_iopwo  AS CHECKBOX.
SELECTION-SCREEN COMMENT 40(30) FOR FIELD p_iopwo.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK ink.

SELECTION-SCREEN end OF BLOCK proc.


SELECTION-SCREEN BEGIN OF BLOCK out WITH FRAME TITLE TEXT-b02.
PARAMETERS: p_vari LIKE disvariant-variant MODIF ID out.
SELECTION-SCREEN END OF BLOCK out.
