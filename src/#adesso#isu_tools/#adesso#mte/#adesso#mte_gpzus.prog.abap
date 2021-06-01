*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_GPZUS
*&
*&---------------------------------------------------------------------*
*&  1.Einspielen der Excel-Datei in die Tabelle /adesso/mte_gpzus
*&  2.Kontrolle der Einträge und Enfernen der fehlerhaften Vorschläge
*&  3.Entfernen der zusammenzuführenden GP's aus der Relevanz-Tabelle
*&
*&  Das Programm darf erst nach der Relevanzermittlung des MTools laufen.
*&
*&---------------------------------------------------------------------*
REPORT /ADESSO/MTE_GPZUS  message-id /adesso/MT_N.

tables: /adesso/mte_gpzs,
        /adesso/mte_rel,
        but020,
        but0bk.


data: it_gpzus  like table of /adesso/mte_gpzs with header line.
data: it_gpzus2 like table of /adesso/mte_gpzs with header line.

data: begin of it_addr occurs 0,
        adrnb like fkkvkp-adrnb,
        vkont like fkkvkp-vkont,
      end of it_addr.

data: w_partner like but000-partner,
      w_partner_u(10) type n,
      w_partner_o(10) type n,
      w_datei type RLGRAP-FILENAME,
      flag_error type c,
      wa_but0bk_u type but0bk,
      wa_but0bk_o type but0bk.

parameters: p_firma like /adesso/mte_rel-firma default 'SWL',
            p_update type c.

start-of-selection.


* Vorgabe für die Zusammenführung vom Fachbereich einlesen
  CALL FUNCTION 'UPLOAD'
    EXPORTING
*     CODEPAGE                      = '1100'
      FILENAME                      = w_datei
      FILETYPE                      = 'ASC'
*     HEADLEN                       = ' '
*     LINE_EXIT                     = ' '
*     TRUNCLEN                      = ' '
*     USER_FORM                     = ' '
*     USER_PROG                     = ' '
*     DAT_D_FORMAT                  = ' '
*   IMPORTING
*     FILELENGTH                    =
    TABLES
      DATA_TAB                      = it_gpzus
    EXCEPTIONS
*     CONVERSION_ERROR              = 1
*     FILE_OPEN_ERROR               = 2
*     FILE_READ_ERROR               = 3
*     INVALID_TYPE                  = 4
*     NO_BATCH                      = 5
*     UNKNOWN_ERROR                 = 6
*     INVALID_TABLE_WIDTH           = 7
*     GUI_REFUSE_FILETRANSFER       = 8
*     CUSTOMER_ERROR                = 9
*     NO_AUTHORITY                  = 10
      OTHERS                        = 11
            .
  IF SY-SUBRC <> 0.
    message A001 with 'Abbruch beim Upload der Excel-Datei'.
    stop.
  ENDIF.

* Einlesen aller Fixen Adressen aus der FKKVKP-Tabelle;
* Es wird später für Restriktionsprüfung benötigt
  select adrnb vkont
         into corresponding fields of table it_addr
         from fkkvkp
         where adrnb ne space.

  loop at it_gpzus.
    split it_gpzus at ';' into it_gpzus-mandt
                               it_gpzus-firma
                               it_gpzus-partner_u
                               it_gpzus-partner_o.

*   Konvertieren der GP-Nummer in C-Feld mit
*   führenden Nullen
    move it_gpzus-partner_u to w_partner_u.
    move it_gpzus-partner_o to w_partner_o.

    it_gpzus-partner_u = w_partner_u.
    it_gpzus-partner_o = w_partner_o.
    modify it_gpzus.
  endloop.


  loop at it_gpzus.

*   Beide Geschäftspartner müssen im System vorhanden sein
    select single partner into w_partner
           from but000
           where partner = it_gpzus-partner_u.
    if sy-subrc > 0.
      write: / it_gpzus-partner_u,
               it_gpzus-partner_o,
              'Zusammenzuführunder GPartner unbekannt'.
      delete it_gpzus.
      continue.
    endif.

    select single partner into w_partner
       from but000
       where partner = it_gpzus-partner_o.
    if sy-subrc > 0.
      write: / it_gpzus-partner_u,
               it_gpzus-partner_o,
               'Referenzierter GPartner unbekannt'.
      delete it_gpzus.
      continue.
    endif.

*   Der O-GP und U-GP müssen unterschiedlich sein
    if it_gpzus-partner_o = it_gpzus-partner_u.
      write: / it_gpzus-partner_u,
               it_gpzus-partner_o,
              'Beide GPartner sind identisch'.
      delete it_gpzus.
      continue.
    endif.

*   Beide Geschäftspartner müssen MIG_relevant sein
    select single obj_key into w_partner
           from /adesso/mte_rel
           where firma = p_firma
             and object = 'PARTNER'
             and obj_key = it_gpzus-partner_u.

    if sy-subrc > 0.
      write: / it_gpzus-partner_u,
               it_gpzus-partner_o,
              'Zusammenzuführunder GPartner ist nicht MIG-relevant'.
      delete it_gpzus.
      continue.
    endif.

    select single obj_key into w_partner
           from /adesso/mte_rel
           where firma = p_firma
             and object = 'PARTNER'
             and obj_key = it_gpzus-partner_o.

    if sy-subrc > 0.
      write: / it_gpzus-partner_u,
               it_gpzus-partner_o,
              'Referenzierter GPartner ist nicht MIG-relevant'.
      delete it_gpzus.
      continue.
    endif.

  endloop.

*  2-Stufige Verbinung unterbinden
  it_gpzus2[] = it_gpzus[].
  sort it_gpzus by partner_o.
  sort it_gpzus2 by partner_u.

  loop at it_gpzus.

    at new partner_o.
      read table it_gpzus2
           with key firma = p_firma
                    partner_u = it_gpzus-partner_o
                    binary search.
      if sy-subrc = 0.
        write: / 'Referenzierter GPartner', it_gpzus-partner_o,
                 'soll selbst mit dem GP', it_gpzus2-partner_o,
                 'zusammengeführt werden'.
        delete it_gpzus.
        continue.
      endif.
    endat.

  endloop.

* MIG-Restriktion checken:
  loop at it_gpzus.

*   Adressen des zusammenführenden GP's
*   dürfen nicht als Fixe Adressen in FKKVKP eingetragen sein
*   (EMIGALL würde auf nicht vorhandene Adressen hinweisen)
    select * from but020
             for all entries in it_addr
             where partner = it_gpzus-partner_u
               and addrnumber = it_addr-adrnb.
      exit.
    endselect.

    if sy-subrc = 0.
*     Die Verwendungsstelle finden
      read table it_addr with key adrnb = but020-addrnumber.
      write: / it_gpzus-partner_u,
               it_gpzus-partner_o,
              'Zusammenzuführunder GPartner besitzt eine Fixe Adresse',
              'des Vertragskontos', it_addr-vkont.
      delete it_gpzus.
      continue.
    endif.

*   Bankverbindungen des zusammenzuführenden Partners müssen alle bei
*   dem Referenzpartner in identischer Form vorkommen;
*   Sonst könnte zu MIG-Fehlern kommen oder auch zu Verwechselung der
*   Bankkonten wegen zufällig identischer BKV-Id in beiden VKonten
    clear flag_error.
    select * from but0bk into wa_but0bk_u
             where partner = it_gpzus-partner_u.
      select single * from but0bk into wa_but0bk_o
                      where partner = it_gpzus-partner_o
                        and bkvid = wa_but0bk_u-bkvid.
      if sy-subrc > 0.
        write: / it_gpzus-partner_u,
                 it_gpzus-partner_o,
                'Bankverbindung', wa_but0bk_u-bkvid,
                'der beiden Geschäftspartner',
                'muss identisch sein'.
        flag_error = 'X'.
        continue.
      else.
        shift wa_but0bk_u-bankl left deleting leading '0'.
        shift wa_but0bk_u-bankn left deleting leading '0'.
        shift wa_but0bk_o-bankl left deleting leading '0'.
        shift wa_but0bk_o-bankn left deleting leading '0'.

        if wa_but0bk_u-banks ne wa_but0bk_o-banks or
           wa_but0bk_u-bankl ne wa_but0bk_o-bankl or
           wa_but0bk_u-bankn ne wa_but0bk_o-bankn.
          write: / it_gpzus-partner_u,
                  it_gpzus-partner_o,
                 'Bankverbindung', wa_but0bk_u-bkvid,
                 'der beiden Geschäftspartner',
                 'muss identisch sein'.
          flag_error = 'X'.
          continue.
        endif.
      endif.
    endselect.
    if not flag_error is initial.
      delete it_gpzus.
      continue.
    endif.

  endloop.

  if not p_update is initial.
* Geprüffte Einträge in die Tab. /adesso/mte_gpzs einspielen
* (sie werden in den GP-abhängigen MIG-Objekten später benötigt)
* Die evtl. existierende DB-Tabelle wird zuvor gelöscht
    sort it_gpzus by partner_u.

    delete from /adesso/mte_gpzs where firma = p_firma.

    insert /adesso/mte_gpzs from table it_gpzus.
    if sy-subrc > 0.
      skip 2.
      write: / 'Programmabbruch beim Insert in die Tabelle /adesso/mte_gpzus'.
      stop.
    endif.

    commit work.

* Zusammenzuführende GPartner aus der Relevenz-Tabelle der MIG entfernen
* Sie werden als MIG-Objekte durch die Referenz-Partner komplett ersetzt
    loop at it_gpzus.
      delete from /adesso/mte_rel
             where firma = p_firma
               and object = 'PARTNER'
               and obj_key = it_gpzus-partner_u.
      if sy-subrc > 0.
        write: / 'Programmabbruch - interner Fehler beim',
                 'Delete in der /adesso/mte_rel',
               /,
               / 'Inhalt der Relevanz-Tabelle kontrollieren'.
        stop.
      endif.

    endloop.
  endif.

  commit work.

* Statistik
  describe table it_gpzus lines sy-tfill.

  skip 2.
  if not p_update is initial.
    write: / 'Programm normal abgeschlossen - ECHTLAUF',
           / 'Es wurden', sy-tfill, 'GP-Einträge berücksichtigt'.
  else.
    write: / 'Programm normal abgeschlossen - SIMULATION',
           / 'Es würden', sy-tfill, 'GP-Einträge berücksichtigt'.
  endif..
