@AbapCatalog.sqlViewName: 'Z_BCK_SFLIGHT'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS VIEW'
define view Z_BOECKMANN_CDS as select from sflight as sflight_table{
    
    key sflight_table.mandt as SFLIGHTMANDT,
        sflight_table.carrid as SFLIGHTCARRID,
        sflight_table.connid as SFLIGHTCONNID
    
    
    //SFLIGHT 
    /* mandt, 
    carrid, 
    connid, 
    fldate, 
    price, 
    currency, 
    planetype, 
    seatsmax, 
    seatsocc, 
    paymentsum, 
    seatsmax_b, 
    seatsocc_b, 
    seatsmax_f, 
    seatsocc_f
    */
}
