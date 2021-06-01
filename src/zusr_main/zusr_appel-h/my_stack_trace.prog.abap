*<SCRIPT:PERSISTENT>
REPORT  rstpda_script_template.

*<SCRIPT:HEADER>
*<SCRIPTNAME>RSTPDA_SCRIPT_TEMPLATE</SCRIPTNAME>
*<SCRIPT_CLASS>LCL_DEBUGGER_SCRIPT</SCRIPT_CLASS>
*<SCRIPT_COMMENT>Debugger Skript: Default Template</SCRIPT_COMMENT>
*<BP_REACHED>X</BP_REACHED>

*</SCRIPT:HEADER>

*<SCRIPT:PRESETTINGS>
*<BP>
*<FLAGACTIVE>X</FLAGACTIVE>
*<KIND>8 </KIND>
*<DUMMYFIELDNPR>1 </DUMMYFIELDNPR>
*</BP>

*</SCRIPT:PRESETTINGS>

*<SCRIPT:SCRIPT_CLASS>
*---------------------------------------------------------------------*
*       CLASS lcl_debugger_script DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_debugger_script DEFINITION INHERITING FROM  cl_tpda_script_class_super  .

  PUBLIC SECTION.
    METHODS: prologue  REDEFINITION,
             init    REDEFINITION,
             script  REDEFINITION,
             end     REDEFINITION.

ENDCLASS.                    "lcl_debugger_script DEFINITION
*---------------------------------------------------------------------*
*       CLASS lcl_debugger_script IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_debugger_script IMPLEMENTATION.
  METHOD prologue.
*** generate abap_source (source handler for ABAP)
    super->prologue( ).
  ENDMETHOD.                    "prolog

  METHOD init.
*** insert your initialization code here
  ENDMETHOD.                    "init
  METHOD script.
****************************************************************
*Interface (CLASS = IF_TPDA_SCRIPT_TRACE_WRITE / METHOD = ADD_EVENT_INFO )
*Importing
*        REFERENCE( P_ABAP_ONLY ) TYPE FLAG OPTIONAL
*        REFERENCE( P_DYNP_ONLY ) TYPE FLAG OPTIONAL
****************************************************************

CALL METHOD TRACE->ADD_EVENT_INFO
*  EXPORTING
*    p_abap_only =
*    p_dynp_only =
    .

*** insert your script code here
  "me->break( ).

  ENDMETHOD.                    "script
  METHOD end.
*** insert your code which shall be executed at the end of the scripting (before trace is saved)
*** here

  ENDMETHOD.                    "end
ENDCLASS.                    "lcl_debugger_script IMPLEMENTATION
*</SCRIPT:SCRIPT_CLASS>

*</SCRIPT:PERSISTENT>
