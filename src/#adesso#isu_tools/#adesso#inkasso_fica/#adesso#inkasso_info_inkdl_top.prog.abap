*&---------------------------------------------------------------------*
*&  Include           /ADESSO/INKASSO_INFO_INKDL_TOP
*&---------------------------------------------------------------------*

DATA: p_string(6000) TYPE c.
DATA: gv_dirname TYPE pathextern.

DATA: gt_dd03m TYPE STANDARD TABLE OF dd03m.
DATA: gs_dd03m TYPE dd03m.
DATA: gt_cust TYPE TABLE OF /adesso/ink_cust.
DATA: gs_cust TYPE /adesso/ink_cust.

DATA: gs_ink_infi     TYPE /adesso/ink_infi.
DATA: gt_ink_infi     TYPE TABLE OF /adesso/ink_infi.
DATA: gt_ink_ialv     TYPE TABLE OF /adesso/ink_infi.
DATA: gs_ink_idat_alv TYPE /adesso/ink_idat_alv.
DATA: gt_ink_idat_alv TYPE TABLE OF /adesso/ink_idat_alv.


DATA: BEGIN OF gs_gpvk,
        gpart	  TYPE gpart_kk,
        vkont	  TYPE vkont_kk,
        satztyp	TYPE /adesso/ink_infost,
        infodat	TYPE /adesso/ink_infodt,
        inkgp	  TYPE inkgp_kk,
      END OF gs_gpvk.
DATA: gt_gpvk  LIKE TABLE OF gs_gpvk.

DATA: gv_abbrgrund TYPE /adesso/ink_abbrgrund.


DATA: gf_read_i    TYPE syst-dbcnt.
DATA: gf_insert_i  TYPE syst-dbcnt.
DATA: gf_subrc     TYPE syst-subrc.

DATA: gv_file_bom      TYPE sychar01,
      gv_file_encoding TYPE sychar01.


TYPES: name_of_dir(1024)  TYPE c,
       name_of_file(260)  TYPE c,
       name_of_path(1285) TYPE c.

DATA: BEGIN OF gs_file,
        dirname     TYPE name_of_dir,
        filename    TYPE name_of_file,
        type(10)    TYPE c,
        len(8)      TYPE p,
        owner(8)    TYPE c,
        mtime(6)    TYPE p,
        mode(9)     TYPE c,
        useable(1)  TYPE c,
        subrc(4)    TYPE c,
        errno(3)    TYPE c,
        errmsg(40)  TYPE c,
        mod_date    TYPE d,
        mod_time(8) TYPE c,
        seen(1)     TYPE c,
        changed(1)  TYPE c,
      END OF gs_file.
DATA: gt_file LIKE TABLE OF gs_file.

CONSTANTS: gc_mark TYPE c VALUE 'X'.

* ALV
TYPE-POOLS: slis.
DATA: gt_event       TYPE slis_t_event.
DATA: gs_listheader  TYPE slis_listheader.
DATA: gt_listheader  TYPE slis_listheader OCCURS 1.
DATA: gs_layout      TYPE slis_layout_alv.
DATA: g_user_command TYPE slis_formname VALUE 'UCOMM_POPUP'.

* Selektionsbidschirm
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME.
PARAMETERS: p_fname LIKE filename-fileintern OBLIGATORY.
SELECTION-SCREEN SKIP.
PARAMETERS: p_updt RADIOBUTTON GROUP butt.
PARAMETERS: p_snew RADIOBUTTON GROUP butt.
PARAMETERS: p_show RADIOBUTTON GROUP butt DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK bl1.
