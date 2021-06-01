*&---------------------------------------------------------------------*
*&  Include           /ADESSO/ESERVICE_EDIFACT_F01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Kopie des Include: ZEBI_ESERVICE_EDIFACT_UPDATF01, wurde aus dem DUW-System übernommen
*----------------------------------------------------------------------*
* Änderungshistorie:
* Datum       Benutzer  Grund
*----------------------------------------------------------------------*
* 29.08.16    M38882    Übernahme für EDIFACT an Endkunde
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  ERROR_HANDLING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_ERROR  text
*      -->P_LS_AUTO_OLD  text
*      -->P_LS_EUIINSTLN  text
*      -->P_LS_EVER  text
*      -->P_LS_NEW_ESERVICE  text
*----------------------------------------------------------------------*
FORM error_handling  USING    iv_error TYPE kennzx
                              is_auto TYPE isuedi_nbservice_auto
                              is_euiinstln TYPE euiinstln
                              is_ever TYPE ever
                              is_new_eservice TYPE eservice
                              is_euitrans TYPE euitrans.

  DATA: ls_object TYPE swc_object.

  IF iv_error IS INITIAL.
    mac_msg_putx co_msg_success '006' '/ADESSO/EDIFACT_INV'
      is_auto-eserviced-service is_ever-vkonto is_euitrans-ext_ui
      space space.
    SET EXTENDED CHECK OFF.
    IF 1 = 2. MESSAGE s006(/adesso/edifact_inv). ENDIF.
    SET EXTENDED CHECK ON.
* attributes may have changed, force new read from DB
    swc_create_object ls_object 'ISUNBSERVC' is_new_eservice-vertrag.
    swc_refresh_object ls_object.
    CLEAR is_new_eservice.
  ELSE.
    mac_msg_putx co_msg_error '007' '/ADESSO/EDIFACT_INV'
      is_auto-eserviced-service is_ever-vkonto is_euitrans-ext_ui
      space space.
    SET EXTENDED CHECK OFF.
    IF 1 = 2. MESSAGE e007(/adesso/edifact_inv). ENDIF.
    SET EXTENDED CHECK ON.
  ENDIF.
ENDFORM.                    " ERROR_HANDLING
*&---------------------------------------------------------------------*
*&      Form  ESERVICE_INSERT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_AUTO_OLD  text
*      <--P_LV_UPDATEDONE  text
*      <--P_LS_NEW_ESERVICE  text
*----------------------------------------------------------------------*
FORM eservice_insert  USING    is_auto TYPE isuedi_nbservice_auto
                               iv_kdate TYPE eservice-service_start
                      CHANGING cv_updatedone TYPE regen-db_update
                               cs_new_eservice TYPE eservice
                               cv_error TYPE kennzx.

  CALL FUNCTION 'ISU_S_NBSERVICE_CREATE'
    EXPORTING
      x_vertrag      = space
      x_keydate      = iv_kdate
      x_upd_online   = 'X'
      x_no_dialog    = 'X'
      x_auto         = is_auto
    IMPORTING
      y_db_update    = cv_updatedone
      y_new_eservice = cs_new_eservice
    EXCEPTIONS
      foreign_lock   = 1
      general_fault  = 2
      input_error    = 3
      not_authorized = 4
      OTHERS         = 5.
  IF sy-subrc <> 0 OR cs_new_eservice IS INITIAL.
    cv_error = 'X'.
  ENDIF.

ENDFORM.                    " ESERVICE_INSERT
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ESERVPROFSERVICE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_AUTO  text
*      -->P_P_PROV  text
*      -->P_P_KDATE  text
*      -->P_LS_EUIINSTLN  text
*----------------------------------------------------------------------*
FORM update_eservprofservice  USING    is_auto TYPE isuedi_nbservice_auto
                                       iv_prov TYPE eservprov-serviceid
                                       iv_kdate TYPE eservice-service_start
                                       is_euiinstln TYPE euiinstln.

  DATA: lt_eservprovservice     TYPE TABLE OF eservprovservice,
        ls_eservprovservice     TYPE eservprovservice,
        ls_eservprovservice_neu TYPE eservprovservice.

  SELECT * FROM eservprovservice INTO TABLE lt_eservprovservice
          WHERE serviceid = is_auto-eserviced-serviceid AND
             service = is_auto-eserviced-service.

  IF lt_eservprovservice[] IS NOT INITIAL.
    SORT lt_eservprovservice BY dateto DESCENDING.
    READ TABLE lt_eservprovservice INTO ls_eservprovservice INDEX 1.
    IF ls_eservprovservice-dateto <> '99991231'.
      ls_eservprovservice_neu = ls_eservprovservice.
* latest entry of this table has to have 31.12.9999 as enddate. otherwise it will be deleted
      DELETE eservprovservice FROM ls_eservprovservice.
* make a new time line
      ls_eservprovservice_neu-datefrom = iv_kdate.
      ls_eservprovservice_neu-dateto = '99991231'.
* put a new entry from p_kdate until 31.12.9999
      INSERT eservprovservice FROM ls_eservprovservice_neu.
    ENDIF.
  ELSE.
* there is no entry in the table regarding service and provider
    CLEAR ls_eservprovservice_neu.
    ls_eservprovservice_neu-mandt = sy-mandt.
    ls_eservprovservice_neu-serviceid = iv_prov.
    ls_eservprovservice_neu-service = is_auto-eserviced-service.
    ls_eservprovservice_neu-dateto = '99991231'.
    ls_eservprovservice_neu-datefrom = iv_kdate.
    INSERT eservprovservice FROM ls_eservprovservice_neu.
  ENDIF.

ENDFORM.                    " UPDATE_ESERVPROFSERVICE
