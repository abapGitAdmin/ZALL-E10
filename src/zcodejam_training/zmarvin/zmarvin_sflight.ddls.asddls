@AbapCatalog.sqlViewName: 'ZMARVIN_SFLIGHT'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Data Definition SFLIGHT'
define view ZMARVIN_DD_SFLIGHT as select from sflight 

association [0..*] to zmarvin_sbook as Buchungen on $projection.carrid = Buchungen.carrid 
                                                and $projection.connid = Buchungen.connid 
                                                and $projection.Datum = Buchungen.fldate

{
    carrid, 
    connid, 
    fldate as Datum, 
    price as Preis, 
    currency as Waehrung, 
    planetype as Flugzeug, 
    seatsmax, 
    seatsocc, 
    paymentsum, 
    Buchungen
}
