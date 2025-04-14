{
  MDVOIDs: "1.0";
  GlobalVariables: [
    {
      StudyName: "MYSTUDY",
      StudyDescription: "MYSTUDY",
      ProtocolName: "000359",
    },
  ];
  BasicDefinitions: [
    {
      Definition: "MeasurementUnit",
      OID: "MU_17",
      Name: "mL",
    },
  ];
  StudyEventRef: [
    {
      MDVOID: "1.0",
      StudyEventOID: "E00",
      OrderNumber: "0",
      Mandatory: "No",
    },
  ];
  StudyEventDef: [
    {
      MDVOID: "1.0",
      OID: "E00",
      Name: "Subject Registration",
      Repeating: "No",
      Type: "Scheduled",
      Category: "AddEvent",
    },
  ];
  FormRef: [
    {
      MDVOID: "1.0",
      StudyEventOID: "E00",
      FormOID: "IC",
    },
  ];
  FormDef: [
    {
      MDVOID: "1.0",
      OID: "LB_LL_CC",
      Name: "Clinical Chemistry – Local lab",
      Repeating: "No",
      Sdv: "None",
      Hidden: "",
    },
  ];
  ItemGroupRef: [
    {
      MDVOID: "1.0",
      FormOID: "LB_LL_CC",
      ItemGroupOID: "LB_LL_CCG22",
    },
  ];
  ItemGroupDef: [
    {
      MDVOID: "1.0",
      OID: "LB_LL_CCG22",
      Name: "Instructions 22",
      Repeating: "No",
      IsReferenceData: "",
      SASDatasetName: "",
      Domain: "",
      Origin: "",
      Purpose: "",
      Comment: "",
    },
  ];
  ItemDef: [
    {
      MDVOID: "1.0",
      OID: "CC_LBPERF",
      Name: "CC_LBPERF",
      DataType: "integer",
      Length: "12",
      SignificantDigits: "",
      SASFieldName: "",
      SDSVarName: "",
      Origin: "",
      Comment: "",
      Question: "Was the sample for clinical chemistry test collected?",
      MeasurementUnitOID: "",
      CodeListOID: "CL_HM_LBPERF",
      HtmlType: "radio",
      Sdv: "Required",
    },
  ];
  ItemRef[
    {
      MDVOID: "1.0",
      ItemGroupOID: "CCG1",
      ItemOID: "CC_LBPERF",
    }
  ];
  CodeList: [
    {
      MDVOID: "1.0",
      OID: "CL_VDYN",
      Name: "CL_VDYN",
      DataType: "text",
      SASFormatName: "YN",
      CodeListType: "CodeListItem",
      CodedValue: "Y",
      DecodedValue: "Yes",
      Rank: "",
      OrderNumber: "",
    },
  ];
  RolesDef: [
    {
      MDVOID: "1.0",
      OID: "R1",
      Name: "Investigator",
      Permissions:
        "AddForm,ResetForm,AddPatient,EditForm,ScheduleEvent,EditEventSchedule,SignEvent,SignForm,ExportReport,DeleteSubjects,AnonymizeData,ViewRoles",
    },
  ];
  SDVSettings: [
    {
      MDVOID: "1.0",
      SDVScope: "All",
    },
  ];
  ActivityDef: [
    {
      MDVOID: "1.0",
      OID: "ACT_E00_START",
      ExcludeDateForm: "true",
    },
  ];
  formitems: [
    {
      MDVOID: "1.0",
      FormOID: "LB_LL_CC",
      FormName: "Clinical Chemistry – Local lab",
      Hidden: "",
      ItemGroupOID: "LB_LL_CCG22",
      ItemOID: "NA",
      Name: "NA",
      DataType: "NA",
      Length: "NA",
      SignificantDigits: "NA",
      SASFieldName: "NA",
      SDSVarName: "NA",
      Origin: "NA",
      Comment: "NA",
      Question: "NA",
      MeasurementUnitOID: "NA",
      CodeListOID: "NA",
      HtmlType: "NA",
      Sdv: "NA",
    },
  ];
}
