FUNCTION /adesso/mtu_sampl_ent_facts.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IFAC_KEY STRUCTURE  /ADESSO/MT_EANLHKEY OPTIONAL
*"      IFAC_FACTS STRUCTURE  /ADESSO/MT_FACTS OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_FAC) LIKE  EANL-ANLAGE
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Anlagefakten (Entladung)

LOOP AT ifac_facts.
IF ifac_facts-optyp EQ 'QUANT'.
 IF ifac_facts-operand NE 'AMLEZKOF01' AND
    ifac_facts-operand NE 'AMREZHIF01' AND
    ifac_facts-operand NE 'WMREZHIF01' AND
    ifac_facts-operand NE 'EMREZHIF01' AND
    ifac_facts-operand NE 'GMRHTHIF01' AND
    ifac_facts-operand NE 'GFVE'.

   DELETE ifac_facts.
 ENDIF.
ELSEIF ifac_facts-optyp EQ 'FACTOR'.
  IF ifac_facts-operand NE 'WFNK0' AND
     ifac_facts-operand NE 'WF1K0'.
   DELETE ifac_facts.
  ENDIF.
ELSEIF ifac_facts-optyp EQ 'QPRICE'.
 IF ifac_facts-operand NE 'GPMAP-0001'.
  DELETE ifac_facts.
 ENDIF.
ELSEIF ifac_facts-optyp EQ 'LPRICE'.
   IF ifac_facts-operand NE 'WPPGRD001' AND
      ifac_facts-operand NE 'WPPGRD002'.

   DELETE ifac_facts.
   ENDIF.
ENDIF.
ENDLOOP.

ENDFUNCTION.
