FUNCTION SE16N_ROLE_DEFINITION.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------

*.this function calls the dialog to create and maintain SE16N-Roles
*.to restrict the access to special tables, columns and lines

   message i222(wusl).
   exit.

*..Check if user has system authority
  CLEAR gd_role_display_only.
   AUTHORITY-CHECK OBJECT 'S_ADMI_FCD'
        ID 'S_ADMI_FCD' FIELD 'DBA'.
      IF SY-SUBRC NE 0.
*........additionally check S_BRWS_CUS as an alternative
    AUTHORITY-CHECK OBJECT 'S_BRWS_CUS'
       ID 'BRWS_KEY' FIELD 'ROLE_MAINT'
       ID 'BRWS_NAME' dummy
       ID 'ACTVT' FIELD '02'.
    IF sy-subrc = 0.
*..........if user has change-authority - allow maintenance
    ELSE.
*..........check for display authority
      AUTHORITY-CHECK OBJECT 'S_BRWS_CUS'
         ID 'BRWS_KEY' FIELD 'ROLE_MAINT'
         ID 'BRWS_NAME' dummy
         ID 'ACTVT' FIELD '03'.
*..........display only
      IF sy-subrc = 0.
        gd_role_display_only = true.
      ELSE.
*............no authority at all
        MESSAGE i103(wusl).
        EXIT.
      ENDIF.
    ENDIF.
      ENDIF.

*.initialize
  perform refresh_role.
  clear: gd_save_role, gd_role, gd_role_txt, gd_save_txt, gs_role.

*.call the maintenance dialog
  call screen 1000.

ENDFUNCTION.
