FUNCTION /ADESSO/MTU_SAMPL_BEL_LOADPROF.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      ILOP_KEY STRUCTURE  ELPASS_KEY
*"      ILOP_ELPASS STRUCTURE  ELPASS_AUTO
*"  CHANGING
*"     REFERENCE(OLDKEY_LOP) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung des Lastprofil zu Anlage

*>> Umschlüsselung der Profilnummern
  LOOP AT ilop_elpass.
    CASE ilop_elpass-profile.
      WHEN '000000001050000003'.
        MOVE '000000000050000000' TO ilop_elpass-profile.
        MODIFY ilop_elpass.
      WHEN '000000001050000004'.
        MOVE '000000000050000001' TO ilop_elpass-profile.
        MODIFY ilop_elpass.
      WHEN '000000001050000005'.
        MOVE '000000000050000002' TO ilop_elpass-profile.
        MODIFY ilop_elpass.
    ENDCASE.
  ENDLOOP.
*<<



ENDFUNCTION.
