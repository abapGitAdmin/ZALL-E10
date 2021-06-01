************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT zes_start_workflow.


PARAMETERS: p_id TYPE char32,
            p_name type ZES_WORKFLOW_NAME.

START-OF-SELECTION.

  DATA: r_start TYPE REF TO zcl_es_wf_contr.



  CREATE OBJECT r_start EXPORTING im_id = p_id  .

  r_start->name = p_name.
  CALL METHOD r_start->start_workflow
    EXPORTING
      iv_name = p_name.


  write: 'Angenommen', / , r_start->name.
