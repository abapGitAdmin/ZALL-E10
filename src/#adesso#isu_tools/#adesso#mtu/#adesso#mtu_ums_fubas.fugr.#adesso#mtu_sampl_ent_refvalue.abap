FUNCTION /adesso/mtu_sampl_ent_refvalue.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IRVA_ETTIFB STRUCTURE  /ADESSO/MT_ETTIFB OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_RVA) LIKE  EANL-ANLAGE
*"----------------------------------------------------------------------
* SAMPLE-Baustein zur Umschlüsselung der Bezugsgrößen (Entladung)

LOOP AT irva_ettifb.

 IF irva_ettifb-operand NE 'AMREZ---03'.
   DELETE irva_ettifb.
 ENDIF.

ENDLOOP.

ENDFUNCTION.
