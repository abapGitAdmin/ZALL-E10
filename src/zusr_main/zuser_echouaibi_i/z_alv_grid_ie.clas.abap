class Z_ALV_GRID_IE definition
  public
  final
  create public .

public section.

  data:
    LT_SCARR type STANDARD TABLE OF SCARR .
  data GR_ALV_GRID type ref to CL_GUI_ALV_GRID .
  data IT_FCAT type SLIS_T_FIELDCAT_ALV .

  methods BUILD_ALV .
  methods ALV_DISPLAY .
  methods HANDLE_DOUBLE_CLICK
    for event DOUBLE_CLICK of CL_GUI_ALV_GRID
    importing
      !E_ROW
      !E_COLUMN
      !ES_ROW_NO .
  methods FETCH_DATA
    importing
      !IM_SO_CARR type TYP_R_CARRID .
protected section.
private section.

  data GT_FCAT type LVC_T_FCAT .
  data WA_FCAT like LINE OF IT_FCAT .
ENDCLASS.



CLASS Z_ALV_GRID_IE IMPLEMENTATION.


  METHOD alv_display.

    gr_alv_grid->set_table_for_first_display(
  EXPORTING
*    i_buffer_active               =                  " Pufferung aktiv
*    i_bypassing_buffer            =                  " Puffer ausschalten
*    i_consistency_check           =                  " Starte Konsistenzverprobung für Schnittstellefehlererkennung
    i_structure_name              =  'SCARR'                " Strukturname der internen Ausgabetabelle
*    is_variant                    =                  " Anzeigevariante
*    i_save                        =                  " Anzeigevariante sichern
*    i_default                     = 'X'              " Defaultanzeigevariante
*    is_layout                     =                  " Layout
*    is_print                      =                  " Drucksteuerung
*    it_special_groups             =                  " Feldgruppen
*    it_toolbar_excluding          =                  " excludierte Toolbarstandardfunktionen
*    it_hyperlink                  =                  " Hyperlinks
*    it_alv_graphics               =                  " Tabelle von der Struktur DTC_S_TC
*    it_except_qinfo               =                  " Tabelle für die Exception Quickinfo
*    ir_salv_adapter               =                  " Interface ALV Adapter
  CHANGING
    it_outtab                     =      lt_scarr            " Ausgabetabelle
*    it_fieldcatalog               =                  " Feldkatalog
*    it_sort                       =                  " Sortierkriterien
*    it_filter                     =                  " Filterkriterien
  EXCEPTIONS
    invalid_parameter_combination = 1                " Parameter falsch
    program_error                 = 2                " Programmfehler
    too_many_lines                = 3                " Zu viele Zeilen in eingabebereitem Grid.
    OTHERS                        = 4
).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.




  ENDMETHOD.


  METHOD build_alv.

    CREATE OBJECT gr_alv_grid
      EXPORTING
*       i_shellstyle      = 0                " Control Style
*       i_lifetime        =                  " Lifetime
        i_parent          = cl_gui_custom_container=>default_screen  " Parent-Container
*       i_appl_events     = space            " Ereignisse als Applikationsevents registrieren
*       i_parentdbg       =                  " Internal, donnot use.
*       i_applogparent    =                  " Container for application log
*       i_graphicsparent  =                  " Container for graphics
*       i_name            =                  " Name
*       i_fcat_complete   = space            " boolsche Variable (X=true, space=false)
      EXCEPTIONS
        error_cntl_create = 1                " Fehler beim Erzeugen des Controls
        error_cntl_init   = 2                " Fehler beim Initialisieren des Controls
        error_cntl_link   = 3                " Fehler beim Linken des Controls
        error_dp_create   = 4                " Fehler beim Erzeugen des DataProvider Control
        OTHERS            = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


  ENDMETHOD.


  method FETCH_DATA.



    select * FROM scarr INTO TABLE lt_scarr
      WHERE carrid in im_so_carr.

  endmethod.


  method HANDLE_DOUBLE_CLICK.
  endmethod.
ENDCLASS.
