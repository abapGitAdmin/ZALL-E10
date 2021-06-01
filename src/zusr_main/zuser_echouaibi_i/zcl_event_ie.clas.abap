class ZCL_EVENT_IE definition
  public
  final
  create public .

public section.

  data LT_MARA type Z_TT_MARA .

  methods CONSTRUCTOR .
  methods ON_HANDLE_GET_MARA_DETAILS
    for event DOUBLE_CLICK of CL_GUI_ALV_GRID
    importing
      !E_ROW
      !E_COLUMN
      !ES_ROW_NO .
  methods STEWARD
    importing
      !IV_NOTFALL type XFELD .
  methods GET_MARA_DETAILS .
  methods BUILD_ALV .
protected section.
private section.

  class-data PAUSE type XFELD .
  data GR_ALV_GRID type ref to CL_GUI_ALV_GRID .

  events CALL_STEWARDS
    exporting
      value(IV_NOTFALL) type XFELD .

  methods ON_HANDLE_CALL_STEWARD
    for event CALL_STEWARDS of ZCL_EVENT_IE
    importing
      !IV_NOTFALL .
ENDCLASS.



CLASS ZCL_EVENT_IE IMPLEMENTATION.


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

* ALV-Anzeige anstoßen

    gr_alv_grid->set_table_for_first_display(
      EXPORTING
*    i_buffer_active               =                  " Pufferung aktiv
*    i_bypassing_buffer            =                  " Puffer ausschalten
*    i_consistency_check           =                  " Starte Konsistenzverprobung für Schnittstellefehlererkennung
     i_structure_name              =  'MARA'                " Strukturname der internen Ausgabetabelle
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
        it_outtab                     =      lt_mara            " Ausgabetabelle
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

    WRITE space.



  ENDMETHOD.


  METHOD constructor.

    SET HANDLER me->on_handle_call_steward FOR ALL INSTANCES.
*    SET HANDLER me->on_handle_get_mara_details FOR me->gr_alv_grid.
    SET HANDLER me->on_handle_get_mara_details FOR ALL INSTANCES.

  ENDMETHOD.


  method GET_MARA_DETAILS.



    select * from mara INTO TABLE lt_mara.

  endmethod.


  METHOD on_handle_call_steward.

    CASE iv_notfall.
      WHEN 'X'.
        WRITE: 'Schnell ein Notfall'.
      WHEN space.
        WRITE: 'schauen wir gemütlich vorbei'.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.


  method ON_HANDLE_GET_MARA_DETAILS.

  READ TABLE lt_mara INTO data(wa_out) INDEX e_row-index.

    IF e_column-fieldname = 'MATNR' .


    SET PARAMETER ID 'MAT' FIELD wa_out-matnr.

    CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

    ENDIF.
  endmethod.


  METHOD steward.


    IF iv_notfall = 'X' OR pause = space.


      RAISE EVENT call_stewards
        EXPORTING
          iv_notfall = iv_notfall                " Feld zum Ankreuzen
        .

    ELSE.
      WRITE: 'der Passagier kann warten, wir haben Pause'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
