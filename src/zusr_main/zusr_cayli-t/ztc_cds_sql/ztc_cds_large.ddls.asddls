@AbapCatalog.sqlViewName: 'ZTC_VIEW_LARGE'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS View Large'
define view ZTC_CDS_LARGE as select from ztc_db_large {
    *
}
