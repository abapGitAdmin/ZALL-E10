************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT z_mitarbeiterliste LINE-SIZE 132.

TABLES zemployees.
**********************************************************************

SELECT * FROM zemployees. "Basic select loop"

  WRITE zemployees.
ENDSELECT.

ULINE.
ULINE.



SELECT * FROM zemployees. " Basic Select loop with a Line -Break"

  WRITE / zemployees.
ENDSELECT.

ULINE.

SELECT * FROM zemployees.

  WRITE / zemployees.
ENDSELECT.
ULINE.
SELECT * FROM zemployees. " Basic select Loop with Skip statement"

  WRITE  zemployees.
  WRITE /.
ENDSELECT.

ULINE.

skip 2.                    " Basic select Loop with Skip statement and with individual fields being output"
SELECT * FROM zemployees.

  WRITE / zemployees-Surname.
  WRITE / zemployees-DOB.
  WRITE / zemployees-Forname.
ENDSELECT.

skip 2.                                  "chaining statments togather"
SELECT * FROM zemployees.

  WRITE: / zemployees-Surname,
   / zemployees-DOB,
   / zemployees-Forname.
ENDSELECT.
