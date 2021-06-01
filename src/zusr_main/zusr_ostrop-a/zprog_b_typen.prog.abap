*&---------------------------------------------------------------------*
*& Report ZPROG_B_TYPEN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprog_b_typen.

DATA : gt_tanklib TYPE ztestpro_types,
       gs_tanklib LIKE LINE OF gt_tanklib.


FORM addtolist USING VALUE(lv_tanktier) TYPE int2
  VALUE(lv_tankname) TYPE ztestpro_d_type
  VALUE(lv_tanknation) TYPE ztestpro_d_type.
  gs_tanklib-tank_name = lv_tankname.
  gs_tanklib-tank_nation = lv_tanknation.
  gs_tanklib-tank_tier = lv_tanktier.
  APPEND gs_tanklib TO gt_tanklib.
ENDFORM.

FORM addthistolist USING VALUE(lv_t_name) TYPE char30
      VALUE(lv_t_nation) TYPE char30
  VALUE(lv_t_tier) TYPE int2.
  DATA: lv_tname   TYPE ztestpro_d_type,
                lv_tnation TYPE ztestpro_d_type.
  lv_tnation = lv_t_nation.
  lv_tname = lv_t_name.
  PERFORM addtolist USING lv_t_tier
        lv_tname
        lv_tnation.
ENDFORM.


START-OF-SELECTION.
  PERFORM addthistolist USING 'T20' 'America' 7.
  PERFORM addthistolist USING 'T30' 'America' 9.
  PERFORM addthistolist USING 'T59' 'China' 8.
  PERFORM addthistolist USING 'Tiger' 'Deutschland' 7.
  PERFORM addthistolist USING 'BDR' 'France' 5.
  PERFORM addthistolist USING 'T10 Heavy' 'America' 5.
  PERFORM addthistolist USING 'M103' 'America' 10.
  PERFORM addthistolist USING 'Chi-Nu-Kai' 'Japan' 5.
  PERFORM addthistolist USING 'Chafee' 'America' 5.

  gs_tanklib-tank_name = 'Panther'.
  MODIFY gt_tanklib INDEX 3 FROM gs_tanklib TRANSPORTING tank_name.

  SORT gt_tanklib BY tank_name ASCENDING.

* HOW TO MODIFY INTERN-TABLE
  gs_tanklib-tank_nation = 'Sweden'.
  MODIFY gt_tanklib FROM gs_tanklib TRANSPORTING tank_nation
  WHERE tank_tier = 5.




  LOOP AT gt_tanklib INTO gs_tanklib.

    WRITE / gs_tanklib-tank_name && ', ' && gs_tanklib-tank_nation && ', ' && gs_tanklib-tank_tier.

  ENDLOOP.

  WRITE /.
  WRITE /  'Mein Favorit ist allerdings: '.
  READ TABLE gt_tanklib INTO gs_tanklib WITH KEY tank_name = 'BDR'.
  WRITE / gs_tanklib-tank_name && ', ' && gs_tanklib-tank_nation && ', ' && gs_tanklib-tank_tier.
