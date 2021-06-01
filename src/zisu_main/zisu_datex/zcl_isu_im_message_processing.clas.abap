class ZCL_ISU_IM_MESSAGE_PROCESSING definition
  public
  inheriting from /IDXGL/CL_DEF_BADI_MSG_PROC
  final
  create public .

public section.

  methods /IDXGC/IF_BADI_MSG_PROCESSING~SET_IDOC_CONTROL_DATA
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ISU_IM_MESSAGE_PROCESSING IMPLEMENTATION.


  METHOD /idxgc/if_badi_msg_processing~set_idoc_control_data.
    "RT, 08.05.2019, Falls mal mehr Serviceanbieter eingerichtet werden, sollte man sich mal eine
    " bessere Logik überlegen.
    cs_control_data-rcvprt = 'LS'.

    CASE sy-mandt.
      WHEN '100'.
        cs_control_data-rcvprn = 'E10CLNT110'.
      WHEN '110'.
        cs_control_data-rcvprn = 'E10CLNT100'.
      WHEN '200'.
        IF cs_control_data-rcvprn = 'AD_HH_S_MB'.
          cs_control_data-rcvprn = 'E10CLNT220'.
        ELSE.
          cs_control_data-rcvprn = 'E10CLNT210'.
        ENDIF.
      WHEN '210'.
        IF cs_control_data-rcvprn = 'AD_HH_S_MB'.
          cs_control_data-rcvprn = 'E10CLNT220'.
        ELSE.
          cs_control_data-rcvprn = 'E10CLNT200'.
        ENDIF.
      WHEN '220'.
        IF cs_control_data-rcvprn CS 'NB'.
          cs_control_data-rcvprn = 'E10CLNT200'.
        ELSE.
          cs_control_data-rcvprn = 'E10CLNT210'.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
