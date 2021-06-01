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
REPORT z_sapnuts_event.


*CLASS cl_events DEFINITION DEFERRED.


CLASS cl_events DEFINITION. "class definition
  PUBLIC SECTION.
    EVENTS : no_material. "event
    METHODS : get_material_details
      IMPORTING im_matnr TYPE mara-matnr
      EXPORTING ex_mara  TYPE mara.
    METHODS : event_handler FOR EVENT no_material OF cl_events. "event handler method
ENDCLASS.


CLASS cl_events IMPLEMENTATION.
  METHOD get_material_details.
    SELECT SINGLE * FROM mara
      INTO ex_mara
      WHERE matnr = im_matnr.
    IF sy-subrc NE 0.
      RAISE EVENT no_material. "triggering point
    ENDIF.
  ENDMETHOD.
  METHOD event_handler.
    WRITE :/ 'No material found'. "event handler method implementation
  ENDMETHOD.
ENDCLASS.

DATA lo_event TYPE REF TO cl_events. "declare class
DATA : wa_mara TYPE mara. "declare work area

PARAMETERS p_matnr TYPE mara-matnr. "Material no input

START-OF-SELECTION.
  CREATE OBJECT LO_EVENT. "create object
  SET HANDLER LO_EVENT->EVENT_HANDLER FOR LO_EVENT. "register event handler method for the object

  CALL METHOD LO_EVENT->GET_MATERIAL_DETAILS "call method to get material details
    EXPORTING
      IM_MATNR = P_MATNR
    IMPORTING
      EX_MARA  = WA_MARA.

  WRITE :/ WA_MARA-MATNR, WA_MARA-MTART, WA_MARA-MEINS, WA_MARA-MATKL.
