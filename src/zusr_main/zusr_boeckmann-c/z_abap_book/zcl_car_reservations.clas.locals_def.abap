*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

TYPES t_reservation_tab TYPE HASHED TABLE
                        OF zreservations
                        WITH UNIQUE KEY reservation_id.
