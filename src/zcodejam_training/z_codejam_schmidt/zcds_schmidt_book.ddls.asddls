@AbapCatalog.sqlViewName: 'ZCDS_ABAP_VIEW2'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Booking'
define view ZCDS_SCHMIDT_BOOK as select from sbook as sb{
    //sbook 
    key sb.mandt as m, 
    key sb.carrid as ca, 
    key sb.connid as co, 
    key sb.fldate as fld, 
    key sb.bookid as bo, 
    sb.customid as cid, 
    sb.custtype as ctyp, 
    sb.smoker as sm, 
    sb.luggweight as lwei, 
    sb.wunit as wunit, 
    sb.invoice as inv, 
    sb.class as cla, 
    sb.forcuram as forna, 
    sb.forcurkey as forkey, 
    sb.loccuram as locna, 
    sb.loccurkey as lockey, 
    sb.order_date as orda, 
    sb.counter as cnt, 
    sb.agencynum as agen, 
    sb.cancelled as canc, 
    sb.reserved as res, 
    sb.passname as passna, 
    sb.passform as passfo, 
    sb.passbirth as passbi
}
