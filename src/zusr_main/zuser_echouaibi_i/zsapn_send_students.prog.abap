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
REPORT zsapn_send_students.


DATA: zstudents TYPE TABLE OF ZSTUDENT_SAPNUTS.
DATA : wa_students TYPE ZSTUDENT_SAPNUTS.

TYPES : BEGIN OF ty_zstudent. "STRUCTURE FOR SEGMENT DATA
          INCLUDE STRUCTURE zstudent_segment.
        TYPES : END OF ty_zstudent.
DATA : zstudent TYPE ty_zstudent.
DATA: BEGIN OF t_edidd OCCURS 0.
        INCLUDE STRUCTURE edidd.
      DATA: END OF t_edidd.

DATA: BEGIN OF f_edidc.
        INCLUDE STRUCTURE edidc.
      DATA: END OF f_edidc.

DATA: BEGIN OF t_edidc OCCURS 0.
        INCLUDE STRUCTURE edidc.
      DATA: END OF t_edidc.
SELECT-OPTIONS: s_std FOR wa_students-student_id.

START-OF-SELECTION.
  SELECT * FROM ZSTUDENT_SAPNUTS INTO TABLE zstudents WHERE student_id IN s_std.
  LOOP AT zstudents INTO wa_students. "send students on eby one
    MOVE-CORRESPONDING wa_students TO zstudent.
    CLEAR t_edidd.
    t_edidd-segnam = 'ZSTUDENT_SEGMENT'. "segment name
    t_edidd-sdata  = zstudent. "IDOC data record
    APPEND t_edidd.
* Fill control record
    CLEAR f_edidc.
    f_edidc-mestyp = 'ZSTUDENT_NT_WE1'.           "Message type
    f_edidc-doctyp = 'ZSTUDENT_IDOC_TYP_OR_BASISTYP'.         "IDOC type
    f_edidc-rcvprt = 'LS'.               "Partner type
    f_edidc-rcvprn = 'E10CLNT210'.         "Receiver partner


    CALL FUNCTION 'MASTER_IDOC_DISTRIBUTE'
      EXPORTING
        master_idoc_control            = f_edidc  ">>>>>
      TABLES
        communication_idoc_control     = t_edidc  "<<<<<
        master_idoc_data               = t_edidd  ">>>>>
      EXCEPTIONS
        error_in_idoc_control          = 1
        error_writing_idoc_status      = 2
        error_in_idoc_data             = 3
        sending_logical_system_unknown = 4
        OTHERS                         = 5.

    COMMIT WORK.
    CLEAR : wa_students, zstudent.
    REFRESH : t_edidd.
  ENDLOOP.


*CLASS lcl_cntry_tax DEFINITION.
*  PUBLIC SECTION.
*    CONSTANTS  : c_idcotype TYPE edidc-idoctp VALUE 'ZSTUDENT_IDOC_TYP_OR_BASISTYP',
*                             c_msgtype TYPE edidc-mestyp VALUE  'ZSTUDENT_SEGMENT',
*                             c_port TYPE edidc-rcvpor VALUE 'A000000002',
*                             c_rec_part_type TYPE edidc-rcvprt VALUE 'LS',
*                             c_rec_sys TYPE edidc-rcvprn VALUE 'E10CLNT210',
*                            c_sndr_part_type TYPE edidc-sndprt VALUE 'LS',
*                            c_sndr_sys TYPE edidc-sndprn VALUE 'E10CLNT210'.
*    DATA : coun_code TYPE zcntry_tax_code-countyr,
*                lt_cnty_tax TYPE TABLE OF zcntry_tax_code,
*                ls_cnty_tax TYPE zcntry_tax_code,
*                lt_data TYPE TABLE OF edidd,
*                ls_data TYPE edidd,
*                lt_comm_idoc TYPE TABLE OF edidc,
*                ls_comm_idoc TYPE edidc,
*                ls_control TYPE edidc.
*    METHODS : constructor IMPORTING i_coun_code TYPE zcntry_tax_code-countyr,
*                        prepare_data,
*                        prepare_cntl_data,
*                        send_idoc.
*ENDCLASS.                    "lcl_cntry_tax DEFINITION


*CLASS lcl_cntry_tax IMPLEMENTATION.
*  METHOD constructor.
*    coun_code = i_coun_code.
*  ENDMETHOD.                    "constructor
*  METHOD prepare_data.
*    DATA : ls_seg TYPE zcntry_tax_seg.
*    SELECT  * FROM ZSTUDENT_SAPNUTS INTO TABLE  lt_cnty_tax WHERE countyr = coun_code.
*    IF sy-subrc = 0.
*      LOOP AT lt_cnty_tax INTO ls_cnty_tax.
*        ls_data-segnam  = 'ZSTUDENT_SEGMENT'. " segment name
*        ls_seg-countyr = ls_cnty_tax-countyr.
*        ls_seg-tax_code = ls_cnty_tax-tax_code.
*        ls_data-sdata = ls_seg.
*        APPEND ls_data TO lt_data.
*        CLEAR ls_data.
*      ENDLOOP.
*    ELSE.
*      MESSAGE 'No record found' TYPE 'E'.
*    ENDIF.
*  ENDMETHOD.                    "prepare_data
*  METHOD prepare_cntl_data.
*    ls_control-idoctp = c_idcotype.
*    ls_control-mestyp = c_msgtype.
*    ls_control-rcvpor = c_port.
*    ls_control-rcvprt = c_rec_part_type .
*    ls_control-rcvprn = c_rec_sys.
*    ls_control-sndprt = c_sndr_part_type .
*    ls_control-sndprn = c_sndr_sys.
*
*  ENDMETHOD.                    "prepare_cntl_data
*  METHOD send_idoc.
*    CALL FUNCTION 'MASTER_IDOC_DISTRIBUTE'
*      EXPORTING
*        master_idoc_control            = ls_control
**       OBJ_TYPE                       = ''
**       CHNUM                          = ''
*      TABLES
*        communication_idoc_control     = lt_comm_idoc
*        master_idoc_data               = lt_data
*      EXCEPTIONS
*        error_in_idoc_control          = 1
*        error_writing_idoc_status      = 2
*        error_in_idoc_data             = 3
*        sending_logical_system_unknown = 4
*        OTHERS                         = 5.
*    IF sy-subrc = 0.
*      LOOP AT lt_comm_idoc INTO ls_comm_idoc.
*        WRITE :/ 'Idoc Generated : ', ls_comm_idoc-docnum.
*      ENDLOOP.
*    ENDIF.
*
*  ENDMETHOD.                    "send_idoc
*ENDCLASS.                    "lcl_cntry_tax IMPLEMENTATION
*
*START-OF-SELECTION.
*  PARAMETERS : p_cntry TYPE zcntry_tax_code-countyr.
*  DATA  : obj TYPE REF TO lcl_cntry_tax.
*
*  CREATE OBJECT obj
*    EXPORTING
*      i_coun_code = p_cntry.
*  CALL METHOD obj->prepare_data.
*  CALL METHOD obj->prepare_cntl_data.
*  CALL METHOD obj->send_idoc.
