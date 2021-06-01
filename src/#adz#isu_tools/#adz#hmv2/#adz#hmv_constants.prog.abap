*&---------------------------------------------------------------------*
*&  Include           /ADZ/HMV_CONSTANTS
*&---------------------------------------------------------------------*

*
**Die Werte kommen aus der Customizing Tabelle /ADZ/hmv_cons
*
DATA:
  t_hmv_cons TYPE TABLE OF /adz/hmv_cons,
  s_hmv_cons TYPE          /adz/hmv_cons.


DATA:
  c_mansp             TYPE mansp_kk,
  c_mahnv             TYPE mahnv_kk,
  c_doc_kzd           TYPE char1,
  c_doc_kzm           TYPE char1,
  c_doc_kzmsb         TYPE char1,                    "Nuss 09.2018
  c_invoice_status_03 TYPE char2,
  c_invoice_status_04 TYPE char2,
  c_listheader_typ    TYPE slis_listheader-typ,
  c_lockaktyp         TYPE fkkopchl-lockaktyp,
  c_lockr             TYPE fkkopchl-lockr,
  c_lotyp             TYPE fkkopchl-lotyp,
  c_proid             TYPE fkkopchl-proid,
  c_proid_dunn        TYPE proid_kk,
  c_prtio             TYPE sy-tabix,
  c_maxtb             TYPE sy-tabix,
  c_maxtd             TYPE sy-tabix,
  c_faedn_from        TYPE dfkkop-faedn,
  c_faedn_to          TYPE i,
  g_status            TYPE slis_formname,
  g_user_command      TYPE slis_formname,
  c_lotyp_gp_vk       TYPE lotyp_kk,
  h_lotyp_gp_vk       TYPE lotyp_kk,
  c_invoice_paym      TYPE tinv_inv_doc-invoice_type,
  c_invoice_paymst    LIKE tinv_inv_doc-inv_doc_status,
  c_invoice_type7     LIKE tinv_inv_doc-invoice_type,
  c_invoice_type8     LIKE tinv_inv_doc-invoice_type,
  c_invoice_type2     TYPE tinv_inv_doc-invoice_type,
  c_invoice_type4     TYPE tinv_inv_doc-invoice_type,
  c_invoice_type12    TYPE tinv_inv_doc-invoice_type,       "Nuss 09.2018
  c_invoice_type13    TYPE tinv_inv_doc-invoice_type,       "Nuss 09.2018
  c_hvorg_akonto      TYPE tfkhvo-hvorg,
  c_memidoc_dnlcrsn   TYPE /idxmm/de_doc_status,
  c_idxmm_sp03_dunn   TYPE char1,
  c_mahnen            TYPE char1,           "Nuss 06.2018
  c_mahnen_memi       TYPE char1,           "Nuss 06.2018
  c_mahnen_msb        TYPE char1,           "Nuss 09.2018
  c_max_selcond_tasks TYPE i,
  c_min_selcond_tasks TYPE i.

*&---------------------------------------------------------------------*
*&  Include           /ADZ/HMV_ASSIGN_CONSTANTS
*&---------------------------------------------------------------------*
FORM assign_constants.

* Konstanten Tabelle lesen
  SELECT *
    FROM /adz/hmv_cons
    INTO TABLE t_hmv_cons.

* Mahnsperrgrund
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_LOCKR'.
  c_lockr  = s_hmv_cons-attvalue.

* Mahnsperren
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_MANSP'.
  c_mansp  = s_hmv_cons-attvalue.

* Mahnverfahren
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_MAHNV'.
  c_mahnv          = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_FAEDN_FROM'.
  c_faedn_from          = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_FAEDN_TO'.
  c_faedn_to          = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_DOC_KZD'.
  c_doc_kzd       = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_DOC_KZM'.
  c_doc_kzm          = s_hmv_cons-attvalue.

* --> Nuss 09.2018
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_DOC_KZMSB'.
  c_doc_kzmsb          = s_hmv_cons-attvalue.
* <-- Nuss 09.2018

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_PROID'.
  c_proid          = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_PRTIO'.
  c_prtio = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_MAXTB'.
  c_maxtb = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_MAXTD'.
  c_maxtd         = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_LISTHEADER_TYP'.
  c_listheader_typ = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'G_USER_COMMAND'.
  g_user_command = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'G_STATUS'.
  g_status = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_LOTYP_GP_VK'.
  c_lotyp_gp_vk = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_PROID_DUNN'.
  c_proid_dunn = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_LOCKAKTYP'.
  c_lockaktyp = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_LOTYP'.
  c_lotyp = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_INVOICE_PAYMST'.
  c_invoice_paymst = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_INVOICE_PAYM'.
  c_invoice_paym = s_hmv_cons-attvalue.

* Invoic Status 03
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_INVOICE_STATUS_03'.
  c_invoice_status_03 = s_hmv_cons-attvalue.
* Invoic Status 04
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_INVOICE_STATUS_04'.
  c_invoice_status_04 = s_hmv_cons-attvalue.

* Invoice Type 02
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_INVOICE_TYPE2'.
  c_invoice_type2 = s_hmv_cons-attvalue.

* Invoice Type 04
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_INVOICE_TYPE4'.
  c_invoice_type4 = s_hmv_cons-attvalue.

* Invoice Type 07
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_INVOICE_TYPE7'.
  c_invoice_type7   = s_hmv_cons-attvalue.

* Invoice Type 08
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_INVOICE_TYPE8'.
  c_invoice_type8   = s_hmv_cons-attvalue.

* --> Nuss 09.2018
* Invoice Type 012
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_INVOICE_TYPE12'.
  c_invoice_type12   = s_hmv_cons-attvalue.

* Invoice Type 013
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_INVOICE_TYPE13'.
  c_invoice_type13   = s_hmv_cons-attvalue.
* <-- Nuss 09.2018

* Status für MeMi-Beleg-Mahnsperre
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_MEMIDOC_DNLCRSN'.
  c_memidoc_dnlcrsn   = s_hmv_cons-attvalue.

* HMV2 - Mahnprozess nach MMMA SP03 aktiv?
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_IDXMM_SP03_DUNN'.
  c_idxmm_sp03_dunn = s_hmv_cons-attvalue.
  " Test neue Syntax
  "c_idxmm_sp03_dunn = t_hmv_cons[ konstante = 'C_IDXMM_SP03_DUNN' ]-attvalue.



* >>> ET_20160308


** --> Nuss 06.2018
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_AVIS_MAHN'.
  c_mahnen = s_hmv_cons-attvalue.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_AVIS_MAHN_MEMI'.
  c_mahnen_memi = s_hmv_cons-attvalue.
** <-- Nuss 06.2018

** --> Nuss 09.2018
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_AVIS_MAHN_MSB'.
  c_mahnen_msb = s_hmv_cons-attvalue.
* <-- Nuss 09.2018

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'MAX_SELCOND_PER_TASK'.
  IF sy-subrc EQ 0.
    c_max_selcond_tasks = s_hmv_cons-attvalue.
  ELSE.
    c_max_selcond_tasks = 10000.
  ENDIF.

  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'MIN_SELCOND_PER_TASK'.
  IF sy-subrc EQ 0.
    c_min_selcond_tasks = s_hmv_cons-attvalue.
  ELSE.
    c_min_selcond_tasks = 2000.
  ENDIF.

ENDFORM.
