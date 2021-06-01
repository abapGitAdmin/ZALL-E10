*****           Implementation of object type ZDISACTION           *****
INCLUDE <object>.
*begin_data object.  " Do not change.. DATA is generated
* only private members may be inserted into structure private
*DATA:
" BEGIN OF PRIVATE,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" END OF PRIVATE,
*  key LIKE swotobjid-objkey.
*end_data object.    " Do not change.. DATA is generated


BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
  BEGIN OF KEY,
      DOCUMENTNUMBER LIKE EDISCACT-DISCNO,
      ACTIVITYNUMBER LIKE EDISCACT-DISCACT,
  END OF KEY.
END_DATA OBJECT. " Do not change.. DATA is generated
DATA: fi_key(1) TYPE c,
      fikey     LIKE dfkksumc-fikey.
DATA: BEGIN OF h_itab OCCURS 0.
        INCLUDE STRUCTURE /ADESSO/SPT_APIK.
DATA:  namea(80) TYPE c.                      "kunden-Adresse
DATA:  house_num2   LIKE eadrdat-house_num2,
       vstelle      LIKE eanl-vstelle,
       v_adress     LIKE /ADESSO/SPT_APIK-name1,
       v_house_num2 LIKE /ADESSO/SPT_APIK-house_num1.
DATA: END OF h_itab.


begin_method zfind_vkont changing container.
TYPE-POOLS: slis, isu05.
DATA: BEGIN OF i_ediscdoc OCCURS 0,
        boole  TYPE boole-boole,
        discno LIKE ediscdoc-discno,
        erdat  LIKE ediscdoc-erdat,
        aedat  LIKE ediscdoc-aedat,
      END OF i_ediscdoc,
      wa_ediscdoc LIKE i_ediscdoc,
      BEGIN OF i_out OCCURS 0,
        boole  TYPE boole-boole,
        discno LIKE ediscdoc-discno,
        erdat  LIKE ediscdoc-erdat,
        aedat  LIKE ediscdoc-aedat,
      END OF i_out,
      h_vkont     LIKE fkkvkp-vkont,
      h_gpart     LIKE fkkvkp-gpart,
      h_refobjkey LIKE ediscdoc-refobjkey,
      h_lines     TYPE i,
      repname     LIKE sy-repid,
      fieldcat    TYPE slis_t_fieldcat_alv,
      it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv,
      etype       LIKE ebagen-exit_type,
      y_interface TYPE isu05_discdoc_auto-interface,
      msgtext1    LIKE sy-msgv1,
      discact     TYPE ediscact-discact.


swc_get_element container 'SPERRVKONT' h_vkont.
swc_get_element container 'SPERRGPART' h_gpart.
CONCATENATE h_vkont h_gpart INTO h_refobjkey.

SELECT
   discno
   erdat
   aedat
INTO
  CORRESPONDING FIELDS OF TABLE i_ediscdoc
FROM
   ediscdoc
WHERE
   status     <> 99 AND
   refobjtype = 'ISUACCOUNT' AND
   refobjkey  = h_refobjkey.
IF sy-subrc = 0.


  repname = sy-repid.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'BOOLE'.
  wa_fieldcat-tabname = 'I_EDISCDOC'.
  wa_fieldcat-reptext_ddic = 'BOOLE'.
  APPEND wa_fieldcat TO fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'DISCNO'.
  wa_fieldcat-tabname = 'I_EDISCDOC'.
  wa_fieldcat-reptext_ddic = 'DISCNO'.
  APPEND wa_fieldcat TO fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'ERDAT'.
  wa_fieldcat-tabname = 'I_EDISCDOC'.
  wa_fieldcat-reptext_ddic = 'ERDAT'.
  APPEND wa_fieldcat TO fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'AEDAT'.
  wa_fieldcat-tabname = 'I_EDISCDOC'.
  wa_fieldcat-reptext_ddic = 'AEDAT'.
  APPEND wa_fieldcat TO fieldcat.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = repname
      i_internal_tabname     = 'I_EDISCDOC'
      i_inclname             = repname
    CHANGING
*     ct_fieldcat            = fieldcat[].
      ct_fieldcat            = fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  repname = sy-repid.
  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title              = 'Sperrbelege'
      i_selection          = 'X'
      i_checkbox_fieldname = 'BOOLE'
      i_scroll_to_sel_line = 'X'
      i_tabname            = 'I_EDISCDOC'
      it_fieldcat          = fieldcat
    IMPORTING
      e_exit               = repname
    TABLES
      t_outtab             = i_ediscdoc[]
    EXCEPTIONS
      program_error        = 1
      OTHERS               = 2.

  IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.

    DESCRIBE TABLE i_ediscdoc LINES h_lines.
    IF h_lines > 0.

      LOOP AT i_ediscdoc INTO wa_ediscdoc WHERE boole = 'X'.
        CALL FUNCTION 'ISU_S_DISCDOC_CHANGE'
          EXPORTING
            x_discno           = wa_ediscdoc-discno
            x_upd_online       = 'X'
            x_no_dialog        = ' '
          IMPORTING
*           Y_DB_UPDATE        =
            y_exit_type        = etype
            y_interface        = y_interface
          EXCEPTIONS
            not_found          = 1
            foreign_lock       = 2
            not_authorized     = 3
            input_error        = 4
            general_fault      = 5
            object_inv_discdoc = 6
            OTHERS             = 7.

        IF sy-subrc = 0.
          swc_set_element container 'DisconnDocNumber'
                                     wa_ediscdoc-discno.
          swc_set_element container 'DisconnectActivity'
                                    y_interface-y_new_discact.
        ELSEIF sy-subrc EQ 1. "not_found
          CONCATENATE text-n00 wa_ediscdoc-discno INTO msgtext1
                      SEPARATED BY space.
          exit_return '1002' sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSEIF sy-subrc EQ 2. "foreign-lock
*    exit_return '1003' sy-msgv1 text-n00 object-key-number space.
          exit_return '1003' sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSEIF sy-subrc EQ 3.
          CONCATENATE text-n00 wa_ediscdoc-discno INTO msgtext1
                      SEPARATED BY space.
*     exit_return '1004' text-n01 msgtext1 space space.
          exit_return '1004' sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSEIF sy-subrc EQ 4.
          exit_return '1005' sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSEIF sy-subrc GE 5. "general_fault + others
          WRITE wa_ediscdoc-discno TO msgtext1 NO-ZERO.
*    concatenate text-n00 object-key-number into msgtext
*                separated by space.
          exit_return '1001' msgtext1 space space space.
        ENDIF.
        IF etype = 'CANC'.
          exit_cancelled.
        ENDIF.
      ENDLOOP.
    ELSE.
      swc_set_element container 'NEU' 1.
    ENDIF.
  ENDIF.
ELSE.
  swc_set_element container 'NEU' 1.
ENDIF.

end_method.

begin_method wiederinbetriebnahme changing container.
TYPE-POOLS slis.
DATA: BEGIN OF i_ediscdoc OCCURS 0,
        boole  TYPE boole-boole,
        discno LIKE ediscdoc-discno,
        erdat  LIKE ediscdoc-erdat,
        aedat  LIKE ediscdoc-aedat,
      END OF i_ediscdoc,
      wa_ediscdoc LIKE i_ediscdoc,
      BEGIN OF i_gebuehr OCCURS 0,
        chgid TYPE tfk047i-chgid,
        mahng TYPE tfk047i-mahng,
        chgtx TYPE tfk047et-chgtx,
        hvorg TYPE tfk047k-hvorg,
        tvorg TYPE tfk047k-tvorg,
        boole TYPE boole-boole,
      END OF i_gebuehr,
      w_gebuehr       LIKE i_gebuehr,
      h_betrag(10)    TYPE c,
      h_vkont         LIKE fkkvkp-vkont,
      h_gpart         LIKE fkkvkp-gpart,
      h_refobjkey     LIKE ediscdoc-refobjkey,
      discno          TYPE ediscdoc-discno,
      h_lines         TYPE i,
      repname         LIKE sy-repid,
      fieldcat        TYPE slis_t_fieldcat_alv,
      it_fieldcat     TYPE slis_t_fieldcat_alv,
      wa_fieldcat     TYPE slis_fieldcat_alv,
      wa_layout       TYPE slis_layout_alv,
      etype           LIKE ebagen-exit_type,
      msgtext1        LIKE sy-msgv1,
      chargesschedule TYPE tfk047i-chgid.

swc_get_element container 'CONTRACTACCOUNT' h_vkont.
swc_get_element container 'BUSINESSPARTNER' h_gpart.


CONCATENATE h_vkont h_gpart INTO h_refobjkey.

SELECT
    tfk047i~chgid
    tfk047i~mahng
    tfk047et~chgtx
    tfk047k~hvorg
    tfk047k~tvorg
INTO TABLE
    i_gebuehr
FROM
   tfk047i JOIN tfk047et ON tfk047i~chgid = tfk047et~chgid
                        AND tfk047et~spras = 'DE'
           JOIN tfk047k  ON tfk047i~chgid = tfk047k~chgid
                        AND tfk047i~chgty = tfk047k~chgty
                        .
IF sy-subrc = 0.

  wa_layout-zebra = 'X'.
  wa_layout-colwidth_optimize = 'X'.

  repname = sy-repid.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'BOOLE'.
  wa_fieldcat-tabname = 'I_GEBUEHR'.
  wa_fieldcat-reptext_ddic = 'Auswahl'.
  APPEND wa_fieldcat TO fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'CHGID'.
  wa_fieldcat-tabname = 'I_GEBUEHR'.
  wa_fieldcat-reptext_ddic = 'Kenn.'.
  APPEND wa_fieldcat TO fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'CHGTX'.
  wa_fieldcat-tabname = 'I_GEBUEHR'.
  wa_fieldcat-reptext_ddic = 'Gebühr                    .'.
  APPEND wa_fieldcat TO fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'MAHNG'.
  wa_fieldcat-tabname = 'I_GEBUEHR'.
  wa_fieldcat-reptext_ddic = 'Betrag'.
  APPEND wa_fieldcat TO fieldcat.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = repname
      i_internal_tabname     = 'I_GEBUEHR'
      i_inclname             = repname
    CHANGING
*     ct_fieldcat            = fieldcat[].
      ct_fieldcat            = fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  repname = sy-repid.
  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title              = 'Gebühren'
      i_selection          = 'X'
      i_checkbox_fieldname = 'BOOLE'
      i_scroll_to_sel_line = 'X'
      i_tabname            = 'I_GEBUEHR'
      it_fieldcat          = fieldcat
      is_layout            = wa_layout
    IMPORTING
      e_exit               = repname
    TABLES
      t_outtab             = i_gebuehr[]
    EXCEPTIONS
      program_error        = 1
      OTHERS               = 2.
  IF sy-subrc = 0.
    LOOP AT i_gebuehr INTO w_gebuehr.
      IF w_gebuehr-boole = 'X'.
        h_betrag = w_gebuehr-mahng.
        REPLACE '.' WITH ',' INTO h_betrag.
        CONDENSE h_betrag NO-GAPS.
        PERFORM geb_buchen USING
                                 h_vkont
                                 h_gpart
                                 h_betrag
                                 w_gebuehr-hvorg
                                 w_gebuehr-tvorg.
        IF w_gebuehr-chgid = '07' OR w_gebuehr-chgid = '08'.
          chargesschedule = w_gebuehr-chgid.
          swc_set_element container 'ChargesSchedule' chargesschedule.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ELSE.
  ENDIF.


ENDIF.

end_method.
*---------------------------------------------------------------------*
*       FORM geb_buchen                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VKONT                                                         *
*  -->  GPART                                                         *
*  -->  BETRAG                                                        *
*---------------------------------------------------------------------*
FORM geb_buchen USING vkont TYPE vkont_kk
                      gpart TYPE gpart_kk
                      betrag
                      hvorg
                      tvorg.

  DATA: tdata   TYPE TABLE OF bdcdata,
        tline   LIKE LINE OF tdata,
        mode(1) TYPE c.
  DATA: BEGIN OF i_mess OCCURS 0.
          INCLUDE STRUCTURE bdcmsgcoll.
  DATA: END OF i_mess,
  BEGIN OF i_datum,
    jahr(4)  TYPE c,
    monat(2) TYPE c,
    tag(2)   TYPE c,
  END OF i_datum,
  h_datum(10) TYPE c.

  PERFORM fikey.
  IF NOT fikey IS INITIAL.

    CLEAR tline.
    tline-program = 'SAPLSP01'.
    tline-dynpro = '0100'.
    tline-dynbegin = 'X'.
    APPEND tline TO tdata.

    CLEAR tline.
    tline-fnam = 'BDC_OKCODE'.
    tline-fval = '=YES'.
    APPEND tline TO tdata.

    CLEAR fi_key.
    REFRESH tdata.
  ENDIF.

  i_datum = sy-datum.
  CONCATENATE i_datum-tag '.'
              i_datum-monat '.'
              i_datum-jahr
  INTO
              h_datum.
  CLEAR tline.
  tline-program = 'SAPLFKPP'.
  tline-dynpro = '0100'.
  tline-dynbegin = 'X'.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKKO-BLART'.
  tline-fval = 'GB'.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKKO-FIKEY'.
  tline-fval = fikey.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKKO-WAERS'.
  tline-fval = 'EUR'.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'BDC_OKCODE'.
  tline-fval = '=IOP'.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-program = 'SAPLFKPP'.
  tline-dynpro = '0202'.
  tline-dynbegin = 'X'.
  APPEND tline TO tdata.


  CLEAR tline.
  tline-fnam = 'FKKOP-BUKRS'.
  tline-fval = '0005'.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKOP-GPART'.
  tline-fval = gpart.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKOP-VKONT'.
  tline-fval = vkont.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKOP-FAEDN'.
  tline-fval = h_datum.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKOP-HVORG'.
  tline-fval = hvorg.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKOP-TVORG'.
  tline-fval = tvorg.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKOP-BETRW'.
  tline-fval = betrag.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'BDC_OKCODE'.
  tline-fval = '=UPDA'.
  APPEND tline TO tdata.

  mode = 'N'.
  CALL TRANSACTION 'FPE1' USING tdata
                          MODE mode
                          UPDATE 'S'
                          MESSAGES INTO i_mess.
ENDFORM.                    "geb_buchen

*---------------------------------------------------------------------*
*       FORM fikey                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM fikey.
*    einmal täglich muss der Schlüssel neu angelegt
*    und gefüllt werden, der Abstimmschlüssel wird in der Tabelle
*    DFKKSUMC gespeichert
  TABLES dfkksumc.

  CONCATENATE sy-datum '-INK' INTO fikey.

  SELECT SINGLE fikey
  INTO fikey
  FROM dfkksumc WHERE cpudt = sy-datum
                  AND xclos <> 'X'
                  AND fikey = fikey.


  IF sy-subrc <> 0.
    fi_key = 'X'.
    CLEAR fikey.
    CONCATENATE sy-datum '-INK' INTO fikey.
    CLEAR dfkksumc.
    dfkksumc-fikey = fikey.
    dfkksumc-cpudt = sy-datum.
    dfkksumc-fikst = '2'.
*    DFKKSUMC-RESOB = PAR_RESOB.
*    DFKKSUMC-RESKY = PAR_RESKY.
    dfkksumc-ernam = sy-uname.
    INSERT dfkksumc.
  ENDIF.

ENDFORM.                    " fi_key
*&--------------------------------------------------------------------*
*&      Form  Send_Email
*&--------------------------------------------------------------------*
FORM send_email USING discno          TYPE ediscdoc-discno
                      chargesschedule TYPE tfk047i-chgid
                      vorgang         TYPE regen-kennzx.
*********************************************************************
* Email versenden
*********************************************************************
  DATA: g_objcont   LIKE soli  OCCURS 0 WITH HEADER LINE,
        g_receivers LIKE soos1 OCCURS 0 WITH HEADER LINE.

  DATA: g_object_hd_change LIKE sood1,
        g_object_type      LIKE sood-objtp.
  DATA: i_user LIKE /ADESSO/SPT_USMA OCCURS 0,
        w_user LIKE /ADESSO/SPT_USMA.
  DATA:   l_betreff     TYPE so_obj_des,
          i_anschreiben TYPE swuoconttab.
  DATA: BEGIN OF i_refobj_isuac,
          vkont TYPE vkont_kk,
          gpart TYPE gpart_kk,
        END OF i_refobj_isuac,
        BEGIN OF i_refobj_instln,
          instln TYPE anlage,
        END OF i_refobj_instln,
        BEGIN OF i_refobj_device,
          device TYPE geraet,
        END OF i_refobj_device,
        vkont        TYPE vkont_kk,
        gpart        TYPE gpart_kk,
        l_device     TYPE geraet,
        l_ext_ui     TYPE ext_ui,
        l_int_ui     TYPE int_ui,
        l_adressat   TYPE char128,
        l_evbsadr    TYPE char128,
        i_eadrdat    LIKE eadrdat,
        i_eadrln     LIKE eadrln,
        l_refobjkey  TYPE edc_refkey,
        l_refobjtype TYPE edc_refobj,
        l_text(6)    TYPE c,
        l_express    TYPE regen-kennzx,
        l_findpar    TYPE efindpar,
        i_result     TYPE efindres OCCURS 0,
        w_result     TYPE efindres,
        BEGIN OF i_anhang OCCURS 0,
          line TYPE so_text255,
        END OF i_anhang.

  REFRESH g_receivers.
  CLEAR g_object_hd_change.


* erstellen prioritätstext für betreffzeile
  IF vorgang = 'W'.
    CASE chargesschedule.
      WHEN   '07'.
        l_text = 'HEUTE'.
        l_express = 'X'.
      WHEN '08'.
        l_text = 'SOFORT'.
        l_express = 'X'.
      WHEN OTHERS.
        l_text = 'WIB:'.
        l_express = ' '.
    ENDCASE.
  ELSE.
    l_text = 'STORNO:'.
  ENDIF.
  CONDENSE l_text.

  SELECT SINGLE
    refobjtype refobjkey
  FROM
    ediscdoc
  INTO
    (l_refobjtype, l_refobjkey)
  WHERE
    discno = discno.
  CASE l_refobjtype.
    WHEN 'INSTLN'.
      i_refobj_instln = l_refobjkey.
      CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
        EXPORTING
          x_address_type             = 'I'
          x_length                   = 80
          x_line_count               = 1
          x_anlage                   = i_refobj_instln-instln
        IMPORTING
          y_addr_lines               = i_eadrln
          y_eadrdat                  = i_eadrdat
        EXCEPTIONS
          not_found                  = 1
          parameter_error            = 2
          object_not_given           = 3
          address_inconsistency      = 4
          installation_inconsistency = 5
          OTHERS                     = 6.

      IF sy-subrc = 0.
        CONDENSE i_eadrdat-street.
        CONDENSE i_eadrdat-house_num1.
        CONDENSE i_eadrdat-house_num2.
        CONDENSE i_eadrdat-post_code1.
        CONDENSE i_eadrdat-city1.
      ENDIF.
      CONCATENATE
      i_eadrdat-street
      i_eadrdat-house_num1
      i_eadrdat-house_num2
      i_eadrdat-post_code1
      i_eadrdat-city1
      INTO l_adressat
      SEPARATED BY ' '.

      SELECT SINGLE vkonto FROM ever
        INTO vkont
        WHERE ever~anlage = i_refobj_instln-instln AND
              ever~auszdat = '99991231'.

      CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
        EXPORTING
          x_address_type             = 'T'
          x_length                   = 80
          x_line_count               = 1
          x_account                  = vkont
        IMPORTING
          y_addr_lines               = i_eadrln
          y_eadrdat                  = i_eadrdat
        EXCEPTIONS
          not_found                  = 1
          parameter_error            = 2
          object_not_given           = 3
          address_inconsistency      = 4
          installation_inconsistency = 5
          OTHERS                     = 6.

      IF sy-subrc = 0.
        CONDENSE i_eadrdat-name1.
        CONDENSE i_eadrdat-name2.
        CONDENSE i_eadrdat-street.
        CONDENSE i_eadrdat-house_num1.
        CONDENSE i_eadrdat-house_num2.
        CONDENSE i_eadrdat-post_code1.
        CONDENSE i_eadrdat-city1.
      ENDIF.

* Ermittle Zählernummer zum Sperrbeleg
      SELECT SINGLE geraet FROM egerr
      JOIN ediscobj ON ediscobj~logiknr = egerr~logiknr
      INTO  l_device
      WHERE ediscobj~discno = discno AND
            egerr~bis = '99991231'.
      l_findpar-d_geraet = l_device.

      CONCATENATE
        'Zähler :'
        l_device
        'Name :'
        i_eadrdat-name1
        i_eadrdat-name2
        i_eadrdat-name3
        i_eadrdat-name4
    'Verbrauchsstelle :'
        l_adressat
      INTO l_adressat
      SEPARATED BY ' '.

    WHEN 'ISUACCOUNT'.
      i_refobj_isuac = l_refobjkey.
      CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
        EXPORTING
          x_address_type             = 'B'
          x_length                   = 80
          x_line_count               = 1
          x_partner                  = i_refobj_isuac-gpart
        IMPORTING
          y_addr_lines               = i_eadrln
          y_eadrdat                  = i_eadrdat
        EXCEPTIONS
          not_found                  = 1
          parameter_error            = 2
          object_not_given           = 3
          address_inconsistency      = 4
          installation_inconsistency = 5
          OTHERS                     = 6.

      IF sy-subrc = 0.
        CONDENSE i_eadrdat-name1.
        CONDENSE i_eadrdat-name2.
        CONDENSE i_eadrdat-street.
        CONDENSE i_eadrdat-house_num1.
        CONDENSE i_eadrdat-house_num2.
        CONDENSE i_eadrdat-post_code1.
        CONDENSE i_eadrdat-city1.
      ENDIF.
    WHEN 'DEVICE'.
      i_refobj_device = l_refobjkey.
  ENDCASE.


* Ermittle Zählernummer zum Sperrbeleg
  SELECT SINGLE geraet FROM egerr
    JOIN ediscobj ON ediscobj~logiknr = egerr~logiknr
    INTO  l_device
    WHERE ediscobj~discno = discno AND
          egerr~bis = '99991231'.
  l_findpar-d_geraet = l_device.
  CALL FUNCTION 'ISU_FINDER'
    EXPORTING
      x_objtype = 'ISUPOD'
      x_findpar = l_findpar
*     X_FREE_EXPR                       =
*     X_MAXROWS =
*     X_MAXROWS_EXTENDED                =
* IMPORTING
*     Y_INCOMPLETE                      =
*     Y_PARTNERSEARCH_INCOMPLETE        =
*     Y_FINDPAR =
*     Y_FREE_EXPR                       =
    TABLES
      yt_result = i_result
*     YT_TRACE  =
* EXCEPTIONS
*     INSUFFICIENT_SELECTION            = 1
*     OBJTYPE_NOT_SUPPORTED             = 2
*     ADDITIONAL_SELECTION_NEEDED       = 3
*     OTHERS    = 4
    .

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ELSE.
    LOOP AT i_result INTO w_result.
      l_int_ui = w_result-objkey.
    ENDLOOP.

  ENDIF.
  SELECT SINGLE ext_ui FROM euitrans
    INTO l_ext_ui
    WHERE euitrans~int_ui = l_int_ui.

  CONCATENATE l_text
              ' Zähler:'
              l_device
              'eingeleitet!'
  INTO l_betreff
  SEPARATED BY ' '.

  CALL FUNCTION 'ZEF_DISCMAIL_TEXT'
    EXPORTING
      device      = l_device
      ext_ui      = l_ext_ui
      adressat    = l_adressat
      vadresse    = l_evbsadr
      i_vorgang   = vorgang
    TABLES
      anschreiben = i_anschreiben.

  SELECT *
  FROM /ADESSO/SPT_USMA
  INTO TABLE i_user
  WHERE aktiv = 'X'.

  IF sy-subrc = 0.
    LOOP AT i_user INTO w_user.
      CALL FUNCTION 'ZEF_DISCMAIL'
        EXPORTING
*         i_address   =
          i_smtp_addr = w_user-smtp_addr
*         I_TELEFON   =
*         I_FAX       =
          i_betreff   = l_betreff
          i_vorgang   = vorgang
        TABLES
          anschreiben = i_anschreiben
          intab       = i_anhang.
    ENDLOOP.
    REFRESH i_anschreiben.
  ENDIF.

ENDFORM.                    " Send_Email

begin_method sendmessage changing container.
DATA: discno          TYPE discno,
      chargesschedule TYPE tfk047i-chgid,
      vorgang         TYPE regen-kennzx.

swc_get_element container 'ChargesSchedule' chargesschedule.
swc_get_element container 'DisconnDocNumber' discno.
swc_get_element container 'Indicators' vorgang.

IF vorgang IS INITIAL.
  vorgang = 'W'.
ENDIF.

PERFORM send_email USING discno chargesschedule vorgang.


end_method.

begin_method zsperrgrund changing container.
DATA:
  disconnectionreason LIKE ediscdoc-discreason,
  indicators          LIKE ewxgen-ivalue,
  ausnahme            LIKE ewxgen-ivalue.
swc_get_element container 'DisconnectionReason' disconnectionreason.
swc_get_element container 'Ausnahme' ausnahme.



CASE disconnectionreason.
  WHEN '01'.
    indicators = 1.
*    IF ausnahme <> 1.
*      indicators = 0.
*      CALL FUNCTION 'POPUP_TO_INFORM'
*           EXPORTING
*                titel = 'Sperrbeleg anlegen'
*                txt1  = ' Sperrgrund Inkassosperre 01 '
*                txt2  = ' nicht zulässig '.
*    ELSE.
*      indicators = 1.
*    ENDIF.
    disconnectionreason = '00'.
  WHEN '00'.
    indicators = 1.
*    CALL FUNCTION 'POPUP_TO_INFORM'
*         EXPORTING
*              titel = 'Sperrbeleg anlegen'
*              txt1  = ' Sperrgrund Unbekannt 00 '
*              txt2  = ' nicht zulässig '.
  WHEN '02'.
    indicators = 2.
  WHEN OTHERS.
    indicators = 1.
ENDCASE.



swc_set_element container 'Indicators' indicators.

end_method.

begin_method transferinkassodatenbank changing container.
DATA:
  disconndocnumber LIKE ediscdoc-discno,
  integervalue     LIKE ewxgen-ivalue.

DATA: BEGIN OF i_refobj,
        vkont TYPE vkont_kk,
        gpart TYPE gpart_kk,
      END OF i_refobj,
      vkont        TYPE vkont_kk,
      gpart        TYPE gpart_kk,
      anlage       TYPE anlage,
      i_eadrdat    LIKE eadrdat,
      i_eadrln     LIKE eadrln,
      l_refobjkey  TYPE edc_refkey,
      l_discreason TYPE discreason.

TABLES /ADESSO/SPT_APIK.
swc_get_element container 'DisconnDocNumber' disconndocnumber.
SELECT SINGLE * FROM /ADESSO/SPT_APIK
                WHERE discno = disconndocnumber.
*        wenn noch nicht da! -> dann einfüllen
IF sy-subrc >< 0.
  SELECT SINGLE refobjkey discreason
  FROM ediscdoc
  INTO (l_refobjkey, l_discreason)
  WHERE discno = disconndocnumber.

  CASE l_discreason.
    WHEN '01'.
      i_refobj = l_refobjkey.
      gpart = i_refobj-gpart.
      vkont = i_refobj-vkont.
      PERFORM data_normal USING disconndocnumber gpart vkont.
      h_itab-laufi = 'DUNN'.
      h_itab-z_zefd003 = '@06@'.
      CALL FUNCTION 'ISU_DB_GET_DUE_AND_DISCREL_POS'
        EXPORTING
          x_vkont             = vkont
          x_discno            = disconndocnumber
        IMPORTING
          y_sumoit            = h_itab-msalm
        EXCEPTIONS
          not_found           = 1
          concurrent_clearing = 2
          OTHERS              = 3.
    WHEN '03'.
      i_refobj = l_refobjkey.
      gpart = i_refobj-gpart.
      vkont = i_refobj-vkont.
      PERFORM data_normal USING disconndocnumber gpart vkont.
      h_itab-laufi = 'CUST'.
      h_itab-z_zefd003 = '@5W@'.
    WHEN '04'.
      i_refobj = l_refobjkey.
      gpart = i_refobj-gpart.
      vkont = i_refobj-vkont.
      PERFORM data_normal USING disconndocnumber gpart vkont.
      h_itab-laufi = 'TECH'.
      h_itab-z_zefd003 = '@AJ@'.
    WHEN '02'.
      anlage = l_refobjkey.
      PERFORM data_leer USING disconndocnumber anlage.
      h_itab-laufi = 'VACA'.
      h_itab-z_zefd003 = '@9C@'.
* Gpart muss belegt sein deshalb gpart = anlage.
  ENDCASE.
  h_itab-laufd = sy-datum.
  h_itab-mdrkd = sy-datum.

  h_itab-opbuk = '0005'.
  MOVE:   h_itab-laufd        TO /ADESSO/SPT_APIK-laufd,
          h_itab-laufi        TO /ADESSO/SPT_APIK-laufi,
          h_itab-gpart        TO /ADESSO/SPT_APIK-gpart,
          h_itab-vkont        TO /ADESSO/SPT_APIK-vkont,
          h_itab-post_code1   TO /ADESSO/SPT_APIK-post_code1,
          h_itab-city1        TO /ADESSO/SPT_APIK-city1,
          h_itab-name1        TO /ADESSO/SPT_APIK-name1,
          h_itab-name2        TO /ADESSO/SPT_APIK-name2,
          h_itab-k_street     TO /ADESSO/SPT_APIK-k_street,
          h_itab-house_num1   TO /ADESSO/SPT_APIK-house_num1,
          h_itab-v_post_code  TO /ADESSO/SPT_APIK-v_post_code,
          h_itab-v_city1      TO /ADESSO/SPT_APIK-v_city1,
          h_itab-v_street     TO /ADESSO/SPT_APIK-v_street,
          h_itab-v_house_num1 TO /ADESSO/SPT_APIK-v_house_num1,
          h_itab-ausdt        TO /ADESSO/SPT_APIK-ausdt,
          h_itab-mdrkd        TO /ADESSO/SPT_APIK-mdrkd,
          h_itab-mahnv        TO /ADESSO/SPT_APIK-mahnv,
          h_itab-opbuk        TO /ADESSO/SPT_APIK-opbuk,
          h_itab-spart        TO /ADESSO/SPT_APIK-spart,
          h_itab-vtref        TO /ADESSO/SPT_APIK-vtref,
          h_itab-mahns        TO /ADESSO/SPT_APIK-mahns,
          "h_itab-mstyp        TO /ADESSO/SPT_APIK-mstyp,
          h_itab-waers        TO /ADESSO/SPT_APIK-waers,
          h_itab-msalm        TO /ADESSO/SPT_APIK-msalm,
          h_itab-mge1m        TO /ADESSO/SPT_APIK-mge1m,
          "h_itab-bonit        TO /ADESSO/SPT_APIK-bonit,
          h_itab-xmsto        TO /ADESSO/SPT_APIK-xmsto,
          "h_itab-xinfo        TO /ADESSO/SPT_APIK-xinfo,
          "h_itab-frdat        TO /ADESSO/SPT_APIK-frdat,
          sy-datum            TO /ADESSO/SPT_APIK-ak_dat,
          sy-uname            TO /ADESSO/SPT_APIK-ernam,
          sy-uname            TO /ADESSO/SPT_APIK-aenam,
          h_itab-zeg_kz       TO /ADESSO/SPT_APIK-zeg_kz,
          h_itab-bea_kz       TO /ADESSO/SPT_APIK-bea_kz,
          h_itab-z_zefd003    TO /ADESSO/SPT_APIK-z_zefd003,
          sy-datum            TO /ADESSO/SPT_APIK-op_dat,
          h_itab-discno       TO /ADESSO/SPT_APIK-discno.
  INSERT /ADESSO/SPT_APIK.
  CLEAR h_itab.
  COMMIT WORK.
ENDIF.
swc_set_element container 'IntegerValue' integervalue.
end_method.

*----------------------------------------------------------------------*
FORM data_normal USING    p_disconndocnumber
                          p_gpart
                          p_vkont.

  DATA:       i_eadrdat LIKE eadrdat,
              i_eadrln  LIKE eadrln,
              l_anlage  TYPE anlage.


  CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
    EXPORTING
      x_address_type             = 'B'
      x_length                   = 80
      x_line_count               = 1
      x_partner                  = p_gpart
    IMPORTING
      y_addr_lines               = i_eadrln
      y_eadrdat                  = i_eadrdat
    EXCEPTIONS
      not_found                  = 1
      parameter_error            = 2
      object_not_given           = 3
      address_inconsistency      = 4
      installation_inconsistency = 5
      OTHERS                     = 6.

  IF sy-subrc = 0.
    CONDENSE i_eadrdat-street.
    CONDENSE i_eadrdat-house_num1.
    CONDENSE i_eadrdat-house_num2.
    CONDENSE i_eadrdat-post_code1.
    CONDENSE i_eadrdat-city1.
  ENDIF.
  h_itab-gpart  =      p_gpart.
  h_itab-vkont =       p_vkont.
  h_itab-post_code1 =  i_eadrdat-post_code1.
  h_itab-city1 = i_eadrdat-city1.
  h_itab-name1 = i_eadrdat-name1.
  h_itab-name2 = i_eadrdat-name2.
  h_itab-k_street = i_eadrdat-street.
  CONCATENATE    i_eadrdat-house_num1
                 i_eadrdat-house_num2
  INTO           h_itab-house_num1.

  SELECT SINGLE
   eastl~anlage        "Anlage
*     v_eanl~sparte       "Sparte
  FROM  ediscdoc
  JOIN ediscobj ON ediscobj~discno = ediscdoc~discno
  JOIN eastl    ON ediscobj~logiknr = eastl~logiknr
  JOIN v_eanl   ON eastl~anlage = v_eanl~anlage
     INTO l_anlage
     WHERE  ediscdoc~discno = p_disconndocnumber.
  CLEAR i_eadrln. CLEAR i_eadrdat.

  CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
    EXPORTING
      x_address_type             = 'I'
      x_length                   = 80
      x_line_count               = 1
      x_anlage                   = l_anlage
    IMPORTING
      y_addr_lines               = i_eadrln
      y_eadrdat                  = i_eadrdat
    EXCEPTIONS
      not_found                  = 1
      parameter_error            = 2
      object_not_given           = 3
      address_inconsistency      = 4
      installation_inconsistency = 5
      OTHERS                     = 6.

  h_itab-v_post_code =  i_eadrdat-post_code1.
  h_itab-v_city1 = i_eadrdat-city1.
  h_itab-v_street = i_eadrdat-street.
  CONCATENATE    i_eadrdat-house_num1
                 i_eadrdat-house_num2
  INTO           h_itab-v_house_num1.

  h_itab-discno = p_disconndocnumber.

ENDFORM.                    " data_normal

*---------------------------------------------------------------------*
*       FORM data_leer                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_DISCONNDOCNUMBER                                            *
*  -->  P_ANLAGE                                                      *
*---------------------------------------------------------------------*
FORM data_leer USING    p_disconndocnumber
                        p_anlage.
  DATA:       i_eadrdat LIKE eadrdat,
              i_eadrln  LIKE eadrln,
              BEGIN OF i_vkont OCCURS 0,
                vkont TYPE vkont_kk,
              END OF i_vkont.

  CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
    EXPORTING
      x_address_type             = 'I'
      x_length                   = 80
      x_line_count               = 1
      x_anlage                   = p_anlage
    IMPORTING
      y_addr_lines               = i_eadrln
      y_eadrdat                  = i_eadrdat
    EXCEPTIONS
      not_found                  = 1
      parameter_error            = 2
      object_not_given           = 3
      address_inconsistency      = 4
      installation_inconsistency = 5
      OTHERS                     = 6.

  h_itab-v_post_code =  i_eadrdat-post_code1.
  h_itab-v_city1 = i_eadrdat-city1.
  h_itab-v_street = i_eadrdat-street.
  CONCATENATE    i_eadrdat-house_num1
                 i_eadrdat-house_num2
  INTO           h_itab-v_house_num1.

  h_itab-discno = p_disconndocnumber.

  IF sy-subrc = 0.
    CONDENSE i_eadrdat-street.
    CONDENSE i_eadrdat-house_num1.
    CONDENSE i_eadrdat-house_num2.
    CONDENSE i_eadrdat-post_code1.
    CONDENSE i_eadrdat-city1.
  ENDIF.
  SELECT
    ever~vkonto
  FROM
    ever
  INTO
    TABLE i_vkont
  WHERE
    ever~anlage = p_anlage.
  SORT i_vkont BY vkont DESCENDING.
  READ TABLE
    i_vkont
  INTO
    h_itab-vkont INDEX 1.
  SELECT SINGLE
    fkkvkp~gpart
  FROM
    fkkvkp
  INTO
    h_itab-gpart
  WHERE
    fkkvkp~vkont = h_itab-vkont.

  h_itab-post_code1 =  i_eadrdat-post_code1.
  h_itab-city1 = i_eadrdat-city1.
  h_itab-name1 = 'LEERSTANDSSPERRE'.
  h_itab-name2 = 'LEERSTANDSSPERRE'.
  h_itab-k_street = i_eadrdat-street.
  CONCATENATE    i_eadrdat-house_num1
                 i_eadrdat-house_num2
  INTO           h_itab-house_num1.


ENDFORM.                    " data_leer

begin_method sperrexist changing container.
DATA:
  lv_installation  LIKE eanl-anlage,
  lv_discno        LIKE ediscdoc-discno,
  disconndocstatus LIKE ediscdoc-status,
  indicators       LIKE ewxgen-ivalue,
  etype            LIKE ebagen-exit_type,
  y_interface      TYPE isu05_discdoc_auto-interface,
  msgtext1         LIKE sy-msgv1,
  lt_v_ediscobj    TYPE TABLE OF v_ediscobj,
  ls_v_ediscobj    TYPE v_ediscobj,
  lv_caccount      TYPE char22,
  lv_vkonto        TYPE vkont_kk,
  lv_fkkvkp        TYPE fkkvkp.

DATA lv_discacttyp TYPE discacttyp.
DATA lv_discact TYPE discact.

swc_get_element container 'Installation' lv_installation.
CALL FUNCTION 'ISU_DB_V_EDISCOBJ_SELECT_ANL'
  EXPORTING
    x_anlage      = lv_installation
  TABLES
    yt_v_ediscobj = lt_v_ediscobj
  EXCEPTIONS
    system_error  = 1
    OTHERS        = 2.

IF sy-subrc <> 0.
  indicators = 0.
ENDIF.

IF sy-subrc = 0.
  IF lines( lt_v_ediscobj ) > 0.
    LOOP AT lt_v_ediscobj INTO ls_v_ediscobj.
      lv_discno = ls_v_ediscobj-discno.
    ENDLOOP.

    CALL FUNCTION 'ISU_S_DISCDOC_CHANGE'
      EXPORTING
        x_discno           = lv_discno
        x_upd_online       = 'X'
        x_no_dialog        = ' '
      IMPORTING
        y_exit_type        = etype
        y_interface        = y_interface
      EXCEPTIONS
        not_found          = 1
        foreign_lock       = 2
        not_authorized     = 3
        input_error        = 4
        general_fault      = 5
        object_inv_discdoc = 6
        OTHERS             = 7.
  ELSE.
    SELECT SINGLE vkonto FROM ever INTO lv_vkonto
    WHERE anlage = lv_installation AND auszdat = '99991231'.

    IF sy-subrc NE 0.
      exit_object_not_found.
    ELSE.
      CALL FUNCTION 'FKK_ACCOUNT_READ'
        EXPORTING
          i_vkont      = lv_vkonto
        IMPORTING
          e_fkkvkp     = lv_fkkvkp
        EXCEPTIONS
          not_found    = 1
          foreign_lock = 2
          OTHERS       = 3.
      IF sy-subrc <> 0.
        exit_object_not_found.
      ENDIF.
      lv_caccount    = lv_vkonto.
      lv_caccount+12 = lv_fkkvkp-gpart.

      SELECT SINGLE discno INTO lv_discno FROM ediscdoc
        WHERE refobjkey = lv_caccount
          AND status <> '99'.
* Prüfen ob Anlagenreferenz
      IF sy-subrc NE 0.
        indicators = 0.
      ELSE.
        CALL FUNCTION 'ISU_S_DISCDOC_CHANGE'
          EXPORTING
            x_discno           = lv_discno
            x_upd_online       = 'X'
            x_no_dialog        = ' '
          IMPORTING
*           Y_DB_UPDATE        =
            y_exit_type        = etype
            y_interface        = y_interface
          EXCEPTIONS
            not_found          = 1
            foreign_lock       = 2
            not_authorized     = 3
            input_error        = 4
            general_fault      = 5
            object_inv_discdoc = 6
            OTHERS             = 7.




        indicators = 1.
      ENDIF.
    ENDIF.
  ENDIF.
  IF sy-subrc = 0.
*    swc_set_element container 'DisconnDocNumber'
*                               disconndocnumber.
*    swc_set_element container 'DisconnectActivity'
*                              y_interface-y_new_discact.
    indicators = 1.
    swc_set_element container 'Indicators' indicators.
*    swc_set_element container 'DisconnDocStatus' disconndocstatus.
  ELSEIF sy-subrc EQ 1. "not_found
    indicators = 0.
    CONCATENATE text-n00 lv_discno INTO msgtext1
                SEPARATED BY space.
    exit_return '1002' sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSEIF sy-subrc EQ 2. "foreign-lock
    indicators = 0.
*    exit_return '1003' sy-msgv1 text-n00 object-key-number space.
    exit_return '1003' sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSEIF sy-subrc EQ 3.
    indicators = 0.
    CONCATENATE text-n00 lv_discno INTO msgtext1
                SEPARATED BY space.
*     exit_return '1004' text-n01 msgtext1 space space.
    exit_return '1004' sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSEIF sy-subrc EQ 4.
    indicators = 0.
    exit_return '1005' sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSEIF sy-subrc GE 5. "general_fault + others
    indicators = 0.
    WRITE lv_discno TO msgtext1 NO-ZERO.
*    concatenate text-n00 object-key-number into msgtext
*                separated by space.
    exit_return '1001' msgtext1 space space space.
  ENDIF.
ELSE.
  indicators = 0.
ENDIF.

SELECT SINGLE discact discacttyp FROM ediscact
INTO (lv_discact, lv_discacttyp)
WHERE discno EQ lv_discno AND discact EQ
  ( SELECT MAX( discact ) FROM ediscact
    WHERE discno EQ lv_discno AND disccanceld EQ abap_false ).

swc_set_element container 'Indicators' indicators.
swc_set_element container 'EV_DisconnDocNumber' lv_discno.
swc_set_element container 'EV_DisconnectActivity' lv_discact.
swc_set_element container 'EV_DisconActivCateg' lv_discacttyp.

end_method.

begin_method zlwcreateswtfordisconall changing container.
DATA:
  xcommit      TYPE regen-kennzx,
  xdiscno      TYPE ediscdoc-discno,
  xdiscact     TYPE ediscact-discact,
  xordstate    TYPE ediscacts-ordstate,
  xtransreason TYPE eideswtmsgdata-transreason,
  xcategory    TYPE eideswtmsgdata-category,
  ybapireturn  LIKE bapireturn1,
  yerror       TYPE regen-kennzx,
  yswitchnum   TYPE eideswtdoc-switchnum,
  ydiscacttyp  TYPE ediscact-discacttyp,
  ydiscact     TYPE ediscact-discact,
  yactdate     TYPE ediscact-actdate,
  i_subrc      TYPE sy-subrc.

swc_get_element container 'XCommit' xcommit.
IF sy-subrc <> 0.
  MOVE 'X' TO xcommit.
ENDIF.
*  SWC_GET_ELEMENT CONTAINER 'XDiscno' XDISCNO.
xdiscno = object-key-documentnumber.
*  SWC_GET_ELEMENT CONTAINER 'XDiscact' XDISCACT.
xdiscact = object-key-activitynumber.
swc_get_element container 'XOrdstate' xordstate.
swc_get_element container 'XTransreason' xtransreason.
swc_get_element container 'XCategory' xcategory.

CALL FUNCTION '/ADESSO/CRSWT_FOR_DISCON_ALL'
  EXPORTING
    x_category    = xcategory
    x_transreason = xtransreason
    x_ordstate    = xordstate
    x_discact     = xdiscact
    x_discno      = xdiscno
    x_commit      = xcommit
  IMPORTING
    y_bapireturn  = ybapireturn
    y_error       = yerror
    y_switchnum   = yswitchnum
    y_discacttyp  = ydiscacttyp
    y_discact     = ydiscact
    y_actdate     = yactdate
  EXCEPTIONS
    zgpke_551     = 9001
    zgpke_552     = 9002
    zgpke_553     = 9003
    zgpke_554     = 9004
    zgpke_555     = 9005
    zgpke_556     = 9006
    zgpke_557     = 9007
    zgpke_558     = 9008
    zgpke_559     = 9009
    zgpke_561     = 9010
    OTHERS        = 01.
i_subrc = sy-subrc.

swc_set_element container 'YError' yerror.
swc_set_element container 'YBapiReturn' ybapireturn.

CASE i_subrc.
  WHEN 0.            " OK
  WHEN 9001.                                                " ZGPKE_551
    exit_return 9001 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9002.                                                " ZGPKE_552
    exit_return 9002 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9003.                                                " ZGPKE_553
    exit_return 9003 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9004.                                                " ZGPKE_554
    exit_return 9004 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9005.                                                " ZGPKE_555
    exit_return 9005 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9006.                                                " ZGPKE_556
    exit_return 9006 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9007.                                                " ZGPKE_557
    exit_return 9007 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9008.                                                " ZGPKE_558
    exit_return 9008 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9009.                                                " ZGPKE_559
    exit_return 9009 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9010.                                                " ZGPKE_561
    exit_return 9010 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_element container 'YBapireturn' ybapireturn.
swc_set_element container 'YError' yerror.
swc_set_element container 'YSwitchnum' yswitchnum.
swc_set_element container 'YDiscacttyp' ydiscacttyp.
swc_set_element container 'YDiscact' ydiscact.
swc_set_element container 'YActdate' yactdate.
end_method.

begin_method zisudbzlwediscdocwbread changing container.
DATA:
  xdiscno        TYPE ediscdoc-discno,
  xdiscact       TYPE ediscact-discact,
  isuswitchd     TYPE swc_object,
  yerror         TYPE regen-kennzx,
  yzlwediscdocwb LIKE /ADESSO/SPT_WBSB.


*  SWC_GET_ELEMENT CONTAINER 'XDiscno' XDISCNO.
*  SWC_GET_ELEMENT CONTAINER 'XDiscact' XDISCACT.
xdiscno = object-key-documentnumber.
xdiscact = object-key-activitynumber.

CALL FUNCTION '/ADESSO/ISU_DB_ZLWDD_WB_READ'
  EXPORTING
    x_discno         = xdiscno
    x_discact        = xdiscact
  IMPORTING
    y_error          = yerror
    y_ZLWEDISCDOC_WB = yzlwediscdocwb
  EXCEPTIONS
    OTHERS           = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.

swc_set_element container 'YError' yerror.
swc_create_object isuswitchd 'ISUSWITCHD' yzlwediscdocwb-wechselbeleg.
swc_set_element container 'ISUSWITCHD' isuswitchd.
end_method.

begin_method zsperrgebuehr_buchen changing container.
DATA:
  contractaccount TYPE fkkvkp-vkont,
  businesspartner TYPE fkkvkp-gpart.
DATA: h_betrag  TYPE tfk047i-mahng,
      l_betrag  TYPE char6,
      l_hvorg   TYPE tfk047k-hvorg,
      l_tvorg   TYPE tfk047k-tvorg,
      ev_result TYPE syst-subrc.


swc_get_element container 'ContractAccount' contractaccount.
swc_get_element container 'BusinessPartner' businesspartner.

*Gebühr lesen zum Gebührenschema (chgid) und Gebührentyp (chgty)

SELECT SINGLE tfk047k~hvorg tfk047k~tvorg tfk047i~mahng FROM
  tfk047i JOIN tfk047k
          ON tfk047i~chgid = tfk047k~chgid AND
             tfk047i~chgty = tfk047k~chgty
  INTO (l_hvorg, l_tvorg, h_betrag)
  WHERE tfk047k~chgid = '04' AND
        tfk047k~chgty = '04'.

l_betrag = h_betrag.
REPLACE ALL OCCURRENCES OF '.' IN l_betrag WITH ','.
* Gebühr buchen
IF sy-subrc = 0.
  PERFORM fpe1_buchung USING
          contractaccount
          businesspartner
          l_betrag
          l_hvorg
          l_tvorg
          CHANGING
            ev_result.

ENDIF.
swc_set_element container 'EV_RESULT' ev_result.
end_method.
*&---------------------------------------------------------------------*
*&      Form  fpe1_buchung
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VKONT      text
*      -->GPART      text
*      -->BETRAG     text
*      -->HVORG      text
*      -->TVORG      text
*----------------------------------------------------------------------*
FORM fpe1_buchung USING
      vkont TYPE vkont_kk
      gpart TYPE gpart_kk
      betrag TYPE char6
      hvorg
      tvorg
  CHANGING
     ev_result TYPE syst-subrc.


  DATA: tdata   TYPE TABLE OF bdcdata,
        tline   LIKE LINE OF tdata,
        mode(1) TYPE c.
  DATA: BEGIN OF i_mess OCCURS 0.
          INCLUDE STRUCTURE bdcmsgcoll.
  DATA: END OF i_mess,
  BEGIN OF i_datum,
    jahr(4)  TYPE c,
    monat(2) TYPE c,
    tag(2)   TYPE c,
  END OF i_datum,
  h_datum(10) TYPE c.

  i_datum = sy-datum.
  CONCATENATE i_datum-tag '.'
  i_datum-monat '.'
  i_datum-jahr
  INTO
  h_datum.

  PERFORM fikey.

  CLEAR tline.
  tline-program = 'SAPLFKPP'.
  tline-dynpro = '0100'.
  tline-dynbegin = 'X'.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'BDC_OKCODE'.
  tline-fval = '/00'.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKKO-BLDAT'.
  tline-fval = h_datum.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKKO-BLART'.
  tline-fval = 'GB'.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKKO-WAERS'.
  tline-fval = 'EUR'.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKKO-BUDAT'.
  tline-fval = h_datum.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKKO-FIKEY'.
  tline-fval = fikey.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'RFPE1-ANZVA_OP'.
  tline-fval = 'SA1'.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'RFPE1-ANZVA_OPK'.
  tline-fval = 'SA1'.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'RFPE1-XTAXC_AUTO'.
  tline-fval = 'X'.
  APPEND tline TO tdata.

*   nur beim ersten Mal am Tag - erscheint das Popup
  IF NOT fi_key IS INITIAL.
*   Ja, der Schlüssel soll angelegt werden!

    CLEAR tline.
    tline-program = 'SAPLSPO1'.
    tline-dynpro = '0100'.
    tline-dynbegin = 'X'.
    APPEND tline TO tdata.

    CLEAR tline.
    tline-fnam = 'BDC_OKCODE'.
    tline-fval = '=YES'.
    APPEND tline TO tdata.
    CLEAR fi_key.
  ENDIF.

  CLEAR tline.
  tline-program = 'SAPLSPO1'.
  tline-dynpro = '0100'.
  tline-dynbegin = 'X'.
  APPEND tline TO tdata.
  CLEAR tline.
  tline-program = 'SAPLFKPP'.
  tline-dynpro = '0500'.
  tline-dynbegin = 'X'.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'BDC_OKCODE'.
  tline-fval = '=UPDA'.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKOPLST-BUKRS(01)'.
  tline-fval = '0005'.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKOPLST-GPART(01)'.
  tline-fval = gpart.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKOPLST-VKONT(01)'.
  tline-fval = vkont.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKOPLST-HVORG(01)'.
  tline-fval = hvorg.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKOPLST-TVORG(01)'.
  tline-fval = tvorg.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKOPLST-FAEDN(01)'.
  tline-fval = h_datum.
  APPEND tline TO tdata.

  CLEAR tline.
  tline-fnam = 'FKKOPLST-BETRW(01)'.
  tline-fval = betrag.
  APPEND tline TO tdata.

  mode = 'N'.
  CALL TRANSACTION 'FPE1' USING tdata
        MODE mode
        UPDATE 'S'
        MESSAGES INTO i_mess.
  ev_result = sy-subrc.
  IF sy-subrc <> 0.
    betrag = betrag.
  ENDIF.
ENDFORM.                    "geb_buchen

begin_method zgetlastaction changing container.
DATA:
  discacttyp  TYPE ediscact-discacttyp,
  lt_ediscact TYPE STANDARD TABLE OF ediscact,
  ls_ediscact TYPE ediscact.



SELECT * FROM ediscact INTO TABLE lt_ediscact
  WHERE discno = object-key-documentnumber.
SORT lt_ediscact BY discact DESCENDING.
READ TABLE lt_ediscact INTO ls_ediscact INDEX 1.
discacttyp = ls_ediscact-discacttyp.

swc_set_element container 'DISCACTTYP' discacttyp.
end_method.
