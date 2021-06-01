FUNCTION /adesso/mtu_sampl_bel_strt_rou.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      ISRT_MRU STRUCTURE  EMG_SR_ABLEINH OPTIONAL
*"      ISRT_EQUNR STRUCTURE  EMG_SR_EQUNR OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_SRT) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* Ableseeinheit
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_ableh IS INITIAL.
    SELECT * INTO TABLE iums_ableh
             FROM /adesso/mtu_abeh.
    filled_ableh = 'X'.
    SORT iums_ableh.
  ENDIF.

  READ TABLE isrt_mru INDEX 1.
* Schlüssel füllen
  CLEAR ikey_ableh.
  ikey_ableh-mandt = sy-mandt.
  ikey_ableh-bukrs = bukrs_v.
  ikey_ableh-ableh_alt = isrt_mru-ableinh.

* Umschlüsselung
  READ TABLE iums_ableh WITH KEY ikey_ableh BINARY SEARCH.
  IF sy-subrc = 0.
    isrt_mru-ableinh = iums_ableh-ableh_neu.
    MODIFY isrt_mru INDEX 1.
  ELSE.
    CONCATENATE 'Fehler bei Abl.Einheit-Umschlüsselung,'
                '(Umschl-Key:'
                ikey_ableh-bukrs
                ikey_ableh-ableh_alt ')'
                INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
  ENDIF.



* Prüfen der migrierten Equipments (keine Umschlüsselung).
* Bei Herne werden die Datensätze, die nicht migriert wurden, gelöscht,
* da nicht alle Tarifkunden übernommen wurden
*-----------------------------------------------------------------------
*   Equi-Nr im Zielsystem ermitteln
 LOOP AT isrt_equnr.
    CLEAR itemksv.
    SELECT SINGLE newkey
           INTO itemksv-newkey
           FROM temksv
           WHERE firma  = 'EVU01'
             AND object = 'DEVICE'
             AND oldkey = isrt_equnr-equnr.
    IF sy-subrc NE 0.
      CONCATENATE 'EQUNR-alt'
                  isrt_equnr-equnr
                  'wurde noch nicht migriert'
                  '(Ausschluss)' "Sonderregegelung Herne
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
      DELETE isrt_equnr.  "Sonderregelung Herne
    ENDIF.
  ENDLOOP.



ENDFUNCTION.
