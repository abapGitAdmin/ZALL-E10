@AbapCatalog.sqlViewName: 'Z_BCK_SBOOK'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'SBOOK'
define view Z_BOECKMANN_CDS_2 as select from sbook as sbook_table{

key sbook_table.class as SbookClaas,
    sbook_table.order_date as SbookOrderDate,
    sbook_table.luggweight as SbookLuggweight

    //sbook_table 
 /*   mandt, 
    carrid, 
    connid, 
    fldate, 
    bookid, 
    customid, 
    custtype, 
    smoker, 
    luggweight, 
    wunit, 
    invoice, 
    class, 
    forcuram, 
    forcurkey, 
    loccuram, 
    loccurkey, 
    order_date, 
    counter, 
    agencynum, 
    cancelled, 
    reserved, 
    passname, 
    passform, 
    passbirth */
}
