class /ADZ/CL_INV_REMADV_HELPER definition
  public
  create public .

public section.

  class-methods GET_ANALAGE
    importing
      !IV_EXT_UI type EXT_UI
    returning
      value(RV_ANLAGE) type ANLAGE .
  class-methods GET_CIC_FRAME_4_USER
    returning
      value(RV_SCREEN_NO) type CICFWSCREENNO .
protected section.
private section.
ENDCLASS.



CLASS /ADZ/CL_INV_REMADV_HELPER IMPLEMENTATION.


  METHOD get_analage.

    SELECT SINGLE euiinstln~anlage INTO rv_anlage
      FROM euiinstln
     INNER JOIN euitrans
             ON  euiinstln~int_ui = euitrans~int_ui
     WHERE euitrans~ext_ui = iv_ext_ui
       AND euiinstln~dateto >= sy-datum
       AND euitrans~dateto >= sy-datum
       AND euiinstln~datefrom <= sy-datum
       AND euitrans~datefrom <= sy-datum.

  ENDMETHOD.


  METHOD get_cic_frame_4_user.

    DATA: lt_cic_prof TYPE TABLE OF cicprofiles.

    CALL FUNCTION 'CIC_GET_ORG_PROFILES'
      EXPORTING
        agent                 = sy-uname
      TABLES
        profile_list          = lt_cic_prof
      EXCEPTIONS
        call_center_not_found = 1
        agent_group_not_found = 2
        profiles_not_found    = 3
        no_hr_record          = 4
        cancel                = 5
        OTHERS                = 6.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

* existiert mind. 1 Eintrag
    IF lines( lt_cic_prof ) EQ 0.
      RETURN.
    ENDIF.

* 1. Datensatz aus Tabelle zuweisen
    READ TABLE lt_cic_prof ASSIGNING FIELD-SYMBOL(<ls_prof>) INDEX 1.
* Fehlerprüfung
    IF <ls_prof> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

* Passendes CIC-Profil lesen
* Konfiguration auslesen um die DYNPRO-Nr zu gelangen
    SELECT SINGLE frame_screen
      INTO rv_screen_no
      FROM cicprofile
     INNER JOIN cicconf
             ON cicconf~mandt      = cicprofile~mandt
            AND cicconf~frame_conf = cicprofile~framework_id
     WHERE cicprofile~mandt   = sy-mandt
       AND cicprofile~cicprof = <ls_prof>-cicprof.

  ENDMETHOD.
ENDCLASS.
