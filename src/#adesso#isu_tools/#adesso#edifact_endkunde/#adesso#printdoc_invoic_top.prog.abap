*&---------------------------------------------------------------------*
*&  Include           /ADESSO/PRINTDOC_INVOIC_TOP
*&---------------------------------------------------------------------*
*
* Änderungshistorie:
* Datum      Benutzer Grund
* ----------------------------------------------------------------

INCLUDE emsg.

TYPE-POOLS: eemsg.

TYPES: BEGIN OF ts_error_tab,
         msg_typ    TYPE emsg_gen-msgty,
         msg_klasse TYPE emsg_gen-msgid,
         msg_nr     TYPE emsg_gen-msgno,
         msg_1      TYPE emsg_gen-nachricht,
         msg_2      TYPE emsg_gen-nachricht,
         msg_3      TYPE emsg_gen-nachricht,
         msg_4      TYPE emsg_gen-nachricht,
       END OF ts_error_tab.

TABLES:         fkkop,
                ever,
                erch.

FIELD-SYMBOLS: <gs_erdz_01>         TYPE          erdz.

DATA:           gs_param            TYPE          eemsg_parm_open,
                gs_eemsg_sub        TYPE          eemsg_sub,
                gt_eemsg_sub        TYPE TABLE OF eemsg_sub,
                gt_fkkvkp           TYPE TABLE OF fkkvkp,
                gs_fkkvkp           TYPE          fkkvkp,
                gs_ever             TYPE          ever,
                gt_erdk             TYPE TABLE OF erdk,
                gs_erdk             TYPE          erdk,
                gt_erdk_paper       TYPE TABLE OF erdk,
                gv_reverse          TYPE          regen-kennzx,
                gv_vkonto           TYPE          fkkvkp-vkont,
                gv_nocomm           TYPE          regen-kennzx,
                gv_noidocsend       TYPE          regen-kennzx,
                gv_filename         TYPE          so_obj_des,
                gs_euiinstln        TYPE          euiinstln,
                gt_erch             TYPE TABLE OF erch,
                gs_erch             TYPE          erch,
                gs_erdz             TYPE          erdz,
                gs_ecrossrefno      TYPE          ecrossrefno,
                gt_ecrossrefno_read TYPE TABLE OF ecrossrefno,
                gs_ecrossrefno_read TYPE          ecrossrefno,
                gs_invoice          TYPE          isu21_print_doc,
                gv_edi_01           TYPE          /adesso/edivar-edivariante,
                gv_anlage_01        TYPE          anlage,

                gv_error            TYPE          sysubrc,
                gv_error_log        TYPE          regen-kennzx,
                gv_receiver         TYPE          sy-subrc,

                gt_message          TYPE TABLE OF solisti1,
                gs_message          TYPE          solisti1,
                gt_attach           TYPE TABLE OF solisti1,
                gs_attach           TYPE          solisti1,

                gt_edivar           TYPE TABLE OF /adesso/edivar,
                gs_edivar           TYPE          /adesso/edivar,

                gv_sender           TYPE          eservprov-serviceid,
                gv_empf             TYPE          eservprov-serviceid,
                gv_handle           TYPE          emsg_gen-handle,
                gs_edi_abs          TYPE          /adesso/edi_abs,
                gs_error_tab        TYPE          ts_error_tab,
                gt_error_tab        TYPE TABLE OF ts_error_tab,
                gv_sent             TYPE          sy-tabix,
                gv_not_sent         TYPE          sy-tabix,
                gv_tabix            TYPE          sy-tabix,
                gv_datum_01         TYPE          datum,
                ls_v_eanl           TYPE v_eanl,
                lt_eanl             TYPE STANDARD TABLE OF eanl,
                ls_eanl             TYPE eanl,
                lv_int_ui           TYPE int_ui.
* End

CLASS cl_abap_char_utilities DEFINITION LOAD.

CONSTANTS: gc_con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
           gc_con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
*-----------------------------------------------------------------------
* Selectionscreen
*-----------------------------------------------------------------------

SELECTION-SCREEN BEGIN OF SCREEN 100 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK selpar WITH FRAME TITLE text-004.
SELECT-OPTIONS: so_gpart  FOR fkkop-gpart,
                so_vkont  FOR fkkop-vkont.
SELECT-OPTIONS: s_edi     FOR  gv_edi_01           MATCHCODE OBJECT zeideh_edivar       OBLIGATORY.
PARAMETERS:     p_sparte TYPE sparte                                                     OBLIGATORY DEFAULT '01',
                p_spself TYPE eservprov-serviceid NO-DISPLAY,
                p_spfrem TYPE eservprov-serviceid NO-DISPLAY.
PARAMETER:      p_extnr TYPE balhdr-extnumber      NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK selpar.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK pardruck WITH FRAME TITLE text-005.
PARAMETERS:     p_pdruck AS CHECKBOX,
                p_email  TYPE somlreci1-receiver DEFAULT 'vorname.nachname@eon-energie.com'.
SELECTION-SCREEN END OF BLOCK pardruck.
SELECTION-SCREEN END OF SCREEN 100.

SELECTION-SCREEN BEGIN OF SCREEN 200 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-b01.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_sel_1 TYPE c             RADIOBUTTON GROUP gr1.
SELECTION-SCREEN COMMENT 4(24) text-c01.
SELECTION-SCREEN POSITION 29.
PARAMETERS: p_idoc_1 TYPE edi_docnum.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_sel_2 TYPE c             RADIOBUTTON GROUP gr1.
SELECTION-SCREEN COMMENT 4(24) text-c02.
SELECTION-SCREEN POSITION 29.
PARAMETERS: p_prbl_1 TYPE opbel_kk.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b01.
SELECTION-SCREEN END OF SCREEN 200.

SELECTION-SCREEN: BEGIN OF TABBED BLOCK mytab FOR 12 LINES,
                  TAB (20) button1 USER-COMMAND push1,
                  TAB (20) button2 USER-COMMAND push2,
                  END OF BLOCK mytab.
