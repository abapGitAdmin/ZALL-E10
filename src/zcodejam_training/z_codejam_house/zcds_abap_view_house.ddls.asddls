@AbapCatalog.sqlViewName: 'ZV_FLIGHT_HOUSE'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'House-J Flight ABAP View Test'
define view ZCDS_ABAP_VIEW_HOUSE as select from sflight as sf{
    //sflight 
    key sf.mandt as Mandt, 
        sf.carrid as Carrier, 
        sf.connid as AirlineCode, 
        sf.fldate as FlightDate, 
        sf.price as Price, 
        sf.currency as Currency, 
        sf.planetype as PlaneType, 
        sf.seatsmax as MaxSeatsEconomy, 
        sf.seatsocc as OccupiedSeatsEconomy, 
        sf.paymentsum as SumOfPayment, 
        sf.seatsmax_b as MaxSeatsBusiness, 
        sf.seatsocc_b as OccupiedSeatsBusiness, 
        sf.seatsmax_f as MaxSeatsFirst, 
        sf.seatsocc_f as OccupiedSeatsFirst
}
