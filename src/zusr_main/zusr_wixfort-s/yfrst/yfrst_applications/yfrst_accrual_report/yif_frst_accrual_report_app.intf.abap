"! <p class="shorttext synchronized" lang="en">Accrual Report</p>
INTERFACE yif_frst_accrual_report_app
  PUBLIC.

  METHODS create_accrual_report
    IMPORTING
      io_message_container    TYPE REF TO /iwbep/if_message_container
      io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity_c
      io_data_provider        TYPE REF TO /iwbep/if_mgw_entry_provider
    EXPORTING
      es_accrual_report       TYPE ycl_frst_accrual_repo_mpc=>ts_accrualreport.
  "! <p class="shorttext synchronized" lang="en">Returns an Entity of an Accrual Report</p>
  "!
  "! @parameter io_message_container | <p class="shorttext synchronized" lang="en">Message Container (for Client messages)</p>
  "! @parameter io_tech_request | <p class="shorttext synchronized" lang="en">Request Details for Read Feed</p>
  "! @parameter es_accrual_report | <p class="shorttext synchronized" lang="en">Returning Accrual Report</p>
  METHODS get_accrual_report
    IMPORTING
      io_message_container TYPE REF TO /iwbep/if_message_container
      io_tech_request      TYPE REF TO /iwbep/if_mgw_req_entity
    EXPORTING
      es_accrual_report    TYPE ycl_frst_accrual_repo_mpc=>ts_accrualreport.
  "! <p class="shorttext synchronized" lang="en">Returns an EntitySet of AccrualReports</p>
  "!
  "! @parameter io_message_container | <p class="shorttext synchronized" lang="en">Message Container (for Client messages)</p>
  "! @parameter io_tech_request | <p class="shorttext synchronized" lang="en">Request Details for Read Feed</p>
  "! @parameter et_accrual_reports | <p class="shorttext synchronized" lang="en">Resulting Accrual Report Set</p>
  METHODS get_accrual_reports
    IMPORTING
      io_message_container TYPE REF TO /iwbep/if_message_container
      io_tech_request      TYPE REF TO /iwbep/if_mgw_req_entityset
    EXPORTING
      et_accrual_reports   TYPE ycl_frst_accrual_repo_mpc=>tt_accrualreport.
  "! <p class="shorttext synchronized" lang="en">Returns an Entity of a Company Code</p>
  "!
  "! @parameter io_message_container | <p class="shorttext synchronized" lang="en">Message Container (for Client messages)</p>
  "! @parameter io_tech_request | <p class="shorttext synchronized" lang="en">Request Details for Read Feed</p>
  "! @parameter es_company_code | <p class="shorttext synchronized" lang="en">Resulting Company Code</p>
  METHODS get_company_code
    IMPORTING
      io_message_container TYPE REF TO /iwbep/if_message_container
      io_tech_request      TYPE REF TO /iwbep/if_mgw_req_entity
    EXPORTING
      es_company_code      TYPE ycl_frst_accrual_repo_mpc=>ts_company.

  "! <p class="shorttext synchronized" lang="en">Returns an EntitySet of Company Codes</p>
  "!
  "! @parameter io_message_container | <p class="shorttext synchronized" lang="en">Message Container (for Client messages)</p>
  "! @parameter io_tech_request | <p class="shorttext synchronized" lang="en">Request Details for Read Feed</p>
  "! @parameter et_company_codes | <p class="shorttext synchronized" lang="en">Resulting Company Code Set</p>
  METHODS get_company_codes
    IMPORTING
      io_message_container TYPE REF TO /iwbep/if_message_container
      io_tech_request      TYPE REF TO /iwbep/if_mgw_req_entityset
    EXPORTING
      et_company_codes     TYPE ycl_frst_accrual_repo_mpc=>tt_company.

ENDINTERFACE.
