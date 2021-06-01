*----------------------------------------------------------------------*
*   INCLUDE /ADESSO/MTE_RELEVANT_TOP                                    *
*----------------------------------------------------------------------*
* Deklarationen
* Datenbanktabellen
TABLES: /adesso/mte_rel,
        /adesso/mte_rlae,
        /adesso/mte_rlak,
        /adesso/mte_rlbk,
        /adesso/mte_relc ,
        /adesso/mte_rlgp,
        /adesso/mte_rlpt,
        /adesso/mte_rltt,
        /adesso/mte_rlvk,
        /adesso/mte_rlvt,
        /adesso/mte_rlsp,
        /adesso/mte_dtab,
        /adesso/mte_rlan,
        tfk002a,
        dfkklocks,
        dfkkop,
        but000,
        bcont,
        fkkvk,
        fkkvkp,
        eanl,
        eanlh,
        ettifb,
        eastl,
        egerh,
        eabp,
        ever,
        evbs,
        iflot,
        v_eger,
        egerr,
        equi,
        te420,
        te422,
        te271,
        stxh,
        fkk_instpln_head,
        enote,
        jest.

* Ranges für Selektionen aus dem Customizing Relevanzermittlung
RANGES: relae FOR te422-termschl,
        relak FOR eanlh-aklasse,
        relbk FOR fkkvkp-opbuk,
        relgp FOR but000-partner,
        relpt FOR te420-termschl,
        reltt FOR eanlh-tariftyp,
        relvk FOR fkkvk-vkont,
        relvt FOR fkkvk-vktyp,
        relsp FOR eanl-sparte,
        relan FOR eanl-anlage.       "Nuss 10.09.2015

* interne Tabelle und Arbeitsbereich zum Zwischenspeichern der
* ermittelten Relevanz
DATA: irel LIKE TABLE OF /adesso/mte_rel,
      wrel LIKE /adesso/mte_rel.
* interne Tabellem zum Zwischenspeichern der Objekte für die
* weiteren Selektionen
DATA: BEGIN OF ieanl OCCURS 0,
        anlage LIKE eanl-anlage,
      END OF ieanl.
DATA: BEGIN OF iever OCCURS 0,
        vertrag LIKE ever-vertrag,
      END OF iever.
DATA: BEGIN OF ivk OCCURS 0,
        vkont LIKE fkkvkp-vkont,
        gpart LIKE fkkvkp-gpart,
      END OF ivk.
DATA: BEGIN OF ibp OCCURS 0,
        partner LIKE but000-partner,
      END OF ibp.
DATA: BEGIN OF ibcont OCCURS 0,
        bpcontact LIKE bcont-bpcontact,
      END OF ibcont.

DATA: BEGIN OF idfkkop OCCURS 0,
        gpart LIKE dfkkop-gpart,
        vkont LIKE dfkkop-vkont,
      END OF idfkkop.


** Hilfsitab für Zähler beim Vertrag
DATA: BEGIN OF ever_count OCCURS 0,
        bukrs  LIKE ever-bukrs,
        sparte LIKE ever-sparte,
        anzahl TYPE i,
      END OF ever_count.


DATA ivksam LIKE TABLE OF ivk WITH HEADER LINE.
* Hilfsfelder
DATA: txfound(1) TYPE c.
DATA: tdname     LIKE stxh-tdname,
      objcount   TYPE i,
      object     LIKE dfkklocks-loobj1,
      counter    TYPE i,
      countertxt TYPE i.

DATA: datab LIKE sy-datum,
      objnr LIKE jest-objnr.

DATA: z_update TYPE i,
      z_insert TYPE i.

DATA: z_commit TYPE i.

** --> Nuss 17.03.2016
DATA: ls_erch TYPE erch,
      lt_erch TYPE TABLE OF erch,
      wa_erch TYPE erch.
** <-- Nuss 17.03.2016

*----------------------------------------------------------------------
* SELEKTIONSBILDSCHIM
*----------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK aa WITH FRAME TITLE text-b02.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p01.
PARAMETERS: firma LIKE temfd-firma DEFAULT 'WBD  ' OBLIGATORY.
SELECTION-SCREEN END OF LINE.
PARAMETERS: lfdnr TYPE /adesso/mte_laufnr NO-DISPLAY.
SELECTION-SCREEN SKIP.
PARAMETERS: pnodel AS CHECKBOX.
PARAMETERS: psaldo AS CHECKBOX.
PARAMETERS: pallgp NO-DISPLAY. "AS CHECKBOX
PARAMETERS: pallvk NO-DISPLAY. "AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK aa.
