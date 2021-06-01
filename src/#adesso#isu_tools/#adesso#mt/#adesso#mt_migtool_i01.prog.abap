*&---------------------------------------------------------------------*
*&  Include           /ADESSO/MT_MIGTOOL_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE fcode.

    WHEN 'BACK'.
      CLEAR fcode.
      CLEAR sy-ucomm.
      LEAVE PROGRAM.

    WHEN 'RELVANZ'.
      CLEAR fcode.
      CLEAR sy-ucomm.
      IF isu = 'X'.
        SUBMIT /adesso/mte_relevanz VIA SELECTION-SCREEN AND RETURN.
      ELSEIF vert = 'X'.
        SUBMIT /adesso/mte_relevanz_vert VIA SELECTION-SCREEN AND RETURN.
      ENDIF.

    WHEN 'ENT'.
      CLEAR fcode.
      CLEAR sy-ucomm.
      CALL SCREEN 300.

    WHEN 'BEL'.
      CLEAR fcode.
      CLEAR sy-ucomm.
      CALL SCREEN 400.

    WHEN 'MIGSTAT'.
      CLEAR fcode.
      CLEAR sy-ucomm.
      SUBMIT remig007 VIA SELECTION-SCREEN AND RETURN.

    WHEN 'MIGWOR'.
      CLEAR fcode.
      CLEAR sy-ucomm.
      CALL TRANSACTION 'EMIGALL'.

    WHEN 'JOBS'.
      CLEAR fcode.
      CLEAR sy-ucomm.
      CALL TRANSACTION 'SM37' AND SKIP FIRST SCREEN.

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

 CASE fcode.

   WHEN 'ENTE'.
     CLEAR fcode.
     CLEAR sy-ucomm.
*     perform search_right_firm.
     LEAVE TO SCREEN 300.

    WHEN 'FT15' OR 'FT03' OR 'FT12'.
      CLEAR fcode.
      CLEAR sy-ucomm.
      LEAVE TO SCREEN 100.

    WHEN 'DELERR'.
      clear fcode.
      clear sy-ucomm.
      SUBMIT /adesso/mte_del_error_tab VIA SELECTION-SCREEN AND RETURN.
*
    WHEN 'BATCH'.
      CLEAR fcode.
      CLEAR sy-ucomm.
*     Jobname zusammenstellen
      CLEAR job_name.
      PERFORM erm_jobname_ent CHANGING job_name.
*     Job starten
      PERFORM job_call_expobject  USING  job_name.

    WHEN 'DIALOG'.
      CLEAR fcode.
      CLEAR sy-ucomm.
*     starten des Ladereports im Dialog
      PERFORM exportreport_dialog.

  ENDCASE.


ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.

CASE fcode.

   WHEN 'ENTE'.
     CLEAR fcode.
     CLEAR sy-ucomm.
     PERFORM search_right_firm.
     LEAVE TO SCREEN 400.


    WHEN 'FT15' OR 'FT03' OR 'FT12'.
      CLEAR fcode.
      CLEAR sy-ucomm.
      LEAVE TO SCREEN 100.

    WHEN 'DISREG'.
      CLEAR fcode.
      CLEAR sy-ucomm.
      SUBMIT  /adesso/disable_enable_regpol
          WITH  mandant         =  sy-mandt
          WITH  enable          =  ' '
          WITH  disable         =  'X'
          AND RETURN.


    WHEN 'ENREG'.
      CLEAR fcode.
      CLEAR sy-ucomm.
      SUBMIT  /adesso/disable_enable_regpol
          WITH  mandant         =  sy-mandt
          WITH  enable          =  'X'
          WITH  disable         =  ' '
          AND RETURN.

    WHEN 'BATCH'.
      CLEAR fcode.
      CLEAR sy-ucomm.
*    Jobname zusammenstellen
      CLEAR job_name.
      PERFORM erm_jobname CHANGING job_name.
*    Job starten
      PERFORM job_call_migobject  USING  job_name.

    WHEN 'DIALOG'.
      CLEAR fcode.
      CLEAR sy-ucomm.
*   starten des Ladereports im Dialog
      PERFORM ladereport_dialog.

  ENDCASE.


ENDMODULE.
