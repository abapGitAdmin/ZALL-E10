FUNCTION /adz/bdr_request_dialog.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_BDR_ORDERS_HDR) TYPE  /ADZ/S_BDR_ORDERS_HDR
*"     REFERENCE(IT_BDR_CREATE_REQ) TYPE  /ADZ/T_BDR_CREATE_REQ
*"  RAISING
*"      /IDXGC/CX_PROCESS_ERROR
*"----------------------------------------------------------------------
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P, THIMEL-R                                                  Datum: 18.08.2019
*
* Beschreibung: Dialog für ORDERS Anfrage
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

  IF gr_orders_req_cntr IS NOT BOUND.
    TRY.
        gr_orders_req_cntr = NEW #( is_bdr_orders_hdr = is_bdr_orders_hdr
                                    it_bdr_create_req = it_bdr_create_req ).
      CATCH /idxgc/cx_process_error.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        LEAVE SCREEN.
    ENDTRY.
  ENDIF.

  gv_doctype = is_bdr_orders_hdr-docname_code.

  gr_orders_req_cntr->create_alv_grid( ).

  CALL SCREEN 100.

ENDFUNCTION.
