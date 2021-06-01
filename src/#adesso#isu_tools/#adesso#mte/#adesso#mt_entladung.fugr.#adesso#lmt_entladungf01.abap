*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LMT_ENTLADUNGF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FILL_IACC_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_ACC  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_iacc_out  USING coldkey TYPE vkont_kk
                         cfirma  TYPE emg_firma
                         cobject TYPE emg_object
                         p_anz_vk_init TYPE i
                         p_anz_vk TYPE i
                         p_anz_vkp TYPE i
                         p_anz_vklock TYPE i
                         p_anz_vkcorr TYPE i
                         p_anz_vktaxex TYPE i.

  LOOP AT iacc_init.
    wacc_out-firma  = cfirma.
    wacc_out-object = cobject.
    wacc_out-dttyp  = 'INIT'.
    wacc_out-oldkey = coldkey.
    wacc_out-data   = iacc_init.
    ADD 1 TO p_anz_vk_init.
    APPEND wacc_out TO iacc_out.
  ENDLOOP.

  LOOP AT iacc_vk.
    wacc_out-firma  = cfirma.
    wacc_out-object = cobject.
    wacc_out-dttyp  = 'VK'.
    wacc_out-oldkey = coldkey.
    wacc_out-data   = iacc_vk.
    ADD 1 TO p_anz_vk.
    APPEND wacc_out TO iacc_out.
  ENDLOOP.

  LOOP AT iacc_vkp.
    wacc_out-firma  = cfirma.
    wacc_out-object = cobject.
    wacc_out-dttyp  = 'VKP'.
    wacc_out-oldkey = coldkey.
    wacc_out-data   = iacc_vkp.
    ADD 1 TO p_anz_vkp.
    APPEND wacc_out TO iacc_out.
  ENDLOOP.

  LOOP AT iacc_vklock.
    wacc_out-firma  = cfirma.
    wacc_out-object = cobject.
    wacc_out-dttyp  = 'VKLOCK'.
    wacc_out-oldkey = coldkey.
    wacc_out-data   = iacc_vklock.
    ADD 1 TO p_anz_vklock.
    APPEND wacc_out TO iacc_out.
  ENDLOOP.

  LOOP AT iacc_vkcorr.
    wacc_out-firma  = cfirma.
    wacc_out-object = cobject.
    wacc_out-dttyp  = 'VKCORR'.
    wacc_out-oldkey = coldkey.
    wacc_out-data   = iacc_vkcorr.
    ADD 1 TO p_anz_vkcorr.
    APPEND wacc_out TO iacc_out.
  ENDLOOP.

  LOOP AT iacc_vktxex.
    wacc_out-firma  = cfirma.
    wacc_out-object = cobject.
    wacc_out-dttyp  = 'VKTXEX'.
    wacc_out-oldkey = coldkey.
    wacc_out-data   = iacc_vktxex.
    ADD 1 TO p_anz_vktaxex.
    APPEND wacc_out TO iacc_out.
  ENDLOOP.


* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_acc.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_ACC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_acc .

  CLEAR: iacc_init,
         iacc_vk,
         iacc_vkp,
         iacc_vklock,
         iacc_vkcorr,
         iacc_vktxex.

  REFRESH: iacc_init,
           iacc_vk,
           iacc_vkp,
           iacc_vklock,
           iacc_vkcorr,
           iacc_vktxex.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IACN_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_ACN  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_iacn_out  USING   coldkey TYPE vkont_kk
                           cfirma  TYPE emg_firma
                           cobject TYPE emg_object.

  LOOP AT iacn_notkey.
    wacn_out-firma  = cfirma.
    wacn_out-object = cobject.
    wacn_out-dttyp  = 'NOTKEY'.
    wacn_out-oldkey = coldkey.
    wacn_out-data   = iacn_notkey.
    APPEND wacn_out TO iacn_out.
  ENDLOOP.

  LOOP AT iacn_notlin.
    wacn_out-firma  = cfirma.
    wacn_out-object = cobject.
    wacn_out-dttyp  = 'NOTLIN'.
    wacn_out-oldkey = coldkey.
    wacn_out-data   = iacn_notlin.
    APPEND wacn_out TO iacn_out.
  ENDLOOP.


* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_acn.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_ACN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_acn .

  CLEAR: iacn_notkey, iacn_notlin.
  REFRESH: iacn_notkey, iacn_notlin.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_BPM_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_BPM  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_bpm_out  USING   coldkey TYPE abplannr
                          cfirma  TYPE emg_firma
                          cobject TYPE emg_object
                          p_anz_eabp TYPE i
                          p_anz_eabpv TYPE i
                          p_anz_eabps TYPE i
                          p_anz_ejvl  TYPE i.

  LOOP AT ibpm_eabp.
    wbpm_out-firma  = cfirma.
    wbpm_out-object = cobject.
    wbpm_out-dttyp  = 'EABP'.
    wbpm_out-oldkey = coldkey.
    wbpm_out-data   = ibpm_eabp.
    ADD 1 TO p_anz_eabp.
    APPEND wbpm_out TO ibpm_out.
  ENDLOOP.


  LOOP AT ibpm_eabpv.
    wbpm_out-firma  = cfirma.
    wbpm_out-object = cobject.
    wbpm_out-dttyp  = 'EABPV'.
    wbpm_out-oldkey = coldkey.
    wbpm_out-data   = ibpm_eabpv.
    ADD 1 TO p_anz_eabpv.
    APPEND wbpm_out TO ibpm_out.
  ENDLOOP.

  LOOP AT ibpm_eabps.
    wbpm_out-firma  = cfirma.
    wbpm_out-object = cobject.
    wbpm_out-dttyp  = 'EABPS'.
    wbpm_out-oldkey = coldkey.
    wbpm_out-data   = ibpm_eabps.
    ADD 1 TO p_anz_eabps.
    APPEND wbpm_out TO ibpm_out.
  ENDLOOP.

  LOOP AT ibpm_ejvl.
    wbpm_out-firma  = cfirma.
    wbpm_out-object = cobject.
    wbpm_out-dttyp  = 'EJVL'.
    wbpm_out-oldkey = coldkey.
    wbpm_out-data   = ibpm_ejvl.
    ADD 1 TO p_anz_ejvl.
    APPEND wbpm_out TO ibpm_out.
  ENDLOOP.


* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_bpm.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INIT_BPM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_bpm .

  CLEAR: ibpm_eabp, ibpm_eabpv, ibpm_eabps, ibpm_ejvl.

  REFRESH: ibpm_eabp, ibpm_eabpv, ibpm_eabps, ibpm_ejvl.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_BCT_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_BCT  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_bct_out  USING   coldkey TYPE ct_contact
                          cfirma  TYPE emg_firma
                          cobject TYPE emg_object
                           p_anz_bcontd TYPE i
                          p_anz_iobjects TYPE i.



  LOOP AT ibct_bcontd.
    wbct_out-firma  = cfirma.
    wbct_out-object = cobject.
    wbct_out-dttyp  = 'BCONTD'.
    wbct_out-oldkey = coldkey.
    wbct_out-data   = ibct_bcontd.
    ADD 1 TO p_anz_bcontd.
    APPEND wbct_out TO ibct_out.
  ENDLOOP.

  LOOP AT ibct_pbcobj.
    wbct_out-firma  = cfirma.
    wbct_out-object = cobject.
    wbct_out-dttyp  = 'PBCOBJ'.
    wbct_out-oldkey = coldkey.
    wbct_out-data   = ibct_pbcobj.
    ADD 1 TO p_anz_iobjects.
    APPEND wbct_out TO ibct_out.
  ENDLOOP.


  CLEAR:  ibct_bcontd, ibct_pbcobj.
  REFRESH: ibct_bcontd, ibct_pbcobj.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IBCN_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_BCN  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_ibcn_out  USING   coldkey TYPE ct_contact
                           cfirma  TYPE emg_firma
                           cobject TYPE emg_object
                             p_anz_key TYPE i
                           p_anz_tline TYPE i.

  LOOP AT ibcn_notkey.
    wbcn_out-firma  = cfirma.
    wbcn_out-object = cobject.
    wbcn_out-dttyp  = 'NOTKEY'.
    wbcn_out-oldkey = coldkey.
    wbcn_out-data   = ibcn_notkey.
    ADD 1 TO p_anz_key.
    APPEND wbcn_out TO ibcn_out.
  ENDLOOP.

  LOOP AT ibcn_notlin.
    wbcn_out-firma  = cfirma.
    wbcn_out-object = cobject.
    wbcn_out-dttyp  = 'NOTLIN'.
    wbcn_out-oldkey = coldkey.
    wbcn_out-data   = ibcn_notlin.
    ADD 1 TO p_anz_tline.
    APPEND wbcn_out TO ibcn_out.
  ENDLOOP.

  CLEAR: ibcn_notkey, ibcn_notlin.
  REFRESH: ibcn_notkey, ibcn_notlin.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_ICON_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_CON  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_icon_out  USING coldkey TYPE tplnr
                          cfirma  TYPE emg_firma
                          cobject TYPE emg_object
                          p_anz_ehaud TYPE i
                          p_anz_addr_data TYPE i
                          p_anz_addr_comm_data TYPE i.

  LOOP AT icon_co_eha.
    wcon_out-firma  = cfirma.
    wcon_out-object = cobject.
    wcon_out-dttyp  = 'CO_EHA'.
    wcon_out-oldkey = coldkey.
    wcon_out-data   = icon_co_eha.
    ADD 1 TO p_anz_ehaud.
    APPEND wcon_out TO icon_out.
  ENDLOOP.

  LOOP AT icon_co_adr.
    wcon_out-firma  = cfirma.
    wcon_out-object = cobject.
    wcon_out-dttyp  = 'CO_ADR'.
    wcon_out-oldkey = coldkey.
    wcon_out-data   = icon_co_adr.
    ADD 1 TO p_anz_addr_data.
    APPEND wcon_out TO icon_out.
  ENDLOOP.

  LOOP AT icon_co_com.
    wcon_out-firma  = cfirma.
    wcon_out-object = cobject.
    wcon_out-dttyp  = 'CO_COM'.
    wcon_out-oldkey = coldkey.
    wcon_out-data   = icon_co_com.
    ADD 1 TO p_anz_addr_comm_data.
    APPEND wcon_out TO icon_out.
  ENDLOOP.


* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_con.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INIT_CON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_con .

  CLEAR:  icon_co_eha,
          icon_co_adr,
          icon_co_com.

  REFRESH: icon_co_eha,
           icon_co_adr,
           icon_co_com.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_ICNO_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_CNO  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_icno_out  USING   coldkey TYPE haus
                           cfirma  TYPE emg_firma
                           cobject TYPE emg_object.

  LOOP AT icno_notkey.
    wcno_out-firma  = cfirma.
    wcno_out-object = cobject.
    wcno_out-dttyp  = 'NOTKEY'.
    wcno_out-oldkey = coldkey.
    wcno_out-data   = icno_notkey.
    APPEND wcno_out TO icno_out.
  ENDLOOP.

  LOOP AT icno_notlin.
    wcno_out-firma  = cfirma.
    wcno_out-object = cobject.
    wcno_out-dttyp  = 'NOTLIN'.
    wcno_out-oldkey = coldkey.
    wcno_out-data   = icno_notlin.
    APPEND wcno_out TO icno_out.
  ENDLOOP.

  CLEAR: icno_notkey, icno_notlin.
  REFRESH: icno_notkey, icno_notlin.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IDGR_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DGR  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_idgr_out  USING coldkey TYPE devgrp
                         cfirma  TYPE emg_firma
                         cobject TYPE emg_object.

  LOOP AT idgr_edevgr.
    wdgr_out-firma  = cfirma.
    wdgr_out-object = cobject.
    wdgr_out-dttyp  = 'EDEVGR'.
    wdgr_out-oldkey = coldkey.
    wdgr_out-data   = idgr_edevgr.
    APPEND wdgr_out TO idgr_out.
  ENDLOOP.

  LOOP AT idgr_device.
    wdgr_out-firma  = cfirma.
    wdgr_out-object = cobject.
    wdgr_out-dttyp  = 'DEVICE'.
    wdgr_out-oldkey = coldkey.
    wdgr_out-data   = idgr_device.
    APPEND wdgr_out TO idgr_out.
  ENDLOOP.


* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_dgr.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_DGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_dgr .

  CLEAR: idgr_edevgr, idgr_device.
  REFRESH: idgr_edevgr, idgr_device.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IDEV_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DEV  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_idev_out  USING coldkey TYPE equnr
                         cfirma  TYPE emg_firma
                         cobject TYPE emg_object.

  LOOP AT idev_equi.
    wdev_out-firma  = cfirma.
    wdev_out-object = cobject.
    wdev_out-dttyp  = 'EQUI'.
    wdev_out-oldkey = coldkey.
    wdev_out-data   = idev_equi.
    APPEND wdev_out TO idev_out.
  ENDLOOP.

  LOOP AT idev_egers.
    wdev_out-firma  = cfirma.
    wdev_out-object = cobject.
    wdev_out-dttyp  = 'EGERS'.
    wdev_out-oldkey = coldkey.
    wdev_out-data   = idev_egers.
    APPEND wdev_out TO idev_out.
  ENDLOOP.

  LOOP AT idev_egerh.
    wdev_out-firma  = cfirma.
    wdev_out-object = cobject.
    wdev_out-dttyp  = 'EGERH'.
    wdev_out-oldkey = coldkey.
    wdev_out-data   = idev_egerh.
    APPEND wdev_out TO idev_out.
  ENDLOOP.

  LOOP AT idev_clhead.
    wdev_out-firma  = cfirma.
    wdev_out-object = cobject.
    wdev_out-dttyp  = 'CLHEAD'.
    wdev_out-oldkey = coldkey.
    wdev_out-data   = idev_clhead.
    APPEND wdev_out TO idev_out.
  ENDLOOP.

  LOOP AT idev_cldata.
    wdev_out-firma  = cfirma.
    wdev_out-object = cobject.
    wdev_out-dttyp  = 'CLDATA'.
    wdev_out-oldkey = coldkey.
    wdev_out-data   = idev_cldata.
    APPEND wdev_out TO idev_out.
  ENDLOOP.


* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_dev.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_DEV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_dev .

  CLEAR:  idev_equi, idev_egers, idev_egerh, idev_clhead, idev_cldata.

  REFRESH: idev_equi, idev_egers, idev_egerh, idev_clhead, idev_cldata.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_DRT_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DRT  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_drt_out  USING   coldkey TYPE emg_oldkey
                          cfirma  TYPE emg_firma
                          cobject TYPE emg_object.

  LOOP AT idrt_drint.
    wdrt_out-firma  = cfirma.
    wdrt_out-object = cobject.
    wdrt_out-dttyp  = 'DRINT'.
    wdrt_out-oldkey = coldkey.
    wdrt_out-data   = idrt_drint.
    APPEND wdrt_out TO idrt_out.
  ENDLOOP.

  LOOP AT idrt_drdev.
    wdrt_out-firma  = cfirma.
    wdrt_out-object = cobject.
    wdrt_out-dttyp  = 'DRDEV'.
    wdrt_out-oldkey = coldkey.
    wdrt_out-data   = idrt_drdev.
    APPEND wdrt_out TO idrt_out.
  ENDLOOP.

  LOOP AT idrt_drreg.
    wdrt_out-firma  = cfirma.
    wdrt_out-object = cobject.
    wdrt_out-dttyp  = 'DRREG'.
    wdrt_out-oldkey = coldkey.
    wdrt_out-data   = idrt_drreg.
    APPEND wdrt_out TO idrt_out.
  ENDLOOP.


  CLEAR: idrt_drint, idrt_drdev, idrt_drreg.
  REFRESH: idrt_drint, idrt_drdev, idrt_drreg.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IDLC_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DLC  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_idlc_out   USING coldkey TYPE devloc
                         cfirma  TYPE emg_firma
                         cobject TYPE emg_object.

  LOOP AT idlc_egpld.
    wdlc_out-firma  = cfirma.
    wdlc_out-object = cobject.
    wdlc_out-dttyp  = 'EGPLD'.
    wdlc_out-oldkey = coldkey.
    wdlc_out-data   = idlc_egpld.
    APPEND wdlc_out TO idlc_out.
  ENDLOOP.


* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_dlc.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_DLC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_dlc .

  CLEAR idlc_egpld.

  REFRESH idlc_egpld.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IDNO_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DNO  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_idno_out  USING   coldkey TYPE devloc
                           cfirma  TYPE emg_firma
                           cobject TYPE emg_object.

  LOOP AT idno_notkey.
    wdno_out-firma  = cfirma.
    wdno_out-object = cobject.
    wdno_out-dttyp  = 'NOTKEY'.
    wdno_out-oldkey = coldkey.
    wdno_out-data   = idno_notkey.
    APPEND wdno_out TO idno_out.
  ENDLOOP.

  LOOP AT idno_notlin.
    wdno_out-firma  = cfirma.
    wdno_out-object = cobject.
    wdno_out-dttyp  = 'NOTLIN'.
    wdno_out-oldkey = coldkey.
    wdno_out-data   = idno_notlin.
    APPEND wdno_out TO idno_out.
  ENDLOOP.

  CLEAR: idno_notkey, idno_notlin.
  REFRESH: idno_notkey, idno_notlin.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IDCD_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DCD  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_idcd_out  USING coldkey TYPE discno
                         cfirma  TYPE emg_firma
                         cobject TYPE emg_object.

  LOOP AT idcd_header.
    wdcd_out-firma  = cfirma.
    wdcd_out-object = cobject.
    wdcd_out-dttyp  = 'HEADER'.
    wdcd_out-oldkey = coldkey.
    wdcd_out-data   = idcd_header.
    APPEND wdcd_out TO idcd_out.
  ENDLOOP.

  LOOP AT idcd_fkkmaz.
    wdcd_out-firma  = cfirma.
    wdcd_out-object = cobject.
    wdcd_out-dttyp  = 'FKKMAZ'.
    wdcd_out-oldkey = coldkey.
    wdcd_out-data   = idcd_fkkmaz.
    APPEND wdcd_out TO idcd_out.
  ENDLOOP.

* initialisieren der Tabellen je Altsystemschlüssel
  CLEAR: idcd_header, idcd_fkkmaz.
  REFRESH: idcd_header, idcd_fkkmaz.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_IDCO_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DCO  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_idco_out  USING    coldkey TYPE discno
                            cfirma  TYPE emg_firma
                            cobject TYPE emg_object.

  LOOP AT idco_header.
    wdco_out-firma  = cfirma.
    wdco_out-object = cobject.
    wdco_out-dttyp  = 'HEADER'.
    wdco_out-oldkey = coldkey.
    wdco_out-data   = idco_header.
    APPEND wdco_out TO idco_out.
  ENDLOOP.

* initialisieren der Tabellen je Altsystemschlüssel
  CLEAR: idco_header.
  REFRESH: idco_header.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IDCE_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DCE  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_idce_out  USING    coldkey TYPE discno
                            cfirma  TYPE emg_firma
                            cobject TYPE emg_object.

  LOOP AT idce_header.
    wdce_out-firma  = cfirma.
    wdce_out-object = cobject.
    wdce_out-dttyp  = 'HEADER'.
    wdce_out-oldkey = coldkey.
    wdce_out-data   = idce_header.
    APPEND wdce_out TO idce_out.
  ENDLOOP.

  LOOP AT idce_anlage.
    wdce_out-firma  = cfirma.
    wdce_out-object = cobject.
    wdce_out-dttyp  = 'ANLAGE'.
    wdce_out-oldkey = coldkey.
    wdce_out-data   = idce_anlage.
    APPEND wdce_out TO idce_out.
  ENDLOOP.

  LOOP AT idce_device.
    wdce_out-firma  = cfirma.
    wdce_out-object = cobject.
    wdce_out-dttyp  = 'DEVICE'.
    wdce_out-oldkey = coldkey.
    wdce_out-data   = idce_device.
    APPEND wdce_out TO idce_out.
  ENDLOOP.



* initialisieren der Tabellen je Altsystemschlüssel
  CLEAR: idce_header, idce_device, idce_anlage, idce_device.
  REFRESH: idce_header, idce_anlage, idce_device.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IDCR_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DCR  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_idcr_out  USING    coldkey TYPE discno
                            cfirma  TYPE emg_firma
                            cobject TYPE emg_object.
  LOOP AT idcr_header.
    wdcr_out-firma  = cfirma.
    wdcr_out-object = cobject.
    wdcr_out-dttyp  = 'HEADER'.
    wdcr_out-oldkey = coldkey.
    wdcr_out-data   = idcr_header.
    APPEND wdcr_out TO idcr_out.
  ENDLOOP.

* initialisieren der Tabellen je Altsystemschlüssel
  CLEAR: idcr_header.
  REFRESH: idcr_header.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IDCM_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DCM  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_idcm_out  USING    coldkey TYPE discno
                            cfirma  TYPE emg_firma
                            cobject TYPE emg_object.
  LOOP AT idcm_header.
    wdcm_out-firma  = cfirma.
    wdcm_out-object = cobject.
    wdcm_out-dttyp  = 'HEADER'.
    wdcm_out-oldkey = coldkey.
    wdcm_out-data   = idcm_header.
    APPEND wdcm_out TO idcm_out.
  ENDLOOP.

  LOOP AT idcm_anlage.
    wdcm_out-firma  = cfirma.
    wdcm_out-object = cobject.
    wdcm_out-dttyp  = 'ANLAGE'.
    wdcm_out-oldkey = coldkey.
    wdcm_out-data   = idcm_anlage.
    APPEND wdcm_out TO idcm_out.
  ENDLOOP.

  LOOP AT idcm_device.
    wdcm_out-firma  = cfirma.
    wdcm_out-object = cobject.
    wdcm_out-dttyp  = 'DEVICE'.
    wdcm_out-oldkey = coldkey.
    wdcm_out-data   = idcm_device.
    APPEND wdcm_out TO idcm_out.
  ENDLOOP.



* initialisieren der Tabellen je Altsystemschlüssel
  CLEAR: idcm_header, idcm_device, idcm_anlage, idcm_device.
  REFRESH: idcm_header, idcm_anlage, idcm_device.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_DOC_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_S  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_doc_out  USING   coldkey TYPE emg_oldkey
                          cfirma  TYPE emg_firma
                          cobject TYPE emg_object.

  LOOP AT idoc_ko.
    wdoc_out-firma  = cfirma.
    wdoc_out-object = cobject.
    wdoc_out-dttyp  = 'KO'.
    wdoc_out-oldkey = coldkey.
    wdoc_out-data   = idoc_ko.
    APPEND wdoc_out TO idoc_out.
  ENDLOOP.

  LOOP AT idoc_op.
    wdoc_out-firma  = cfirma.
    wdoc_out-object = cobject.
    wdoc_out-dttyp  = 'OP'.
    wdoc_out-oldkey = coldkey.
    wdoc_out-data   = idoc_op.
    APPEND wdoc_out TO idoc_out.
  ENDLOOP.

  LOOP AT idoc_opk.
    wdoc_out-firma  = cfirma.
    wdoc_out-object = cobject.
    wdoc_out-dttyp  = 'OPK'.
    wdoc_out-oldkey = coldkey.
    wdoc_out-data   = idoc_opk.
    APPEND wdoc_out TO idoc_out.
  ENDLOOP.

  LOOP AT idoc_opl.
    wdoc_out-firma  = cfirma.
    wdoc_out-object = cobject.
    wdoc_out-dttyp  = 'OPL'.
    wdoc_out-oldkey = coldkey.
    wdoc_out-data   = idoc_opl.
    APPEND wdoc_out TO idoc_out.
  ENDLOOP.

  LOOP AT idoc_addinf.
    wdoc_out-firma  = cfirma.
    wdoc_out-object = cobject.
    wdoc_out-dttyp  = 'ADDINF'.
    wdoc_out-oldkey = coldkey.
    wdoc_out-data   = idoc_addinf.
    APPEND wdoc_out TO idoc_out.
  ENDLOOP.




* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_doc.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_doc .

  CLEAR: idoc_ko, idoc_op, idoc_opk, idoc_opl, idoc_addinf.

  REFRESH: idoc_ko, idoc_op, idoc_opk, idoc_opl, idoc_addinf.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_FAC_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_FAC  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_fac_out  USING   coldkey TYPE anlage
                          cfirma  TYPE emg_firma
                          cobject TYPE emg_object.

  LOOP AT ifac_key.
    wfac_out-firma  = cfirma.
    wfac_out-object = cobject.
    wfac_out-dttyp  = 'KEY'.
    wfac_out-oldkey = coldkey.
    wfac_out-data   = ifac_key.
    APPEND wfac_out TO ifac_out.
  ENDLOOP.


  LOOP AT ifac_facts.
    wfac_out-firma  = cfirma.
    wfac_out-object = cobject.
    wfac_out-dttyp  = 'FACTS'.
    wfac_out-oldkey = coldkey.
    wfac_out-data   = ifac_facts.
    APPEND wfac_out TO ifac_out.
  ENDLOOP.

* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_fac.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_FAC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_fac .

  CLEAR: ifac_key, ifac_facts.

  REFRESH: ifac_key, ifac_facts.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_INS_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_INS  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_ins_out  USING   coldkey TYPE anlage
                          cfirma  TYPE emg_firma
                          cobject TYPE emg_object
                          p_anz_key TYPE i
                          p_anz_data TYPE i
                          p_anz_rcat TYPE i
                          p_anz_pod  TYPE i.

  LOOP AT ins_key.
    wins_out-firma  = cfirma.
    wins_out-object = cobject.
    wins_out-dttyp  = 'KEY'.
    wins_out-oldkey = coldkey.
    wins_out-data   = ins_key.
    ADD 1 TO p_anz_key.
    APPEND wins_out TO ins_out.
  ENDLOOP.

  LOOP AT ins_data.
    wins_out-firma  = cfirma.
    wins_out-object = cobject.
    wins_out-dttyp  = 'DATA'.
    wins_out-oldkey = coldkey.
    wins_out-data   = ins_data.
    ADD 1 TO p_anz_data.
    APPEND wins_out TO ins_out.
  ENDLOOP.

  LOOP AT ins_rcat.
    wins_out-firma  = cfirma.
    wins_out-object = cobject.
    wins_out-dttyp  = 'RCAT'.
    wins_out-oldkey = coldkey.
    wins_out-data   = ins_rcat.
    ADD 1 TO p_anz_rcat.
    APPEND wins_out TO ins_out.
  ENDLOOP.

  LOOP AT ins_pod.
    wins_out-firma  = cfirma.
    wins_out-object = cobject.
    wins_out-dttyp  = 'POD'.
    wins_out-oldkey = coldkey.
    wins_out-data   = ins_pod.
    ADD 1 TO p_anz_pod.
    APPEND wins_out TO ins_out.
  ENDLOOP.

*  Fakten werden in eigenem Migrationsobjekt migriert
*  LOOP AT ins_facts.
*    wins_out-firma  = cfirma.
*    wins_out-object = cobject.
*    wins_out-dttyp  = 'FACTS'.
*    wins_out-oldkey = coldkey.
*    wins_out-data   = ins_facts.
*    APPEND wins_out TO ins_out.
*  ENDLOOP.

* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_ins.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_INS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_ins .

  CLEAR: ins_key, ins_data, ins_rcat, ins_pod, ins_facts.

  REFRESH: ins_key, ins_data, ins_rcat, ins_pod, ins_facts.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_ICH_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DATEI  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_ich_out   USING   coldkey LIKE /adesso/mt_transfer-oldkey
                            cfirma  TYPE emg_firma
                           cobject TYPE emg_object
                          p_anz_key TYPE i
                          p_anz_data TYPE i
                          p_anz_rcat TYPE i
                          p_anz_pod  TYPE i.

  LOOP AT ich_key.
    wich_out-firma  = cfirma.
    wich_out-object = cobject.
    wich_out-dttyp  = 'KEY'.
    wich_out-oldkey = coldkey.
    wich_out-data   = ich_key.
    ADD 1 TO p_anz_key.
    APPEND wich_out TO ich_out.
  ENDLOOP.

  LOOP AT ich_data.
    wich_out-firma  = cfirma.
    wich_out-object = cobject.
    wich_out-dttyp  = 'DATA'.
    wich_out-oldkey = coldkey.
    wich_out-data   = ich_data.
    ADD 1 TO p_anz_data.
    APPEND wich_out TO ich_out.
  ENDLOOP.

  LOOP AT ich_rcat.
    wich_out-firma  = cfirma.
    wich_out-object = cobject.
    wich_out-dttyp  = 'RCAT'.
    wich_out-oldkey = coldkey.
    wich_out-data   = ich_rcat.
    ADD 1 TO p_anz_rcat.
    APPEND wich_out TO ich_out.
  ENDLOOP.

*  LOOP AT ich_facts.
*    wich_out-firma  = cfirma.
*    wich_out-object = cobject.
*    wich_out-dttyp  = 'FACTS'.
*    wich_out-oldkey = coldkey.
*    wich_out-data   = ich_facts.
*    APPEND wich_out TO ich_out.
*  ENDLOOP.

*  LOOP AT ich_pod.
*    wich_out-firma = cfirma.
*    wich_out-object = cobject.
*    wich_out-dttyp = 'POD'.
*    wich_out-data = ich_pod.
*    ADD 1 TO p_anz_pod.
*    APPEND wich_out TO ich_out.
*  ENDLOOP.

* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_ich.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_ICH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_ich .

  CLEAR: ich_key, ich_data, ich_rcat, ich_facts.

  REFRESH: ich_key, ich_data, ich_rcat, ich_facts.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IPL_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_IPL  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_ipl_out  USING   coldkey TYPE vkont_kk
                          cfirma  TYPE emg_firma
                          cobject TYPE emg_object.

  LOOP AT ipl_ipkey.
    wipl_out-firma  = cfirma.
    wipl_out-object = cobject.
    wipl_out-dttyp  = 'IPKEY'.
    wipl_out-oldkey = coldkey.
    wipl_out-data   = ipl_ipkey.
    APPEND wipl_out TO ipl_out.
  ENDLOOP.

  LOOP AT ipl_ipdata.
    wipl_out-firma  = cfirma.
    wipl_out-object = cobject.
    wipl_out-dttyp  = 'IPDATA'.
    wipl_out-oldkey = coldkey.
    wipl_out-data   = ipl_ipdata.
    APPEND wipl_out TO ipl_out.
  ENDLOOP.

  LOOP AT ipl_ipopky.
    wipl_out-firma  = cfirma.
    wipl_out-object = cobject.
    wipl_out-dttyp  = 'IPOPKY'.
    wipl_out-oldkey = coldkey.
    wipl_out-data   = ipl_ipopky.
    APPEND wipl_out TO ipl_out.
  ENDLOOP.



* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_ipl.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_IPL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_ipl .

  CLEAR: ipl_ipkey, ipl_ipdata, ipl_ipopky.

  REFRESH: ipl_ipkey, ipl_ipdata, ipl_ipopky.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_INM_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_INM  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_inm_out  USING coldkey TYPE emg_oldkey
                        cfirma  TYPE emg_firma
                        cobject TYPE emg_object
                        p_anz_interface TYPE i
                        p_anz_auto_zw TYPE i
                        p_anz_auto_ger TYPE i
                        p_anz_container TYPE i.


  LOOP AT inm_di_int.
    winm_out-firma  = cfirma.
    winm_out-object = cobject.
    winm_out-dttyp  = 'DI_INT'.
    winm_out-oldkey = coldkey.
    winm_out-data   = inm_di_int.
    ADD 1 TO p_anz_interface.
    APPEND winm_out TO inm_out.
  ENDLOOP.

  LOOP AT inm_di_zw.
    winm_out-firma  = cfirma.
    winm_out-object = cobject.
    winm_out-dttyp  = 'DI_ZW'.
    winm_out-oldkey = coldkey.
    winm_out-data   = inm_di_zw.
    ADD 1 TO p_anz_auto_zw.
    APPEND winm_out TO inm_out.
  ENDLOOP.

  LOOP AT inm_di_ger.
    winm_out-firma  = cfirma.
    winm_out-object = cobject.
    winm_out-dttyp  = 'DI_GER'.
    winm_out-oldkey = coldkey.
    winm_out-data   = inm_di_ger.
    ADD 1 TO p_anz_auto_ger.
    APPEND winm_out TO inm_out.
  ENDLOOP.

  LOOP AT inm_di_cnt.
    winm_out-firma  = cfirma.
    winm_out-object = cobject.
    winm_out-dttyp  = 'DI_CNT'.
    winm_out-oldkey = coldkey.
    winm_out-data   = inm_di_cnt.
    ADD 1 TO p_anz_container.
    APPEND winm_out TO inm_out.
  ENDLOOP.



* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_inm.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_INM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_inm .

  CLEAR: inm_di_int, inm_di_zw, inm_di_ger, inm_di_cnt.
  REFRESH: inm_di_int, inm_di_zw, inm_di_ger, inm_di_cnt.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_ILOP_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_LOP  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_ilop_out  USING    coldkey TYPE anlage
                            cfirma  TYPE emg_firma
                            cobject TYPE emg_object.
  LOOP AT ilop_key.
    wlop_out-firma  = cfirma.
    wlop_out-object = cobject.
    wlop_out-dttyp  = 'KEY'.
    wlop_out-oldkey = coldkey.
    wlop_out-data   = ilop_key.
    APPEND wlop_out TO ilop_out.
  ENDLOOP.

  LOOP AT ilop_elpass.
    wlop_out-firma  = cfirma.
    wlop_out-object = cobject.
    wlop_out-dttyp  = 'ELPASS'.
    wlop_out-oldkey = coldkey.
    wlop_out-data   = ilop_elpass.
    APPEND wlop_out TO ilop_out.
  ENDLOOP.

* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_lop.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_LOP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_lop .

  CLEAR ilop_key.
  CLEAR ilop_elpass.

  REFRESH ilop_key.
  REFRESH ilop_elpass.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_MOI_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_MOI  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_moi_out  USING   coldkey TYPE vertrag
                          cfirma  TYPE emg_firma
                          cobject TYPE emg_object
                          p_anz_everd TYPE i.

  LOOP AT imoi_ever.
    wmoi_out-firma  = cfirma.
    wmoi_out-object = cobject.
    wmoi_out-dttyp  = 'EVER'.
    wmoi_out-oldkey = coldkey.
    wmoi_out-data   = imoi_ever.
    ADD 1 TO p_anz_everd.
    APPEND wmoi_out TO imoi_out.
  ENDLOOP.

  CLEAR: imoi_ever.
  REFRESH: imoi_ever.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_INOC_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_NOC  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_inoc_out  USING coldkey TYPE tplnr
                         cfirma  TYPE emg_firma
                         cobject TYPE emg_object.

  LOOP AT inoc_key.
    wnoc_out-firma  = cfirma.
    wnoc_out-object = cobject.
    wnoc_out-dttyp  = 'KEY'.
    wnoc_out-oldkey = coldkey.
    wnoc_out-data   = inoc_key.
    APPEND wnoc_out TO inoc_out.
  ENDLOOP.

  LOOP AT inoc_notes.
    wnoc_out-firma  = cfirma.
    wnoc_out-object = cobject.
    wnoc_out-dttyp  = 'NOTES'.
    wnoc_out-oldkey = coldkey.
    wnoc_out-data   = inoc_notes.
    APPEND wnoc_out TO inoc_out.
  ENDLOOP.

  LOOP AT inoc_text.
    wnoc_out-firma  = cfirma.
    wnoc_out-object = cobject.
    wnoc_out-dttyp  = 'TEXT'.
    wnoc_out-oldkey = coldkey.
    wnoc_out-data   = inoc_text.
    APPEND wnoc_out TO inoc_out.
  ENDLOOP.


* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_noc.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_NOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_noc .

  CLEAR:  inoc_key,
          inoc_notes,
          inoc_text.

  REFRESH: inoc_key,
           inoc_notes,
           inoc_text.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_INOD_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_NOD  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_inod_out  USING coldkey TYPE devloc
                         cfirma  TYPE emg_firma
                         cobject TYPE emg_object.

  LOOP AT inod_key.
    wnod_out-firma  = cfirma.
    wnod_out-object = cobject.
    wnod_out-dttyp  = 'KEY'.
    wnod_out-oldkey = coldkey.
    wnod_out-data   = inod_key.
    APPEND wnod_out TO inod_out.
  ENDLOOP.

  LOOP AT inod_notes.
    wnod_out-firma  = cfirma.
    wnod_out-object = cobject.
    wnod_out-dttyp  = 'NOTES'.
    wnod_out-oldkey = coldkey.
    wnod_out-data   = inod_notes.
    APPEND wnod_out TO inod_out.
  ENDLOOP.

  LOOP AT inod_text.
    wnod_out-firma  = cfirma.
    wnod_out-object = cobject.
    wnod_out-dttyp  = 'TEXT'.
    wnod_out-oldkey = coldkey.
    wnod_out-data   = inod_text.
    APPEND wnod_out TO inod_out.
  ENDLOOP.


* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_nod.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_NOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_nod .

  CLEAR:  inod_key,
          inod_notes,
          inod_text.

  REFRESH: inod_key,
           inod_notes,
           inod_text.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IPAR_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_PAR  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_ipar_out  USING coldkey TYPE bu_partner
                         cfirma  TYPE emg_firma
                         cobject TYPE emg_object
                         p_anz_init TYPE i
                         p_anz_ekun TYPE i
                         p_anz_but000 TYPE i
                         p_anz_buticom TYPE i
                         p_anz_but001 TYPE i
                         p_anz_but0bk TYPE i
                         p_anz_but020 TYPE i
                         p_anz_but021 TYPE i
                         p_anz_but0cc TYPE i
                         p_anz_shipto TYPE i
                         p_anz_taxnum TYPE i
                         p_anz_eccard TYPE i
                         p_anz_eccardh TYPE i
                         p_anz_but0is TYPE i.


  LOOP AT ipar_init.
    wpar_out-firma  = cfirma.
    wpar_out-object = cobject.
    wpar_out-dttyp  = 'INIT'.
    wpar_out-oldkey = coldkey.
    wpar_out-data   = ipar_init.
    ADD 1 TO p_anz_init.
    APPEND wpar_out TO ipar_out.
  ENDLOOP.

  LOOP AT ipar_ekun.
    wpar_out-firma  = cfirma.
    wpar_out-object = cobject.
    wpar_out-dttyp  = 'EKUN'.
    wpar_out-oldkey = coldkey.
    wpar_out-data   = ipar_ekun.
    ADD 1 TO p_anz_ekun.
    APPEND wpar_out TO ipar_out.
  ENDLOOP.

  LOOP AT ipar_but000.
    wpar_out-firma  = cfirma.
    wpar_out-object = cobject.
    wpar_out-dttyp  = 'BUT000'.
    wpar_out-oldkey = coldkey.
    wpar_out-data   = ipar_but000.
    ADD 1 TO p_anz_but000.
    APPEND wpar_out TO ipar_out.
  ENDLOOP.

  LOOP AT ipar_but001.
    wpar_out-firma  = cfirma.
    wpar_out-object = cobject.
    wpar_out-dttyp  = 'BUT001'.
    wpar_out-oldkey = coldkey.
    wpar_out-data   = ipar_but001.
    ADD 1 TO p_anz_but001.
    APPEND wpar_out TO ipar_out.
  ENDLOOP.

  LOOP AT ipar_bus000icomm.
    wpar_out-firma = cfirma.
    wpar_out-object = cobject.
    wpar_out-dttyp = 'BUTCOM'.
    wpar_out-oldkey = coldkey.
    wpar_out-data = ipar_bus000icomm.
    ADD 1 TO p_anz_buticom.
    APPEND wpar_out TO ipar_out.
  ENDLOOP.

  LOOP AT ipar_but0bk.
    wpar_out-firma  = cfirma.
    wpar_out-object = cobject.
    wpar_out-dttyp  = 'BUT0BK'.
    wpar_out-oldkey = coldkey.
    wpar_out-data   = ipar_but0bk.
    ADD 1 TO p_anz_but0bk.
    APPEND wpar_out TO ipar_out.
  ENDLOOP.

  LOOP AT ipar_but020.
    wpar_out-firma  = cfirma.
    wpar_out-object = cobject.
    wpar_out-dttyp  = 'BUT020'.
    wpar_out-oldkey = coldkey.
    wpar_out-data   = ipar_but020.
    ADD 1 TO p_anz_but020.
    APPEND wpar_out TO ipar_out.
  ENDLOOP.

  LOOP AT ipar_but021.
    wpar_out-firma  = cfirma.
    wpar_out-object = cobject.
    wpar_out-dttyp  = 'BUT021'.
    wpar_out-oldkey = coldkey.
    wpar_out-data   = ipar_but021.
    ADD 1 TO p_anz_but021.
    APPEND wpar_out TO ipar_out.
  ENDLOOP.

  LOOP AT ipar_but0cc.
    wpar_out-firma  = cfirma.
    wpar_out-object = cobject.
    wpar_out-dttyp  = 'BUT0CC'.
    wpar_out-oldkey = coldkey.
    wpar_out-data   = ipar_but0cc.
    ADD 1 TO p_anz_but0cc.
    APPEND wpar_out TO ipar_out.
  ENDLOOP.

  LOOP AT ipar_shipto.
    wpar_out-firma  = cfirma.
    wpar_out-object = cobject.
    wpar_out-dttyp  = 'SHIPTO'.
    wpar_out-oldkey = coldkey.
    wpar_out-data   = ipar_shipto.
    ADD 1 TO p_anz_shipto.
    APPEND wpar_out TO ipar_out.
  ENDLOOP.

  LOOP AT ipar_taxnum.
    wpar_out-firma  = cfirma.
    wpar_out-object = cobject.
    wpar_out-dttyp  = 'TAXNUM'.
    wpar_out-oldkey = coldkey.
    wpar_out-data   = ipar_taxnum.
    ADD 1 TO p_anz_taxnum.
    APPEND wpar_out TO ipar_out.
  ENDLOOP.

  LOOP AT ipar_eccard.
    wpar_out-firma  = cfirma.
    wpar_out-object = cobject.
    wpar_out-dttyp  = 'ECCARD'.
    wpar_out-oldkey = coldkey.
    wpar_out-data   = ipar_eccard.
    APPEND wpar_out TO ipar_out.
  ENDLOOP.

  LOOP AT ipar_eccrdh.
    wpar_out-firma  = cfirma.
    wpar_out-object = cobject.
    wpar_out-dttyp  = 'ECCRDH'.
    wpar_out-oldkey = coldkey.
    wpar_out-data   = ipar_eccrdh.
    ADD 1 TO p_anz_eccardh.
    APPEND wpar_out TO ipar_out.
  ENDLOOP.


  LOOP AT ipar_but0is.
    wpar_out-firma  = cfirma.
    wpar_out-object = cobject.
    wpar_out-dttyp  = 'BUT0IS'.
    wpar_out-oldkey = coldkey.
    wpar_out-data   = ipar_but0is.
    ADD 1 TO p_anz_but0is.
    APPEND wpar_out TO ipar_out.
  ENDLOOP.

* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_par.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_PAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_par .

  CLEAR:  ipar_init,
          ipar_ekun,
          ipar_but000,
          ipar_bus000icomm,
          ipar_but001,
          ipar_but0bk,
          ipar_but020,
          ipar_but021,
          ipar_but0cc,
          ipar_shipto,
          ipar_taxnum,
          ipar_eccard,
          ipar_eccrdh,
          ipar_but0is.

  REFRESH: ipar_init,
          ipar_ekun,
          ipar_but000,
          ipar_bus000icomm,
          ipar_but001,
          ipar_but0bk,
          ipar_but020,
          ipar_but021,
          ipar_but0cc,
          ipar_shipto,
          ipar_taxnum,
          ipar_eccard,
          ipar_eccrdh,
          ipar_but0is.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_PNO_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_PNO  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_pno_out  USING   coldkey TYPE emg_oldkey
                          cfirma  TYPE emg_firma
                          cobject TYPE emg_object.

  LOOP AT ipno_notkey.
    wpno_out-firma  = cfirma.
    wpno_out-object = cobject.
    wpno_out-dttyp  = 'NOTKEY'.
    wpno_out-oldkey = coldkey.
    wpno_out-data   = ipno_notkey.
    APPEND wpno_out TO ipno_out.
  ENDLOOP.

  LOOP AT ipno_notlin.
    wpno_out-firma  = cfirma.
    wpno_out-object = cobject.
    wpno_out-dttyp  = 'NOTLIN'.
    wpno_out-oldkey = coldkey.
    wpno_out-data   = ipno_notlin.
    APPEND wpno_out TO ipno_out.
  ENDLOOP.

  CLEAR: ipno_notkey, ipno_notlin.
  REFRESH: ipno_notkey, ipno_notlin.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_PAY_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_PAY  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_pay_out  USING   coldkey TYPE abplannr
                          cfirma  TYPE emg_firma
                          cobject TYPE emg_object.

  LOOP AT ipay_fkkko.
    wpay_out-firma  = cfirma.
    wpay_out-object = cobject.
    wpay_out-dttyp  = 'FKKKO'.
    wpay_out-oldkey = coldkey.
    wpay_out-data   = ipay_fkkko.
    APPEND wpay_out TO ipay_out.
  ENDLOOP.

  LOOP AT ipay_fkkopk.
    wpay_out-firma  = cfirma.
    wpay_out-object = cobject.
    wpay_out-dttyp  = 'FKKOPK'.
    wpay_out-oldkey = coldkey.
    wpay_out-data   = ipay_fkkopk.
    APPEND wpay_out TO ipay_out.
  ENDLOOP.

  LOOP AT ipay_seltns.
    wpay_out-firma  = cfirma.
    wpay_out-object = cobject.
    wpay_out-dttyp  = 'SELTNS'.
    wpay_out-oldkey = coldkey.
    wpay_out-data   = ipay_seltns.
    APPEND wpay_out TO ipay_out.
  ENDLOOP.


* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_pay.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_PAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_pay .

  CLEAR: ipay_fkkko, ipay_fkkopk, ipay_seltns.

  REFRESH: ipay_fkkko, ipay_fkkopk, ipay_seltns.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IPOS_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_POS  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_ipos_out  USING    coldkey TYPE anlage
                            cfirma  TYPE emg_firma
                            cobject TYPE emg_object.

  LOOP AT ipos_podsrv.
    wpos_out-firma  = cfirma.
    wpos_out-object = cobject.
    wpos_out-dttyp  = 'PODSRV'.
    wpos_out-oldkey = coldkey.
    wpos_out-data   = ipos_podsrv.
    APPEND wpos_out TO ipos_out.
  ENDLOOP.


* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_pos.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_POS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_pos .

  CLEAR ipos_podsrv.

  REFRESH ipos_podsrv.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IPRE_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_PRE  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_ipre_out  USING coldkey TYPE vstelle
                         cfirma  TYPE emg_firma
                         cobject TYPE emg_object
                         p_anz_evbsd TYPE i.


  LOOP AT ipre_evbsd.
    wpre_out-firma  = cfirma.
    wpre_out-object = cobject.
    wpre_out-dttyp  = 'EVBSD'.
    wpre_out-oldkey = coldkey.
    wpre_out-data   = ipre_evbsd.
    ADD 1 TO p_anz_evbsd.
    APPEND wpre_out TO ipre_out.
  ENDLOOP.


* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_pre.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_PRE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_pre .

  CLEAR: ipre_evbsd.

  REFRESH: ipre_evbsd.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_RVA_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_RVA  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_rva_out   USING   coldkey TYPE anlage
                          cfirma  TYPE emg_firma
                          cobject TYPE emg_object.

  LOOP AT irva_ettifb.
    wrva_out-firma  = cfirma.
    wrva_out-object = cobject.
    wrva_out-dttyp  = 'ETTIFB'.
    wrva_out-oldkey = coldkey.
    wrva_out-data   = irva_ettifb.
    APPEND wrva_out TO irva_out.
  ENDLOOP.

  CLEAR: irva_ettifb.
  REFRESH: irva_ettifb.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_ISRT_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_SRT  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_isrt_out  USING coldkey TYPE ableinheit
                         cfirma  TYPE emg_firma
                         cobject TYPE emg_object.

  LOOP AT isrt_mru.
    wsrt_out-firma  = cfirma.
    wsrt_out-object = cobject.
    wsrt_out-dttyp  = 'MRU'.
    wsrt_out-oldkey = coldkey.
    wsrt_out-data   = isrt_mru.
    APPEND wsrt_out TO isrt_out.
  ENDLOOP.

  LOOP AT isrt_equnr.
    wsrt_out-firma  = cfirma.
    wsrt_out-object = cobject.
    wsrt_out-dttyp  = 'EQUNR'.
    wsrt_out-oldkey = coldkey.
    wsrt_out-data   = isrt_equnr.
    APPEND wsrt_out TO isrt_out.
  ENDLOOP.

* initialisieren der Tabellen je Altsystemschlüssel
  CLEAR: isrt_mru, isrt_equnr.
  REFRESH: isrt_mru, isrt_equnr.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IDVR_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DVR  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_idvr_out   USING    coldkey LIKE /adesso/mt_devicerel
                             cfirma  TYPE emg_firma
                             cobject TYPE emg_object.

  LOOP AT idvr_int.
    wdvr_out-firma  = cfirma.
    wdvr_out-object = cobject.
    wdvr_out-dttyp  = 'INT'.
    wdvr_out-oldkey = coldkey.
    wdvr_out-data   = idvr_int.
    APPEND wdvr_out TO idvr_out.
  ENDLOOP.

*  LOOP AT idvr_dev.
*    wdvr_out-firma  = cfirma.
*    wdvr_out-object = cobject.
*    wdvr_out-dttyp  = 'DEV'.
*    wdvr_out-oldkey = coldkey.
*    wdvr_out-data   = idvr_dev.
*    APPEND wdvr_out TO idvr_out.
*  ENDLOOP.

  LOOP AT idvr_reg.
    wdvr_out-firma  = cfirma.
    wdvr_out-object = cobject.
    wdvr_out-dttyp  = 'REG'.
    wdvr_out-oldkey = coldkey.
    wdvr_out-data   = idvr_reg.
    APPEND wdvr_out TO idvr_out.
  ENDLOOP.

  PERFORM init_dvr.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_DVR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_dvr .

  CLEAR: idvr_int,
         idvr_reg,
         idvr_dev.


  REFRESH: idvr_int,
           idvr_reg,
           idvr_dev.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_IDIR_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DIR  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_idir_out  USING    coldkey TYPE equnr
                             cfirma  TYPE emg_firma
                             cobject TYPE emg_object.

  LOOP AT idir_int.
    wdir_out-firma  = cfirma.
    wdir_out-object = cobject.
    wdir_out-dttyp  = 'DVMINT'.
    wdir_out-oldkey = coldkey.
    wdir_out-data   = idir_int.
    APPEND wdir_out TO idir_out.
  ENDLOOP.

  LOOP AT idir_dev.
    wdir_out-firma  = cfirma.
    wdir_out-object = cobject.
    wdir_out-dttyp  = 'DVMDEV'.
    wdir_out-oldkey = coldkey.
    wdir_out-data   = idir_dev.
    APPEND wdir_out TO idir_out.
  ENDLOOP.

  LOOP AT idir_dev_flag.
    wdir_out-firma  = cfirma.
    wdir_out-object = cobject.
    wdir_out-dttyp  = 'DVMDFL'.
    wdir_out-oldkey = coldkey.
    wdir_out-data   = idir_dev_flag.
    APPEND wdir_out TO idir_out.
  ENDLOOP.

  LOOP AT idir_reg.
    wdir_out-firma  = cfirma.
    wdir_out-object = cobject.
    wdir_out-dttyp  = 'DVMREG'.
    wdir_out-oldkey = coldkey.
    wdir_out-data   = idir_reg.
    APPEND wdir_out TO idir_out.
  ENDLOOP.

  LOOP AT idir_reg_flag.
    wdir_out-firma  = cfirma.
    wdir_out-object = cobject.
    wdir_out-dttyp  = 'DVMRFL'.
    wdir_out-oldkey = coldkey.
    wdir_out-data   = idir_reg_flag.
    APPEND wdir_out TO idir_out.
  ENDLOOP.

  PERFORM init_dir.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_DIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_dir .

  CLEAR: idir_int,
         idir_dev,
         idir_dev_flag,
         idir_reg,
         idir_reg_flag.


  REFRESH: idir_int,
           idir_dev,
           idir_dev_flag,
           idir_reg,
           idir_reg_flag.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_IRAG_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_RAG  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_irag_out  USING    coldkey TYPE strt_code
                             cfirma  TYPE emg_firma
                             cobject TYPE emg_object.

  LOOP AT iadr_co_st.
    wrag_out-firma  = cfirma.
    wrag_out-object = cobject.
    wrag_out-dttyp  = 'STREET'.
    wrag_out-oldkey = coldkey.
    wrag_out-data   = iadr_co_st.
    APPEND wrag_out TO irag_out.
  ENDLOOP.

  LOOP AT iadr_co_isu.
    wrag_out-firma  = cfirma.
    wrag_out-object = cobject.
    wrag_out-dttyp  = 'ISU'.
*  wrag_out-oldkey = oldkey_rag.
    wrag_out-oldkey = coldkey.
    wrag_out-data   = iadr_co_isu.
    APPEND wrag_out TO irag_out.
  ENDLOOP.

  LOOP AT iadr_co_mru.
    wrag_out-firma  = cfirma.
    wrag_out-object = cobject.
    wrag_out-dttyp  = 'MRU'.
*  wrag_out-oldkey = oldkey_rag.
    wrag_out-oldkey = coldkey.
    wrag_out-data   = iadr_co_mru.
    APPEND wrag_out TO irag_out.
  ENDLOOP.

  LOOP AT iadr_co_con.
    wrag_out-firma  = cfirma.
    wrag_out-object = cobject.
    wrag_out-dttyp  = 'KON'.
*  wrag_out-oldkey = oldkey_rag.
    wrag_out-oldkey = coldkey.
    wrag_out-data   = iadr_co_con.
    APPEND wrag_out TO irag_out.
  ENDLOOP.

  LOOP AT iadr_co_ccs.
    wrag_out-firma  = cfirma.
    wrag_out-object = cobject.
    wrag_out-dttyp  = 'CCS'.
*  wrag_out-oldkey = oldkey_rag.
    wrag_out-oldkey = coldkey.
    wrag_out-data   = iadr_co_ccs.
    APPEND wrag_out TO irag_out.
  ENDLOOP.

* initialisieren der Tabellen je Altsystemschlüssel
  CLEAR: iadr_co_isu, iadr_co_mru, iadr_co_con, iadr_co_ccs, iadr_co_st.
  REFRESH: iadr_co_isu, iadr_co_mru, iadr_co_con, iadr_co_ccs, iadr_co_st.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_INM_INF_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_INM  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*      -->P_ANZ_INTERFACE  text
*      -->P_ANZ_AUTO_ZW  text
*      -->P_ANZ_AUTO_GER  text
*      -->P_ANZ_CONTAINER  text
*----------------------------------------------------------------------*
FORM fill_inm_inf_out  USING coldkey TYPE emg_oldkey
                        cfirma  TYPE emg_firma
                        cobject TYPE emg_object
                        p_anz_interface TYPE i
                        p_anz_auto_zw TYPE i
                        p_anz_auto_ger TYPE i
                        p_anz_container TYPE i.

  LOOP AT inm_di_int.
    winm_out-firma  = cfirma.
    winm_out-object = cobject.
    winm_out-dttyp  = 'DI_INT'.
    winm_out-oldkey = coldkey.
    winm_out-data   = inm_di_int.
    ADD 1 TO p_anz_interface.
    APPEND winm_out TO inm_out.
  ENDLOOP.

  LOOP AT inm_di_zw.
    winm_out-firma  = cfirma.
    winm_out-object = cobject.
    winm_out-dttyp  = 'DI_ZW'.
    winm_out-oldkey = coldkey.
    winm_out-data   = inm_di_zw.
    ADD 1 TO p_anz_auto_zw.
    APPEND winm_out TO inm_out.
  ENDLOOP.

  LOOP AT inm_di_ger.
    winm_out-firma  = cfirma.
    winm_out-object = cobject.
    winm_out-dttyp  = 'DI_GER'.
    winm_out-oldkey = coldkey.
    winm_out-data   = inm_di_ger.
    ADD 1 TO p_anz_auto_ger.
    APPEND winm_out TO inm_out.
  ENDLOOP.

  LOOP AT inm_di_cnt.
    winm_out-firma  = cfirma.
    winm_out-object = cobject.
    winm_out-dttyp  = 'DI_CNT'.
    winm_out-oldkey = coldkey.
    winm_out-data   = inm_di_cnt.
    ADD 1 TO p_anz_container.
    APPEND winm_out TO inm_out.
  ENDLOOP.

* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_inm.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_MOH_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_MOH  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*      -->P_ANZ_EVERD  text
*----------------------------------------------------------------------*
FORM fill_moh_out  USING coldkey TYPE vertrag
                          cfirma  TYPE emg_firma
                          cobject TYPE emg_object
                          p_anz_everd TYPE i.

  LOOP AT imoh_ever.
    wmoh_out-firma  = cfirma.
    wmoh_out-object = cobject.
    wmoh_out-dttyp  = 'EVER'.
    wmoh_out-oldkey = coldkey.
    wmoh_out-data   = imoh_ever.
    ADD 1 TO p_anz_everd.
    APPEND wmoh_out TO imoh_out.
  ENDLOOP.

  CLEAR: imoh_ever.
  REFRESH: imoh_ever.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_MOO_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_MOO  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*      -->P_ANZ_EAUSD  text
*      -->P_ANZ_EAUSVD  text
*----------------------------------------------------------------------*
FORM fill_moo_out  USING    coldkey TYPE vertrag
                            cfirma   TYPE emg_firma
                            cobject TYPE emg_object
                            p_anz_eausd TYPE i
                            p_anz_eausvd TYPE i.

  LOOP AT imoo_eaus.
    wmoo_out-firma = cfirma.
    wmoo_out-object = cobject.
    wmoo_out-dttyp = 'EAUSD'.
    wmoo_out-oldkey = coldkey.
    wmoo_out-data = imoo_eaus.
    ADD 1 TO p_anz_eausd.
    APPEND wmoo_out TO imoo_out.
  ENDLOOP.

  LOOP AT imoo_eausv.
    wmoo_out-firma = cfirma.
    wmoo_out-object = cobject.
    wmoo_out-dttyp = 'EAUSVD'.
    wmoo_out-oldkey = coldkey.
    wmoo_out-data = imoo_eausv.
    ADD 1 TO p_anz_eausvd.
    APPEND wmoo_out TO imoo_out.
  ENDLOOP.


  CLEAR: imoo_eaus, imoo_eausv.

  REFRESH: imoo_eaus, imoo_eausv.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_DUN_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_O_KEY  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*      -->P_ANZ_KEY  text
*      -->P_ANZ_FKKMA  text
*----------------------------------------------------------------------*
FORM fill_dun_out  USING    coldkey
                            cfirma
                            cobject
                            p_anz_key
                            p_anz_fkkma.

  LOOP AT idun_key.
    wdun_out-firma  = cfirma.
    wdun_out-object = cobject.
    wdun_out-dttyp  = 'KEY'.
    wdun_out-oldkey = coldkey.
    wdun_out-data   = idun_key.
    ADD 1 TO p_anz_key.
    APPEND wdun_out TO idun_out.
  ENDLOOP.

  LOOP AT idun_fkkma.
    wdun_out-firma = cfirma.
    wdun_out-object = cobject.
    wdun_out-dttyp = 'FKKMA'.
    wdun_out-oldkey = coldkey.
    wdun_out-data = idun_fkkma.
    APPEND wdun_out TO idun_out.
  ENDLOOP.

  PERFORM init_dun.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  INIT_DUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_dun .

  CLEAR: idun_key,
         idun_fkkma.

  REFRESH: idun_key,
            idun_fkkma.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_INV_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_INV  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*      -->P_ANZ_HEAD  text
*      -->P_ANZ_DOC  text
*      -->P_ANZ_DOC_DB  text
*      -->P_ANZ_LINEB  text
*      -->P_ANZ_APPEND  text
*----------------------------------------------------------------------*
FORM fill_inv_out  USING    coldkey
                            cfirma
                            cobject
                            p_anz_head
                            p_anz_doc
                            p_anz_doc_db
                            p_anz_lineb
                            p_anz_append.

  LOOP AT iinv_head.
    winv_out-firma  = cfirma.
    winv_out-object = cobject.
    winv_out-dttyp  = 'HEAD'.
    winv_out-oldkey = coldkey.
    winv_out-data   = iinv_head.
    ADD 1 TO p_anz_head.
    APPEND winv_out TO iinv_out.
  ENDLOOP.

  LOOP AT iinv_doc.
    winv_out-firma = cfirma.
    winv_out-object = cobject.
    winv_out-dttyp = 'DOC'.
    winv_out-oldkey = coldkey.
    winv_out-data = iinv_doc.
    ADD 1 TO p_anz_doc.
    APPEND winv_out TO iinv_out.
  ENDLOOP.

  LOOP AT iinv_docdb.
    winv_out-firma = cfirma.
    winv_out-object = cobject.
    winv_out-dttyp = 'DOC_DB'.
    winv_out-oldkey = coldkey.
    winv_out-data = iinv_docdb.
    ADD 1 TO p_anz_doc_db.
    APPEND winv_out TO iinv_out.
  ENDLOOP.

  LOOP AT iinv_lineb.
    winv_out-firma = cfirma.
    winv_out-object = cobject.
    winv_out-dttyp = 'LINEB'.
    winv_out-oldkey = coldkey.
    winv_out-data = iinv_lineb.
    ADD 1 TO p_anz_lineb.
    APPEND winv_out TO iinv_out.
  ENDLOOP.

  LOOP AT iinv_append.
    winv_out-firma = cfirma.
    winv_out-object = cobject.
    winv_out-dttyp = 'APPEND'.
    winv_out-oldkey = coldkey.
    winv_out-data = iinv_append.
    ADD 1 TO p_anz_append.
    APPEND winv_out TO iinv_out.
  ENDLOOP.

  PERFORM init_inv.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_INV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_inv .

  CLEAR: iinv_head, iinv_docdb, iinv_doc, iinv_lineb, iinv_append.
  REFRESH: iinv_head, iinv_docdb, iinv_doc, iinv_lineb, iinv_append.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_INN_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_INN  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*      -->P_ANZ_KEY  text
*      -->P_ANZ_DATA  text
*      -->P_ANZ_RCAT  text
*      -->P_ANZ_POD  text
*----------------------------------------------------------------------*
FORM fill_inn_out USING   coldkey TYPE anlage
                          cfirma  TYPE emg_firma
                          cobject TYPE emg_object
                          p_anz_key TYPE i
                          p_anz_data TYPE i
                          p_anz_rcat TYPE i
                          p_anz_pod  TYPE i.

  LOOP AT inn_key.
    winn_out-firma  = cfirma.
    winn_out-object = cobject.
    winn_out-dttyp  = 'KEY'.
    winn_out-oldkey = coldkey.
    winn_out-data   = inn_key.
    ADD 1 TO p_anz_key.
    APPEND winn_out TO inn_out.
  ENDLOOP.

  LOOP AT inn_data.
    winn_out-firma  = cfirma.
    winn_out-object = cobject.
    winn_out-dttyp  = 'DATA'.
    winn_out-oldkey = coldkey.
    winn_out-data   = inn_data.
    ADD 1 TO p_anz_data.
    APPEND winn_out TO inn_out.
  ENDLOOP.

  LOOP AT inn_rcat.
    winn_out-firma  = cfirma.
    winn_out-object = cobject.
    winn_out-dttyp  = 'RCAT'.
    winn_out-oldkey = coldkey.
    winn_out-data   = inn_rcat.
    ADD 1 TO p_anz_rcat.
    APPEND winn_out TO inn_out.
  ENDLOOP.

  LOOP AT inn_pod.
    winn_out-firma  = cfirma.
    winn_out-object = cobject.
    winn_out-dttyp  = 'POD'.
    winn_out-oldkey = coldkey.
    winn_out-data   = inn_pod.
    ADD 1 TO p_anz_pod.
    APPEND winn_out TO inn_out.
  ENDLOOP.

* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_inn.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_INN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_inn .

  CLEAR: inn_key, inn_data, inn_rcat, inn_pod.

  REFRESH: inn_key, inn_data, inn_rcat, inn_pod.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_ICN_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DATEI  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*      -->P_ANZ_KEY  text
*      -->P_ANZ_DATA  text
*      -->P_ANZ_RCAT  text
*      -->P_ANZ_POD  text
*----------------------------------------------------------------------*
FORM fill_icn_out  USING   coldkey LIKE /adesso/mt_transfer-oldkey
                          cfirma  TYPE emg_firma
                          cobject TYPE emg_object
                          p_anz_key TYPE i
                          p_anz_data TYPE i
                          p_anz_rcat TYPE i
                          p_anz_pod  TYPE i.

  LOOP AT icn_key.
    wicn_out-firma  = cfirma.
    wicn_out-object = cobject.
    wicn_out-dttyp  = 'KEY'.
    wicn_out-oldkey = coldkey.
    wicn_out-data   = icn_key.
    ADD 1 TO p_anz_key.
    APPEND wicn_out TO icn_out.
  ENDLOOP.

  LOOP AT icn_data.
    wicn_out-firma  = cfirma.
    wicn_out-object = cobject.
    wicn_out-dttyp  = 'DATA'.
    wicn_out-oldkey = coldkey.
    wicn_out-data   = icn_data.
    ADD 1 TO p_anz_data.
    APPEND wicn_out TO icn_out.
  ENDLOOP.

  LOOP AT icn_rcat.
    wicn_out-firma  = cfirma.
    wicn_out-object = cobject.
    wicn_out-dttyp  = 'RCAT'.
    wicn_out-oldkey = coldkey.
    wicn_out-data   = icn_rcat.
    ADD 1 TO p_anz_rcat.
    APPEND wicn_out TO icn_out.
  ENDLOOP.

  LOOP AT icn_pod.
    wicn_out-firma = cfirma.
    wicn_out-object = cobject.
    wicn_out-dttyp = 'POD'.
    wicn_out-data = icn_pod.
    ADD 1 TO p_anz_pod.
    APPEND wicn_out TO icn_out.
  ENDLOOP.


* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_icn.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_ICN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_icn .

  CLEAR: icn_key, icn_data, icn_rcat, icn_pod.
  REFRESH: icn_key, icn_data, icn_rcat, icn_pod.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_PAY_OUT_NEU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_PAY  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*----------------------------------------------------------------------*
FORM fill_pay_out_neu  USING   coldkey TYPE  /adesso/mt_transfer-oldkey
                               cfirma  TYPE emg_firma
                               cobject TYPE emg_object.

  LOOP AT ipay_fkkko.
    wpay_out-firma  = cfirma.
    wpay_out-object = cobject.
    wpay_out-dttyp  = 'FKKKO'.
    wpay_out-oldkey = coldkey.
    wpay_out-data   = ipay_fkkko.
    APPEND wpay_out TO ipay_out.
  ENDLOOP.

  LOOP AT ipay_fkkopk.
    wpay_out-firma  = cfirma.
    wpay_out-object = cobject.
    wpay_out-dttyp  = 'FKKOPK'.
    wpay_out-oldkey = coldkey.
    wpay_out-data   = ipay_fkkopk.
    APPEND wpay_out TO ipay_out.
  ENDLOOP.

  LOOP AT ipay_seltns.
    wpay_out-firma  = cfirma.
    wpay_out-object = cobject.
    wpay_out-dttyp  = 'SELTNS'.
    wpay_out-oldkey = coldkey.
    wpay_out-data   = ipay_seltns.
    APPEND wpay_out TO ipay_out.
  ENDLOOP.


* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_pay.


ENDFORM.                    " FILL_PAY_OUT_NEU
