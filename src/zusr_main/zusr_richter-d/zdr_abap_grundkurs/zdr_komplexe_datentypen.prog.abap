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
report zdr_komplexe_datentypen.

types: begin of lty_s_mitarbeiter,
         pernr   type i,
         vorname type string,
         name    type string,
         alter   type i,
       end of lty_s_mitarbeiter.

types lty_t_mitarbeiter type table of lty_s_mitarbeiter.

data: gs_mitarbeiter  type lty_s_mitarbeiter,
      gt_mitarbeiter  type sorted table of lty_s_mitarbeiter with unique key pernr,
      gt_mitarbeiter2 type lty_t_mitarbeiter.

**********************************************************************
* Einfügen
**********************************************************************
gs_mitarbeiter-pernr = 2.
gs_mitarbeiter-vorname = 'Hans'.
gs_mitarbeiter-name = 'Peter'.
gs_mitarbeiter-alter = '50'.
*append gs_mitarbeiter to gt_mitarbeiter.
insert gs_mitarbeiter into table gt_mitarbeiter.
clear gs_mitarbeiter.

gs_mitarbeiter-pernr = 1.
gs_mitarbeiter-vorname = 'Paul'.
gs_mitarbeiter-name = 'Müller'.
gs_mitarbeiter-alter = '23'.
*append gs_mitarbeiter to gt_mitarbeiter.
insert gs_mitarbeiter into table gt_mitarbeiter.
*insert gs_mitarbeiter into gt_mitarbeiter index 1.
clear gs_mitarbeiter.

append lines of gt_mitarbeiter to gt_mitarbeiter2.
*insert lines of gt_mitarbeiter into table gt_mitarbeiter.
insert lines of gt_mitarbeiter from 1 to 2 into table gt_mitarbeiter2.

**********************************************************************
* Auslesen
**********************************************************************
read table gt_mitarbeiter index 2 into gs_mitarbeiter.
read table gt_mitarbeiter with table key pernr = 1 into gs_mitarbeiter.
read table gt_mitarbeiter with key name = 'Peter' into  gs_mitarbeiter.

clear gs_mitarbeiter.
loop at gt_mitarbeiter into gs_mitarbeiter where pernr = 1 and  name = 'Meyer'.
  write: / gs_mitarbeiter-vorname, gs_mitarbeiter-name, gs_mitarbeiter-alter.
  clear gs_mitarbeiter.
endloop.

**********************************************************************
* Verändern
**********************************************************************
sort gt_mitarbeiter2 by name pernr ascending.

gs_mitarbeiter-pernr = 2.
gs_mitarbeiter-vorname = 'Hans'.
gs_mitarbeiter-name = 'Meyer'.
gs_mitarbeiter-alter = '50'.

modify table gt_mitarbeiter from gs_mitarbeiter. "wenn Primärschlussel vorhanden
modify gt_mitarbeiter from  gs_mitarbeiter index 2. "falls nicht

**********************************************************************
* Löschen
**********************************************************************
delete table gt_mitarbeiter from gs_mitarbeiter. "Suche Zeile auf Basis von PK und lösche
delete gt_mitarbeiter index 1.

*check sy-subrc = 0.

if sy-subrc = 0.
  write: 'Löschen hat nicht geklappt'.
endif.

write: / gs_mitarbeiter-vorname, gs_mitarbeiter-name, gs_mitarbeiter-alter.
