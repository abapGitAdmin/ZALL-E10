CLASS /adz/cl_inv_gui_dialogbox DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS :
      create_dialogbox
        IMPORTING
                  VALUE(iv_width)        TYPE i DEFAULT 30
                  VALUE(iv_height)       TYPE i DEFAULT 30
                  VALUE(iv_top)          TYPE i DEFAULT 10
                  VALUE(iv_left)         TYPE i DEFAULT 10
                  VALUE(iv_title)        TYPE c OPTIONAL
                  is_layout              TYPE lvc_s_layo OPTIONAL
        CHANGING
                  ct_fieldcat            TYPE lvc_t_fcat
                  ct_data                TYPE ANY TABLE
        RETURNING VALUE(ro_gui_alv_grid) TYPE REF TO cl_gui_alv_grid
        .
    METHODS :
      constructor
         IMPORTING io_cont  type ref to CL_GUI_CONTAINER,
      dialogbox_close
                  FOR EVENT close OF cl_gui_dialogbox_container
        IMPORTING sender.



  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mo_cont type  ref to CL_GUI_CONTAINER.
ENDCLASS.



CLASS /adz/cl_inv_gui_dialogbox IMPLEMENTATION.
  method constructor.
    mo_cont = io_cont.
  endmethod.

  METHOD dialogbox_close.
    sender->free(
       EXCEPTIONS
           OTHERS  = 1 ).
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    free mo_cont.
  ENDMETHOD.


  METHOD create_dialogbox.
    DATA lo_dialogbox             TYPE REF TO cl_gui_dialogbox_container.
    DATA lo_alv_grid              TYPE REF TO cl_gui_alv_grid.
    CREATE OBJECT lo_dialogbox
      EXPORTING
        width                       = iv_width   "Breite
        height                      = iv_height  "Höhe
        top                         = iv_top     "Abstand von oben
        left                        = iv_left    "Abstand von links
        caption                     = iv_title
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
    DATA(lo_handler) = NEW /adz/cl_inv_gui_dialogbox( io_cont =  lo_dialogbox ).
    SET HANDLER lo_handler->dialogbox_close FOR lo_dialogbox.

    DATA(ls_layout) = VALUE lvc_s_layo( col_opt = 'X'  no_toolbar = 'X' ).
    if is_layout is SUPPLIED.
      ls_layout = is_layout.
    endif.

    TRY.
        lo_alv_grid =  NEW cl_gui_alv_grid( i_parent = lo_dialogbox ).
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
        "i_default                     = abap_true " Defaultanzeigevariante
        is_layout                     =  ls_layout        " Layout
*        is_print                      =                  " Drucksteuerung
*        it_special_groups             =                  " Feldgruppen
        "it_toolbar_excluding          =  lt_std_func_excl      " excludierte Toolbarstandardfunktionen
*        it_hyperlink                  =                  " Hyperlinks
*        it_alv_graphics               =                  " Tabelle von der Struktur DTC_S_TC
*        it_except_qinfo               =                  " Tabelle für die Exception Quickinfo
*        ir_salv_adapter               =                  " Interface ALV Adapter
      CHANGING
        it_outtab                     = ct_data           " Ausgabetabelle
        it_fieldcatalog               = ct_fieldcat       " Feldkatalog
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
    ro_gui_alv_grid = lo_alv_grid.

  ENDMETHOD.
ENDCLASS.
