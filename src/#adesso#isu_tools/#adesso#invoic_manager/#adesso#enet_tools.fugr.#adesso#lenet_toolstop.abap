FUNCTION-POOL /ADESSO/ENET_TOOLS.               "MESSAGE-ID ..

* INCLUDE LZAD_ENET_TOOLSD...                " Local class definition

FIELD-SYMBOLS <preise>.
CONSTANTS:
          con_sp_nsp(30)        TYPE c VALUE 'NSP',
          con_sp_msp(30)        TYPE c value 'MSP',
          con_sp_hsp(30)        TYPE c VALUE 'HSP',
          con_sp_msp_u_nsp(30)  TYPE c VALUE 'MSP mit USP auf NSP',
          con_sp_hsp_u_msp(30)  TYPE c VALUE 'HSP mit USP auf MSP',
          con_sp_msp_m_nsp(30)  TYPE c VALUE 'MSP mit NSP-seitiger Messung',
          con_sp_hsp_m_msp(30)  TYPE c VALUE 'HSP mit NSP-seitiger Messung'.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9001 OUTPUT.

if <preise> IS ASSIGNED.
CALL FUNCTION '/ADESSO/ENET_DISPLAY'
  EXPORTING
    i_preise       = <preise>
          .
ENDIF.

ENDMODULE.                 " STATUS_9001  OUTPUT
