FUNCTION SE16N_GET_LAYOUT_FIELDS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_ALV_GRID) TYPE REF TO  CL_GUI_ALV_GRID OPTIONAL
*"     VALUE(I_TABNAME) TYPE  TABNAME OPTIONAL
*"     VALUE(I_SAVE_VARIANT) TYPE  CHAR1 OPTIONAL
*"  CHANGING
*"     VALUE(IS_DISVARIANT) TYPE  DISVARIANT OPTIONAL
*"     VALUE(IT_DEFAULT_FCAT) TYPE  SLIS_T_FIELDCAT_ALV OPTIONAL
*"     VALUE(ET_LAYOUT_FIELDS) TYPE  SE16N_OUTPUT_T OPTIONAL
*"  EXCEPTIONS
*"      LAYOUT_NOT_FOUND
*"      FIELDCAT_NOT_FOUND
*"----------------------------------------------------------------------

*...................................................................
*.Either hand over an instance for ALV-Grid (I_ALV_GRID)
*.or provide the structure IS_DISVARIANT and I_TABNAME (to let the
*.default fieldcatalog be determined by the function) OR
*.ET_LAYOUT_FIELDS directly, if your default fieldcatalog cannot be
*.determined out of a DDIC-Structure
*...................................................................

  data: lt_fieldcatalog  type lvc_t_fcat.
  data: lt_filter        type LVC_T_FILT.
  data: lt_sort          type LVC_T_SORT.
  data: ls_fieldcatalog  type lvc_s_fcat.
  data: ls_filter        type LVC_s_FILT.
  data: ls_sort          type LVC_s_SORT.
  data: ls_layout_fields like se16n_output.
  data: I_LAYOUT         TYPE  SLIS_LAYOUT_ALV.
  data: ET_SORT          TYPE  SLIS_T_SORTINFO_ALV.
  data: ET_FILTER        TYPE  SLIS_T_FILTER_ALV.
  data: ET_FIELDCAT      TYPE  SLIS_T_FIELDCAT_ALV.
  data: ES_SORT          TYPE  SLIS_SORTINFO_ALV.
  data: ES_FILTER        TYPE  SLIS_FILTER_ALV.
  data: ES_FIELDCAT      TYPE  SLIS_FIELDCAT_ALV.
  data: ls_variant       type DISVARIANT.
  data: ls_layout        type LVC_S_LAYO.

  if not i_alv_grid is initial.
    CALL METHOD I_ALV_GRID->GET_VARIANT
      IMPORTING
        ES_VARIANT = ls_variant.
    ls_variant-username  = sy-uname.
    ls_variant-variant   = c_dummy_layo.
    ls_variant-text      = c_dummy_text.
    clear ls_variant-dependvars.
    CALL METHOD i_alv_grid->GET_FRONTEND_FIELDCATALOG
      IMPORTING
        ET_FIELDCATALOG = lt_fieldcatalog.
    CALL METHOD i_alv_grid->GET_FRONTEND_LAYOUT
      IMPORTING
        ES_LAYOUT = ls_layout.
    CALL METHOD i_alv_grid->GET_FILTER_CRITERIA
      IMPORTING
        ET_FILTER = lt_filter.
    CALL METHOD I_ALV_GRID->GET_SORT_CRITERIA
      IMPORTING
        ET_SORT = lt_sort.
***********************************************************
          CALL METHOD i_alv_grid->SET_FRONTEND_FIELDCATALOG
            EXPORTING
              IT_FIELDCATALOG = lt_fieldcatalog.
          CALL METHOD i_alv_grid->SET_FRONTEND_LAYOUT
            EXPORTING
              IS_LAYOUT = ls_layout.
          CALL METHOD i_alv_grid->SET_FILTER_CRITERIA
            EXPORTING
              IT_FILTER = lt_filter.
          CALL METHOD i_ALV_GRID->SET_VARIANT
            EXPORTING
              IS_variant = ls_variant
              I_SAVE     = 'A'.
*          CALL METHOD i_ALV_GRID->SAVE_VARIANT_DARK
*             EXPORTING
*               IS_VARIANT = ls_variant.
          CALL METHOD i_ALV_GRID->SAVE_VARIANT
            EXPORTING
              I_DIALOG = space.
          clear ls_variant-variant.
          clear ls_variant-text.
*.....restart SE16N with new layout
          GD-VARIANT = c_dummy_layo.
************************************************************
    loop at lt_fieldcatalog into ls_fieldcatalog
         where no_out <> true
           and ref_table = gd-tab.
      ls_layout_fields-field = ls_fieldcatalog-fieldname.
      collect ls_layout_fields into et_layout_fields.
    endloop.
    loop at lt_filter into ls_filter.
      ls_layout_fields-field = ls_filter-fieldname.
      collect ls_layout_fields into et_layout_fields.
    endloop.
    loop at lt_sort into ls_sort.
      ls_layout_fields-field = ls_sort-fieldname.
      collect ls_layout_fields into et_layout_fields.
    endloop.
  else.
    if not is_disvariant is initial.
      if not i_tabname is initial and
         it_default_fcat is initial.
        CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
          EXPORTING
            I_STRUCTURE_NAME       = i_tabname
          CHANGING
            CT_FIELDCAT            = it_default_fcat
          EXCEPTIONS
            INCONSISTENT_INTERFACE = 1
            PROGRAM_ERROR          = 2
            OTHERS                 = 3.

        IF SY-SUBRC <> 0.
          raise fieldcat_not_found.
        ENDIF.
      endif.
      CALL FUNCTION 'REUSE_ALV_VARIANT_SELECT'
        EXPORTING
          I_DIALOG            = 'N'
          I_USER_SPECIFIC     = 'X'
          IT_DEFAULT_FIELDCAT = it_default_fcat
          I_LAYOUT            = i_layout
        IMPORTING
          ET_FIELDCAT         = et_fieldcat
          ET_SORT             = et_sort
          ET_FILTER           = et_filter
        CHANGING
          CS_VARIANT          = is_disvariant
        EXCEPTIONS
          WRONG_INPUT         = 1
          FC_NOT_COMPLETE     = 2
          NOT_FOUND           = 3
          PROGRAM_ERROR       = 4
          OTHERS              = 5.

      IF SY-SUBRC <> 0.
        raise layout_not_found.
      else.
        loop at et_fieldcat into es_fieldcat
             where no_out <> true.
          ls_layout_fields-field = es_fieldcat-fieldname.
          collect ls_layout_fields into et_layout_fields.
        endloop.
        loop at et_filter into es_filter.
          ls_layout_fields-field = es_filter-fieldname.
          collect ls_layout_fields into et_layout_fields.
        endloop.
        loop at et_sort into es_sort.
          ls_layout_fields-field = es_sort-fieldname.
          collect ls_layout_fields into et_layout_fields.
        endloop.
      ENDIF.

    endif.
  endif.



ENDFUNCTION.
