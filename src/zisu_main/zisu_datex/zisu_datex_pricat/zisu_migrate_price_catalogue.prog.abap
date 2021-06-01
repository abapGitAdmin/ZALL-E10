*&---------------------------------------------------------------------*
*& Report ZISU_MIGRATE_PRICE_CATALOGUE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zisu_migrate_price_catalogue.

TABLES: zmosb_pricat.

DATA: gt_zmosb_pricat      TYPE TABLE OF zmosb_pricat,
      gt_zmosb_pricat_txt  TYPE TABLE OF zmosb_pricat_txt,
      gt_zmosb_pricat_ver  TYPE TABLE OF zmosb_pricat_ver,
      gt_zmosb_pricat_vtxt TYPE TABLE OF zmosb_pcat_v_txt,
      gt_zmosb_price       TYPE TABLE OF zmosb_price.

DATA: gt_mosb_pricat      TYPE TABLE OF /mosb/pricat,
      gt_mosb_pricat_txt  TYPE TABLE OF /mosb/pricat_txt,
      gt_mosb_pricat_ver  TYPE TABLE OF /mosb/pricat_ver,
      gt_mosb_pricat_vtxt TYPE TABLE OF /mosb/pcat_v_txt,
      gt_mosb_price       TYPE TABLE OF /mosb/price,
      gt_mosb_pri_pkg     TYPE TABLE OF /mosb/pri_pkg.

DATA gr_price_catalogue TYPE REF TO zcl_price_catalogue.

FIELD-SYMBOLS: <zmosb_pricat>      TYPE  zmosb_pricat,
               <zmosb_pricat_txt>  TYPE  zmosb_pricat_txt,
               <zmosb_pricat_ver>  TYPE  zmosb_pricat_ver,
               <zmosb_pricat_vtxt> TYPE  zmosb_pcat_v_txt,
               <zmosb_price>       TYPE  zmosb_price.

FIELD-SYMBOLS: <mosb_pricat>      TYPE  /mosb/pricat,
               <mosb_pricat_txt>  TYPE  /mosb/pricat_txt,
               <mosb_pricat_ver>  TYPE  /mosb/pricat_ver,
               <mosb_pricat_vtxt> TYPE  /mosb/pcat_v_txt,
               <mosb_price>       TYPE  /mosb/price,
               <mosb_pri_pkg>     TYPE  /mosb/pri_pkg.

SELECTION-SCREEN BEGIN OF BLOCK select1 WITH FRAME TITLE TEXT-001 .
SELECT-OPTIONS: sel_cat FOR zmosb_pricat-price_catalogue_id.
SELECTION-SCREEN END OF BLOCK select1.


START-OF-SELECTION.

  SELECT * FROM zmosb_pricat INTO TABLE gt_zmosb_pricat
   WHERE price_catalogue_id IN sel_cat.

  IF sy-subrc EQ 0.
    "Selection der alten Daten aus DB
    SELECT * FROM zmosb_pricat_txt INTO TABLE gt_zmosb_pricat_txt
      WHERE price_catalogue_id IN sel_cat.
    SELECT * FROM zmosb_pricat_ver INTO TABLE gt_zmosb_pricat_ver
      WHERE price_catalogue_id IN sel_cat.
    SELECT * FROM zmosb_pcat_v_txt INTO TABLE gt_zmosb_pricat_vtxt
      WHERE price_catalogue_id IN sel_cat.
    SELECT * FROM zmosb_price INTO TABLE gt_zmosb_price
      WHERE price_catalogue_id IN sel_cat.

    "Übertragen in neues Tabellenformat
    LOOP AT gt_zmosb_pricat ASSIGNING <zmosb_pricat>.
      APPEND INITIAL LINE TO gt_mosb_pricat ASSIGNING <mosb_pricat>.
      MOVE-CORRESPONDING <zmosb_pricat> TO <mosb_pricat>.
    ENDLOOP.

    LOOP AT gt_zmosb_pricat_txt ASSIGNING <zmosb_pricat_txt>.
      APPEND INITIAL LINE TO gt_mosb_pricat_txt ASSIGNING <mosb_pricat_txt>.
      MOVE-CORRESPONDING <zmosb_pricat_txt> TO <mosb_pricat_txt>.
    ENDLOOP.

    SORT gt_zmosb_pricat_ver BY val_start_date ASCENDING.
    LOOP AT gt_zmosb_pricat_ver ASSIGNING <zmosb_pricat_ver>.
      APPEND INITIAL LINE TO gt_mosb_pricat_ver ASSIGNING <mosb_pricat_ver>.
      MOVE-CORRESPONDING <zmosb_pricat_ver> TO <mosb_pricat_ver>.
      <mosb_pricat_ver>-pricat_version_id = <zmosb_pricat_ver>-pricat_version.
      <mosb_pricat_ver>-pricat_ver_released = abap_true.
    ENDLOOP.

    LOOP AT gt_zmosb_pricat_vtxt ASSIGNING <zmosb_pricat_vtxt>.
      APPEND INITIAL LINE TO gt_mosb_pricat_vtxt ASSIGNING <mosb_pricat_vtxt>.
      MOVE-CORRESPONDING <zmosb_pricat_vtxt> TO <mosb_pricat_vtxt>.
      <mosb_pricat_vtxt>-pricat_version_id = <zmosb_pricat_vtxt>-pricat_version.
    ENDLOOP.

    LOOP AT gt_zmosb_price ASSIGNING <zmosb_price>.
      APPEND INITIAL LINE TO gt_mosb_price ASSIGNING <mosb_price>.
      MOVE-CORRESPONDING <zmosb_price> TO <mosb_price>.

      CASE <mosb_price>-price_class.
        WHEN 'Z25'.
          <mosb_price>-billing_rule = '03'.
        WHEN 'Z26'.
          <mosb_price>-billing_rule = '02'.
        WHEN 'Z27'.
          <mosb_price>-billing_rule = '02'.
        WHEN OTHERS.
          <mosb_price>-billing_rule = '01'.
      ENDCASE.

      <mosb_price>-pricat_version_id = <zmosb_price>-price_version.
    ENDLOOP.

    "Abspeichern neue Tabellen auf Datenbank
    INSERT /mosb/pricat FROM TABLE gt_mosb_pricat.
    IF sy-subrc = 0.
      INSERT /mosb/pricat_txt FROM TABLE gt_mosb_pricat_txt.
      IF sy-subrc = 0.
        INSERT /mosb/pricat_ver FROM TABLE gt_mosb_pricat_ver.
        IF sy-subrc = 0.
          INSERT /mosb/pcat_v_txt FROM TABLE gt_mosb_pricat_vtxt.
          IF sy-subrc = 0.
            IF sy-subrc = 0.
              INSERT /mosb/price FROM TABLE gt_mosb_price.
              IF sy-subrc = 0.
                "Preisschlüsselstamm ermittln und speichern
                SORT gt_mosb_pricat_ver BY price_catalogue_id val_end_date DESCENDING.
                DELETE ADJACENT DUPLICATES FROM gt_mosb_pricat_ver COMPARING price_catalogue_id.
                LOOP AT gt_mosb_pricat_ver ASSIGNING <mosb_pricat_ver>.
                  LOOP AT  gt_mosb_price ASSIGNING <mosb_price>
                    WHERE price_catalogue_id = <mosb_pricat_ver>-price_catalogue_id
                    AND pricat_version_id = <mosb_pricat_ver>-pricat_version_id.
                    APPEND INITIAL LINE TO gt_mosb_pri_pkg ASSIGNING <mosb_pri_pkg>.
                    MOVE-CORRESPONDING <mosb_price> TO <mosb_pri_pkg>.

                    CREATE OBJECT gr_price_catalogue
                      EXPORTING
                        iv_company_code = <zmosb_pricat>-company_code
                        iv_keydate      = <mosb_pricat_ver>-val_start_date.

                    CALL METHOD gr_price_catalogue->get_price_key_group
                      EXPORTING
                        iv_price_class     = <mosb_pri_pkg>-price_class
                        iv_price_class_add = <mosb_pri_pkg>-price_class_add
                      RECEIVING
                        rv_price_key_group = <mosb_pri_pkg>-pos_price_key_group.
                  ENDLOOP.
                ENDLOOP.
                INSERT /mosb/pri_pkg FROM TABLE gt_mosb_pri_pkg.
                IF sy-subrc = 0.
                  COMMIT WORK.
                  WRITE 'Alle Daten übertragen.'.
                ELSE.
                  ROLLBACK WORK.
                  WRITE 'Fehler beim Preisschlüsselstamm. Übertragung zurückgesetzt.'.
                ENDIF.
              ELSE.
                ROLLBACK WORK.
                WRITE 'Fehler bei Preistabelle. Übertragung zurückgesetzt.'.
              ENDIF.
            ELSE.
              ROLLBACK WORK.
              WRITE 'Fehler bei Texttabelle zur Version. Übertragung zurückgesetzt.'.
            ENDIF.
          ELSE.
            ROLLBACK WORK.
            WRITE 'Fehler bei Versionstabelle. Übertragung zurückgesetzt.'.
          ENDIF.
        ELSE.
          ROLLBACK WORK.
          WRITE 'Fehler bei Texttabelle zum Preiskatalog. Übertragung zurückgesetzt.'.
        ENDIF.
      ELSE.
        ROLLBACK WORK.
        WRITE 'Fehler bei Tabelle Preiskatalog. Übertragung zurückgesetzt.'.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
      WRITE 'Fehler beim Preisschlüsselstamm. Übertragung zurückgesetzt.'.
    ENDIF.
  ELSE.
    WRITE 'Kein entsprechender Preiskatalog gefunden.'.
  ENDIF.
