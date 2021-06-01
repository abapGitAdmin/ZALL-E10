@AbapCatalog.sqlViewName: '/ADO/VIEW_DEMO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS view demo'
define view /ADO/SQL_CDS_VIEW_DEMO as select from /ado/sql_all {

    latitude

    // /ado/sql_all.address,
    // /ado/sql_all.gender,
    // case /ado/sql_all.city
    //     when 'Phoenix' then 'Arizona'
    //     else ''
    // end as State
    
}
// where gender = 'female'
