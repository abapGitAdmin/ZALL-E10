class /ADZ/CL_MDC_PD_PROCESS_STEPS definition
  public
  create public .

public section.

  interfaces BI_OBJECT .
  interfaces BI_PERSISTENT .
  interfaces IF_WORKFLOW .

  class-methods GET_SERVICEPROVIDER
    importing
      !IV_PROC_REF type /IDXGC/DE_PROC_REF
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO
    exporting
      !ET_SERVPROV_DETAILS type /IDXGC/T_SERVPROV_DETAILS
    raising
      /IDXGC/CX_PROCESS_ERROR .
protected section.
private section.
ENDCLASS.



CLASS /ADZ/CL_MDC_PD_PROCESS_STEPS IMPLEMENTATION.


  METHOD GET_SERVICEPROVIDER.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 07.11.2019
*
* Beschreibung: Tabelle Serviceprovider aus der angegebenen Schrittnummer lesen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    TRY.
        DATA(lr_ctx) = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = iv_proc_ref
                                                               iv_wmode   = cl_isu_wmode=>co_display ).
        lr_ctx->get_proc_step_data( EXPORTING iv_proc_step_no   = iv_proc_step_no
                                    IMPORTING es_proc_step_data = DATA(ls_proc_step_data) ).
        et_servprov_details = ls_proc_step_data-serviceprovider.
      CATCH /idxgc/cx_process_error.
        "Leere Tabelle zurückgeben bei Fehler.
        CLEAR: et_servprov_details.
    ENDTRY.

    lr_ctx->close( ).
  ENDMETHOD.
ENDCLASS.
