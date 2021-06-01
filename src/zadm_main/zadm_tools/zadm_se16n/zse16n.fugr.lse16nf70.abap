*----------------------------------------------------------------------*
*   INCLUDE LSE16NF70                                                  *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  alv_variant_f4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_variant_f4.

DATA: ls_variant LIKE disvariant.
data: ld_exit(1).
DATA: BEGIN OF dynpfields OCCURS 1.
      INCLUDE STRUCTURE dynpread.
DATA: END OF dynpfields.


perform fill_variant changing ls_variant.

CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
     EXPORTING
          is_variant          = ls_variant
          i_save              = gd_save
     IMPORTING
          E_EXIT              = ld_exit
          es_variant          = ls_variant
     EXCEPTIONS
          not_found           = 1
          program_error       = 2
          OTHERS              = 3.

IF sy-subrc = 0 and ld_exit <> true.
   gd-variant     = ls_variant-variant.
   gd-varianttext = ls_variant-text.
   CLEAR dynpfields.
   REFRESH dynpfields.
   dynpfields-fieldname  = 'GD-VARIANT'.
   dynpfields-fieldvalue = gd-variant.
   APPEND dynpfields.
   dynpfields-fieldname  = 'GD-VARIANTTEXT'.
   dynpfields-fieldvalue = gd-varianttext.
   APPEND dynpfields.
   CALL FUNCTION 'DYNP_VALUES_UPDATE'
     EXPORTING
          dyname     = sy-cprog
          dynumb     = sy-dynnr
     TABLES
          dynpfields = dynpfields.
*.if no variant found, send appropriate message
else.
  if sy-subrc = 1.
    message s073(0k).
  endif.
endif.

ENDFORM.                    " alv_variant_f4
*&---------------------------------------------------------------------*
*&      Form  check_variant
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_alv_variant.

DATA: ls_variant LIKE disvariant.

*.Only do the check if there is a display variant
if gd-variant = space.
   clear gd-varianttext.
endif.
check: gd-variant <> space.

perform fill_variant changing ls_variant.

  CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
       EXPORTING
            i_save        = gd_save
       CHANGING
            cs_variant    = ls_variant
       EXCEPTIONS
            wrong_input   = 1
            not_found     = 2
            program_error = 3
            OTHERS        = 4.
  IF sy-subrc <> 0.
*    IF mess = 'X'.
        MESSAGE e213(ga).
*    ENDIF.
  ELSE.
     move-corresponding ls_variant to gs_variant.
     gd-varianttext = ls_variant-text.
  ENDIF.


ENDFORM.                    " check_variant
*&---------------------------------------------------------------------*
*&      Form  fill_variant
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_VARIANT  text
*----------------------------------------------------------------------*
FORM fill_variant CHANGING LS_VARIANT structure disvariant.

clear ls_variant.
*.the report is always se16n and then the table
  if not gd-layout_group is initial.
*....in case of SE16A allow several different layout groups
     concatenate gd_variant-report gd-tab gd-layout_group
           into ls_variant-report.
  else.
     concatenate gd_variant-report gd-tab into ls_variant-report.
  endif.
*.the handle defines if the texttable is on or not
  if gd-no_txt = true.
     ls_variant-handle = space.
  else.
     ls_variant-handle = true.
  endif.
*.the log group defines if it is client dependent
  ls_variant-log_group = gd-read_clnt.
*.User name
  ls_variant-username  = sy-uname.

*.Now fill in the current variant (if none, take dummy one)
  ls_variant-variant   = gd-variant.
  ls_variant-text      = gd-varianttext.

ENDFORM.                    " fill_variant
*&---------------------------------------------------------------------*
*&      Form  ADD_FIELD_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ADD_FIELD_F4 .

data: return_tab   like ddshretval occurs 0 with header line.
data: selval       like help_info-fldvalue.

  selval = gd-add_field.
  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME                   = gd-add_field_reftab
      FIELDNAME                 = gd-add_field_reffld
      VALUE                     = selval
      SELECTION_SCREEN          = true
    TABLES
      RETURN_TAB                = return_tab
    EXCEPTIONS
      OTHERS                    = 5.

  IF SY-SUBRC <> 0.
     exit.
  else.
     read table return_tab index 1.
     check: sy-subrc = 0.
     gd-add_field = return_tab-fieldval.
  ENDIF.

ENDFORM.                    " ADD_FIELD_F4
