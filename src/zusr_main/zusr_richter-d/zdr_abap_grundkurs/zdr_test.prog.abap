************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RICHTER-D                                     Datum: 02.06.2020
*
* Beschreibung: Udemy Schulung
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
report zdr_test.

tables: pa0000.

data: gt_pa0000 type table of pa0000,
      gv_pernr  like p0000-pernr,
      gt_rgdir  like table of pc261.

*call function 'CU_READ_RGDIR'.

field-symbols <table> type data.
assign pa0000 to <table>.

select *
  from pa0000
  into table gt_pa0000
  up to 100 rows.

if sy-subrc <> 0.
* Implement suitable error handling here

endif.
