FUNCTION SE16N_GET_GROUPING_FROM_LAYOUT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_ALV_GRID) TYPE REF TO  CL_GUI_ALV_GRID OPTIONAL
*"     VALUE(I_TAB) TYPE  TABNAME OPTIONAL
*"  TABLES
*"      LT_SELFIELDS STRUCTURE  SE16N_SELFIELDS
*"  CHANGING
*"     VALUE(IS_DISVARIANT) TYPE  DISVARIANT OPTIONAL
*"     VALUE(IT_DEFAULT_FCAT) TYPE  SLIS_T_FIELDCAT_ALV OPTIONAL
*"     VALUE(ET_LAYOUT_FIELDS) TYPE  SE16N_OUTPUT_T OPTIONAL
*"  EXCEPTIONS
*"      LAYOUT_NOT_FOUND
*"----------------------------------------------------------------------

*...................................................................
*.This function module determines the fields of a layout that are
*.necessary for ths select to display all wanted information.
*...................................................................
*..chosen layout gd-variant is NOT yet set, so the methods don't know
*..the content
*..either I have to set the layout temporarily or I use the read way

  data: ls_layout_fields like se16n_output.
  data: ls_selfields     like se16n_selfields.
  data: ld_tabix         like sy-tabix.
  data: ls_disvariant    type disvariant.

*.if user clicks on a layout that is not the current one then the
*.methods to read the current layout will not work. Therefore I have
*.to use the read function for any kind of layout.
  if i_alv_grid is initial.
    move-corresponding gs_variant to ls_disvariant.
*...This is the call via layout hotspot. In that case GD-Variant
*...is filled
    ls_disvariant-variant = gd-variant.
    CALL FUNCTION 'SE16N_GET_LAYOUT_FIELDS'
      EXPORTING
*       I_ALV_GRID         = i_alv_grid
        I_TABNAME          = i_tab
      CHANGING
        IS_DISVARIANT      = ls_disvariant
*       IT_DEFAULT_FCAT    =
        ET_LAYOUT_FIELDS   = et_layout_fields
      EXCEPTIONS
        LAYOUT_NOT_FOUND   = 1
        FIELDCAT_NOT_FOUND = 2
        OTHERS             = 3.
  else.
    CALL FUNCTION 'SE16N_GET_LAYOUT_FIELDS'
      EXPORTING
        I_ALV_GRID         = i_alv_grid
*       I_TABNAME          = i_tab
      CHANGING
*       IS_DISVARIANT      = ls_disvariant
*       IT_DEFAULT_FCAT    =
        ET_LAYOUT_FIELDS   = et_layout_fields
      EXCEPTIONS
        LAYOUT_NOT_FOUND   = 1
        FIELDCAT_NOT_FOUND = 2
        OTHERS             = 3.
  endif.
  IF SY-SUBRC <> 0.
    raise layout_not_found.
  ENDIF.
*............................................................
*.Now hand over layout_fields to caller to check whether the names
*.are correct. If not, fill in the correct names.
*.Example: COVP needs OBJNR instead of KOSTL and LSTAR
*.         CEL_KTXT needs KSTAR
  refresh gt_layout_fields.
  gt_layout_fields[] = et_layout_fields[].
  perform external_exit using c_ext_layout_fcat
                        changing gd-exit_done.
  if gd-exit_done = true.
     et_layout_fields[] = gt_layout_fields[].
  endif.
*............................................................

  loop at lt_selfields into ls_Selfields.
    ld_tabix = sy-tabix.
    clear: ls_selfields-sum_up, ls_Selfields-group_by.
*......check if field is used in layout
    read table et_layout_fields into ls_layout_fields
          with key field = ls_selfields-fieldname.
    if sy-subrc = 0.
      case ls_selfields-datatype.
        when 'QUAN' or 'CURR' or 'INT1' or 'INT2' or 'INT4'.
          ls_Selfields-sum_up = true.
        when others.
          ls_Selfields-group_by = true.
      endcase.
    endif.
    modify lt_selfields from ls_Selfields index ld_tabix.
  endloop.




ENDFUNCTION.
