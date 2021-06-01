FUNCTION-POOL ZADM_REQ_POPUP.               "MESSAGE-ID ..
TABLES ZADM_REQ_LOG.
DATA g_ok_code TYPE ok.
DATA gv_ok TYPE c.
DATA gv_abr TYPE c.



* INCLUDE LZADM_REQ_POPUPD...                " Local class definition
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
leave to SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0100 INPUT.
leave to SCREEN 0.
ENDMODULE.
