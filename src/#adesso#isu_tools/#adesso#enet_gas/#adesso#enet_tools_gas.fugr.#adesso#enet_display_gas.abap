FUNCTION /ADESSO/ENET_DISPLAY_GAS.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_PREISE)
*"--------------------------------------------------------------------

  DATA:
    lt_nametab TYPE TABLE OF /adesso/nametab_s,
    ls_nametab TYPE /adesso/nametab_s.

  ls_nametab-name = 'BETRIEB' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'MESSUNG' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'SUMME' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'HARDW' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'ABRECH' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'GP'  .
  APPEND ls_nametab TO lt_nametab.
    ls_nametab-name = 'FLEI'  .
  APPEND ls_nametab TO lt_nametab.
    ls_nametab-name = 'FARB'  .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'AP'  .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'LP'  .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'KA'  .
  APPEND ls_nametab TO lt_nametab.



  DATA ls_anz TYPE /adesso/nametab_preis_s.
  DATA    ls_preis_dat        TYPE /adesso/enet_preis_dats.
  DATA lt_anz TYPE /adesso/enet_nametab_preis.
  DATA ls_keyinfo TYPE slis_keyinfo_alv.
  FIELD-SYMBOLS: <preis> TYPE /adesso/enet_preise_t.

  LOOP AT lt_nametab INTO ls_nametab.
    ASSIGN COMPONENT ls_nametab-name OF STRUCTURE i_preise TO <preis>.
    LOOP AT <preis> INTO ls_preis_dat.
      ls_anz-name = ls_nametab-name.
      MOVE-CORRESPONDING ls_preis_dat TO ls_anz.
      APPEND ls_anz TO lt_anz.

    ENDLOOP.

  ENDLOOP.
  ls_keyinfo-header01 = 'NAME'.
  ls_keyinfo-item01 = 'NAME'.

  " BREAK-POINT.
  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_tabname_header        = 'LT_NAMETAB'
      i_tabname_item          = 'LT_ANZ'
      i_structure_name_header = '/ADESSO/NAMETAB_S'
      i_structure_name_item   = '/ADESSO/NAMETAB_PREIS_S'
      is_keyinfo              = ls_keyinfo
    TABLES
      t_outtab_header         = lt_nametab
      t_outtab_item           = lt_anz
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*  DATA: gr_table TYPE REF TO cl_salv_hierseq_table.
*  DATA: isflight TYPE TABLE OF sflight.
*  DATA: ibinding TYPE salv_t_hierseq_binding.
*  DATA: xbinding TYPE salv_s_hierseq_binding.
*
*  xbinding-master = 'NAME'.
*  xbinding-slave = 'NAME'.
*  APPEND xbinding TO ibinding.
*  cl_salv_hierseq_table=>factory(
*   EXPORTING
*   t_binding_level1_level2 = ibinding
*   IMPORTING
*   r_hierseq = gr_table
*   CHANGING
*   t_table_level1 = lt_nametab
*   t_table_level2 = lt_anz ).
*  gr_table->display( ).





ENDFUNCTION.
