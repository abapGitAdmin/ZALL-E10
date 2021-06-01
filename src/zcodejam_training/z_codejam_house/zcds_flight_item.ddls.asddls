@AbapCatalog.sqlViewName: 'ZV_FLIGHTBOOK_JH'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'House-J Flight Item Test'
define view ZCDS_FLIGHT_ITEM as select from sbook as sb {
    //sb 
    sb.mandt as CustomerName, 
    sb.carrid as AirlineCode, 
    sb.connid as CarrierID, 
    sb.fldate as FlightDate, 
    sb.bookid as BookingID, 
    sb.customid as CustomerID, 
    sb.custtype as CustomerType, 
    sb.smoker as Smoker, 
    sb.luggweight as LuggageWeight, 
    sb.wunit as WeightUnit, 
    sb.invoice as Invoice, 
    sb.class as Class, 
    sb.forcuram as ForeignCurrencyAmount, 
    sb.forcurkey as ForeignCurrencyType, 
    sb.loccuram as LocalCurrencyAmount, 
    sb.loccurkey as LocalCurrencyType, 
    sb.order_date as OrderDate,
    sb.counter as Counter, 
    sb.agencynum as AgencyNumber, 
    sb.cancelled as Cancelled, 
    sb.reserved as Resereved, 
    sb.passname as PassportName, 
    sb.passform as PassportForm, 
    sb.passbirth as PassportBirthDate
}
