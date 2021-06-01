FUNCTION-POOL /adesso/vkonto_view.          "MESSAGE-ID ..

TABLES: ci_fkkvkp.

DATA: gt_fkkvkp TYPE STANDARD TABLE OF fkkvkp.

DATA: gs_fkkvkp     TYPE fkkvkp,
      gs_fkkvk      TYPE fkkvk,
      gs_fkkvkp_neu TYPE fkkvkp,
      gs_fkkvk_neu  TYPE fkkvk.

DATA:  gv_aktyp TYPE bu_aktyp.

CONSTANTS:  gc_03 TYPE bu_aktyp VALUE '03'.
