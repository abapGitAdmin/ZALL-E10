*&---------------------------------------------------------------------*
*& Report ZTHIMEL_TEST_SCHULUNG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zthimel_test_schulung.

DATA: lr_process TYPE REF TO /idxgc/if_process.

lr_process = /adz/cl_bdr_process=>/idxgc/if_process~get_instance( iv_process_ref = '00000000000000000473' ).


lr_process->close_pdocs( ).


lr_process->complete( ).


IF 1 = 2.

endif.
