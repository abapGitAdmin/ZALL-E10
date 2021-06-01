FUNCTION /adesso/mtu_sampl_ent_instln.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      INS_KEY STRUCTURE  /ADESSO/MT_EANLHKEY OPTIONAL
*"      INS_DATA STRUCTURE  /ADESSO/MT_EMG_EANL OPTIONAL
*"      INS_RCAT STRUCTURE  /ADESSO/MT_ISU_AITTYP OPTIONAL
*"      INS_POD STRUCTURE  /ADESSO/MT_EUI_EXT_OBJ_AUTO OPTIONAL
*"      INS_FACTS STRUCTURE  /ADESSO/MT_FACTS OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_INS) LIKE  EANL-ANLAGE
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Anlage (Entladung)

  DATA: w_eadrdat    LIKE eadrdat,
        w_addr_data  LIKE isu_reg0.

  CLEAR: w_eadrdat, w_addr_data.

* Für Anlage KEY lesen
  READ TABLE ins_key INDEX 1.

* Ableseeinheit aus der Regionalstruktur holen
  CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
    EXPORTING
      x_address_type             = 'I'
      x_read_mru                 = 'X'
      x_anlage                   = ins_key-anlage
    IMPORTING
      y_eadrdat                  = w_eadrdat
      y_addr_data                = w_addr_data
    EXCEPTIONS
      not_found                  = 1
      parameter_error            = 2
      object_not_given           = 3
      address_inconsistency      = 4
      installation_inconsistency = 5
      OTHERS                     = 6.

  IF sy-subrc <> 0.
    CONCATENATE 'Fehler bei der Ermittlung der Ableseeinheit'
                '.'
                INTO meldung
                SEPARATED BY space.
    APPEND meldung.
    RAISE no_key.

  ELSE.
*   Neue Ableseeinheit in Struktur übertragen
    ins_data-ableinh = w_addr_data-ableinh.
    MODIFY ins_data INDEX 1.
  ENDIF.

ENDFUNCTION.
