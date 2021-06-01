FUNCTION /adesso/fkk_sample_1205.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_POSTAB) LIKE  FKKEPOS STRUCTURE  FKKEPOS
*"     VALUE(I_FKKL1) LIKE  FKKL1 STRUCTURE  FKKL1 OPTIONAL
*"     VALUE(I_FKKEPOSC) LIKE  FKKEPOSC STRUCTURE  FKKEPOSC OPTIONAL
*"     VALUE(I_HEADER_ARC) LIKE  FKKKO STRUCTURE  FKKKO OPTIONAL
*"     VALUE(I_FIRST_CALL) TYPE  BOOLEAN DEFAULT SPACE
*"  EXPORTING
*"     VALUE(E_POSTAB) LIKE  FKKEPOS STRUCTURE  FKKEPOS
*"     VALUE(E_DO_NOT_DISPLAY_LINE) TYPE  BOOLEAN
*"     VALUE(E_ONLY_SHOW_IN_PAYMENT_LIST) TYPE  BOOLEAN
*"--------------------------------------------------------------------
  DATA: ls_dfkkcoll TYPE dfkkcoll,
        ls_but000   TYPE but000.



  CALL FUNCTION 'ISU_ACC_DISP_BASIC_LIST_1205'
    EXPORTING
      i_postab                    = i_postab
      i_fkkl1                     = i_fkkl1
      i_langu                     = sy-langu
      i_fkkeposc                  = i_fkkeposc
      i_header_arc                = i_header_arc
      i_first_call                = i_first_call
    IMPORTING
      e_postab                    = e_postab
      e_do_not_display_line       = e_do_not_display_line
      e_only_show_in_payment_list = e_only_show_in_payment_list.

*  e_postab = i_postab.

  SELECT SINGLE * FROM dfkkcoll INTO ls_dfkkcoll
    WHERE opbel = e_postab-opbel.

  SELECT SINGLE * FROM but000 INTO ls_but000
    WHERE partner = ls_dfkkcoll-inkgp.


  e_postab-zzgpart_ink_gp = ls_dfkkcoll-inkgp.

  CASE ls_but000-type.
    WHEN '1'.                  "natürliche Person
      e_postab-zzgpart_ink_name = ls_but000-name_first.
    WHEN '2'.                  "Organisation.
      e_postab-zzgpart_ink_name = ls_but000-name_org1.

    WHEN '3'.                    "Gruppe
      e_postab-zzgpart_ink_name = ls_but000-name_grp1.
  ENDCASE.

ENDFUNCTION.
