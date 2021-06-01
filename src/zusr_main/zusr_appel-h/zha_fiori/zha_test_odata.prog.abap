************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&         $USER  $DATE
************************************************************************
*******
REPORT zha_test_odata.

data lt_zha_base type standard table of zha_base.

delete from zha_base.
select * from snwd_so into CORRESPONDING FIELDS OF table lt_zha_base.
modify zha_base from table lt_zha_base.


* http://sap-ae1.test-server.ag:8001/sap/opu/odata/sap/ZHA_CDS_TEST1_CDS/ZHA_CDS_TEST1
* http://sap-ae1.test-server.ag:8001/sap/opu/odata/sap/ZHA_CDS_TEST1_CDS/ZHA_CDS_TEST1?$top=3
* http://sap-ae1.test-server.ag:8001/sap/opu/odata/sap/ZHA_CDS_TEST1_CDS/ZHA_CDS_TEST1('500000001')

commit work.
select count( * ) from zha_base into @data(lv_rows).
write : /, lv_rows, 'rows'.
