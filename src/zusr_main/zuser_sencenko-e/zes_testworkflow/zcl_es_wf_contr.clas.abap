class ZCL_ES_WF_CONTR definition
  public
  create public .

public section.

  interfaces BI_OBJECT .
  interfaces BI_PERSISTENT .
  interfaces IF_WORKFLOW .
  interfaces BI_EVENT_HANDLER .
  interfaces BI_EVENT_HANDLER_STATIC .

  data NAME type ZES_WORKFLOW_NAME .

  events START_WORKFLOW_EVENT
    exporting
      value(IV_NAME) type ZES_WORKFLOW_NAME .

  methods CONSTRUCTOR
    importing
      !IM_ID type CHAR0032 .
  methods START_WORKFLOW
    importing
      !IV_NAME type ZES_WORKFLOW_NAME .
protected section.

  data AS_POR type SIBFLPOR .
  constants AC_TYPEID type SIBFTYPEID value 'ZCL_ES_WF_CONTR' ##NO_TEXT.
private section.
ENDCLASS.



CLASS ZCL_ES_WF_CONTR IMPLEMENTATION.


  method BI_PERSISTENT~FIND_BY_LPOR.
    DATA: lr_wf_contr TYPE REF TO zcl_es_wf_contr.

    TRY.
        lr_wf_contr = NEW #( im_id = CONV #( lpor-instid ) ).
      CATCH cx_no_check .

    ENDTRY.

    result = lr_wf_contr.

  endmethod.


  method BI_PERSISTENT~LPOR.
    result = me->as_por.
  endmethod.


  method CONSTRUCTOR.

as_por-instid = im_ID.
    as_por-typeid = ac_typeid.
    as_por-catid = swfco_objtype_cl.


  endmethod.


  method START_WORKFLOW.

    Data: lr_event_container type ref to if_swf_ifs_parameter_container,
          lr_event type REF TO if_swf_evt_event .


**********************************************************************
* Eigener Test
**********************************************************************

*        call method cl_swf_evt_event=>get_instance
*        EXPORTING
*          im_objcateg        = as_por-catid
*            im_objtype         = as_por-typeid
*            im_event           = 'START_WORKFLOW_EVENT'
*            im_objkey          = as_por-instid
*            im_event_container = lr_event_container
*           RECEIVING re_event = lr_event.
*
*        lr_event->set_property( EXPORTING im_property = 'Banana'  ).
*
*
*        call METHOD lr_event->raise.



TRY.
*  RAISE EVENT start_workflow_event EXPORTING iv_name = iv_name.
        "LOL
        CALL METHOD cl_swf_evt_event=>get_event_container
          EXPORTING
            im_objcateg  = as_por-catid
            im_objtype   = as_por-typeid
            im_event     = 'START_WORKFLOW_EVENT'
          RECEIVING
            re_reference = lr_event_container.

        CALL METHOD cl_swf_evt_event=>raise
          EXPORTING

            im_objcateg        = as_por-catid
            im_objtype         = as_por-typeid
            im_event           = 'START_WORKFLOW_EVENT'
            im_objkey          = as_por-instid
            im_event_container = lr_event_container .

        COMMIT WORK AND WAIT.

      CATCH cx_swf_evt_exception.
        write: 'Fehler'.
    ENDTRY .
  endmethod.
ENDCLASS.
