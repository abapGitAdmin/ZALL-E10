@AbapCatalog.sqlViewName: 'ZHA_CDSTECH_T1'
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true  
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'HA CDS test'
@Search.searchable: true
@UI.headerInfo: { typeName: 'Sales Order', typeNamePlural: 'Sales Orders', title.value: 'Sales order' }
@OData.publish: true

//* http://sap-ae1.test-server.ag:8001/sap/opu/odata/sap/ZHA_CDS_TEST1_CDS/ZHA_CDS_TEST1
//* http://sap-ae1.test-server.ag:8001/sap/opu/odata/sap/ZHA_CDS_TEST1_CDS/ZHA_CDS_TEST1?$top=3
//* http://sap-ae1.test-server.ag:8001/sap/opu/odata/sap/ZHA_CDS_TEST1_CDS/ZHA_CDS_TEST1('500000001')
define view ZHA_CDS_TEST1 as select from zha_base {
   @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
   @UI.lineItem: { position: 10, importance: 'HIGH' }
   key  so_id as order_id,
   
   @UI.selectionField.position: 20
   @UI.lineItem: { position: 20, importance: 'HIGH' }
   billing_status,
   
   @UI.lineItem: { position: 50, importance: 'HIGH' }
   @Semantics.amount.currencyCode: 'currency_code'
   @DefaultAggregation: #SUM
   gross_amount,

   @UI.lineItem: { position: 40, importance: 'HIGH' }
   @Semantics.currencyCode: true
   currency_code   
}
