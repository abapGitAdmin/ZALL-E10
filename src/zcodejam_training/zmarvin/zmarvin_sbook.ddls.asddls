@AbapCatalog.sqlViewName: 'ZMARVIN_SBOOK'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Data Definition SFBOOK'
define view ZMARVIN_DD_SBOOK as select from sbook {
   //SBOOK 
   mandt, 
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
   passbirth
}
