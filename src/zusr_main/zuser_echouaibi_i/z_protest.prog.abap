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
*&
************************************************************************
*******
REPORT Z_PROTEST.

TABLES: mara.
*---------------------------------------------------------------------*
*                        W O R K  A R E A S                           *
*---------------------------------------------------------------------*
DATA:
*  Material Data
  BEGIN OF wa_mara,
    matnr    TYPE   mara-matnr,         " Material No.
    mtart    TYPE   mara-mtart,         " Material Type
    bismt    TYPE   mara-bismt,         " Old material No.
    matkl    TYPE   mara-matkl,         " Material group
    meins    TYPE   mara-meins,         " Base Unit of Measure
    brgew    TYPE   mara-brgew,         " Gross Weight
    ntgew    TYPE   mara-ntgew,         " Net Weight
    gewei    TYPE   mara-gewei,         " Weight Unit
  END OF wa_mara,

* Field Catalog

wa_fieldcat   TYPE lvc_s_fcat.

*---------------------------------------------------------------------*
*                   I N T E R N A L   T A B L E S                     *
*---------------------------------------------------------------------*
DATA:
* For Material Data
  t_mara LIKE STANDARD TABLE OF wa_mara,
* For Field Catalog
  t_fieldcat  TYPE lvc_t_fcat.

*---------------------------------------------------------------------*
*                     W O R K  V A R I A B L E S                      *
*---------------------------------------------------------------------*
DATA:
* User Command
  ok_code TYPE sy-ucomm,
* Reference Variable for Docking Container
  r_dock_container  TYPE REF TO cl_gui_docking_container,
* Reference Variable for alv grid
  r_grid  TYPE REF TO cl_gui_alv_grid.

*---------------------------------------------------------------------*
*                S T A R T   O F   S E L E C T I O N                  *
*---------------------------------------------------------------------*
START-OF-SELECTION.
* To Display the Data
  PERFORM display_output.
*&--------------------------------------------------------------------*
*&      Form  display_output                                          *
*&--------------------------------------------------------------------*
*       To Call the  screen & display the output                      *
*---------------------------------------------------------------------*
*   There are no interface parameters to be passed to this subroutine.*
*---------------------------------------------------------------------*
FORM display_output .
* To fill the Field Catalog
  PERFORM fill_fieldcat USING :
      'MATNR'    'T_MARA'         'Material No.',
      'MTART'    'T_MARA'         'Material Type',
      'BISMT'    'T_MARA'         'Old Material No.',
      'MATKL'    'T_MARA'         'Material Group',
      'MEINS'    'T_MARA'         'Base Unit of Measure',
      'BRGEW'    'T_MARA'         'Gross Weight',
      'NTGEW'    'T_MARA'         'Net Weight',
      'GEWEI'    'T_MARA'         'Weight Unit'.
  CALL SCREEN 500.
ENDFORM.                               " Display_output

*&--------------------------------------------------------------*
*&      Form  FILL_FIELDCAT                                     *
*&--------------------------------------------------------------*
*       To Fill the Field Catalog                               *
*---------------------------------------------------------------*
*  Three Parameters are passed                                  *
*  pv_field   TYPE any for Field                                *
*  pv_tabname TYPE any for Table Name                           *
*  pv_coltext TYPE any for Header Text                          *
*---------------------------------------------------------------*
FORM fill_fieldcat  USING   pv_field   TYPE any
                            pv_tabname TYPE any
                            pv_coltext TYPE any .

  wa_fieldcat-fieldname  = pv_field.
  wa_fieldcat-tabname    = pv_tabname.
  wa_fieldcat-coltext    = pv_coltext.

  APPEND wa_fieldcat TO t_fieldcat.
  CLEAR  wa_fieldcat.
ENDFORM.                               " FILL_FIELDCAT

*Create the Screen 0500.

*Flow Logic for Screen 500.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT                                    *
*&---------------------------------------------------------------------*
*       To Set GUI Status & Title                                      *
*----------------------------------------------------------------------*
MODULE status_0500 OUTPUT.

  SET PF-STATUS 'STATUS'.
  SET TITLEBAR 'TITLE'.

ENDMODULE.                             " STATUS_0500  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  CREATE_OBJECTS  OUTPUT                                 *
*&---------------------------------------------------------------------*
*       To Call the Docking Container & Display Method                 *
*----------------------------------------------------------------------*
MODULE create_objects OUTPUT.
* Create a Docking container and dock the control at right side of screen
  CHECK r_dock_container IS  INITIAL.
  CREATE OBJECT r_dock_container
    EXPORTING
   side                        = cl_gui_docking_container=>dock_at_right
      extension                   = 780
      caption                     = 'Materials'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.                               "  IF sy-subrc <> 0.

* To Create the Grid Instance
  CREATE OBJECT r_grid
    EXPORTING
      i_parent          = r_dock_container
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.
  IF sy-subrc <> 0.
 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.                               " IF sy-subrc <> 0.

* Formatted Output Table is Sent to Control
  CALL METHOD r_grid->set_table_for_first_display
    CHANGING
      it_outtab                      =  t_mara
      it_fieldcatalog                =  t_fieldcat
*      it_sort                       =
*      it_filter                     =
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4
          .
  IF sy-subrc <> 0.
   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.                               " IF sy-subrc <> 0.
ENDMODULE.                             " CREATE_OBJECTS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT                               *
*&---------------------------------------------------------------------*
*     To Fetch the Material Data & Refresh Table after get User Command*
*----------------------------------------------------------------------*
MODULE user_command_0500 INPUT.
  CASE ok_code.
    WHEN 'EXECUTE'.
      SELECT matnr                     " material no.
             mtart                     " material type
             bismt                     " old material no.
             matkl                     " material group
             meins                     " base unit of measure
             brgew                     " gross weight
             ntgew                     " net weight
             gewei                     " weight unit
        FROM mara
        INTO TABLE t_mara
        WHERE  mtart = mara-mtart.
      IF sy-subrc <> 0.
      ENDIF.                           " IF sy-subrc EQ 0.
      CALL METHOD r_grid->refresh_table_display.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      LEAVE TO SCREEN 0.
  ENDCASE.                             " CASE ok_code.
ENDMODULE.                             " USER_COMMAND_0500  INPUT
