@AbapCatalog.sqlViewName: 'Z_CDS_ENET_G_VIE'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS Zugriff auf /adesso/c_enet_g'
define view Z_CDS_ENET_G as select from /adesso/c_enet_g {
    ///adesso/c_enet_g
    mandt,
    tabelle, // blubber
    datei,
    length(datei) as laenge
}
 
