FUNCTION /adesso/ea_find_gesperrte_anla.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_INT_UI) TYPE  EIDESWTDOC-POD
*"     REFERENCE(I_DATUM) TYPE  EUITRANS-DATEFROM
*"  EXPORTING
*"     REFERENCE(E_ANLAGEN_GESPERRT) TYPE  STRUC_ANLAGE_TAB
*"     REFERENCE(E_ANLAGEN_SPERREING) TYPE  STRUC_ANLAGE_TAB
*"     REFERENCE(E_DISCNO) TYPE  ECRM_EDISCNO_TAB
*"     REFERENCE(E_SPERREN) TYPE  KENNZX
*"  EXCEPTIONS
*"      NO_POD
*"      NO_ANLAGEN
*"----------------------------------------------------------------------

  DATA: lf_euihead       TYPE euihead,
        lf_euitrans      TYPE euitrans,
        lf_installation  TYPE bapiisupodinstln,
        lt_installations TYPE TABLE OF bapiisupodinstln,
        lo_anlage        TYPE swc0_object,
        ld_sperrstatus   TYPE eanldiscst,
        lt_disc          TYPE TABLE OF swc0_object,
        lo_disc          TYPE swc0_object,
        ld_discno        TYPE ECRM_EDISCNO.




*1.  POD prüfen.
  SELECT SINGLE * FROM euihead INTO lf_euihead WHERE int_ui = i_int_ui.
  IF sy-subrc NE 0.
    RAISE no_pod.
  ENDIF.

  SELECT SINGLE * FROM euitrans INTO lf_euitrans
  WHERE int_ui = i_int_ui AND dateto GE i_datum AND datefrom LE i_datum.

  IF sy-subrc NE 0.
    RAISE no_pod.
  ENDIF.


*2. Anlagen zum Pod besorgen
  CALL FUNCTION 'BAPI_ISUPOD_GETINSTALLATION'
    EXPORTING
      pointofdelivery = lf_euitrans-ext_ui
      keydate         = i_datum
    TABLES
      installation    = lt_installations.

  IF lt_installations[] IS INITIAL.
    RAISE no_anlagen.
  ENDIF.

* Untersuchen der Anlagen
  LOOP AT lt_installations INTO lf_installation.

    swc0_create_object lo_anlage 'INSTLN' lf_installation-installation.

    swc0_get_property lo_anlage 'DisconnectionStatus' ld_sperrstatus.
    CHECK sy-subrc EQ 0.
    CLEAR lt_disc.
    swc0_get_table_property
        lo_anlage 'ActDisconnectionDocuments' lt_disc.
    LOOP AT lt_disc INTO lo_disc.
      swc0_get_object_key lo_disc ld_discno-discno.
      COLLECT ld_discno INTO e_discno.
    ENDLOOP.
    CASE ld_sperrstatus.
      WHEN '00'. "Komplett in Betrieb
      WHEN '05'. "Sperre eingeleitet
        APPEND lf_installation TO e_anlagen_sperreing.
      WHEN '10' OR '11'. "Komplett gesperrt.
        APPEND lf_installation TO e_anlagen_gesperrt.
    ENDCASE.
    swc0_free_object lo_anlage.
  ENDLOOP.


  CLEAR e_sperren.
  IF NOT e_anlagen_gesperrt[] IS INITIAL.
    MOVE 'X' TO e_sperren.
  ELSEIF NOT e_anlagen_sperreing[] IS INITIAL.
    MOVE 'E' TO e_sperren.
  ENDIF.


ENDFUNCTION.
