FUNCTION-POOL /adesso/fi_neg_remadv.           "MESSAGE-ID ..
DATA ok TYPE ok.
TYPES: BEGIN OF t_bemerkung,
         int_inv_doc_nr(18) TYPE n,
         datum          TYPE dats,
         text(240)      TYPE c,
         uname          TYPE  uname,
       END OF t_bemerkung.
.
DATA bemerkung(200) TYPE c.
DATA gt_bemerkung TYPE TABLE OF t_bemerkung .
DATA gs_bemerkung LIKE LINE OF gt_bemerkung.
* INCLUDE LZAD_FI_NEG_REAMADVD...            " Local class definition
