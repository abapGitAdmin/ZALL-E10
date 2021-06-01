@AbapCatalog.sqlViewName: 'ZCDS_ABAP_VIEW'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS View'

@OData.publish: true

define view ZCDS_SCHMIDT as select from sflight as sf 
association [0..*] to ZCDS_SCHMIDT_BOOK as _Book on $projection.ca = _Book.ca and 
                                                    $projection.co = _Book.co and 
                                                    $projection.fld = _Book.fld
                               
{
    //sflight 
    key sf.mandt as m, 
    key sf.carrid as ca, 
    key sf.connid as co, 
    key sf.fldate as fld, 
    sf.price as p, 
    sf.currency as cu, 
    sf.planetype as pl, 
    sf.seatsmax as smax, 
    sf.seatsocc as scoc, 
    sf.paymentsum as pay,
    
    _Book
}
