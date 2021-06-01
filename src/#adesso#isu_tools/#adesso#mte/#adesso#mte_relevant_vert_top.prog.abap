*----------------------------------------------------------------------*
*   INCLUDE /ADESSO/MTE_RELEVANT_TOP                                    *
*----------------------------------------------------------------------*
TABLES: /adesso/mte_rel,
        dfkkop,
        stxh.

DATA: wa_ever       TYPE ever,
      wa_ever_h     type ever,
      wa_fkkvk      TYPE fkkvk,
      wa_fkkvkp     TYPE fkkvkp,
      wa_bcont      TYPE bcont,
      wa_eanl       TYPE eanl,
      wa_evbs       TYPE evbs,
      wa_iflot      TYPE iflot,
      wa_enote      TYPE enote,
      wa_eausv       TYPE eausv,
      wa_eastl      TYPE eastl,
      wa_eanlh      TYPE eanlh,
      wa_egerr     TYPE egerr.

DATA: it_ever TYPE STANDARD TABLE OF ever,
      it_fkkvk  TYPE STANDARD TABLE OF fkkvk,
      it_fkkvkp TYPE STANDARD TABLE OF fkkvkp,
      it_bcont  TYPE STANDARD TABLE OF bcont,
      it_eanl   TYPE STANDARD TABLE OF eanl,
      it_evbs   TYPE STANDARD TABLE OF evbs,
      it_iflot  TYPE STANDARD TABLE OF iflot,
      it_enote  TYPE STANDARD TABLE OF enote,
      it_eausv  TYPE STANDARD TABLE OF eausv,
      it_eastl  TYPE STANDARD TABLE OF eastl.


* interne Tabelle und Arbeitsbereich zum Zwischenspeichern der
* ermittelten Relevanz
DATA: irel LIKE TABLE OF /adesso/mte_rel,
      wrel LIKE /adesso/mte_rel.
* interne Tabellem zum Zwischenspeichern der Objekte für die
* weiteren Selektionen

* Anlagen
DATA: BEGIN OF ieanl OCCURS 0,
        anlage LIKE eanl-anlage,
      END OF ieanl.

* aktive Verträge
DATA: BEGIN OF iever_akt OCCURS 0,
        vertrag LIKE ever-vertrag,
      END OF iever_akt.

* beendete Verträge
DATA: BEGIN OF iever_end OCCURS 0,
        vertrag LIKE ever-vertrag,
      END OF iever_end.

* Verträge (mit Auszug)
* aktuell außer Acht gelassen
DATA: BEGIN OF iever_ausz OCCURS 0,
        vertrag LIKE ever-vertrag,
      END OF iever_ausz.

* Vertragskonten
DATA: BEGIN OF ivk OCCURS 0,
        vkont LIKE fkkvkp-vkont,
        gpart LIKE fkkvkp-gpart,
      END OF ivk.

* Geschäftspartner
DATA: BEGIN OF ibp OCCURS 0,
        partner LIKE but000-partner,
      END OF ibp.

* Geschäftspartnerkontakte
DATA: BEGIN OF ibcont OCCURS 0,
        bpcontact LIKE bcont-bpcontact,
      END OF ibcont.

* Vertragskonten und GP mit offenen Salden
DATA: BEGIN OF idfkkop OCCURS 0,
        gpart LIKE dfkkop-gpart,
        vkont LIKE dfkkop-vkont,
      END OF idfkkop.

* Geräteifosäte
DATA: BEGIN OF iegerr OCCURS 0,
       equnr LIKE egerr-equnr,
     END OF iegerr.

**  -> Nuss 22.01.2013
** Abschlagspläne
DATA: BEGIN OF ieabp OCCURS 0.
        INCLUDE STRUCTURE eabp.
DATA: END OF ieabp.
** <-- Nuss 22.01.2013

* Hilfsfelder
DATA: txfound(1) TYPE c.
DATA: tdname LIKE stxh-tdname,
      objcount TYPE i.

DATA: datab LIKE sy-datum.
DATA: p_abrdat LIKE sy-datum.
DATA: h_anlage TYPE anlage.

DATA: z_update TYPE i,
      z_insert TYPE i,
      z_commit TYPE i.


*----------------------------------------------------------------------
* SELEKTIONSBILDSCHIM
*----------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK aa WITH FRAME TITLE text-b02.
PARAMETERS: firma LIKE temfd-firma DEFAULT 'EGUT ' OBLIGATORY.
SELECTION-SCREEN SKIP.
PARAMETERS: lfdnr TYPE /adesso/mte_laufnr NO-DISPLAY.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF BLOCK aa.
