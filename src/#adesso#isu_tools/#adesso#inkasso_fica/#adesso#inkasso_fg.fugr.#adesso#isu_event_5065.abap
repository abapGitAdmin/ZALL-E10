FUNCTION /adesso/isu_event_5065 .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      T_DFKKCOLL STRUCTURE  DFKKCOLL
*"      T_ALL_COLL STRUCTURE  DFKKCOLL
*"      T_RECALL_COLL STRUCTURE  DFKKCOLL
*"      T_REASSIGN_COLL STRUCTURE  DFKKCOLL
*"  CHANGING
*"     VALUE(DO_RECALL) LIKE  BOOLE-BOOLE
*"  EXCEPTIONS
*"      ERROR_FOUND
*"--------------------------------------------------------------------
* T_DFKKCOLL :      Items to be submitted
* T_ALL_COLL :      All previously submitted items
* T_RECALL_COLL :   Items to be recalled from the Collection agency
* T_REASSIGN_COLL:  Items to be reassign to another Collection Agency
* DO_RECALL (flag): Must be set if items have to be recalled
************************************************************************

  DATA: rec_index LIKE sy-index.

* Recall items from a collection agency
  LOOP AT t_all_coll.
    MOVE-CORRESPONDING t_all_coll TO t_recall_coll.
    APPEND t_recall_coll.
  ENDLOOP.

  DESCRIBE TABLE t_recall_coll   LINES rec_index.
  IF NOT rec_index IS INITIAL.
    do_recall = 'X'.
  ENDIF.

*-------------------------- EXAMPLE -----------------------------------*
* If the receivables are at the agency for more than 60 days           *
*----------------------------------------------------------------------*
*  DATA: rec_index LIKE sy-index.
*  DATA: limit_date LIKE sy-datum.
*  limit_date = sy-datum - 60.
*
** Reassign selected items to a new collection agency (this is only
** called in case of manual recall)
*  LOOP AT t_recall_coll WHERE agdat LT limit_date.
*    MOVE-CORRESPONDING t_recall_coll TO t_reassign_coll.
*    MOVE 'COL-AG1' TO t_reassign_coll-inkgp.         "Collection Agency
*    APPEND t_reassign_coll.
*  ENDLOOP.
*
** Recall items from a collection agency
*  LOOP AT t_all_coll WHERE agdat LT limit_date.
*    MOVE-CORRESPONDING t_all_coll TO t_recall_coll.
*    APPEND t_recall_coll.
*  ENDLOOP.
*
** Reassign items to a new collection agency
*  LOOP AT t_all_coll WHERE agdat LT limit_date.
*    MOVE-CORRESPONDING t_all_coll TO t_reassign_coll.
*    MOVE 'COL-AG1' TO t_reassign_coll-inkgp.         "Collection Agency
*    APPEND t_reassign_coll.
*  ENDLOOP.
**
*  DESCRIBE TABLE t_recall_coll   LINES rec_index.
*  IF NOT rec_index IS INITIAL.
*    do_recall = 'X'.
*  ENDIF.
**---------------------------------------------------------------------*

ENDFUNCTION.
