*----------------------------------------------------------------------*
***INCLUDE LSE16NF22.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_TEMPERATURE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_TEMPERATURE USING p_session_ctrl
                               TYPE REF TO CL_ABAP_SESSION_TEMPERATURE
                           VALUE(p_temperature_cold).

  DATA: xroot          TYPE REF TO cx_root.
  STATICS: sc_session_ctrl TYPE REF TO cl_abap_session_temperature.

*.In case SE16SL calls SE16N_INTERFACE the session_control could
*.already be set. In this case take over session_control.
*.If in addition temperature is set to cold, set the session to cold.
  IF NOT p_session_ctrl IS INITIAL.
     sc_session_ctrl = p_session_ctrl.
  ENDIF.

  IF sc_session_ctrl IS INITIAL.
  TRY.
    CALL METHOD CL_ABAP_SESSION_TEMPERATURE=>GET_SESSION_CONTROL
      RECEIVING
            rt_session_control = sc_session_ctrl.
      CATCH cx_abap_session_temperature INTO xroot.
*        MESSAGE xroot TYPE 'I'.
    ENDTRY.
  ENDIF.

  IF sc_session_ctrl IS NOT INITIAL.
*...if temperature is set, take this date for access
    IF NOT gd-temperature IS INITIAL AND
           gd-temperature <> SPACE.
      TRY.
          CALL METHOD sc_session_ctrl->set_temperature
            EXPORTING
              im_temperature = gd-temperature.
        CATCH cx_abap_session_temperature INTO xroot.
        CATCH cx_parameter_invalid_range INTO xroot.
          MESSAGE xroot TYPE 'I'.
      ENDTRY.
*...new standard is hot
    ELSE.
      CALL METHOD sc_session_ctrl->set_hot.
    ENDIF.
*...external caller did set cold -> set it
    IF p_temperature_cold = true.
      CALL METHOD SC_SESSION_CTRL->SET_COLD.
    ENDIF.
  ENDIF.

ENDFORM.                    " SET_TEMPERATURE
*&---------------------------------------------------------------------*
*&      Form  CHANGE_SCREEN_0700
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_screen_0700 .

  DATA: ld_enabled(1).

  CALL METHOD cl_data_aging_state=>is_enabled
    RECEIVING
      rt_is_enabled = ld_enabled.
  IF ld_enabled <> true.
    LOOP AT SCREEN.
      IF screen-group4 = 'DA'.
        screen-invisible = 1.
        screen-input     = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
