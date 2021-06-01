FUNCTION /adesso/mtu_sampl_ent_device.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDEV_EQUI STRUCTURE  /ADESSO/MT_V_EQUI OPTIONAL
*"      IDEV_EGERS STRUCTURE  /ADESSO/MT_EGERS OPTIONAL
*"      IDEV_EGERH STRUCTURE  /ADESSO/MT_EGERH OPTIONAL
*"      IDEV_CLHEAD STRUCTURE  /ADESSO/MT_EMG_CLSHEAD OPTIONAL
*"      IDEV_CLDATA STRUCTURE  /ADESSO/MT_API_AUSP OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DEV) LIKE  EQUI-EQUNR
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Geräte (Entladung)
*   die Herstellernamen sollen teilweise geändert werden
*   siehe Umschlüsselungstabelle HERSTELLER

LOOP AT idev_equi.
    IF idev_equi-herst = 'Hersteller M520'.
       idev_equi-herst = 'Hersteller M220'.
       MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'Actaris'.
       idev_equi-herst = 'Actaris'.
       MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'Allmess'.
        idev_equi-herst = 'Allmess Schlumberger GmbH'.
        MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'Bopp & Reuther'.
           idev_equi-herst = 'Bopp & Reuther'.
           MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'Elster'.
        idev_equi-herst = 'Elster Handel GmbH'.
        MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'Elster Handel GmbH'.
        idev_equi-herst = 'Elster Handel GmbH'.
        MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'GMT Gasmesstechnik'.
        idev_equi-herst = 'Gas-Mess-Technik'.
        MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'Heitland'.
        IF idev_equi-matnr = 'G01040'.
         idev_equi-herst = 'Elster Handel GmbH'.
         MODIFY idev_equi.
        ELSE.
        idev_equi-herst =  'Heitland GmbH'.
        MODIFY idev_equi.
        ENDIF.
    ELSEIF idev_equi-herst = 'Helbeck & Kusemann'.
        idev_equi-herst =  'Helbeck & Kusemann'.
        MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'Instromet'.
        idev_equi-herst =  'Instromet'.
        MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'Kromschröder'.
        idev_equi-herst = 'G.Kromschröder AG'.
        MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'Manthey, Remscheid'.
         idev_equi-herst =  'Manthey'.
         MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'Pipersberg'.
         idev_equi-herst = 'Hermann Pipersberg jr.GmbH'.
         MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'Reck & Co Zetel'.
         idev_equi-herst = 'Reck'.
         MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'RMG (Regel- und Messtechnik)'.
         idev_equi-herst = 'RMG'.
         MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'Rombach'.
         idev_equi-herst  = 'Schlumberger Rombach'.
         MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'Schlumberger'.
         idev_equi-herst  = 'Schlumberger Rombach'.
         MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'Spanner-Pollux'.
          idev_equi-herst  = 'Spanner-Pollux GmbH'.
          MODIFY idev_equi.
    ELSEIF idev_equi-herst = 'SPX(Spanner - Pollux)'.
          idev_equi-herst  = 'Spanner-Pollux GmbH'.
          MODIFY idev_equi.
    ELSE.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
