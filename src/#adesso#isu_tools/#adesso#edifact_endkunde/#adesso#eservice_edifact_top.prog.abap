*&---------------------------------------------------------------------*
*&  Include           /ADESSO/ESERVICE_EDIFACT_TOP
*&---------------------------------------------------------------------*
* Report zur Aktualisierung der Tabelle Eservice bzgl. die neue Serviceart
* zum Thema Rechnungslegung EDIFACT, sobald des entsp. Vertragskontos
* vom Sachbearbeiter mit der EDI Variante gekennzeichnet ist.
*
* Änderungshistorie:
* Datum       Benutzer  Grund
*-----------------------------------------------------------------
*-----------------------------------------------------------------
INCLUDE <cntn01>.

INCLUDE emsg.

TYPE-POOLS: eemsg.

DATA: gs_param     TYPE eemsg_parm_open,
      gs_eemsg_sub TYPE eemsg_sub,
      gt_eemsg_sub TYPE TABLE OF eemsg_sub,
      gv_handle    TYPE emsg_gen-handle.

DATA: gs_fkkvkp TYPE fkkvkp.

DATA: gt_euiinstln    TYPE TABLE OF euiinstln,
      gt_ever         TYPE TABLE OF ever,
      gt_anlage       TYPE TABLE OF eanl-anlage,
      gt_eservice     TYPE TABLE OF eservice,
      gv_vertrag_neu  TYPE service_key,
      gv_error        TYPE kennzx,
      gs_ever         TYPE ever,
      gs_eservprov    TYPE eservprov,
      gs_eservice     TYPE eservice,
      gs_eservice_old TYPE eservice,
      gs_euitrans     TYPE euitrans,
      gs_euiinstln    TYPE euiinstln.

DATA: gv_updatedone   TYPE regen-db_update,
      gs_auto         TYPE isuedi_nbservice_auto,
      gs_auto_old     TYPE isuedi_nbservice_auto,
      gs_new_eservice TYPE eservice.

DATA: gt_eservprovservice     TYPE TABLE OF eservprovservice,
      gs_eservprovservice     TYPE eservprovservice,
      gs_eservprovservice_neu TYPE eservprovservice.

DATA: gv_keydatum TYPE sy-datum.
