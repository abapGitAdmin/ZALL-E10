*"* local class implementation for public class
*"* /ADZ/SCI_RESULT_WUL


class LCL_HELPER definition final.

  public section.
    methods: GET_WB_MANAGER     returning value(p_RESULT) type ref to IF_WB_MANAGER.

endclass.


class LCL_HELPER implementation.

  method GET_WB_MANAGER.

    clear: P_RESULT.

    if CL_WB_MANAGER=>IS_RUNNING( ) and SY-TCODE(2) <> 'SE'.

      ">>> customer incident 0000115243 2015
      "   workbench tool transport check trigger navigation via popup dynpro
      "    in such an environment workbench navigation is not possible
      "<<<

      CL_WB_MANAGER=>GET_INSTANCE(
        importing  P_INSTANCE       = P_RESULT
        exceptions NO_INSTANCE      = 0
                   others           = 0 ).

    endif.

  endmethod.

endclass.
