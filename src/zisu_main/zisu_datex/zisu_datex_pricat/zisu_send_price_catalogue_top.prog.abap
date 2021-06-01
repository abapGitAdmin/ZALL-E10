*&---------------------------------------------------------------------*
*& Include ZISU_SEND_PRICE_CATALOGUE_TOP                     Report ZISU_SEND_PRICE_CATALOGUE
*&
*&---------------------------------------------------------------------*
REPORT zisu_send_price_catalogue.
TABLES: edextask.

SELECTION-SCREEN BEGIN OF BLOCK select1 WITH FRAME TITLE TEXT-001 .
PARAMETERS: p_pricat TYPE zmosb_pricat_ver-price_catalogue_id,
            p_priver TYPE zmosb_pricat_ver-pricat_version.
SELECTION-SCREEN END OF BLOCK select1.


SELECTION-SCREEN BEGIN OF BLOCK select2 WITH FRAME TITLE TEXT-002 .
PARAMETERS:     p_msb   TYPE /idxgc/s_proc_step_hdr_dispall-own_servprov.
SELECTION-SCREEN END OF BLOCK select2.
SELECTION-SCREEN BEGIN OF BLOCK select3  WITH FRAME TITLE TEXT-003 .

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_di  RADIOBUTTON GROUP rece USER-COMMAND sel DEFAULT 'X'.
SELECTION-SCREEN COMMENT 3(26) text-t01.
SELECT-OPTIONS : so_lief  FOR edextask-dexservprov NO INTERVALS MODIF ID SEL.
SELECTION-SCREEN END OF LINE.

PARAMETERS: p_all TYPE kennzx RADIOBUTTON GROUP rece.
SELECTION-SCREEN END OF BLOCK select3.
