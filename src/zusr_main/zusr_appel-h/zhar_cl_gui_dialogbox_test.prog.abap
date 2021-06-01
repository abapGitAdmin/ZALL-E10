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
* INITIAL         appel-h  01.01.2020
************************************************************************
*******
REPORT zhar_cl_gui_dialogbox_test.


SELECT proc_ref, proc_step_ref, quant_type_qual, quantity_ext, datefrom, dateto FROM /idxgc/prst_mciq
  INTO TABLE @DATA(lt_mciq)
WHERE proc_ref      = '0'
 AND  proc_step_ref = '010'.

lt_mciq = value #( base lt_mciq ( proc_ref = '001' ) ).

DATA lo_structdescr   TYPE REF TO cl_abap_structdescr.
DATA ls_data          LIKE LINE OF lt_mciq.

lo_structdescr ?= cl_abap_structdescr=>describe_by_data( ls_data ).
DATA(lt_comp) = lo_structdescr->get_components( ).

DATA(lt_fieldcat) = VALUE lvc_t_fcat( FOR ls IN lt_comp ( fieldname = ls-name ref_table = '/IDXGC/PRST_MCIQ' ) ).
lt_fieldcat[ fieldname = 'QUANTITY_EXT' ]-do_sum = 'X'.
DATA(ls_layout) = VALUE lvc_s_layo( col_opt = 'X'
   no_toolbar = 'X' ).

DATA lo_dialogbox             TYPE REF TO cl_gui_dialogbox_container.
DATA lo_alv_grid              TYPE REF TO cl_gui_alv_grid.
CREATE OBJECT lo_dialogbox
  EXPORTING
    width                       = 1000 "Breite
    height                      = 100  "Höhe
    top                         = 100 "Abstand von oben
    left                        = 200 "Abstand von links
    caption                     = 'Quantities'
    no_autodef_progid_dynnr     = abap_true
  EXCEPTIONS
    cntl_error                  = 1
    cntl_system_error           = 2
    create_error                = 3
    lifetime_error              = 4
    lifetime_dynpro_dynpro_link = 5
    event_already_registered    = 6
    error_regist_event          = 7
    OTHERS                      = 8.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

DATA(lo_handler) = NEW zhar_cl_dialogbox_handler(  ).

SET HANDLER lo_handler->dialogbox_close FOR lo_dialogbox.

TRY.
    lo_alv_grid =  NEW cl_alv_grid_xt( i_parent = lo_dialogbox i_optimize_output = '' ).
  CATCH cx_root INTO DATA(lx_ex).
    MESSAGE 'problems creating cl_gui_alv_grid' TYPE 'X'.
ENDTRY.

lo_alv_grid->set_table_for_first_display(
   EXPORTING
*        i_buffer_active               =                  " Pufferung aktiv
*        i_bypassing_buffer            =                  " Puffer ausschalten
*        i_consistency_check           =                  " Starte Konsistenzverprobung für Schnittstellefehlererkennung
*        i_structure_name              =  lv_strucname     " Strukturname der internen Ausgabetabelle
    "is_variant                    =  ls_variant       " Anzeigevariante
    i_save                        =  'A'              " Anzeigevariante sichern
    !i_default                     = abap_true " Defaultanzeigevariante
    is_layout                     =  ls_layout        " Layout
*        is_print                      =                  " Drucksteuerung
*        it_special_groups             =                  " Feldgruppen
    "it_toolbar_excluding          =  lt_std_func_excl      " excludierte Toolbarstandardfunktionen
*        it_hyperlink                  =                  " Hyperlinks
*        it_alv_graphics               =                  " Tabelle von der Struktur DTC_S_TC
*        it_except_qinfo               =                  " Tabelle für die Exception Quickinfo
*        ir_salv_adapter               =                  " Interface ALV Adapter
  CHANGING
    it_outtab                     = lt_mciq        " Ausgabetabelle
    it_fieldcatalog               = lt_fieldcat       " Feldkatalog
*        it_sort                       =                  " Sortierkriterien
*        it_filter                     =                  " Filterkriterien
*      EXCEPTIONS
*        invalid_parameter_combination = 1                " Parameter falsch
*        program_error                 = 2                " Programmfehler
*        too_many_lines                = 3                " Zu viele Zeilen in eingabebereitem Grid.
*        others                        = 4
).
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.
"SET HANDLER me->/adz/if_inv_salv_table_evt_hlr~on_user_command FOR lo_alv_grid.
"SET HANDLER me->/adz/if_inv_salv_table_evt_hlr~on_hotspotclick FOR lo_alv_grid.
WRITE: space.
