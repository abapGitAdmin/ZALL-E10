FUNCTION-POOL /adesso/wo_req MESSAGE-ID /adesso/wo_mon .

*----------------------------------------------------------------------
* Datenbanktabellen
*----------------------------------------------------------------------
TABLES: /adesso/wo_req.                "Dialogfelder für /ADESSO/WO_REQ

*----------------------------------------------------------------------
* interne Tabellen
*----------------------------------------------------------------------
DATA: gt_tc_fkkop TYPE TABLE OF /adesso/wo_fkkcoll.
DATA: gs_tc_fkkop TYPE /adesso/wo_fkkcoll.
DATA: gt_begr TYPE TABLE OF /adesso/wo_begr.   "Berechtigungsgruppen
DATA: gs_begr TYPE /adesso/wo_begr.
DATA: gt_bgus TYPE TABLE OF /adesso/wo_bgus.   "User - Berechtigungsgruppe
DATA: gs_bgus TYPE /adesso/wo_bgus.
DATA: gt_cust  TYPE TABLE OF /adesso/wo_cust.  "Customizing allgemein

*----------------------------------------------------------------------
* Felder
*----------------------------------------------------------------------
DATA: okcode      TYPE ok.
DATA: save_okcode TYPE ok.
DATA: text        TYPE string.
DATA: i           TYPE i.
DATA: char(40)    TYPE c.

*----------------------------------------------------------------------
* Text-Editor
*----------------------------------------------------------------------
DATA: seditor_container TYPE REF TO cl_gui_custom_container,
      stext_editor      TYPE REF TO cl_gui_textedit.

DATA: gt_editor_text TYPE TABLE OF text80.
DATA  gt_i_text TYPE TABLE OF text80.
DATA: BEGIN OF gs_text ,                                     "OCCURS 0,
        text TYPE text80,
      END OF gs_text.
*DATA  gt_i_text LIKE gs_text OCCURS 0 WITH HEADER LINE.
DATA: gv_text_modified TYPE c VALUE '' .      " Wurde irgend etwas verändert ?

*----------------------------------------------------------------------
* Table Control
*----------------------------------------------------------------------
CONTROLS: TC_FKKOP TYPE TABLEVIEW USING SCREEN 0110.
