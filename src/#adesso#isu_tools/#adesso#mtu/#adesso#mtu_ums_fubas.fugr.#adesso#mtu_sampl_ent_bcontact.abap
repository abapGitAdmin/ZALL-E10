FUNCTION /ADESSO/MTU_SAMPL_ENT_BCONTACT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IBCT_BCONTD STRUCTURE  /ADESSO/MT_BCONTD OPTIONAL
*"      IBCT_PBCOBJ STRUCTURE  /ADESSO/MT_BPC_OBJ OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_BCT) LIKE  BCONT-BPCONTACT
*"----------------------------------------------------------------------

  TABLES: bconto.
  TABLES: but000, ehauisu.
  TABLES: /adesso/mte_rel.
  DATA: i_obj TYPE TABLE OF bconto WITH HEADER LINE.

  READ TABLE ibct_bcontd INDEX 1.

  SELECT * FROM bconto INTO CORRESPONDING FIELDS OF TABLE i_obj
             WHERE bpcontact = ibct_bcontd-bpcontact.

  IF NOT i_obj[] IS INITIAL.
    LOOP AT i_obj.
      IF NOT i_obj-objkey IS INITIAL.
        IF i_obj-objkey NE '0000000000000'.
          MOVE: i_obj-objtype TO ibct_pbcobj-objtype,
                i_obj-objkey TO ibct_pbcobj-objkey.
          APPEND ibct_pbcobj.
          CLEAR ibct_pbcobj.
        ENDIF.
      ENDIF.
    ENDLOOP.


    IF NOT ibct_pbcobj[] IS INITIAL.
      LOOP AT ibct_pbcobj.
        IF ibct_pbcobj-objtype = 'ISUPARTNER'.
**     Prüfen Partner auf Relevanz
          SELECT SINGLE * FROM /adesso/mte_rel
               WHERE firma = firma
               AND object = 'PARTNER'
               AND obj_key = ibct_pbcobj-objkey.
          IF sy-subrc NE 0.
            DELETE ibct_pbcobj.
            CONTINUE.
          ENDIF.
          MOVE 'ZGPARTNER' TO ibct_pbcobj-objrole.
        ELSEIF ibct_pbcobj-objtype = 'CONNOBJ'.
**     Prüfen Anschlussobjekt auf Relevanz
          SELECT SINGLE * FROM /adesso/mte_rel
               WHERE firma = firma
               AND object = 'CONNOBJ'
               AND obj_key = ibct_pbcobj-objkey.
          IF sy-subrc NE 0.
            DELETE ibct_pbcobj.
            CONTINUE.
          ENDIF.
          MOVE  'ZAOBJEKT' TO ibct_pbcobj-objrole.
        ENDIF.
        MODIFY ibct_pbcobj.
      ENDLOOP.
    ENDIF.
  ENDIF.

  CLEAR i_obj. REFRESH i_obj.

*  Geschäftspartnerzusammenführung hier auskommentiert
*  DATA: w_partner_u LIKE /adesso/mte_gpzs-partner_u,
*        w_partner_o LIKE /adesso/mte_gpzs-partner_o.
*
*** Geschäftspartnerzusammenführung
*  READ TABLE ibct_bcontd INDEX 1.
*
*  SELECT SINGLE partner_u partner_o
*         FROM /adesso/mte_gpzs
*         INTO (w_partner_u, w_partner_o)
*         WHERE firma = firma
*          AND partner_u = ibct_bcontd-partner.
*
*** Zusammenführung erforderlich
*** Schlüssel des Geschäftspartners ersetzen
*  IF sy-subrc = 0.
*    ibct_bcontd-partner = w_partner_o.
*    MODIFY ibct_bcontd INDEX 1.
*  ENDIF.
*
** Umschlüsselung der ACTIVITY und CCLASS,
** der Tabelle BCONT
** in 6 Fällen muss umgeschlüsselt werden
** 08.07.2008 X_BRUENKEN.Y
*
*  IF ibct_bcontd-cclass = '0003'.
*    IF ibct_bcontd-activity = '0001' OR
*       ibct_bcontd-activity = '0002'.
*      MOVE '0001' TO ibct_bcontd-activity.
*      MOVE '0100' TO ibct_bcontd-cclass.
*      MODIFY ibct_bcontd index 1.
*    ENDIF.
*
*  ELSEIF ibct_bcontd-cclass = '0011'.
*    IF ibct_bcontd-activity = '0008'.
*
*      MOVE '0010' TO ibct_bcontd-activity.
*      MOVE '0210' TO ibct_bcontd-cclass.
*      MODIFY ibct_bcontd index 1.
*
*    ELSEIF ibct_bcontd-activity = '0009'.
*      MOVE '0001' TO ibct_bcontd-activity.
*      MOVE '0210' TO ibct_bcontd-cclass.
*      MODIFY ibct_bcontd index 1.
*    ENDIF.
*
*  ELSEIF ibct_bcontd-cclass = '0015'.
*    IF ibct_bcontd-activity = '0001' OR
*       ibct_bcontd-activity = '0002'.
*      MOVE '0005' TO ibct_bcontd-activity.
*      MOVE '0210' TO ibct_bcontd-cclass.
*      MODIFY ibct_bcontd index 1.
*    ENDIF.
*  ELSE.
*  ENDIF.

ENDFUNCTION.
