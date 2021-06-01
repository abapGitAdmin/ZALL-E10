@AbapCatalog.sqlViewName: '/ADO/SQL_SEL_IDZ'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Select *'
define view /ADO/SQL_SELECT_ALL_IDZ 
  as select from /ado/sql_all_idz 
{
  *
}            
where order_id < '100477540' 
