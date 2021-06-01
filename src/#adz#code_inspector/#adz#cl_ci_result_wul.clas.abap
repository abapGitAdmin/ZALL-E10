class /ADZ/CL_CI_RESULT_WUL definition
  public
  inheriting from CL_CI_RESULT_ROOT
  create public .

public section.

  methods SET_INFO
    redefinition .
protected section.

  types:
    begin of T_TADIR_KEY,
          OBJTYPE type TROBJTYPE,
          OBJNAME type SOBJ_NAME,
        end   of T_TADIR_KEY .
private section.

  types:
    begin of T_TRDIR_TADIR,
          TRDIR_NAME type TRDIR-NAME,
          TADIR_KEY  type T_TADIR_KEY,
          SUBRC      type SY-SUBRC,
        end   of T_TRDIR_TADIR .
ENDCLASS.



CLASS /ADZ/CL_CI_RESULT_WUL IMPLEMENTATION.


  method SET_INFO.

    CALL METHOD SUPER->SET_INFO
      EXPORTING
        P_INFO   = p_info
      RECEIVING
        P_RESULT = p_result.

    description = |{ p_info-param1 } Verwendung in:|.

  endmethod.
ENDCLASS.
