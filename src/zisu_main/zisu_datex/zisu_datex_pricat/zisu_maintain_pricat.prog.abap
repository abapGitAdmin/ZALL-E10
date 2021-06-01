*&---------------------------------------------------------------------*
*& Report ZISU_DISPLAY_PRICAT_IN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZISU_MAINTAIN_PRICAT.

CALL FUNCTION 'VIEWCLUSTER_MAINTENANCE_CALL'
  EXPORTING
    viewcluster_name     = 'ZVC_PRICAT'
    maintenance_action   = 'S'
    show_selection_popup = space
  EXCEPTIONS
    foreign_lock         = 2.
