*****           Implementation of object type /ADESSO/WB           *****
INCLUDE <object>.
BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
  BEGIN OF KEY,
      SWITCHNUM LIKE EIDESWTDOC-SWITCHNUM,
  END OF KEY.
END_DATA OBJECT. " Do not change.. DATA is generated

begin_method zlwfindcomments2 changing container.
DATA:
  kzcomment     TYPE regen-kennzx,
  hinweistext   TYPE eideswtmsgdataco-commenttxt,
  msgdata       TYPE eideswtmsgdata,
  pd_kzcomment  TYPE regen-kennzx,
  pd_commenttxt TYPE eideswtmsgdataco-commenttxt.

swc_get_element container 'MsgData' msgdata.

CALL FUNCTION '/ADESSO/EA_GET_COMMENT'
  EXPORTING
    i_switchnum  = msgdata-switchnum
    i_msgdatanum = msgdata-msgdatanum
  IMPORTING
    e_kz_comment = pd_kzcomment
    e_commenttxt = pd_commenttxt.

MOVE pd_commenttxt TO hinweistext.
MOVE pd_kzcomment TO kzcomment.

swc_set_element container 'KZComment' kzcomment.
swc_set_element container 'Hinweistext' hinweistext.
end_method.




begin_method zlwediscdocdata changing container.
DATA:
  xdiscno         TYPE ediscdoc-discno,
  ybapireturn     LIKE bapireturn1,
  yerror          TYPE regen-kennzx,
  yediscdoc       TYPE ediscdoc,
  yediscact       TYPE ediscact,
  ydiscact_storno TYPE ediscact,
  ycommenttxt     TYPE eideswtmsgdataco-commenttxt,
  yordstate       TYPE ediscact-ordstate.

swc_get_element container 'XDiscno' xdiscno.

CALL FUNCTION '/ADESSO/LW_EDISCDOC_DATA'
  EXPORTING
    x_discno         = xdiscno
  IMPORTING
    y_bapireturn     = ybapireturn
    y_error          = yerror
    y_ediscdoc       = yediscdoc
    y_ediscact       = yediscact
    y_discact_storno = ydiscact_storno
    y_commenttxt     = ycommenttxt
    y_ordstate       = yordstate
  EXCEPTIONS
    zgpke_551        = 01
    zgpke_552        = 02
    OTHERS           = 03.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN 01.    " to be implemented
  WHEN 02.    " to be implemented
  WHEN OTHERS.       " to be implemented
ENDCASE.

swc_set_element container 'YBapireturn' ybapireturn.
swc_set_element container 'YError' yerror.
swc_set_element container 'YEdiscdoc' yediscdoc.
swc_set_element container 'YEdiscact' yediscact.
swc_set_element container 'YEdiscactStorno' ydiscact_storno.
swc_set_element container 'YCommenttxt' ycommenttxt.
swc_set_element container 'OrderStatus' yordstate.
end_method.




begin_method zlwcommentediscdoc changing container.
DATA:
  xwmode       TYPE regen-wmode,
  xdiscact     TYPE ediscact-discact,
  xdiscno      TYPE ediscdoc-discno,
  xdiscreason  TYPE ediscdoc-discreason,
  ydescript    TYPE ediscordstatet-descript,
  xycommenttxt TYPE eideswtmsgdataco-commenttxt,
  xydiscno     TYPE ediscdoc-discno,
  xydiscreason TYPE ediscdoc-discreason,
  xyordstate   TYPE ediscact-ordstate,
  xyrefobjtype TYPE ediscdoc-refobjtype,
  xybetrw      TYPE dfkkop-betrw,
  xytelnr      TYPE adr2-telnr_long,
  xyemail      TYPE adr6-smtp_addr,
  xyhvorg      TYPE dfkkop-hvorg,
  xytvorg      TYPE dfkkop-tvorg,
  xybemerkung  TYPE /adesso/spt_edisccomment.

swc_get_element container 'XWmode' xwmode.
swc_get_element container 'XDiscact' xdiscact.
swc_get_element container 'XDiscno' xdiscno.
swc_get_element container 'XDiscreason' xdiscreason.
swc_get_element container 'XyCommenttxt' xycommenttxt.
swc_get_element container 'XyDiscno' xydiscno.
swc_get_element container 'XyDiscreason' xydiscreason.
swc_get_element container 'XyOrdstate' xyordstate.
swc_get_element container 'XyRefobjtype' xyrefobjtype.
swc_get_element container 'XyBetrw' xybetrw.
swc_get_element container 'XyTelnr' xytelnr.
swc_get_element container 'XyEmail' xyemail.
swc_get_element container 'XYBemerkung' xybemerkung.

IF xwmode EQ '1'.
  xdiscno = xydiscno.
ENDIF.

CALL FUNCTION '/ADESSO/LW_COMMENT_EDISCDOC'
  EXPORTING
    x_wmode       = xwmode
    x_discno      = xdiscno
    x_discact     = xdiscact
  IMPORTING
    y_descript    = ydescript
  CHANGING
    xy_commenttxt = xycommenttxt
    xy_discno     = xydiscno
    xy_discreason = xydiscreason
    xy_ordstate   = xyordstate
    xy_betrw      = xybetrw
    xy_telnr      = xytelnr
    xy_email      = xyemail
    xy_refobjtype = xyrefobjtype
    xy_hvorg      = xyhvorg
    xy_tvorg      = xytvorg
    xy_bemerkung  = xybemerkung
  EXCEPTIONS
    OTHERS        = 01.
*CASE sy-subrc.
*  WHEN 0.            " OK
*  WHEN OTHERS.       " to be implemented
*ENDCASE.

swc_set_element container 'XyCommenttxt' xycommenttxt.
swc_set_element container 'XyDiscreason' xydiscreason.
swc_set_element container 'XyOrdstate' xyordstate.
swc_set_element container 'XyBetrw' xybetrw.
swc_set_element container 'XyTelnr' xytelnr.
swc_set_element container 'XyEmail' xyemail.
swc_set_element container 'XyRefobjtype' xyrefobjtype.
swc_set_element container 'XyDiscno' xydiscno.
swc_set_element container 'XyHvorg' xyhvorg.
swc_set_element container 'XyTvorg' xytvorg.
swc_set_element container 'YDescript' ydescript.
swc_set_element container 'XYBemerkung' xybemerkung.
end_method.




begin_method zlwediscdoc changing container.
DATA:
  xcommit     TYPE regen-kennzx,
  xokcode     TYPE regen-okcode,
  xrefobjtype TYPE ediscdoc-refobjtype,
  xactdat     TYPE ediscact-actdate,
  xordstat    TYPE ediscacts-ordstate,
  xordact     TYPE ediscact-discact,
  xcontact    TYPE regen-kennzx,
  xcclass     TYPE bcont-cclass,
  xactivity   TYPE bcont-activity,
  xgebuehr    TYPE regen-kennzx,
  xbetrw      TYPE dfkkop-betrw,
  xbukrs      TYPE dfkkop-bukrs,
  xdiscnoref  TYPE ediscdoc-discno,
  xhvorg      TYPE dfkkop-hvorg,
  xtvorg      TYPE dfkkop-tvorg,
  xdiscreason TYPE ediscdoc-discreason,
  ybapireturn LIKE bapireturn1,
  yerror      TYPE regen-kennzx,
  ydiscacttyp TYPE ediscact-discacttyp,
  xyanlage    TYPE eanl-anlage,
  xydiscno    TYPE ediscdoc-discno,
  xyextui     TYPE euitrans-ext_ui,
  i_subrc     TYPE sy-subrc,
  xswitchnum  TYPE eideswtdoc-switchnum,
*     xybemerkung TYPE TABLE OF tline." nkreft 20141205 Stand der P61 wieder herstellen für Transport von Aenderungen fuer SR-1417063
  xybemerkung TYPE /adesso/spt_edisccomment.

swc_get_element container 'XCommit' xcommit.
swc_get_element container 'XOkcode' xokcode.
IF sy-subrc <> 0.
  MOVE 'DARK_CREATE_DCOR' TO xokcode.
ENDIF.
swc_get_element container 'XRefobjtype' xrefobjtype.
swc_get_element container 'XActdat' xactdat.
swc_get_element container 'XOrdstat' xordstat.
swc_get_element container 'XOrdact' xordact.
swc_get_element container 'XContact' xcontact.
swc_get_element container 'XCclass' xcclass.
swc_get_element container 'XActivity' xactivity.
swc_get_element container 'XGebuehr' xgebuehr.
swc_get_element container 'XBetrw' xbetrw.
swc_get_element container 'XBukrs' xbukrs.
swc_get_element container 'XDiscnoRef' xdiscnoref.
swc_get_element container 'XHvorg' xhvorg.
swc_get_element container 'XTvorg' xtvorg.
swc_get_element container 'XDiscreason' xdiscreason.
swc_get_element container 'XyAnlage' xyanlage.
swc_get_element container 'XyDiscno' xydiscno.
swc_get_element container 'XyExtUi' xyextui.
swc_get_element container 'XYBemerkung' xybemerkung.
xswitchnum = object-key-switchnum.

CALL FUNCTION '/ADESSO/LW_EDISCDOC'
  EXPORTING
    x_discreason = xdiscreason
    x_tvorg      = xtvorg
    x_hvorg      = xhvorg
    x_discno_ref = xdiscnoref
    x_bukrs      = xbukrs
    x_betrw      = xbetrw
    x_gebuehr    = xgebuehr
    x_activity   = xactivity
    x_cclass     = xcclass
    x_commit     = xcommit
    x_okcode     = xokcode
    x_refobjtype = xrefobjtype
    x_actdat     = xactdat
    x_ordstat    = xordstat
    x_ordact     = xordact
    x_switchnum  = xswitchnum
    x_contact    = xcontact
  IMPORTING
    y_bapireturn = ybapireturn
    y_error      = yerror
    y_discacttyp = ydiscacttyp
  CHANGING
    xy_anlage    = xyanlage
    xy_discno    = xydiscno
    xy_ext_ui    = xyextui
    xy_lines     = xybemerkung
  EXCEPTIONS
    zgpke_501    = 9001
    zgpke_502    = 9002
    zgpke_503    = 9003
    zgpke_504    = 9004
    zgpke_505    = 9005
    zgpke_506    = 9006
    zgpke_507    = 9007
    zgpke_551    = 9008
    zgpke_552    = 9009
    zgpke_509    = 9011
    zgpke_510    = 9012
    zgpke_511    = 9013
    OTHERS       = 01.

i_subrc = sy-subrc.
swc_set_element container 'YError' yerror.
swc_set_element container 'YBapireturn' ybapireturn.
swc_set_element container 'XyAnlage' xyanlage.
swc_set_element container 'XyDiscno' xydiscno.
swc_set_element container 'XyExtUi' xyextui.

CASE i_subrc.
  WHEN 0.            " OK
  WHEN 9001.                                                " ZGPKE_501
    exit_return 9001 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9002.                                                " ZGPKE_502
    exit_return 9002 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9003.                                                " ZGPKE_503
    exit_return 9003 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9004.                                                " ZGPKE_504
    exit_return 9004 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9005.                                                " ZGPKE_505
    exit_return 9005 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9006.                                                " ZGPKE_506
    exit_return 9006 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9007.                                                " ZGPKE_507
    exit_return 9007 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9008.                                                " ZGPKE_551
    exit_return 9008 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9009.                                                " ZGPKE_552
    exit_return 9009 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 01.    " to be implemented
  WHEN 9011.                                                " ZGPKE_509
    exit_return 9011 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9012.                                                " ZGPKE_510
    exit_return 9012 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 9013.                                                " ZGPKE_511
    exit_return 9013 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN OTHERS.       " to be implemented
ENDCASE.
end_method.




begin_method zdbzlwediscdocwbread changing container.
DATA:
  xwechselbeleg  TYPE eideswtmsgdata-switchnum,
  ydiscno        TYPE ediscdoc-discno,
  yzlwediscdocwb LIKE /adesso/spt_wbsb,
  disconnect     TYPE swc_object.

*  SWC_GET_ELEMENT CONTAINER 'XWechselbeleg' XWECHSELBELEG.
xwechselbeleg = object-key-switchnum.

CALL FUNCTION '/ADESSO/DB_ZLWEDISCDOC_WB_READ'
  EXPORTING
    x_wechselbeleg   = xwechselbeleg
  IMPORTING
    y_discno         = ydiscno
    y_zlwediscdoc_wb = yzlwediscdocwb
  EXCEPTIONS
    not_found        = 9001
    OTHERS           = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN 9001.         " NOT_FOUND
    exit_return 9001 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN OTHERS.       " to be implemented
ENDCASE.

swc_set_element container 'YDiscno' ydiscno.
swc_set_element container 'YZlwediscdocWb' yzlwediscdocwb.
swc_create_object disconnect 'DISCONNECT' ydiscno.
swc_set_element container 'DISCONNECT' disconnect.
end_method.

begin_method zlwgetmessagedata changing container.

DATA:
  iswitchnum           TYPE eideswtdoc-switchnum,
  imsgdata             TYPE eideswtmsgdata,
  ibeginnzum           TYPE eideswtmsgdata-moveindate,
  iendezum             TYPE eideswtmsgdata-moveoutdate,
  itransreason         TYPE eideswtmsgdata-transreason,
  ibkv                 TYPE eservprov-serviceid,
  icategory            TYPE eideswtmsgdata-category,
  imetmethod           TYPE eideswtmsgdata-metmethod,
  iintui               TYPE eideswtdoc-pod,
  emsgdata             TYPE eideswtmsgdata,
  ipossend             TYPE eideswtmsgdata-moveoutdate,
  ianswerstatus        TYPE eideswtmsgdata-msgstatus,
  eanswerstatus        TYPE eideswtmsgdata-msgstatus,
** PhL 2016-04-07
*  inetzanschlusskap    TYPE eideswtmsgdata-zz_netzanschkap,
*/ PhL 2016-04-07
  iempfservprov        TYPE eideswtdoc-service_prov_old,
  eserviceproviderold  TYPE eservprov-serviceid,
  ld_moveoutdate       TYPE eideswtdoc-moveoutdate,
  ld_moveindate        TYPE eideswtdoc-moveindate,
  ekzzwauszugstorno    TYPE regen-kennzx,
  icommenttxt          TYPE eideswtmsgdataco-commenttxt,
  ecommenttxt          TYPE eideswtmsgdataco-commenttxt,
  e44mehrf             TYPE flag,
  kzzwangsauszugstorno TYPE flag.


swc_get_element container 'IMsgdata' imsgdata.
swc_get_element container 'IBeginnzum' ibeginnzum.
swc_get_element container 'IEndezum' iendezum.
swc_get_element container 'ITransreason' itransreason.
swc_get_element container 'IBkv' ibkv.
swc_get_element container 'ICategory' icategory.
swc_get_element container 'IMetmethod' imetmethod.
swc_get_element container 'IIntUi' iintui.
swc_get_element container 'IAnswerstatus' ianswerstatus.
swc_get_element container 'IPossEnd' ipossend.
** PhL 2016-04-07
*swc_get_element container 'INetzanschlusskap' inetzanschlusskap.
*/ PhL 2016-04-07
swc_get_element container 'IEmpfServProv'  iempfservprov.
swc_get_element container 'ICommenttxt'  icommenttxt.
swc_get_element container 'E44Mehrf' e44mehrf.
swc_get_element container 'IZwangsauszugStorno' kzzwangsauszugstorno.

iswitchnum = object-key-switchnum.

CALL FUNCTION '/ADESSO/LW_GET_MESSAGEDATA'
  EXPORTING
    i_bkv                = ibkv
    i_category           = icategory
    i_metmethod          = imetmethod
    i_int_ui             = iintui
    i_switchnum          = iswitchnum
    i_msgdata            = imsgdata
    i_beginnzum          = ibeginnzum
    i_endezum            = iendezum
    i_transreason        = itransreason
*   i_possend            = ipossend
** PhL 2016-04-07
*    i_netzanschlkap      = inetzanschlusskap
*/ PhL 2016-04-07
    i_empf_serviceid     = iempfservprov
    i_answerstatus       = ianswerstatus
    i_commenttxt         = icommenttxt
    i_kennze44           = e44mehrf
    i_zwangsauszugstorno = kzzwangsauszugstorno
  IMPORTING
    e_msgdata            = emsgdata
    e_serviceid_old      = eserviceproviderold
    e_zwaus_storno       = ekzzwauszugstorno
    e_answerstatus       = eanswerstatus
    e_commenttxt         = ecommenttxt
  EXCEPTIONS
    OTHERS               = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.

* bei einer Zwangsabmeldung (Kategorie = E02 und ieanswerstatus =
* initial ) muss im Wechselbeleg das Auszugsdatumn gepflegt werden
* so noch nicht geschehen
swc_get_property self 'MoveOutDate' ld_moveoutdate.
IF ld_moveoutdate IS INITIAL.
  swc_get_property self 'MoveInDate' ld_moveindate.
  COMPUTE ld_moveoutdate = ld_moveindate - 1.
  swc_set_element container 'ESwitchMoveOutDate' ld_moveoutdate.
ENDIF.

swc_set_element container 'ECommenttxt'  ecommenttxt.
swc_set_element container 'ESwitchMoveOutDate' ld_moveoutdate.
swc_set_element container 'EMsgdata' emsgdata.
swc_set_element container 'EServiceProviderOld' eserviceproviderold.
swc_set_element container 'EAnswerstatus' eanswerstatus.


end_method.
