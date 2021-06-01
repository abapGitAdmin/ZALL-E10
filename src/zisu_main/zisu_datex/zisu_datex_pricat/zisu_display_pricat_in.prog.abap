*&---------------------------------------------------------------------*
*& Report ZISU_DISPLAY_PRICAT_IN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZISU_DISPLAY_PRICAT_IN.

CALL FUNCTION 'VIEWCLUSTER_MAINTENANCE_CALL'          "SW 261095
  EXPORTING
    viewcluster_name     = 'ZVC_PRICAT_IN'
    maintenance_action   = 'S'
    show_selection_popup = space
  EXCEPTIONS
    foreign_lock         = 2.
