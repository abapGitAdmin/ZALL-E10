interface /ADESSO/IF_BPM_FILL_CONTAINER
  public .


  methods GET_METMETHOD
    importing
      !IV_ELEMENT type SWC_EDITEL
    returning
      value(RS_MESSAGE) type EDIMESSAGE .
  methods GET_REGIOGROUP
    importing
      !IV_ELEMENT type SWC_EDITEL
    returning
      value(RS_MESSAGE) type EDIMESSAGE .
  methods GET_ACLASS
    importing
      !IV_ELEMENT type SWC_EDITEL
    returning
      value(RS_MESSAGE) type EDIMESSAGE .
  methods GET_INSTLN_TYPE
    importing
      !IV_ELEMENT type SWC_EDITEL
    returning
      value(RS_MESSAGE) type EDIMESSAGE .
  methods GET_GRID
    importing
      !IV_ELEMENT type SWC_EDITEL
    returning
      value(RS_MESSAGE) type EDIMESSAGE .
  methods GET_POD
    importing
      !IV_ELEMENT type SWC_EDITEL
    returning
      value(RS_MESSAGE) type EDIMESSAGE .
  methods GET_ISU_TASK
    importing
      !IV_ELEMENT type SWC_EDITEL
    returning
      value(RS_MESSAGE) type EDIMESSAGE .
  methods GET_CCAT
    importing
      !IV_ELEMENT type SWC_EDITEL
    returning
      value(RS_MESSAGE) type EDIMESSAGE .
  methods GET_MANDT
    importing
      !IV_ELEMENT type SWC_EDITEL
    returning
      value(RS_MESSAGE) type EDIMESSAGE .
  methods GET_SYSID
    importing
      !IV_ELEMENT type SWC_EDITEL
    returning
      value(RS_MESSAGE) type EDIMESSAGE .
  methods GET_CUSTOMER_FLAG
    importing
      !IV_ELEMENT type SWC_EDITEL
    returning
      value(RS_MESSAGE) type EDIMESSAGE .
endinterface.
