*&---------------------------------------------------------------------*
*& Report ZSCH_09_RTTI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsch_09_rtti.

DATA: gr_typedescr           TYPE REF TO cl_abap_typedescr,
      gr_typedescr_typedescr TYPE REF TO cl_abap_typedescr.

START-OF-SELECTION.

WRITE: / 'Name des Datenelement: XUBNAME'.
gr_typedescr = cl_abap_typedescr=>describe_by_name( 'XUBNAME' ).
gr_typedescr_typedescr = cl_abap_typedescr=>describe_by_object_ref( gr_typedescr ).
WRITE: / 'Beschreibungsobjekt Typname:', gr_typedescr_typedescr->absolute_name.

WRITE: / 'Name des Datenelement: USR01'.
gr_typedescr = cl_abap_typedescr=>describe_by_name( 'USR01' ).
gr_typedescr_typedescr = cl_abap_typedescr=>describe_by_object_ref( gr_typedescr ).
WRITE: / 'Beschreibungsobjekt Typname:', gr_typedescr_typedescr->absolute_name.
