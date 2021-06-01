*&---------------------------------------------------------------------*
*&  Include           /ADESSO/DRKBELEG_FREIGABETOP
*&---------------------------------------------------------------------*
* TOP Include im Report /ADESSO/DRKBELEG_FREIGABE
* inhalt: Datendefinitionen
*
* Änderungshistorie:
*     Datum       Benutzer  Grund
* ---------------------------------------------------------------------

INCLUDE emsg.

TYPE-POOLS: eemsg.

DATA: gs_param     TYPE eemsg_parm_open,
      gs_eemsg_sub TYPE eemsg_sub,
      gt_eemsg_sub TYPE TABLE OF eemsg_sub,
      gv_handle    TYPE emsg_gen-handle.

DATA: gt_erdk         TYPE TABLE OF erdk,
      gt_fkkvkp       TYPE TABLE OF fkkvkp,
      gt_erdk_temp    TYPE TABLE OF erdk,
      gt_zeide_edivar TYPE TABLE OF /adesso/edivar,
      gs_zeide_edivar TYPE /adesso/edivar,
      gs_eanl         TYPE eanl,
      gs_fkkvkp       TYPE fkkvkp,
      gt_fkkvk        TYPE TABLE OF fkkvk,
      gs_eservprovp   TYPE eservprovp,
      gs_ever         TYPE ever,
      gs_euiinstln    TYPE euiinstln,
      gs_eservice     TYPE eservice,
      gs_erdk         TYPE erdk.

DATA: gt_erdz    TYPE TABLE OF erdz,
      gs_erdz    TYPE erdz,
      gv_service TYPE sercode,
      gv_vertrag TYPE vertrag,
      gv_mark    TYPE regen-kennzx,
      gv_datum   TYPE /adesso/dbfreidat,
      gv_cond    TYPE string.

FIELD-SYMBOLS <gs_erdk> TYPE erdk.

DATA: gv_00                      TYPE sy-tabix.
