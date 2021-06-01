FUNCTION-POOL z_adesso_inv_manager.              "MESSAGE-ID ..

* INCLUDE LZAD_INV_MANAGERD...               " Local class definition

DATA ok TYPE ok.
data DINT_INV_DOC_NO TYPE INV_INT_INV_DOC_NO.
DATA Dfreetext1 TYPE /IDEXGE/REJ_NOTI-FREE_TEXT1.
DATA DFORALL TYPE c.
DATA DRSTGR TYPE TINV_INV_DOC-RSTGR.

** Class
CLASS: cl_inv_inv_remadv_log   DEFINITION LOAD,
       cl_inv_inv_remadv_doc   DEFINITION LOAD.
CONSTANTS co_spart_strom TYPE sparte VALUE 'ST'.
CONSTANTS co_spart_gas   TYPE sparte VALUE 'GA'.
CONSTANTS co_z_msgid TYPE sy-msgid VALUE 'Z_ADESSO_INV_MANAGER'.

TYPES: BEGIN OF t_customizing_consumption,
         is_rlm(1)        TYPE c, "RLM
         is_slp(1)        TYPE c, "SLP
         is_pauschal(1)   TYPE c, "Pauschalanlage
         pauschverb       TYPE inv_quant,
         sparte           TYPE sparte, "Sparte
         t_tinv_c_inchcka TYPE ttinv_c_inchcka, "Prüfparameter aus CustomizingTTINV_C_INCHCKA
         t_tinv_c_inchckp TYPE ttinv_c_inchckp, "Prüfparameter aus Customizing
         tinv_c_inchcka   TYPE tinv_c_inchcka,
         tinv_c_inchckp   TYPE tinv_c_inchckp,
         r_servid         TYPE iisu_ranges, "Zu prüfende Artikelnummern
         r_mrreason       TYPE iisu_ranges,
         r_anlage         TYPE iisu_ranges,
         datedif          TYPE i, "Toleranzdatum
         searchdate       TYPE i, "Toleranzdatum Suchzeitraum
         consdiff         TYPE i,
         firstproc        TYPE d,
         maxleiprof       TYPE profval,
         anlage           TYPE anlage,
         int_ui           TYPE int_ui,
         ext_ui           TYPE ext_ui,
       END OF t_customizing_consumption.

TYPES: BEGIN OF t_mengen_invoice,
         artikelnr TYPE inv_product_id,
         menge     TYPE inv_quant,
       END OF t_mengen_invoice.

TYPES tt_mengen_invoice TYPE TABLE OF t_mengen_invoice.

** MessageWork
INCLUDE: inv_return_msg,
         iee_inv_constants_cust,
         iece_servprov_const,
         iinvoice_ident_type,
         ie00flag.


DATA gv_ok_sim TYPE ok.


DATA: go_cont     TYPE REF TO cl_gui_custom_container, "Definition Container-Referenzobjekt für Control
      go_alv_cont TYPE REF TO cl_gui_alv_grid.         "Definition ALV-Referenzobjekt

TYPES: BEGIN OF t_ausgabe_sim,
         int_inv_doc_no TYPE inv_int_inv_doc_no,
         status_old(1)  TYPE c,
         status_sim_vp  TYPE icon_d,
         status_sim_msc TYPE icon_d,
         msc_start      TYPE /adesso/inv_msc-msc_start,
         msc_end        TYPE /adesso/inv_msc-msc_end,
         case           TYPE /adesso/inv_case-casenr,
         status_ok      TYPE c,
         status_rek     TYPE c,
         status_bear    TYPE c,
         bemerkung      TYPE /adesso/invtext-text,
       END OF t_ausgabe_sim.

TYPES: BEGIN OF t_log_sim,
         int_inv_doc_no TYPE inv_int_inv_doc_no,
         verbrauchmsc   TYPE c,
         messages       TYPE ttinv_log_msgbody,
       END OF t_log_sim.

DATA gt_log_sim TYPE TABLE OF t_log_sim.


TYPES: tt_ausgabe_sim TYPE STANDARD TABLE OF t_ausgabe_sim.

DATA: gt_ausgabe_sim TYPE TABLE OF t_ausgabe_sim.

CONSTANTS: true  TYPE xfeld VALUE 'X',
           false TYPE xfeld VALUE space.

DATA gt_inv_doc_no TYPE tinv_int_inv_doc_no.

CONSTANTS: gv_handle_num1 TYPE slis_handl VALUE 'NUM1'.

* Constants for isu_objects
INCLUDE /isidex/inv_inchck_constants.
