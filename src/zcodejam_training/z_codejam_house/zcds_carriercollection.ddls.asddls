@AbapCatalog.sqlViewName: 'ZV_HOUSE_CARRIER'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'A View of the Flight Carriers'
define view ZCDS_CarrierCollection as select from scarr as sc {
    //scarr 
    sc.mandt as Customer, 
    sc.carrid as AirlineCode, 
    sc.carrname as AirlineName, 
    sc.currcode as CurrencyUsedByAirline, 
    sc.url as AirlineWebsite
}
