@AbapCatalog.sqlViewName: 'ZTC_VIEW_MEDIUM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS View Medium'
define view ZTC_CDS_MEDIUM as select from ztc_db_medium {
    *
}
