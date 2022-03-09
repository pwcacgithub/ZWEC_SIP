class ZCLCU_SIP_SOURCEWR definition
  public
  final
  create public .

public section.

  constants GC_STATUS_OPEN type Z_WRSTATUS value 'O' ##NO_TEXT.
  constants GC_DESIGNQTYUOM type MEINS value 'EA' ##NO_TEXT.
  constants GC_DIGUOM type MEABM value 'FT' ##NO_TEXT.

  methods SET_DATA
    importing
      !IS_WORK_REQUEST type ZCLECC_WORK_REQUEST
    exporting
      !ES_RESPONSE type ZCLECC_WRRESPONSE .
  methods CONVERT_TIMESTAMP
    importing
      !IV_INPUT type STRING
    exporting
      !EV_OUTPUT type BKK_TIMESTAMP
      !EV_DATE type DATUM .
  methods SET_RESPONSE
    importing
      !IV_WO type STRING
      !IV_MATNO type STRING optional
      !IV_MSGNO type MSGNR optional
      !IV_MSGTYP type CHAR10
      !IV_MSGV1 type STRING optional
      !IV_MSGV2 type STRING optional
    changing
      !CS_RESPONSE type ZCLECC_WRRESPONSE
      !CT_RETURN type BAPIRET2_T optional .
  methods SET_DATA_JOINTUSE
    importing
      !IS_INPUT type ZCLECC_JOINT_USE
    exporting
      !ES_OUTPUT type ZCLECC_JOINT_USE_RESPONSE .
  methods SET_RESPONSE_JOINTUSE
    importing
      !IV_WO type STRING
      !IV_IR type STRING optional
      !IV_MSGNO type MSGNR optional
      !IV_MSGTYP type CHAR10 optional
      !IV_MSGV1 type STRING optional
      !IV_MSGV2 type STRING optional
    changing
      !CS_RESPONSE type ZCLECC_JOINT_USE_RESPONSE
      !CT_RETURN type BAPIRET2_T optional .
  class-methods GET_WR_HEADER
    importing
      !IS_HEADER type ZCL_ZCU_W076_SIP_TICKE_MPC=>TS_HEADER
    exporting
      !ET_DATA type ZCL_ZCU_W076_SIP_TICKE_MPC=>TT_HEADER .
  class-methods GET_WR_ITEM
    importing
      !IS_ITEM type ZCL_ZCU_W076_SIP_TICKE_MPC=>TS_ITEM
    exporting
      !ET_DATA type ZCL_ZCU_W076_SIP_TICKE_MPC=>TT_ITEM .
  class-methods CONVERT_AUFNR_INTERNAL
    changing
      !CV_AUFNR type AUFNR .
  methods UPDATE_WR_STATUS
    importing
      !IT_SIPNO type RSELOPTION
    exporting
      !ET_RETURN type BAPIRET2_T .
  methods DATE_TO_TIMESTAMP
    importing
      !IV_DATE type DATUM
      !IV_TIME type TIMS
    exporting
      !EV_TIMESTAMP type STRING .
  methods FILL_RETURN
    importing
      !IV_MSGV1 type STRING
      !IV_MSGV2 type Z_SIPNO
      !IV_MSGTYPE type BAPI_MTYPE
      !IV_MSGNO type MSGNR
    changing
      !CT_RETURN type BAPIRET2_T .
  methods SET_DATA_MAXIMO
    importing
      !IS_INPUT type ZCLECC_WORK_ORDER
    exporting
      !ES_OUTPUT type ZCLECC_WORESPONSE .
  methods SET_RESPONSE_MAXIMO
    importing
      !IV_WO type STRING
      !IV_PMWO type STRING optional
      !IV_MATNO type STRING optional
      !IV_MSGNO type MSGNR optional
      !IV_MSGTYP type CHAR10
      !IV_MSGV1 type STRING optional
      !IV_MSGV2 type STRING optional
    changing
      !CS_RESPONSE type ZCLECC_WORESPONSE
      !CT_RETURN type BAPIRET2_T optional .
protected section.
private section.
ENDCLASS.



CLASS ZCLCU_SIP_SOURCEWR IMPLEMENTATION.


  METHOD convert_aufnr_internal.
***********************************************************************
*  Method:      CONVERT_AUFNR_INTERNAL                                *
*  Overview:    Work Request Master Data                              *
*  Author:      Vignesh Sunkasi                                       *
*  Create Date: 06/24/2020                                            *
*  Comments:    Add leading zeros to the Work Order number            *
*                                                                     *
***********************************************************************
*  CHANGE HISTORY:                                                    *
*                                                                     *
***********************************************************************
    IF cv_aufnr IS NOT INITIAL.
      SHIFT cv_aufnr RIGHT DELETING TRAILING space.
      TRANSLATE cv_aufnr USING ' 0'.
    ENDIF.
  ENDMETHOD.


  METHOD convert_timestamp.
***********************************************************************
*  Method:      CONVERT_TIMESTAMP                                     *
*  Overview:    Work Request Master Data                              *
*  Author:      Vignesh Sunkasi                                       *
*  Create Date: 06/24/2020                                            *
*  Comments:    Convert time and date to timestamp for the            *
*               corresponding timezone                                *
***********************************************************************
*  CHANGE HISTORY:                                                    *
*                                                                     *
***********************************************************************
    DATA: "Variables
      lv_time24   TYPE tims,
      lv_day(2)   TYPE c,
      lv_month(2) TYPE c,
      lv_year(4)  TYPE c.

    CLEAR: ev_output.

    SPLIT iv_input AT 'T' INTO DATA(lv_date) DATA(lv_time_comp).

    CONDENSE lv_date.
    SPLIT lv_date AT '-' INTO lv_year lv_month lv_day.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_day
      IMPORTING
        output = lv_day.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_month
      IMPORTING
        output = lv_month.

    CONCATENATE lv_year lv_month lv_day INTO DATA(lv_datum).
    ev_date = lv_datum.

    SPLIT lv_time_comp AT '-' INTO DATA(lv_time) DATA(lv_timezone) ##NEEDED.
    CONDENSE lv_time.
    CALL FUNCTION 'CONVERT_TIME_INPUT'
      EXPORTING
        input                     = lv_time
      IMPORTING
        output                    = lv_time24
      EXCEPTIONS
        plausibility_check_failed = 1
        wrong_format_in_input     = 2
        OTHERS                    = 3.
    IF sy-subrc = 0.
      CONVERT DATE lv_datum TIME lv_time24
      INTO TIME STAMP ev_output TIME ZONE sy-zonlo.
    ENDIF.
  ENDMETHOD.


  METHOD date_to_timestamp.
***********************************************************************
*  Method:      DATE_TO_TIMESTAMP                                     *
*  Overview:    Work Request Master Data                              *
*  Author:      Vignesh Sunkasi                                       *
*  Create Date: 06/24/2020                                            *
*  Comments:    Convert time and date to timestamp for the            *
*               corresponding timezone                                *
***********************************************************************
*  CHANGE HISTORY:                                                    *
*                                                                     *
***********************************************************************
    IF iv_date IS NOT INITIAL AND
       iv_time IS NOT INITIAL.

      DATA(lv_year)  = iv_date+0(4).
      DATA(lv_month) = iv_date+4(2).
      DATA(lv_day)   = iv_date+6(2).
      CONCATENATE lv_year lv_month lv_day INTO DATA(lv_date) SEPARATED BY '-'.

      DATA(lv_hour) = iv_time+0(2).
      DATA(lv_min)  = iv_time+2(2).
      DATA(lv_sec)  = iv_time+4(2).
      CONCATENATE lv_hour lv_min lv_sec INTO DATA(lv_time) SEPARATED BY ':'.

      CONCATENATE lv_date lv_time INTO ev_timestamp SEPARATED BY space.

    ENDIF.
  ENDMETHOD.


  METHOD fill_return.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.09.2020
*&  Functional Design Name : Fill return structure with error message
*&  Purpose                : Fill return structure with error message
*&  Transport Request No   : D10K936685
*****************************************************************************
    DATA: lv_msg   TYPE string,
          lv_msgv1 TYPE symsgv,
          lv_msgv2 TYPE symsgv.

    lv_msgv1 = iv_msgv1.
    lv_msgv2 = iv_msgv2.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = zif_cu_sip=>gc_zcu_msg
        msgnr               = iv_msgno
        msgv1               = lv_msgv1
        msgv2               = lv_msgv2
      IMPORTING
        message_text_output = lv_msg.

    APPEND INITIAL LINE TO ct_return ASSIGNING FIELD-SYMBOL(<ls_return>).
    <ls_return>-type       = iv_msgtype.
    <ls_return>-id         = zif_cu_sip=>gc_zcu_msg.
    <ls_return>-number     = iv_msgno.
    <ls_return>-message_v1 = lv_msgv1.
    <ls_return>-message_v2 = lv_msgv2.
    <ls_return>-message    = lv_msg.
  ENDMETHOD.


  METHOD get_wr_header.
*****************************************************************************
*&  Created By             : Kripa S P
*&  Created On             : 31.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the WR Header details
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: lt_param TYPE zttca_param.

    CONSTANTS: lc_code_group TYPE qmsm-mngrp VALUE 'MX-M',
               lc_task_code  TYPE qmsm-mncod VALUE 'PROJ'.

    CLEAR et_data.

    SELECT a~wrno,
          a~addr1,
          a~city,
          a~cwrno,
          a~cdate,
          a~supplier,
          a~suppliercompany,
          b~name1,
          b~regio,
          b~txjcd,
          a~bussunit,
          a~novellid,
          a~operdistrict,
          a~rdate,
          a~sqmile,
          a~sqmiledescr,
          a~state,
          a~woid,
          a~woidblanket,
          a~wrdesc,
          a~wrname,
          a~wrtype,
          a~wosubtype,
          a~zip,
          a~zipplus4,
          a~permit_no,
          a~erdat,
          a~ernam,
          a~aedat,
          a~aenam,
          a~status,
          a~final,
          a~swrcounter,
          a~comments,
          a~source,
          a~currentnum,
          a~workcompleted,
          a~projectowner,
          a~pmoperation,
          a~township
      FROM ztcu_wrheader AS a
      LEFT OUTER JOIN lfa1 AS b
      ON a~suppliercompany = b~lifnr
      UP TO 1 ROWS
      INTO @DATA(lw_wrheader)
      WHERE wrno = @is_header-wrno.
    ENDSELECT.
    IF sy-subrc = 0.

      "Get Novellid name
      CALL METHOD zclcu_sip_utility=>get_name
        EXPORTING
          iv_userid = lw_wrheader-novellid
        IMPORTING
          ev_name   = DATA(lv_novellid_name).

      "Get Project Owner name
      CALL METHOD zclcu_sip_utility=>get_name
        EXPORTING
          iv_userid = lw_wrheader-projectowner
        IMPORTING
          ev_name   = DATA(lv_projowner_name).

      IF lw_wrheader-suppliercompany IS INITIAL.
        SELECT a~lifnr,
               a~name1,
               a~regio,
               a~txjcd
          FROM lfa1 AS a
          INNER JOIN ekko AS b
                    ON a~lifnr = b~lifnr
                    INTO @DATA(lw_vend_name)
          UP TO 1 ROWS
          WHERE ebeln = @is_header-contract.
        ENDSELECT.
        IF sy-subrc <> 0.
          CLEAR lw_vend_name.
        ENDIF.
      ELSE.
        lw_vend_name-lifnr = lw_wrheader-suppliercompany.
        lw_vend_name-name1 = lw_wrheader-name1.
        lw_vend_name-regio = lw_wrheader-regio.
        lw_vend_name-txjcd = lw_wrheader-txjcd.
      ENDIF.

      IF lw_wrheader-source = zif_cu_sip=>gc_source-maximo OR
         lw_wrheader-source = zif_cu_sip=>gc_source-maximo_lower.
        "Get Project WO for Maximo
        SELECT a~qmnum,
               b~matxt
          UP TO 1 ROWS
          FROM qmel AS a
          INNER JOIN qmsm AS b
          ON a~qmnum = b~qmnum
          INTO @DATA(ls_matxt)
          WHERE a~aufnr = @lw_wrheader-woid AND
                b~mngrp = @lc_code_group AND
                b~mncod = @lc_task_code.
        ENDSELECT.
        IF sy-subrc = 0.
          "Get Project Description and Project Phase
          SELECT SINGLE aufnr,
                 ktext,
                 zzsmp_phase
            FROM aufk
            INTO @DATA(ls_aufk)
            WHERE aufnr = @ls_matxt-matxt.
          IF sy-subrc <> 0.
            CLEAR ls_aufk.
          ENDIF.
        ENDIF.

        "Get company code for which Dig fields will be visible
        NEW zcl_ca_utility( )->get_parameter(
        EXPORTING
          i_busproc           = 'CU'             " Business Process
          i_busact            = 'TECH'           " Business Activity
          i_validdate         = sy-datum         " Parameter Validity Start Date
          i_param             = 'CCODE_MAXIMO'
        CHANGING
          t_param             = lt_param         " Parameter value
        EXCEPTIONS
          invalid_busprocess  = 1                " Invalid Business Process
          invalid_busactivity = 2                " Invalid Business Activity
          OTHERS              = 3
       ).
      ENDIF.

      APPEND INITIAL LINE TO et_data ASSIGNING FIELD-SYMBOL(<ls_header>).
      MOVE-CORRESPONDING lw_wrheader TO <ls_header> ##ENH_OK.

      <ls_header>-novellidname        = lv_novellid_name.
      <ls_header>-projectowner_name   = lv_projowner_name.
      <ls_header>-suppliercompany     = lw_vend_name-lifnr.
      <ls_header>-suppliercompanyname = lw_vend_name-name1.
      <ls_header>-regio               = lw_vend_name-regio.
      <ls_header>-txjcd               = lw_vend_name-txjcd.
      <ls_header>-wrdesc              = lw_wrheader-wrname.
      <ls_header>-project             = lw_wrheader-wrname.
      <ls_header>-projdesc            = lw_wrheader-wrdesc.
      <ls_header>-completiondate      = lw_wrheader-cdate.
      <ls_header>-planneddate         = lw_wrheader-rdate.
      <ls_header>-wrdate              = lw_wrheader-erdat. "#EC CI_CONV_OK
      <ls_header>-addrline1           = lw_wrheader-addr1. "#EC CI_CONV_OK
      <ls_header>-addrline2           = lw_wrheader-city.
      <ls_header>-postalcode          = lw_wrheader-zip.
      <ls_header>-plant               = lw_wrheader-operdistrict.
      <ls_header>-area                = lw_wrheader-state.
      <ls_header>-permitno            = lw_wrheader-permit_no. "#EC CI_CONV_OK
      <ls_header>-cjobno              = lw_wrheader-cwrno. "#EC CI_CONV_OK

      IF lw_wrheader-source = zif_cu_sip=>gc_source-maximo OR
         lw_wrheader-source = zif_cu_sip=>gc_source-maximo_lower.

        <ls_header>-maximo       = abap_true.
        <ls_header>-projectwo    = ls_matxt-matxt.
        <ls_header>-projectdescr = ls_aufk-ktext.
        <ls_header>-projectphase = ls_aufk-zzsmp_phase.

        IF lw_wrheader-wrtype = zif_cu_sip=>gc_restoration-restor_lower OR
           lw_wrheader-wrtype = zif_cu_sip=>gc_restoration-restor_upper.
          <ls_header>-restoration = abap_true.

          READ TABLE lt_param TRANSPORTING NO FIELDS
          WITH KEY value = lw_wrheader-bussunit.
          IF sy-subrc = 0.
            <ls_header>-digvisible = abap_true.
          ENDIF.
        ENDIF.
      ENDIF.

      IF lw_wrheader-woid IS NOT INITIAL.
        <ls_header>-costobject          = lw_wrheader-woid.
      ELSEIF lw_wrheader-woidblanket IS NOT INITIAL.
        <ls_header>-costobject = lw_wrheader-woidblanket.
      ENDIF.

      IF <ls_header>-costobject IS NOT INITIAL.
        IF lw_wrheader-source = zif_cu_sip=>gc_source-wmis OR
           lw_wrheader-source = zif_cu_sip=>gc_source-wmis_lower.
          <ls_header>-coflag  = zif_cu_sip=>gc_co-io.
        ELSEIF lw_wrheader-source = zif_cu_sip=>gc_source-maximo OR
               lw_wrheader-source = zif_cu_sip=>gc_source-maximo_lower.
          <ls_header>-coflag  = zif_cu_sip=>gc_co-pm.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_wr_item.
*****************************************************************************
*&  Created By             : Kripa S P
*&  Created On             : 31.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the WR Header details
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR: et_data.

    DATA: lv_error     TYPE bapi_msg,
          lw_wr        TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_item,
          lv_matnr     TYPE matnr,
          lw_item      TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_item,
          lv_counter   TYPE bnfpo,
          lv_lineno    TYPE z_linenum,
          lv_designqty TYPE z_designqty.

    SELECT a~wrno,
           a~itemcode,
           a~woid,
           a~linenum,
           a~type,
           b~source,
           c~maktx,
           a~designqty,
           a~acctno1,
           a~acctno2,
           a~diglength,
           a~digwidth,
           a~digfromloc,
           a~digtoloc
      FROM ztcu_writem AS a
      INNER JOIN ztcu_wrheader AS b
      ON a~wrno = b~wrno
      LEFT OUTER JOIN makt AS c
      ON a~itemcode = c~matnr
      AND c~spras   = @sy-langu
      INTO TABLE @DATA(lt_item)
      WHERE a~wrno  = @is_item-wrno.
    IF sy-subrc = 0.
      SORT lt_item BY wrno itemcode woid.

      IF is_item-contract IS NOT INITIAL .
        SELECT ebeln,
               matnr,
               meins,
               netpr
          FROM ekpo
          INTO TABLE @DATA(lt_ekpo)
          WHERE ebeln = @is_item-contract AND
                loekz = @space.
        IF sy-subrc EQ 0.
          SORT lt_ekpo BY matnr.
        ENDIF.
      ENDIF.

      "Calculate Accumulated Quantity
      CALL METHOD zclcu_sip_utility=>calculate_accumulatedqty
        EXPORTING
          iv_appindicator   = is_item-appindicator
          iv_wrno           = is_item-wrno
        IMPORTING
          et_accumulatedqty = DATA(lt_accumulatedqty).

      LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
        AT NEW itemcode.
          lv_lineno = lv_lineno + 10 .
        ENDAT.

        AT NEW woid.
          MOVE-CORRESPONDING <ls_item> TO lw_item ##ENH_OK.

          lw_item-linenum = lv_lineno.

          lv_counter = lv_counter + 1.
          lw_item-counter = lv_counter.

          IF lv_counter > 1.
            lw_item-parentlineno   = lv_lineno.
            lw_item-splitindicator = zif_cu_sip=>gc_splitindicator-system.
          ENDIF.

          lw_item-itemdescr = <ls_item>-maktx.

          IF <ls_item>-woid IS NOT INITIAL.
            IF <ls_item>-source = zif_cu_sip=>gc_source-wmis OR
               <ls_item>-source = zif_cu_sip=>gc_source-wmis_lower.
              lw_item-coflag = 'IO'.
            ELSEIF <ls_item>-source = zif_cu_sip=>gc_source-maximo OR
                   <ls_item>-source = zif_cu_sip=>gc_source-maximo_lower.
              lw_item-coflag = 'PM'.
            ENDIF.
            lw_item-costobject = <ls_item>-woid.
          ENDIF.

          READ TABLE lt_ekpo ASSIGNING FIELD-SYMBOL(<ls_ekpo>)
          WITH KEY matnr = <ls_item>-itemcode BINARY SEARCH.
          IF sy-subrc = 0.
            lw_item-netprice  = <ls_ekpo>-netpr.
          ENDIF.

          CLEAR: lw_item-designqty,
                 lw_item-designqtyuom,
                 lw_item-accumalatedqty.
        ENDAT.

        lv_designqty = lv_designqty + <ls_item>-designqty.

        AT END OF itemcode.
          IF lw_item-parentlineno IS NOT INITIAL.
            READ TABLE et_data ASSIGNING FIELD-SYMBOL(<ls_data>)
            WITH KEY wrno    = <ls_item>-wrno
                     linenum = lv_lineno
                     counter = 1.
            IF sy-subrc = 0.
              <ls_data>-designqty = lv_designqty.

              READ TABLE lt_ekpo ASSIGNING <ls_ekpo>
              WITH KEY matnr = <ls_item>-itemcode BINARY SEARCH.
              IF sy-subrc = 0.
                <ls_data>-designqtyuom = <ls_ekpo>-meins.
              ENDIF.

              READ TABLE lt_accumulatedqty ASSIGNING FIELD-SYMBOL(<ls_accumqty>)
              WITH KEY itemcode = <ls_item>-itemcode BINARY SEARCH.
              IF sy-subrc = 0.
                <ls_data>-accumalatedqty = <ls_accumqty>-accumqty.
              ENDIF.

            ENDIF.
          ELSE.
            lw_item-designqty = lv_designqty.

            READ TABLE lt_ekpo ASSIGNING <ls_ekpo>
            WITH KEY matnr = <ls_item>-itemcode BINARY SEARCH.
            IF sy-subrc = 0.
              lw_item-designqtyuom = <ls_ekpo>-meins.
            ENDIF.

            READ TABLE lt_accumulatedqty ASSIGNING <ls_accumqty>
            WITH KEY itemcode = <ls_item>-itemcode BINARY SEARCH.
            IF sy-subrc = 0.
              lw_item-accumalatedqty = <ls_accumqty>-accumqty.
            ENDIF.
          ENDIF.


          CLEAR: lv_counter,
                 lv_designqty.
        ENDAT.

        AT END OF woid.
          IF <ls_item>-source = zif_cu_sip=>gc_source-wmis OR
             <ls_item>-source = zif_cu_sip=>gc_source-wmis_lower.
            lw_item-maximo = abap_false.
          ELSEIF <ls_item>-source = zif_cu_sip=>gc_source-maximo OR
                 <ls_item>-source = zif_cu_sip=>gc_source-maximo_lower.
            lw_item-maximo = abap_true.
          ENDIF.

          APPEND lw_item TO et_data.
          CLEAR: lw_item.
        ENDAT.

      ENDLOOP.
    ENDIF.

    SORT et_data BY linenum.

  ENDMETHOD.


  METHOD set_data.
***********************************************************************
*  Method:      SET_DATA                                              *
*  Overview:    Work Request Master Data                              *
*  Author:      Vignesh Sunkasi                                       *
*  Create Date: 06/24/2020                                            *
*  Comments:    Get the WR master data from WMIS/Maximo and update    *
*               the corresponding custom tables                       *
***********************************************************************
*  CHANGE HISTORY:                                                    *
*                                                                     *
***********************************************************************
    DATA:
      "Variable
      lv_item       TYPE z_linenum,
      lv_vendor     TYPE lifnr,
      lv_userid     TYPE xubname,
      lv_usrid_hr   TYPE sysid,
      lv_plant      TYPE werks_d,
      lv_wo         TYPE aufnr,
      lv_mat        TYPE matnr,
      lv_cocode     TYPE bukrs,
      lv_wrno       TYPE z_wrno,
      lv_mcode      TYPE z_municipality_code,
      "Internal Table
      lt_wrheader   TYPE STANDARD TABLE OF ztcu_wrheader,
      lt_writem     TYPE STANDARD TABLE OF ztcu_writem,
      lt_writem_tmp TYPE STANDARD TABLE OF ztcu_writem,
      lt_wrno       TYPE STANDARD TABLE OF z_wrno,
      lt_vendor     TYPE STANDARD TABLE OF lifnr,
      lt_userid     TYPE STANDARD TABLE OF xubname,
      lt_usrid_hr   TYPE STANDARD TABLE OF sysid,
      lt_plant      TYPE STANDARD TABLE OF werks_d,
      lt_wo         TYPE STANDARD TABLE OF aufnr,
      lt_cocode     TYPE STANDARD TABLE OF bukrs,
      lt_mcode      TYPE STANDARD TABLE OF z_municipality_code,
      lt_return     TYPE bapiret2_t,
      lt_param      TYPE zttca_param,
      "WorkArea
      ls_wrheader   TYPE ztcu_wrheader,
      ls_writem     TYPE ztcu_writem.

    CLEAR es_response.

*Get the source
    READ TABLE is_work_request-ecc_work_request-control ASSIGNING FIELD-SYMBOL(<ls_control>)
    INDEX 1.
    IF sy-subrc = 0.
      DATA(lv_source) = <ls_control>-sender.
    ENDIF.

*Fill the response control structure
    APPEND INITIAL LINE TO es_response-ecc_wrresponse-control
    ASSIGNING FIELD-SYMBOL(<ls_control_response>).
    IF <ls_control_response> IS ASSIGNED.
      <ls_control_response>-receiver = lv_source.
    ENDIF.

*Validations
    LOOP AT is_work_request-ecc_work_request-wrrecord ASSIGNING FIELD-SYMBOL(<ls_header>).
      IF <ls_header>-work_order_number IS NOT INITIAL.
        lv_wrno = <ls_header>-work_order_number.
        APPEND lv_wrno TO lt_wrno.
      ENDIF.

      IF <ls_header>-sapvendor_number IS NOT INITIAL.
        lv_vendor = <ls_header>-sapvendor_number.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_vendor
          IMPORTING
            output = lv_vendor.

        APPEND lv_vendor TO lt_vendor.
      ENDIF.

      IF <ls_header>-designer_id IS NOT INITIAL.
        lv_userid = <ls_header>-designer_id.
        APPEND lv_userid TO lt_userid.

        lv_usrid_hr = <ls_header>-designer_id.
        APPEND lv_usrid_hr TO lt_usrid_hr.
      ENDIF.

      IF <ls_header>-plant IS NOT INITIAL.
        lv_plant = <ls_header>-plant.
        APPEND lv_plant TO lt_plant.
      ENDIF.

      IF <ls_header>-ionumber IS NOT INITIAL.
        lv_wo = <ls_header>-ionumber.

        CALL METHOD zclcu_sip_sourcewr=>convert_aufnr_internal
          CHANGING
            cv_aufnr = lv_wo.

        APPEND lv_wo TO lt_wo.
      ENDIF.

      IF <ls_header>-ionumber_blanket IS NOT INITIAL.
        lv_wo = <ls_header>-ionumber_blanket.

        CALL METHOD zclcu_sip_sourcewr=>convert_aufnr_internal
          CHANGING
            cv_aufnr = lv_wo.

        APPEND lv_wo TO lt_wo.
      ENDIF.

      IF <ls_header>-pmwork_order_id IS NOT INITIAL.
        lv_wo = <ls_header>-pmwork_order_id.

        CALL METHOD zclcu_sip_sourcewr=>convert_aufnr_internal
          CHANGING
            cv_aufnr = lv_wo.

        APPEND lv_wo TO lt_wo.
      ENDIF.

      IF <ls_header>-company_code IS NOT INITIAL.
        lv_cocode = <ls_header>-company_code.
        APPEND lv_cocode TO lt_cocode.
      ENDIF.

      IF <ls_header>-municipality_code IS NOT INITIAL.
        lv_mcode = <ls_header>-municipality_code.
        IF lv_mcode = <ls_header>-municipality_code.
          APPEND lv_mcode TO lt_mcode.
        ENDIF.
      ENDIF.

      LOOP AT <ls_header>-writem ASSIGNING FIELD-SYMBOL(<ls_item>).
        IF <ls_item>-cost_object IS NOT INITIAL.
          lv_wo = <ls_item>-cost_object.

          CALL METHOD zclcu_sip_sourcewr=>convert_aufnr_internal
            CHANGING
              cv_aufnr = lv_wo.

          APPEND lv_wo TO lt_wo.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

*Master table
    IF lt_wrno IS NOT INITIAL.
      SELECT wrno
        FROM ztcu_wrheader
        INTO TABLE @DATA(lt_wr)
        FOR ALL ENTRIES IN @lt_wrno
        WHERE wrno = @lt_wrno-table_line.
      IF sy-subrc = 0.
        SORT lt_wr BY wrno.
      ENDIF.
    ENDIF.

    IF lt_vendor IS NOT INITIAL.
      SELECT lifnr
        FROM lfa1
        INTO TABLE @DATA(lt_lfa1)
        FOR ALL ENTRIES IN @lt_vendor
        WHERE lifnr = @lt_vendor-table_line.
      IF sy-subrc = 0.
        SORT lt_lfa1 BY lifnr.
      ENDIF.
    ENDIF.

    IF lt_userid IS NOT INITIAL.
      SELECT bname
        FROM usr02
        INTO TABLE @DATA(lt_usr02)
        FOR ALL ENTRIES IN @lt_userid
        WHERE bname = @lt_userid-table_line.
      IF sy-subrc = 0.
        SORT lt_usr02 BY bname.
      ENDIF.
    ENDIF.

    IF lt_usrid_hr IS NOT INITIAL.
      SELECT usrid
        FROM pa0105
        INTO TABLE @DATA(lt_pa0105)
        FOR ALL ENTRIES IN @lt_usrid_hr
        WHERE usrid = @lt_usrid_hr-table_line.
      IF sy-subrc = 0.
        SORT lt_pa0105 BY usrid.
      ENDIF.
    ENDIF.

    IF lt_plant IS NOT INITIAL.
      SELECT werks
        FROM t001w
        INTO TABLE @DATA(lt_t001w)
        FOR ALL ENTRIES IN @lt_plant
        WHERE werks = @lt_plant-table_line.
      IF sy-subrc = 0.
        SORT lt_t001w BY werks.
      ENDIF.
    ENDIF.

    IF lt_wo IS NOT INITIAL.
      SELECT aufnr
        FROM aufk
        INTO TABLE @DATA(lt_aufk)
        FOR ALL ENTRIES IN @lt_wo
        WHERE aufnr = @lt_wo-table_line.
      IF sy-subrc = 0.
        SORT lt_aufk BY aufnr.
      ENDIF.
    ENDIF.

    IF lt_cocode IS NOT INITIAL.
      SELECT bukrs
        FROM t001
        INTO TABLE @DATA(lt_t001)
        FOR ALL ENTRIES IN @lt_cocode
        WHERE bukrs = @lt_cocode-table_line.
      IF sy-subrc = 0.
        SORT lt_t001 BY bukrs.
      ENDIF.
    ENDIF.

    IF lt_mcode IS NOT INITIAL.
      SELECT mcode
        FROM ztcu_communicode
        INTO TABLE @DATA(lt_municipcode)
        FOR ALL ENTRIES IN @lt_mcode
        WHERE mcode = @lt_mcode-table_line AND
              validfrom LE @sy-datum AND
              validto   GE @sy-datum.
      IF sy-subrc = 0.
        SORT lt_municipcode BY mcode.
      ENDIF.
    ENDIF.

    NEW zcl_ca_utility( )->get_parameter(
  EXPORTING
    i_busproc           = 'CU'             " Business Process
    i_busact            = 'TECH'           " Business Activity
    i_validdate         = sy-datum         " Parameter Validity Start Date
    i_param             = 'RESTORATION'
  CHANGING
    t_param             = lt_param         " Parameter value
  EXCEPTIONS
    invalid_busprocess  = 1                " Invalid Business Process
    invalid_busactivity = 2                " Invalid Business Activity
    OTHERS              = 3
).
    IF sy-subrc = 0.
      SORT lt_param BY value.
    ENDIF.

*Fill the header structur
    LOOP AT is_work_request-ecc_work_request-wrrecord ASSIGNING <ls_header>.
      IF <ls_header>-work_order_number IS NOT INITIAL.
        IF <ls_header>-work_action_type = 'U'.
          READ TABLE lt_wr TRANSPORTING NO FIELDS
          WITH KEY wrno = <ls_header>-work_order_number BINARY SEARCH ##WARN_OK.
          IF sy-subrc = 0.
            ls_wrheader-wrno      = <ls_header>-work_order_number.
          ELSE.
            DATA(lv_header_error) = abap_true.
            me->set_response(
              EXPORTING
                iv_wo       = <ls_header>-work_order_number
                iv_msgno    = '012'
                iv_msgtyp   = zif_cu_sip=>gc_rejected
                iv_msgv1    = <ls_header>-work_order_number
              CHANGING
                cs_response =  es_response
                ct_return   = lt_return
            ).
          ENDIF.
        ELSEIF <ls_header>-work_action_type = 'C'.
          READ TABLE lt_wr TRANSPORTING NO FIELDS
          WITH KEY wrno = <ls_header>-work_order_number BINARY SEARCH ##WARN_OK.
          IF sy-subrc <> 0.
            ls_wrheader-wrno      = <ls_header>-work_order_number.
          ELSE.
            lv_header_error = abap_true.
            me->set_response(
              EXPORTING
                iv_wo       = <ls_header>-work_order_number
                iv_msgno    = '011'
                iv_msgtyp   = zif_cu_sip=>gc_rejected
                iv_msgv1    = <ls_header>-work_order_number
              CHANGING
                cs_response =  es_response
                ct_return   = lt_return
            ).
          ENDIF.
        ENDIF.
      ENDIF.

      IF <ls_header>-sapvendor_number IS NOT INITIAL.
        lv_vendor = <ls_header>-sapvendor_number.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_vendor
          IMPORTING
            output = lv_vendor.

        READ TABLE lt_lfa1 TRANSPORTING NO FIELDS
        WITH KEY lifnr = lv_vendor BINARY SEARCH.
        IF sy-subrc = 0.
          ls_wrheader-suppliercompany      = lv_vendor.
        ELSE.
          lv_header_error = abap_true.
          me->set_response(
            EXPORTING
              iv_wo       = <ls_header>-work_order_number
              iv_msgno    = '010'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_sap_vendor_number
              iv_msgv2    = <ls_header>-sapvendor_number
            CHANGING
              cs_response =  es_response
              ct_return   = lt_return
          ).
        ENDIF.
      ENDIF.

      IF <ls_header>-designer_id IS NOT INITIAL.
        READ TABLE lt_usr02 TRANSPORTING NO FIELDS
        WITH KEY bname = <ls_header>-designer_id BINARY SEARCH ##WARN_OK.
        IF sy-subrc = 0.
          ls_wrheader-novellid      = <ls_header>-designer_id.
        ELSE.
          READ TABLE lt_pa0105 TRANSPORTING NO FIELDS
          WITH KEY usrid = <ls_header>-designer_id BINARY SEARCH ##WARN_OK.
          IF sy-subrc = 0.
            ls_wrheader-novellid      = <ls_header>-designer_id.
          ENDIF.
        ENDIF.
        IF ls_wrheader-novellid IS INITIAL.
          lv_header_error = abap_true.
          me->set_response(
            EXPORTING
              iv_wo       = <ls_header>-work_order_number
              iv_msgno    = '013'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_designer_id
              iv_msgv2    = <ls_header>-designer_id
            CHANGING
              cs_response =  es_response
              ct_return   = lt_return
          ).
        ENDIF.
      ENDIF.

      IF <ls_header>-plant IS NOT INITIAL.
        READ TABLE lt_t001w TRANSPORTING NO FIELDS
        WITH KEY werks = <ls_header>-plant BINARY SEARCH ##WARN_OK.
        IF sy-subrc = 0.
          ls_wrheader-operdistrict  = <ls_header>-plant.
        ELSE.
          lv_header_error = abap_true.
          me->set_response(
            EXPORTING
              iv_wo       = <ls_header>-work_order_number
              iv_msgno    = '010'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_plant
              iv_msgv2    = <ls_header>-plant
            CHANGING
              cs_response =  es_response
              ct_return   = lt_return
          ).
        ENDIF.
      ENDIF.

      IF <ls_header>-ionumber IS NOT INITIAL.
        lv_wo = <ls_header>-ionumber.

        CALL METHOD zclcu_sip_sourcewr=>convert_aufnr_internal
          CHANGING
            cv_aufnr = lv_wo.

        READ TABLE lt_aufk TRANSPORTING NO FIELDS
        WITH KEY aufnr = lv_wo BINARY SEARCH.
        IF sy-subrc = 0.
          ls_wrheader-woid          = lv_wo.
        ELSE.
          lv_header_error = abap_true.
          me->set_response(
            EXPORTING
              iv_wo       = <ls_header>-work_order_number
              iv_msgno    = '010'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_io_number
              iv_msgv2    = <ls_header>-ionumber
            CHANGING
              cs_response =  es_response
              ct_return   = lt_return
          ).
        ENDIF.
      ENDIF.

      IF <ls_header>-ionumber_blanket IS NOT INITIAL.
        lv_wo = <ls_header>-ionumber_blanket.

        CALL METHOD zclcu_sip_sourcewr=>convert_aufnr_internal
          CHANGING
            cv_aufnr = lv_wo.

        READ TABLE lt_aufk TRANSPORTING NO FIELDS
        WITH KEY aufnr = lv_wo BINARY SEARCH.
        IF sy-subrc = 0.
          ls_wrheader-woidblanket   = lv_wo.
        ELSE.
          lv_header_error = abap_true.
          me->set_response(
            EXPORTING
              iv_wo       = <ls_header>-work_order_number
              iv_msgno    = '010'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_io_number_blanket
              iv_msgv2    = <ls_header>-ionumber_blanket
            CHANGING
              cs_response =  es_response
              ct_return   = lt_return
          ).
        ENDIF.
      ENDIF.

      IF <ls_header>-pmwork_order_id IS NOT INITIAL.
        lv_wo = <ls_header>-pmwork_order_id.

        CALL METHOD zclcu_sip_sourcewr=>convert_aufnr_internal
          CHANGING
            cv_aufnr = lv_wo.

        READ TABLE lt_aufk TRANSPORTING NO FIELDS
        WITH KEY aufnr = lv_wo BINARY SEARCH.
        IF sy-subrc = 0.
          ls_wrheader-woid        = lv_wo.
        ELSE.
          lv_header_error = abap_true.
          me->set_response(
            EXPORTING
              iv_wo       = <ls_header>-work_order_number
              iv_msgno    = '010'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_pmwoid
              iv_msgv2    = <ls_header>-pmwork_order_id
            CHANGING
              cs_response =  es_response
              ct_return   = lt_return
          ).
        ENDIF.
      ENDIF.

      IF <ls_header>-company_code IS NOT INITIAL.
        READ TABLE lt_t001 TRANSPORTING NO FIELDS
        WITH KEY bukrs = <ls_header>-company_code BINARY SEARCH ##WARN_OK.
        IF sy-subrc = 0.
          ls_wrheader-bussunit      = <ls_header>-company_code.
        ELSE.
          lv_header_error = abap_true.
          me->set_response(
            EXPORTING
              iv_wo       = <ls_header>-work_order_number
              iv_msgno    = '010'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_companycode
              iv_msgv2    = <ls_header>-company_code
            CHANGING
              cs_response =  es_response
              ct_return   = lt_return
          ).
        ENDIF.
      ENDIF.

      IF <ls_header>-municipality_code IS NOT INITIAL.

        READ TABLE lt_municipcode TRANSPORTING NO FIELDS
        WITH KEY mcode = <ls_header>-municipality_code BINARY SEARCH.
        IF sy-subrc = 0.
          ls_wrheader-municipcode          = <ls_header>-municipality_code.
        ELSE.
          lv_header_error = abap_true.
          me->set_response(
            EXPORTING
              iv_wo       = <ls_header>-work_order_number
              iv_msgno    = '013'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_mcode
              iv_msgv2    = <ls_header>-municipality_code
            CHANGING
              cs_response =  es_response
              ct_return   = lt_return
          ).
        ENDIF.
      ENDIF.

      IF <ls_header>-construction_completion_date IS NOT INITIAL.
        ls_wrheader-cdatetimestamp = <ls_header>-construction_completion_date.
        me->convert_timestamp(
          EXPORTING
            iv_input  = <ls_header>-construction_completion_date
          IMPORTING
            ev_date   = ls_wrheader-cdate
        ).
      ENDIF.

      IF <ls_header>-work_release_date IS NOT INITIAL.
        ls_wrheader-rdatetimestamp = <ls_header>-work_release_date.
        me->convert_timestamp(
          EXPORTING
            iv_input  = <ls_header>-work_release_date
          IMPORTING
            ev_date   = ls_wrheader-rdate
      ).
      ENDIF.

      IF <ls_header>-wrtype IS NOT INITIAL.
        ls_wrheader-wrtype        = <ls_header>-wrtype.
        READ TABLE lt_param TRANSPORTING NO FIELDS
        WITH KEY value = ls_wrheader-wrtype BINARY SEARCH.
        IF sy-subrc = 0.
          DATA(lv_restoration) = abap_true.
        ENDIF.
      ENDIF.

      ls_wrheader-sqmile        = <ls_header>-shop_sqmile_value.
      ls_wrheader-sqmiledescr   = <ls_header>-shop_sqmile_desc.
      ls_wrheader-state         = <ls_header>-state.
      ls_wrheader-addr1         = <ls_header>-address.
      ls_wrheader-city          = <ls_header>-city.
      ls_wrheader-cwrno         = <ls_header>-vendor_ref_number.
      ls_wrheader-wrdesc        = <ls_header>-work_order_desc.
      ls_wrheader-wrname        = <ls_header>-work_order_name.
      ls_wrheader-zip           = <ls_header>-zip_code.
      ls_wrheader-zipplus4      = <ls_header>-zip_plus4.
      ls_wrheader-permit_no     = <ls_header>-permit_number.
      ls_wrheader-workcompleted = <ls_header>-work_completed.
      ls_wrheader-erdat         = sy-datum.
      ls_wrheader-ernam         = sy-uname.
      ls_wrheader-status        = gc_status_open.
      ls_wrheader-comments      = <ls_header>-construction_comments.
      ls_wrheader-source        = lv_source.

*Fill the Item structure
      IF <ls_header>-work_action_type = 'C'.

        LOOP AT <ls_header>-writem ASSIGNING <ls_item>.
          lv_item = lv_item + 10.
          ls_writem-wrno          = <ls_header>-work_order_number.
          ls_writem-linenum       = lv_item.
          ls_writem-type          = 'M'.
          IF <ls_item>-material_number IS NOT INITIAL.
            lv_mat = <ls_item>-material_number.
            CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
              EXPORTING
                input        = lv_mat
              IMPORTING
                output       = lv_mat
              EXCEPTIONS
                length_error = 1
                OTHERS       = 2.
            IF sy-subrc = 0.
              ls_writem-itemcode      = lv_mat.
            ENDIF.

          ENDIF.
          IF <ls_item>-cost_object IS NOT INITIAL.
            lv_wo = <ls_item>-cost_object.

            CALL METHOD zclcu_sip_sourcewr=>convert_aufnr_internal
              CHANGING
                cv_aufnr = lv_wo.

            READ TABLE lt_aufk TRANSPORTING NO FIELDS
            WITH KEY aufnr = lv_wo BINARY SEARCH.
            IF sy-subrc = 0.
              ls_writem-woid          = lv_wo.
            ELSE.
              DATA(lv_item_error) = abap_true.
              me->set_response(
                EXPORTING
                  iv_wo       = <ls_header>-work_order_number
                  iv_matno    = <ls_item>-material_number
                  iv_msgno    = '010'
                  iv_msgtyp   = zif_cu_sip=>gc_rejected
                  iv_msgv1    = zif_cu_sip=>gc_costobject
                  iv_msgv2    = <ls_item>-cost_object
                CHANGING
                  cs_response =  es_response
                  ct_return   = lt_return
              ).
            ENDIF.
          ENDIF.
          ls_writem-designqty     = <ls_item>-design_quantity. "#EC CI_CONV_OK
          ls_writem-diglength     = <ls_item>-dig_length.
          ls_writem-digwidth      = <ls_item>-dig_width.
          ls_writem-digfromloc    = <ls_item>-dig_from_loc.
          IF ls_writem-digfromloc IS INITIAL AND
            lv_restoration = abap_true.
            lv_item_error = abap_true.
            me->set_response(
              EXPORTING
                iv_wo       = <ls_header>-work_order_number
                iv_matno    = <ls_item>-material_number
                iv_msgno    = '015'
                iv_msgtyp   = zif_cu_sip=>gc_rejected
                iv_msgv1    = zif_cu_sip=>gc_digfromloc
              CHANGING
                cs_response =  es_response
                ct_return   = lt_return
            ).
          ENDIF.
          ls_writem-digtoloc      = <ls_item>-dig_to_loc.
          IF ls_writem-digtoloc IS INITIAL AND
            lv_restoration = abap_true.
            lv_item_error = abap_true.
            me->set_response(
              EXPORTING
                iv_wo       = <ls_header>-work_order_number
                iv_matno    = <ls_item>-material_number
                iv_msgno    = '015'
                iv_msgtyp   = zif_cu_sip=>gc_rejected
                iv_msgv1    = zif_cu_sip=>gc_digtoloc
              CHANGING
                cs_response =  es_response
                ct_return   = lt_return
            ).
          ENDIF.

          IF lv_item_error = abap_false.
            APPEND ls_writem TO lt_writem_tmp.
          ENDIF.

        ENDLOOP.
      ENDIF.

      IF lv_header_error IS INITIAL AND
         lv_item_error IS INITIAL.
        APPEND ls_wrheader TO lt_wrheader.
        APPEND LINES OF lt_writem_tmp TO lt_writem.

        me->set_response(
          EXPORTING
            iv_wo       = <ls_header>-work_order_number
            iv_msgtyp   = zif_cu_sip=>gc_accepted
          CHANGING
            cs_response =  es_response
            ct_return   = lt_return
        ).
      ENDIF.

      CLEAR: lv_item,
             lv_header_error,
             lv_item_error,
             lv_restoration,
             lt_writem_tmp,
             ls_wrheader,
             ls_writem.
    ENDLOOP.

*Update the Header and Item tables
    IF lt_wrheader IS NOT INITIAL AND
       lt_writem IS NOT INITIAL.
      MODIFY ztcu_wrheader FROM TABLE lt_wrheader.
      IF sy-subrc = 0.
        MODIFY ztcu_writem FROM TABLE lt_writem.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.
    ENDIF.

*Update SLG1 Log
    IF lt_return IS NOT INITIAL.
      NEW zcl_ca_utility_applog( )->create_log(
        EXPORTING
          iv_object   = 'ZCU'
          iv_subobj   = 'SIP'
          iv_external = 'I655'
          it_logs     = lt_return
      ).
    ENDIF.

  ENDMETHOD.


  METHOD set_data_jointuse.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.09.2020
*&  Functional Design Name : Work Request - IR Update
*&  Purpose                : Joint Use
*&  Transport Request No   : D10K936685
*****************************************************************************
    DATA: lv_userid       TYPE xubname,
          lv_usrid_hr     TYPE sysid,
          lv_plant        TYPE werks_d,
          lv_cocode       TYPE bukrs,
          lv_wrno         TYPE z_wrno,
          lv_ir           TYPE z_irno,
          lv_mcode        TYPE z_municipality_code,
          lt_wrno         TYPE STANDARD TABLE OF z_wrno,
          lt_userid       TYPE STANDARD TABLE OF xubname,
          lt_usrid_hr     TYPE STANDARD TABLE OF sysid,
          lt_plant        TYPE STANDARD TABLE OF werks_d,
          lt_cocode       TYPE STANDARD TABLE OF bukrs,
          lt_ir           TYPE STANDARD TABLE OF z_irno,
          lt_wriritem     TYPE STANDARD TABLE OF ztcu_wriritem,
          lt_wriritem_tmp TYPE STANDARD TABLE OF ztcu_wriritem,
          lt_wrirheader   TYPE STANDARD TABLE OF ztcu_wrirheader,
          lt_mcode        TYPE STANDARD TABLE OF z_municipality_code,
          lt_return       TYPE bapiret2_t,
          ls_wriritem     TYPE ztcu_wriritem,
          ls_wrirheader   TYPE ztcu_wrirheader.


    CLEAR es_output.

    LOOP AT is_input-ecc_joint_use-joint_use_header ASSIGNING FIELD-SYMBOL(<ls_input>).
      IF <ls_input>-company_code IS NOT INITIAL.
        lv_cocode = <ls_input>-company_code.
        APPEND lv_cocode TO lt_cocode.
      ENDIF.

      IF <ls_input>-desginer_id  IS NOT INITIAL.
        lv_userid = <ls_input>-desginer_id.
        APPEND lv_userid TO lt_userid.

        lv_usrid_hr = <ls_input>-desginer_id.
        APPEND lv_usrid_hr TO lt_usrid_hr.
      ENDIF.

      IF lt_usrid_hr IS NOT INITIAL.
        SELECT usrid
          FROM pa0105
          INTO TABLE @DATA(lt_pa0105)
          FOR ALL ENTRIES IN @lt_usrid_hr
          WHERE usrid = @lt_usrid_hr-table_line.
        IF sy-subrc = 0.
          SORT lt_pa0105 BY usrid.
        ENDIF.
      ENDIF.

      IF <ls_input>-plant IS NOT INITIAL.
        lv_plant = <ls_input>-plant.
        APPEND lv_plant TO lt_plant.
      ENDIF.

      IF <ls_input>-work_order_number IS NOT INITIAL.
        lv_wrno = <ls_input>-work_order_number.
        APPEND lv_wrno TO lt_wrno.
      ENDIF.

      IF <ls_input>-municipality_code IS NOT INITIAL.
        lv_mcode = <ls_input>-municipality_code.

        IF lv_mcode = <ls_input>-municipality_code.
          APPEND lv_mcode TO lt_mcode.
        ENDIF.
      ENDIF.

      LOOP AT <ls_input>-joint_use_item-irnumber ASSIGNING FIELD-SYMBOL(<ls_ir>).
        lv_ir = <ls_ir>.
        APPEND lv_ir TO lt_ir.
      ENDLOOP.
    ENDLOOP.

*Master table
    IF lt_cocode IS NOT INITIAL.
      SELECT bukrs
        FROM t001
        INTO TABLE @DATA(lt_t001)
        FOR ALL ENTRIES IN @lt_cocode
        WHERE bukrs = @lt_cocode-table_line.
      IF sy-subrc = 0.
        SORT lt_t001 BY bukrs.
      ENDIF.
    ENDIF.

    IF lt_userid IS NOT INITIAL.
      SELECT bname
        FROM usr02
        INTO TABLE @DATA(lt_usr02)
        FOR ALL ENTRIES IN @lt_userid
        WHERE bname = @lt_userid-table_line.
      IF sy-subrc = 0.
        SORT lt_usr02 BY bname.
      ENDIF.
    ENDIF.

    IF lt_plant IS NOT INITIAL.
      SELECT werks
        FROM t001w
        INTO TABLE @DATA(lt_t001w)
        FOR ALL ENTRIES IN @lt_plant
        WHERE werks = @lt_plant-table_line.
      IF sy-subrc = 0.
        SORT lt_t001w BY werks.
      ENDIF.
    ENDIF.

    IF lt_wrno IS NOT INITIAL.
      SELECT wrno
        FROM ztcu_wrheader
        INTO TABLE @DATA(lt_wr)
        FOR ALL ENTRIES IN @lt_wrno
        WHERE wrno = @lt_wrno-table_line.
      IF sy-subrc = 0.
        SORT lt_wr BY wrno.
      ENDIF.
    ENDIF.

    IF lt_ir IS NOT INITIAL.
      SELECT irno                                       "#EC CI_NOFIRST
        FROM ztcu_wriritem
        INTO TABLE @DATA(lt_wrir)
        FOR ALL ENTRIES IN @lt_ir
        WHERE irno = @lt_ir-table_line.
      IF sy-subrc = 0.
        SORT lt_wrir BY irno.
      ENDIF.
    ENDIF.

    IF lt_mcode IS NOT INITIAL.
      SELECT mcode
        FROM ztcu_communicode
        INTO TABLE @DATA(lt_municipcode)
        FOR ALL ENTRIES IN @lt_mcode
        WHERE mcode = @lt_mcode-table_line AND
              validfrom LE @sy-datum AND
              validto   GE @sy-datum.
      IF sy-subrc = 0.
        SORT lt_municipcode BY mcode.
      ENDIF.
    ENDIF.

    LOOP AT is_input-ecc_joint_use-joint_use_header ASSIGNING <ls_input>.
      IF <ls_input>-work_order_number IS NOT INITIAL.
        ls_wrirheader-wrno = <ls_input>-work_order_number.
      ENDIF.

      IF <ls_input>-plant IS NOT INITIAL.
        READ TABLE lt_t001w TRANSPORTING NO FIELDS
        WITH KEY werks = <ls_input>-plant BINARY SEARCH ##WARN_OK.
        IF sy-subrc = 0.
          ls_wrirheader-plant = <ls_input>-plant.
        ELSE.
          DATA(lv_header_error) = abap_true.
          me->set_response_jointuse(
            EXPORTING
              iv_wo       = <ls_input>-work_order_number
              iv_msgno    = '010'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_plant
              iv_msgv2    = <ls_input>-plant
            CHANGING
              cs_response =  es_output
              ct_return   = lt_return
          ).
        ENDIF.
      ENDIF.

      IF <ls_input>-desginer_id IS NOT INITIAL.
        READ TABLE lt_usr02 TRANSPORTING NO FIELDS
        WITH KEY bname = <ls_input>-desginer_id BINARY SEARCH ##WARN_OK.
        IF sy-subrc = 0.
          ls_wrirheader-novellid = <ls_input>-desginer_id.
        ELSE.
          READ TABLE lt_pa0105 TRANSPORTING NO FIELDS
         WITH KEY usrid = <ls_input>-desginer_id BINARY SEARCH ##WARN_OK.
          IF sy-subrc = 0.
            ls_wrirheader-novellid      = <ls_input>-desginer_id.
          ENDIF.
        ENDIF.
        IF ls_wrirheader-novellid IS INITIAL.
          lv_header_error = abap_true.
          me->set_response_jointuse(
            EXPORTING
              iv_wo       = <ls_input>-work_order_number
              iv_msgno    = '013'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_designer_id
              iv_msgv2    = <ls_input>-desginer_id
            CHANGING
              cs_response =  es_output
              ct_return   = lt_return
          ).
        ENDIF.
      ENDIF.

      IF <ls_input>-municipality_code IS NOT INITIAL.
        READ TABLE lt_municipcode TRANSPORTING NO FIELDS
        WITH KEY mcode = <ls_input>-municipality_code BINARY SEARCH ##WARN_OK.
        IF sy-subrc = 0.
          ls_wrirheader-municipcode = <ls_input>-municipality_code.
        ELSE.
          lv_header_error = abap_true.
          me->set_response_jointuse(
            EXPORTING
              iv_wo       = <ls_input>-work_order_number
              iv_msgno    = '013'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_mcode
              iv_msgv2    = <ls_input>-municipality_code
            CHANGING
              cs_response =  es_output
              ct_return   = lt_return
          ).
        ENDIF.
      ENDIF.

      IF <ls_input>-company_code IS NOT INITIAL.
        READ TABLE lt_t001 TRANSPORTING NO FIELDS
        WITH KEY bukrs = <ls_input>-company_code BINARY SEARCH.
        IF sy-subrc = 0.
          ls_wrirheader-bussunit    = <ls_input>-company_code.
        ELSE.
          lv_header_error = abap_true.
          me->set_response_jointuse(
          EXPORTING
          iv_wo       = <ls_input>-work_order_number
          iv_msgno    = '010'
          iv_msgtyp   = zif_cu_sip=>gc_rejected
          iv_msgv1    = 'Company Code'
          iv_msgv2    = <ls_input>-company_code
          CHANGING
          cs_response = es_output
          ct_return   = lt_return
          ).
        ENDIF.
      ENDIF.

      IF <ls_input>-construction_completion_date IS NOT INITIAL.
        me->convert_timestamp(
          EXPORTING
            iv_input  = <ls_input>-construction_completion_date
          IMPORTING
            ev_output = ls_wrirheader-cdate
        ).
      ENDIF.

      ls_wrirheader-address     = <ls_input>-address.
      ls_wrirheader-city        = <ls_input>-city.
      ls_wrirheader-state       = <ls_input>-state.
      ls_wrirheader-wrdesc      = <ls_input>-work_order_desc.
      ls_wrirheader-wrname      = <ls_input>-work_order_name.
      ls_wrirheader-zip         = <ls_input>-zip_code.
      ls_wrirheader-zipplus4    = <ls_input>-zip_plus4.
      ls_wrirheader-municipcode = <ls_input>-municipality_code.

      LOOP AT <ls_input>-joint_use_item-irnumber ASSIGNING <ls_ir>.
        IF <ls_ir> IS NOT INITIAL.
          READ TABLE lt_wrir TRANSPORTING NO FIELDS
          WITH KEY irno = <ls_ir> BINARY SEARCH ##WARN_OK.
          IF sy-subrc <> 0.
            ls_wriritem-wrno = <ls_input>-work_order_number.
            ls_wriritem-irno = <ls_ir>.

            APPEND ls_wriritem TO lt_wriritem_tmp.
          ELSE.
            DATA(lv_ir_error) = abap_true.
            me->set_response_jointuse(
              EXPORTING
                iv_wo       = <ls_input>-work_order_number
                iv_ir       = <ls_ir>
                iv_msgno    = '014'
                iv_msgtyp   = zif_cu_sip=>gc_rejected
                iv_msgv1    = <ls_ir>
              CHANGING
                cs_response =  es_output
                ct_return   = lt_return
                            ).
          ENDIF.
        ELSE.
          lv_ir_error = abap_true.
          me->set_response_jointuse(
            EXPORTING
              iv_wo       = <ls_input>-work_order_number
              iv_ir       = <ls_ir>
              iv_msgno    = '015'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = 'IR Number'
            CHANGING
              cs_response =  es_output
              ct_return   = lt_return
                          ).
        ENDIF.
      ENDLOOP.

      IF lv_header_error IS INITIAL AND
         lv_ir_error IS INITIAL .
        APPEND ls_wrirheader TO lt_wrirheader.
        APPEND LINES OF lt_wriritem_tmp TO lt_wriritem.

        me->set_response_jointuse(
          EXPORTING
            iv_wo       = <ls_input>-work_order_number
            iv_msgtyp   = zif_cu_sip=>gc_accepted
          CHANGING
            cs_response =  es_output
            ct_return   = lt_return
                        ).
      ENDIF.

      CLEAR: lv_header_error,
             lv_ir_error,
             ls_wrirheader,
             ls_wriritem,
             lt_wriritem_tmp.
    ENDLOOP.

*Update the Header and Item tables
    IF lt_wrirheader IS NOT INITIAL AND
       lt_wriritem IS NOT INITIAL.
      MODIFY ztcu_wrirheader FROM TABLE lt_wrirheader.
      IF sy-subrc = 0.
        INSERT ztcu_wriritem FROM TABLE lt_wriritem.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.
    ENDIF.

*Update SLG1 Log
    IF lt_return IS NOT INITIAL.
      NEW zcl_ca_utility_applog( )->create_log(
        EXPORTING
          iv_object   = 'ZCU'
          iv_subobj   = 'SIP'
          iv_external = 'I658'
          it_logs     = lt_return
      ).
    ENDIF.
  ENDMETHOD.


  METHOD set_data_maximo.
***********************************************************************
*  Method:      SET_DATA_MAXIMO                                       *
*  Overview:    Work Request Master Data - Maximo                     *
*  Author:      Vignesh Sunkasi                                       *
*  Create Date: 10/10/2020                                            *
*  Comments:    Get the WR master data from Maximo and update         *
*               the corresponding custom tables                       *
***********************************************************************
*  CHANGE HISTORY:                                                    *
*   1           C144096     Desc- D10K941249/Work Description field
*                                 optional/TFS 2785                   *
*   2           C144096     Desc-D10K941283/Work items should be
*                                optional/TFS 2845                    *
***********************************************************************
    DATA:
      "Variable
      lv_item       TYPE i,
      lv_vendor     TYPE lifnr,
      lv_userid     TYPE xubname,
      lv_plant      TYPE werks_d,
      lv_wo         TYPE aufnr,
      lv_mat        TYPE matnr,
      lv_cocode     TYPE bukrs,
      lv_wrno       TYPE z_wrno,
      lv_mcode      TYPE z_municipality_code,
      "Internal Table
      lt_wrheader   TYPE STANDARD TABLE OF ztcu_wrheader,
      lt_writem     TYPE STANDARD TABLE OF ztcu_writem,
      lt_writem_tmp TYPE STANDARD TABLE OF ztcu_writem,
      lt_wrno       TYPE STANDARD TABLE OF z_wrno,
      lt_vendor     TYPE STANDARD TABLE OF lifnr,
      lt_userid     TYPE STANDARD TABLE OF xubname,
      lt_plant      TYPE STANDARD TABLE OF werks_d,
      lt_wo         TYPE STANDARD TABLE OF aufnr,
      lt_mat        TYPE STANDARD TABLE OF matnr,
      lt_cocode     TYPE STANDARD TABLE OF bukrs,
      lt_mcode      TYPE STANDARD TABLE OF z_municipality_code,
      lt_return     TYPE bapiret2_t,
      "WorkArea
      ls_wrheader   TYPE ztcu_wrheader,
      ls_writem     TYPE ztcu_writem.

    CLEAR es_output.

*Get the source
    READ TABLE is_input-ecc_work_order-control ASSIGNING FIELD-SYMBOL(<ls_control>)
    INDEX 1.
    IF sy-subrc = 0.
      DATA(lv_source) = <ls_control>-sender.
    ENDIF.

*Fill the response control structure
    APPEND INITIAL LINE TO es_output-ecc_woresponse-control
    ASSIGNING FIELD-SYMBOL(<ls_control_response>).
    IF <ls_control_response> IS ASSIGNED.
      <ls_control_response>-receiver = lv_source.
    ENDIF.

*Validations
    LOOP AT is_input-ecc_work_order-worecord ASSIGNING FIELD-SYMBOL(<ls_header>).
      IF <ls_header>-work_id IS NOT INITIAL.
        lv_wrno = <ls_header>-work_id.
        APPEND lv_wrno TO lt_wrno.
      ENDIF.

      IF <ls_header>-sapvendor_number IS NOT INITIAL.
        lv_vendor = <ls_header>-sapvendor_number.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_vendor
          IMPORTING
            output = lv_vendor.

        APPEND lv_vendor TO lt_vendor.
      ENDIF.

      IF <ls_header>-designer_id IS NOT INITIAL.
        lv_userid = <ls_header>-designer_id.
        APPEND lv_userid TO lt_userid.
      ENDIF.

      IF <ls_header>-project_owner IS NOT INITIAL.
        lv_userid = <ls_header>-project_owner.
        APPEND lv_userid TO lt_userid.
      ENDIF.

      IF <ls_header>-plant IS NOT INITIAL.
        lv_plant = <ls_header>-plant.
        APPEND lv_plant TO lt_plant.
      ENDIF.

      IF <ls_header>-pmwork_order_id IS NOT INITIAL.
        lv_wo = <ls_header>-pmwork_order_id.

        APPEND lv_wo TO lt_wo.
      ENDIF.

      IF <ls_header>-company_code IS NOT INITIAL.
        lv_cocode = <ls_header>-company_code.
        APPEND lv_cocode TO lt_cocode.
      ENDIF.

      IF <ls_header>-municipality_code IS NOT INITIAL.
        lv_mcode = <ls_header>-municipality_code.
        APPEND lv_mcode TO lt_mcode.
      ENDIF.

      LOOP AT <ls_header>-woitem ASSIGNING FIELD-SYMBOL(<ls_item>).
        IF <ls_item>-material_number IS NOT INITIAL.
          lv_mat = <ls_item>-material_number.
          CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
            EXPORTING
              input        = lv_mat
            IMPORTING
              output       = lv_mat
            EXCEPTIONS
              length_error = 1
              OTHERS       = 2.
          IF sy-subrc = 0.
            APPEND lv_mat TO lt_mat.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDLOOP.

*Master table
    IF lt_wrno IS NOT INITIAL.
      SELECT wrno
        FROM ztcu_wrheader
        INTO TABLE @DATA(lt_wr)
        FOR ALL ENTRIES IN @lt_wrno
        WHERE wrno = @lt_wrno-table_line.
      IF sy-subrc = 0.
        SORT lt_wr BY wrno.
      ENDIF.
    ENDIF.

    IF lt_vendor IS NOT INITIAL.
      SELECT lifnr
        FROM lfa1
        INTO TABLE @DATA(lt_lfa1)
        FOR ALL ENTRIES IN @lt_vendor
        WHERE lifnr = @lt_vendor-table_line.
      IF sy-subrc = 0.
        SORT lt_lfa1 BY lifnr.
      ENDIF.
    ENDIF.

    IF lt_userid IS NOT INITIAL.
      SELECT bname
        FROM usr02
        INTO TABLE @DATA(lt_usr02)
        FOR ALL ENTRIES IN @lt_userid
        WHERE bname = @lt_userid-table_line.
      IF sy-subrc = 0.
        SORT lt_usr02 BY bname.
      ENDIF.
    ENDIF.

    IF lt_plant IS NOT INITIAL.
      SELECT werks
        FROM t001w
        INTO TABLE @DATA(lt_t001w)
        FOR ALL ENTRIES IN @lt_plant
        WHERE werks = @lt_plant-table_line.
      IF sy-subrc = 0.
        SORT lt_t001w BY werks.
      ENDIF.
    ENDIF.

    IF lt_wo IS NOT INITIAL.
      SELECT aufnr
        FROM aufk
        INTO TABLE @DATA(lt_aufk)
        FOR ALL ENTRIES IN @lt_wo
        WHERE aufnr = @lt_wo-table_line.
      IF sy-subrc = 0.
        SORT lt_aufk BY aufnr.
      ENDIF.
    ENDIF.

    IF lt_aufk IS NOT INITIAL.
      SELECT a~aufnr,
             a~aufpl,
             b~vornr
        FROM afko AS a
        INNER JOIN afvc AS b
        ON a~aufpl = b~aufpl
        INTO TABLE @DATA(lt_operations)
        FOR ALL ENTRIES IN @lt_aufk
        WHERE a~aufnr = @lt_aufk-aufnr.
      IF sy-subrc = 0.
        SORT lt_operations BY aufnr vornr.
      ENDIF.
    ENDIF.

    IF lt_mat IS NOT INITIAL.
      SELECT matnr
        FROM mara
        INTO TABLE @DATA(lt_mara)
        FOR ALL ENTRIES IN @lt_mat
        WHERE matnr = @lt_mat-table_line.
      IF sy-subrc = 0.
        SORT lt_mara BY matnr.
      ENDIF.
    ENDIF.

    IF lt_cocode IS NOT INITIAL.
      SELECT bukrs
        FROM t001
        INTO TABLE @DATA(lt_t001)
        FOR ALL ENTRIES IN @lt_cocode
        WHERE bukrs = @lt_cocode-table_line.
      IF sy-subrc = 0.
        SORT lt_t001 BY bukrs.
      ENDIF.
    ENDIF.

    IF lt_mcode IS NOT INITIAL.
      SELECT mcode
        FROM ztcu_communicode
        INTO TABLE @DATA(lt_municipcode)
        FOR ALL ENTRIES IN @lt_mcode
        WHERE mcode = @lt_mcode-table_line AND
              validfrom LE @sy-datum AND
              validto   GE @sy-datum.
      IF sy-subrc = 0.
        SORT lt_municipcode BY mcode.
      ENDIF.
    ENDIF.

*Fill the header structur
    LOOP AT is_input-ecc_work_order-worecord ASSIGNING <ls_header>.
      "Work ID
      IF <ls_header>-work_id IS NOT INITIAL.
        READ TABLE lt_wr TRANSPORTING NO FIELDS
        WITH KEY wrno = <ls_header>-work_id BINARY SEARCH ##WARN_OK.
        IF sy-subrc <> 0.
          ls_wrheader-wrno      = <ls_header>-work_id.
        ELSE.
          DATA(lv_header_error) = abap_true.
          me->set_response_maximo(
            EXPORTING
              iv_wo       = <ls_header>-work_id
              iv_pmwo     = <ls_header>-pmwork_order_id
              iv_msgno    = '025'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = <ls_header>-work_id
            CHANGING
              cs_response = es_output
              ct_return   = lt_return
          ).
        ENDIF.
      ELSE.
        lv_header_error = abap_true.
        me->set_response_maximo(
          EXPORTING
            iv_wo       = <ls_header>-work_id
            iv_pmwo     = <ls_header>-pmwork_order_id
            iv_msgno    = '015'
            iv_msgtyp   = zif_cu_sip=>gc_rejected
            iv_msgv1    = 'Work Id'
          CHANGING
            cs_response = es_output
            ct_return   = lt_return
        ).
      ENDIF.

      "SAP Vendor Number
      IF <ls_header>-sapvendor_number IS NOT INITIAL.
        lv_vendor = <ls_header>-sapvendor_number.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_vendor
          IMPORTING
            output = lv_vendor.

        READ TABLE lt_lfa1 TRANSPORTING NO FIELDS
        WITH KEY lifnr = lv_vendor BINARY SEARCH.
        IF sy-subrc = 0.
          ls_wrheader-suppliercompany      = lv_vendor.
        ELSE.
          lv_header_error = abap_true.
          me->set_response_maximo(
            EXPORTING
              iv_wo       = <ls_header>-work_id
              iv_pmwo     = <ls_header>-pmwork_order_id
              iv_msgno    = '010'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_sap_vendor_number
              iv_msgv2    = <ls_header>-sapvendor_number
            CHANGING
              cs_response = es_output
              ct_return   = lt_return
          ).
        ENDIF.
      ELSE.
        lv_header_error = abap_true.
        me->set_response_maximo(
          EXPORTING
            iv_wo       = <ls_header>-work_id
            iv_pmwo     = <ls_header>-pmwork_order_id
            iv_msgno    = '015'
            iv_msgtyp   = zif_cu_sip=>gc_rejected
            iv_msgv1    = zif_cu_sip=>gc_sap_vendor_number
          CHANGING
            cs_response = es_output
            ct_return   = lt_return
        ).
      ENDIF.

      "Designer ID
      IF <ls_header>-designer_id IS NOT INITIAL.
        READ TABLE lt_usr02 TRANSPORTING NO FIELDS
        WITH KEY bname = <ls_header>-designer_id BINARY SEARCH ##WARN_OK.
        IF sy-subrc = 0.
          ls_wrheader-novellid      = <ls_header>-designer_id.
        ELSE.
          lv_header_error = abap_true.
          me->set_response_maximo(
            EXPORTING
              iv_wo       = <ls_header>-work_id
              iv_pmwo     = <ls_header>-pmwork_order_id
              iv_msgno    = '013'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_designer_id
              iv_msgv2    = <ls_header>-designer_id
            CHANGING
              cs_response = es_output
              ct_return   = lt_return
          ).
        ENDIF.
      ELSE.
        lv_header_error = abap_true.
        me->set_response_maximo(
          EXPORTING
            iv_wo       = <ls_header>-work_id
            iv_pmwo     = <ls_header>-pmwork_order_id
            iv_msgno    = '015'
            iv_msgtyp   = zif_cu_sip=>gc_rejected
            iv_msgv1    = zif_cu_sip=>gc_designer_id
          CHANGING
            cs_response = es_output
            ct_return   = lt_return
        ).
      ENDIF.

      "Project Owner
      IF <ls_header>-project_owner IS NOT INITIAL.
        READ TABLE lt_usr02 TRANSPORTING NO FIELDS
        WITH KEY bname = <ls_header>-project_owner BINARY SEARCH ##WARN_OK.
        IF sy-subrc = 0.
          ls_wrheader-projectowner      = <ls_header>-project_owner.
        ELSE.
          lv_header_error = abap_true.
          me->set_response_maximo(
            EXPORTING
              iv_wo       = <ls_header>-work_id
              iv_pmwo     = <ls_header>-pmwork_order_id
              iv_msgno    = '013'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_projectowner
              iv_msgv2    = <ls_header>-project_owner
            CHANGING
              cs_response = es_output
              ct_return   = lt_return
          ).
        ENDIF.
      ENDIF.

      "Plant
      IF <ls_header>-plant IS NOT INITIAL.
        READ TABLE lt_t001w TRANSPORTING NO FIELDS
        WITH KEY werks = <ls_header>-plant BINARY SEARCH ##WARN_OK.
        IF sy-subrc = 0.
          ls_wrheader-operdistrict  = <ls_header>-plant.
        ELSE.
          lv_header_error = abap_true.
          me->set_response_maximo(
            EXPORTING
              iv_wo       = <ls_header>-work_id
              iv_pmwo     = <ls_header>-pmwork_order_id
              iv_msgno    = '010'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_plant
              iv_msgv2    = <ls_header>-plant
            CHANGING
              cs_response = es_output
              ct_return   = lt_return
          ).
        ENDIF.
      ELSE.
        lv_header_error = abap_true.
        me->set_response_maximo(
          EXPORTING
            iv_wo       = <ls_header>-work_id
            iv_pmwo     = <ls_header>-pmwork_order_id
            iv_msgno    = '015'
            iv_msgtyp   = zif_cu_sip=>gc_rejected
            iv_msgv1    = zif_cu_sip=>gc_plant
          CHANGING
            cs_response = es_output
            ct_return   = lt_return
        ).
      ENDIF.

      "PM Work Order ID
      IF <ls_header>-pmwork_order_id IS NOT INITIAL.
        lv_wo = <ls_header>-pmwork_order_id.

        READ TABLE lt_aufk TRANSPORTING NO FIELDS
        WITH KEY aufnr = lv_wo BINARY SEARCH.
        IF sy-subrc = 0.
          ls_wrheader-woid        = lv_wo.
        ELSE.
          lv_header_error = abap_true.
          me->set_response_maximo(
            EXPORTING
              iv_wo       = <ls_header>-work_id
              iv_pmwo     = <ls_header>-pmwork_order_id
              iv_msgno    = '010'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_pmwoid
              iv_msgv2    = <ls_header>-pmwork_order_id
            CHANGING
              cs_response = es_output
              ct_return   = lt_return
          ).
        ENDIF.
      ELSE.
        lv_header_error = abap_true.
        me->set_response_maximo(
          EXPORTING
            iv_wo       = <ls_header>-work_id
            iv_pmwo     = <ls_header>-pmwork_order_id
            iv_msgno    = '015'
            iv_msgtyp   = zif_cu_sip=>gc_rejected
            iv_msgv1    = zif_cu_sip=>gc_pmwoid
          CHANGING
            cs_response = es_output
            ct_return   = lt_return
        ).
      ENDIF.

      "Operation
      IF <ls_header>-operation IS NOT INITIAL AND
         <ls_header>-pmwork_order_id IS NOT INITIAL.
        lv_wo = <ls_header>-pmwork_order_id.

        READ TABLE lt_operations TRANSPORTING NO FIELDS
        WITH KEY aufnr = lv_wo
                 vornr = <ls_header>-operation BINARY SEARCH.
        IF sy-subrc = 0.
          ls_wrheader-pmoperation        = <ls_header>-operation.
        ELSE.
          lv_header_error = abap_true.
          me->set_response_maximo(
            EXPORTING
              iv_wo       = <ls_header>-work_id
              iv_pmwo     = <ls_header>-pmwork_order_id
              iv_msgno    = '010'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_operations
              iv_msgv2    = <ls_header>-operation
            CHANGING
              cs_response = es_output
              ct_return   = lt_return
          ).
        ENDIF.
      ELSE.
        lv_header_error = abap_true.
        me->set_response_maximo(
         EXPORTING
           iv_wo       = <ls_header>-work_id
           iv_pmwo     = <ls_header>-pmwork_order_id
           iv_msgno    = '015'
           iv_msgtyp   = zif_cu_sip=>gc_rejected
           iv_msgv1    = zif_cu_sip=>gc_operations
         CHANGING
           cs_response = es_output
           ct_return   = lt_return
        ).
      ENDIF.

      "Company Code
      IF <ls_header>-company_code IS NOT INITIAL.
        READ TABLE lt_t001 TRANSPORTING NO FIELDS
        WITH KEY bukrs = <ls_header>-company_code BINARY SEARCH ##WARN_OK.
        IF sy-subrc = 0.
          ls_wrheader-bussunit      = <ls_header>-company_code.
        ELSE.
          lv_header_error = abap_true.
          me->set_response_maximo(
            EXPORTING
              iv_wo       = <ls_header>-work_id
              iv_pmwo     = <ls_header>-pmwork_order_id
              iv_msgno    = '010'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_companycode
              iv_msgv2    = <ls_header>-company_code
            CHANGING
              cs_response = es_output
              ct_return   = lt_return
          ).
        ENDIF.
      ELSE.
        lv_header_error = abap_true.
        me->set_response_maximo(
          EXPORTING
            iv_wo       = <ls_header>-work_id
            iv_pmwo     = <ls_header>-pmwork_order_id
            iv_msgno    = '015'
            iv_msgtyp   = zif_cu_sip=>gc_rejected
            iv_msgv1    = zif_cu_sip=>gc_companycode
          CHANGING
            cs_response = es_output
            ct_return   = lt_return
        ).
      ENDIF.

      "Municipality Code
      IF <ls_header>-municipality_code IS NOT INITIAL.
        lv_mcode = <ls_header>-municipality_code.

        READ TABLE lt_municipcode TRANSPORTING NO FIELDS
        WITH KEY mcode = lv_mcode BINARY SEARCH.
        IF sy-subrc = 0.
          ls_wrheader-municipcode          = lv_mcode.
        ELSE.
          lv_header_error = abap_true.
          me->set_response_maximo(
            EXPORTING
              iv_wo       = <ls_header>-work_id
              iv_pmwo     = <ls_header>-pmwork_order_id
              iv_msgno    = '010'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_mcode
              iv_msgv2    = <ls_header>-municipality_code
            CHANGING
              cs_response = es_output
              ct_return   = lt_return
          ).
        ENDIF.
      ENDIF.

      IF <ls_header>-work_release_date IS NOT INITIAL.
        ls_wrheader-rdatetimestamp = <ls_header>-work_release_date.
        me->convert_timestamp(
          EXPORTING
            iv_input  = <ls_header>-work_release_date
          IMPORTING
            ev_date   = ls_wrheader-rdate
      ).
      ELSE.
        lv_header_error = abap_true.
        me->set_response_maximo(
          EXPORTING
            iv_wo       = <ls_header>-work_id
            iv_pmwo     = <ls_header>-pmwork_order_id
            iv_msgno    = '015'
            iv_msgtyp   = zif_cu_sip=>gc_rejected
            iv_msgv1    = 'Work Release Date'
          CHANGING
            cs_response = es_output
            ct_return   = lt_return
        ).
      ENDIF.

      "WO Type
      IF <ls_header>-wotype IS NOT INITIAL.
        ls_wrheader-wrtype        = <ls_header>-wotype.
        IF ls_wrheader-wrtype = zif_cu_sip=>gc_restoration-restor_lower OR
           ls_wrheader-wrtype = zif_cu_sip=>gc_restoration-restor_upper.
          DATA(lv_restoration) = abap_true.
        ENDIF.
      ELSE.
        lv_header_error = abap_true.
        me->set_response_maximo(
          EXPORTING
            iv_wo       = <ls_header>-work_id
            iv_pmwo     = <ls_header>-pmwork_order_id
            iv_msgno    = '015'
            iv_msgtyp   = zif_cu_sip=>gc_rejected
            iv_msgv1    = 'WO Type'
          CHANGING
            cs_response = es_output
            ct_return   = lt_return
        ).
      ENDIF.

      IF <ls_header>-address IS NOT INITIAL.
        ls_wrheader-addr1         = <ls_header>-address.
      ELSE.
        lv_header_error = abap_true.
        me->set_response_maximo(
          EXPORTING
            iv_wo       = <ls_header>-work_id
            iv_pmwo     = <ls_header>-pmwork_order_id
            iv_msgno    = '015'
            iv_msgtyp   = zif_cu_sip=>gc_rejected
            iv_msgv1    = 'Address'
          CHANGING
            cs_response = es_output
            ct_return   = lt_return
        ).
      ENDIF.

      IF <ls_header>-work_description IS NOT INITIAL.
        ls_wrheader-wrdesc        = <ls_header>-work_description.
*Start of changes by C144096 for TFS 2785
*      ELSE.
*        lv_header_error = abap_true.
*        me->set_response_maximo(
*          EXPORTING
*            iv_wo       = <ls_header>-work_id
*            iv_pmwo     = <ls_header>-pmwork_order_id
*            iv_msgno    = '015'
*            iv_msgtyp   = zif_cu_sip=>gc_rejected
*            iv_msgv1    = 'Work Description'
*          CHANGING
*            cs_response = es_output
*            ct_return   = lt_return
*        ).
*End of changes by C144096  for TFS 2785
      ENDIF.

      IF <ls_header>-work_name IS NOT INITIAL.
        ls_wrheader-wrname        = <ls_header>-work_name.
      ELSE.
        lv_header_error = abap_true.
        me->set_response_maximo(
          EXPORTING
            iv_wo       = <ls_header>-work_id
            iv_pmwo     = <ls_header>-pmwork_order_id
            iv_msgno    = '015'
            iv_msgtyp   = zif_cu_sip=>gc_rejected
            iv_msgv1    = 'Work Name'
          CHANGING
            cs_response = es_output
            ct_return   = lt_return
        ).
      ENDIF.

      ls_wrheader-sqmile        = <ls_header>-shop_sqmile_value.
      ls_wrheader-sqmiledescr   = <ls_header>-shop_sqmile_desc.
      ls_wrheader-state         = <ls_header>-state.
      ls_wrheader-city          = <ls_header>-city.
      ls_wrheader-cwrno         = <ls_header>-vendor_ref_number.
      ls_wrheader-zip           = <ls_header>-zip_code.
      ls_wrheader-zipplus4      = <ls_header>-zip_plus4.
      ls_wrheader-township      = <ls_header>-township.
      ls_wrheader-wosubtype     = <ls_header>-wosub_type.
      ls_wrheader-erdat         = sy-datum.
      ls_wrheader-ernam         = sy-uname.
      ls_wrheader-status        = gc_status_open.
      ls_wrheader-comments      = <ls_header>-construction_comments.
      ls_wrheader-source        = lv_source.

*Fill Permits number
      LOOP AT <ls_header>-permits ASSIGNING FIELD-SYMBOL(<ls_permits>).
        IF ls_wrheader-permit_no IS INITIAL.
          ls_wrheader-permit_no = <ls_permits>-permit_number.
        ELSE.
          CONCATENATE ls_wrheader-permit_no <ls_permits>-permit_number
          INTO ls_wrheader-permit_no SEPARATED BY ','.
        ENDIF.
      ENDLOOP.

*Fill the Item structure
      LOOP AT <ls_header>-woitem ASSIGNING <ls_item>.
        lv_item = lv_item + 10.
        ls_writem-wrno          = <ls_header>-work_id.
        ls_writem-linenum       = lv_item.
        ls_writem-type          = 'M'.
        IF <ls_item>-material_number IS NOT INITIAL.
          lv_mat = <ls_item>-material_number.
          CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
            EXPORTING
              input        = lv_mat
            IMPORTING
              output       = lv_mat
            EXCEPTIONS
              length_error = 1
              OTHERS       = 2.
          IF sy-subrc <> 0.
            CLEAR lv_mat.
          ENDIF.

          READ TABLE lt_mara TRANSPORTING NO FIELDS
          WITH KEY matnr =  lv_mat BINARY SEARCH.
          IF sy-subrc = 0.
            ls_writem-itemcode      = lv_mat.
          ELSE.
            DATA(lv_item_error) = abap_true.
            me->set_response_maximo(
              EXPORTING
                iv_wo       = <ls_header>-work_id
                iv_pmwo     = <ls_header>-pmwork_order_id
                iv_matno    = <ls_item>-material_number
                iv_msgno    = '010'
                iv_msgtyp   = zif_cu_sip=>gc_rejected
                iv_msgv1    = zif_cu_sip=>gc_materialnumber
                iv_msgv2    = <ls_item>-material_number
              CHANGING
                cs_response = es_output
                ct_return   = lt_return
            ).
          ENDIF.
        ELSE.
          lv_item_error = abap_true.
          me->set_response_maximo(
            EXPORTING
              iv_wo       = <ls_header>-work_id
              iv_pmwo     = <ls_header>-pmwork_order_id
              iv_matno    = <ls_item>-material_number
              iv_msgno    = '015'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_materialnumber
            CHANGING
              cs_response = es_output
              ct_return   = lt_return
          ).
        ENDIF.

        IF <ls_item>-design_quantity IS NOT INITIAL.
          ls_writem-designqty     = <ls_item>-design_quantity. "#EC CI_CONV_OK
        ELSE.
          lv_item_error = abap_true.
          me->set_response_maximo(
            EXPORTING
              iv_wo       = <ls_header>-work_id
              iv_pmwo     = <ls_header>-pmwork_order_id
              iv_matno    = <ls_item>-material_number
              iv_msgno    = '015'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = 'Design Quantity'
            CHANGING
              cs_response = es_output
              ct_return   = lt_return
          ).
        ENDIF.

        ls_writem-diglength     = <ls_item>-dig_length.
        ls_writem-digwidth      = <ls_item>-dig_width.
        ls_writem-digfromloc    = <ls_item>-dig_from_loc.
        ls_writem-digtoloc      = <ls_item>-dig_to_loc.

        IF ls_writem-digfromloc IS INITIAL AND
          lv_restoration = abap_true.
          lv_item_error = abap_true.
          me->set_response_maximo(
            EXPORTING
              iv_wo       = <ls_header>-work_id
              iv_pmwo     = <ls_header>-pmwork_order_id
              iv_matno    = <ls_item>-material_number
              iv_msgno    = '015'
              iv_msgtyp   = zif_cu_sip=>gc_rejected
              iv_msgv1    = zif_cu_sip=>gc_digfromloc
            CHANGING
              cs_response = es_output
              ct_return   = lt_return
          ).
        ENDIF.

        IF lv_item_error = abap_false.
          APPEND ls_writem TO lt_writem_tmp.
        ENDIF.

      ENDLOOP.

      IF lv_header_error IS INITIAL AND
         lv_item_error IS INITIAL.
        APPEND ls_wrheader TO lt_wrheader.
        APPEND LINES OF lt_writem_tmp TO lt_writem.

        me->set_response_maximo(
          EXPORTING
            iv_wo       = <ls_header>-work_id
            iv_msgtyp   = zif_cu_sip=>gc_accepted
          CHANGING
            cs_response = es_output
            ct_return   = lt_return
        ).
      ENDIF.

      CLEAR: lv_item,
             lv_header_error,
             lv_item_error,
             lv_restoration,
             lt_writem_tmp,
             ls_wrheader,
             ls_writem.
    ENDLOOP.

*Update the Header and Item tables
*Start of changes by C144096 for TFS 2845
*    IF lt_wrheader IS NOT INITIAL AND
    IF lt_wrheader IS NOT INITIAL.
*       lt_writem IS NOT INITIAL.
*End of changes by C144096 for TFS 2845
      MODIFY ztcu_wrheader FROM TABLE lt_wrheader.
      IF sy-subrc = 0.
*Start of changes by C144096 for TFS 2845
       COMMIT WORK AND WAIT.
       IF lt_writem IS NOT INITIAL.
*End of changes by C144096 for TFS 2845
        MODIFY ztcu_writem FROM TABLE lt_writem.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
        ENDIF.
       ENDIF.
      ENDIF.
    ENDIF.

*Update SLG1 Log
    IF lt_return IS NOT INITIAL.
      NEW zcl_ca_utility_applog( )->create_log(
        EXPORTING
          iv_object   = 'ZCU'
          iv_subobj   = 'SIP'
          iv_external = 'I669'
          it_logs     = lt_return
      ).
    ENDIF.

  ENDMETHOD.


  METHOD set_response.
***********************************************************************
*  Method:      SET_RESPONSE                                          *
*  Overview:    Work Request Master Data                              *
*  Author:      Vignesh Sunkasi                                       *
*  Create Date: 06/24/2020                                            *
*  Comments:    Set the response for WMIS - I655                      *
*                                                                     *
***********************************************************************
*  CHANGE HISTORY:                                                    *
*                                                                     *
***********************************************************************
    DATA: lv_msg   TYPE string,
          lv_msgv1 TYPE symsgv,
          lv_msgv2 TYPE symsgv.

    IF iv_msgno IS NOT INITIAL.
      lv_msgv1 = iv_msgv1.
      lv_msgv2 = iv_msgv2.

      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = zif_cu_sip=>gc_zcu_msg
          msgnr               = iv_msgno
          msgv1               = lv_msgv1
          msgv2               = lv_msgv2
        IMPORTING
          message_text_output = lv_msg.
    ENDIF.

    APPEND INITIAL LINE TO cs_response-ecc_wrresponse-record
    ASSIGNING FIELD-SYMBOL(<ls_response>).
    <ls_response>-wrnumber        = iv_wo.
    <ls_response>-material_number = iv_matno.
    <ls_response>-status          = iv_msgtyp.
    <ls_response>-message         = lv_msg.

    APPEND INITIAL LINE TO ct_return
    ASSIGNING FIELD-SYMBOL(<ls_return>).
    IF iv_msgtyp = zif_cu_sip=>gc_accepted.
      <ls_return>-type = zif_cu_sip=>gc_success.
      lv_msgv1 = iv_wo.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = zif_cu_sip=>gc_zcu_msg
          msgnr               = '000'
          msgv1               = lv_msgv1
        IMPORTING
          message_text_output = lv_msg.

      <ls_return>-id         =  zif_cu_sip=>gc_zcu_msg.
      <ls_return>-number     = '000'.
      <ls_return>-message_v1 = lv_msgv1.
      <ls_return>-message    = lv_msg.

    ELSEIF iv_msgtyp = zif_cu_sip=>gc_rejected.
      <ls_return>-type       = zif_cu_sip=>gc_error.
      <ls_return>-id         =  zif_cu_sip=>gc_zcu_msg.
      <ls_return>-number     = iv_msgno.
      <ls_return>-message_v1 = lv_msgv1.
      <ls_return>-message_v2 = lv_msgv2.
      <ls_return>-message    = lv_msg.

    ENDIF.
  ENDMETHOD.


  METHOD set_response_jointuse.
***********************************************************************
*  Method:      SET_RESPONSE_JOINTUSE                                 *
*  Overview:    Work Request Master Data                              *
*  Author:      Vignesh Sunkasi                                       *
*  Create Date: 06/24/2020                                            *
*  Comments:    Set the response for JointUse - I658                  *
*                                                                     *
***********************************************************************
*  CHANGE HISTORY:                                                    *
*                                                                     *
***********************************************************************
    DATA: lv_msg   TYPE string,
          lv_msgv1 TYPE symsgv,
          lv_msgv2 TYPE symsgv.

    IF iv_msgno IS NOT INITIAL.
      lv_msgv1 = iv_msgv1.
      lv_msgv2 = iv_msgv2.

      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = zif_cu_sip=>gc_zcu_msg
          msgnr               = iv_msgno
          msgv1               = lv_msgv1
          msgv2               = lv_msgv2
        IMPORTING
          message_text_output = lv_msg.
    ENDIF.

    APPEND INITIAL LINE TO cs_response-ecc_joint_use_response-joint_use_response_record
    ASSIGNING FIELD-SYMBOL(<ls_response>).
    <ls_response>-wrnumber        = iv_wo.
    <ls_response>-irnumber        = iv_ir.
    <ls_response>-status          = iv_msgtyp.
    <ls_response>-message         = lv_msg.

    APPEND INITIAL LINE TO ct_return
    ASSIGNING FIELD-SYMBOL(<ls_return>).
    IF iv_msgtyp = zif_cu_sip=>gc_accepted.
      <ls_return>-type = zif_cu_sip=>gc_success.
      lv_msgv1 = iv_wo.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = zif_cu_sip=>gc_zcu_msg
          msgnr               = '000'
          msgv1               = lv_msgv1
        IMPORTING
          message_text_output = lv_msg.

      <ls_return>-id         =  zif_cu_sip=>gc_zcu_msg.
      <ls_return>-number     = '000'.
      <ls_return>-message_v1 = lv_msgv1.
      <ls_return>-message    = lv_msg.

    ELSEIF iv_msgtyp = zif_cu_sip=>gc_rejected.
      <ls_return>-type       = zif_cu_sip=>gc_error.
      <ls_return>-id         =  zif_cu_sip=>gc_zcu_msg.
      <ls_return>-number     = iv_msgno.
      <ls_return>-message_v1 = lv_msgv1.
      <ls_return>-message_v2 = lv_msgv2.
      <ls_return>-message    = lv_msg.

    ENDIF.
  ENDMETHOD.


  METHOD set_response_maximo.
***********************************************************************
*  Method:      SET_RESPONSE_MAXIMO                                   *
*  Overview:    Work Request Master Data                              *
*  Author:      Vignesh Sunkasi                                       *
*  Create Date: 06/24/2020                                            *
*  Comments:    Set the response for Maximo - I669                    *
*                                                                     *
***********************************************************************
*  CHANGE HISTORY:                                                    *
*                                                                     *
***********************************************************************
    DATA: lv_msg   TYPE string,
          lv_msgv1 TYPE symsgv,
          lv_msgv2 TYPE symsgv.

    IF iv_msgno IS NOT INITIAL.
      lv_msgv1 = iv_msgv1.
      lv_msgv2 = iv_msgv2.

      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = zif_cu_sip=>gc_zcu_msg
          msgnr               = iv_msgno
          msgv1               = lv_msgv1
          msgv2               = lv_msgv2
        IMPORTING
          message_text_output = lv_msg.
    ENDIF.

    APPEND INITIAL LINE TO cs_response-ecc_woresponse-woresponse_record
    ASSIGNING FIELD-SYMBOL(<ls_response>).
    <ls_response>-work_id         = iv_wo.
    <ls_response>-pmwork_order_id = iv_pmwo.
    <ls_response>-material_number = iv_matno.
    <ls_response>-status          = iv_msgtyp.
    <ls_response>-message         = lv_msg.

    APPEND INITIAL LINE TO ct_return
    ASSIGNING FIELD-SYMBOL(<ls_return>).
    IF iv_msgtyp = zif_cu_sip=>gc_accepted.
      <ls_return>-type = zif_cu_sip=>gc_success.
      lv_msgv1 = iv_wo.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = zif_cu_sip=>gc_zcu_msg
          msgnr               = '000'
          msgv1               = lv_msgv1
        IMPORTING
          message_text_output = lv_msg.

      <ls_return>-id         =  zif_cu_sip=>gc_zcu_msg.
      <ls_return>-number     = '000'.
      <ls_return>-message_v1 = lv_msgv1.
      <ls_return>-message    = lv_msg.

    ELSEIF iv_msgtyp = zif_cu_sip=>gc_rejected.
      <ls_return>-type       = zif_cu_sip=>gc_error.
      <ls_return>-id         =  zif_cu_sip=>gc_zcu_msg.
      <ls_return>-number     = iv_msgno.
      <ls_return>-message_v1 = lv_msgv1.
      <ls_return>-message_v2 = lv_msgv2.
      <ls_return>-message    = lv_msg.

    ENDIF.
  ENDMETHOD.


  METHOD update_wr_status.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.09.2020
*&  Functional Design Name : Work Request Status Update
*&  Purpose                : Work Request Status Update
*&  Transport Request No   : D10K936685
*****************************************************************************


    DATA: lo_proxy      TYPE REF TO zclco_ecc_work_status_update_o,
          lt_param      TYPE zttca_param,
          lt_comments   TYPE zclwork_status_update_comm_tab,
          lt_invdetails TYPE zclwork_status_update_invo_tab,
          lw_wostatus   TYPE zclwork_status_update_work_ord,
          lw_output     TYPE zclecc_work_status_update,
          lv_latest     TYPE boolean,
          lt_return     TYPE bapiret2_t.

    "Get the Invoice and WR details
    SELECT a~sipno,
           a~wrno,
           a~final,
           a~outoftolerance,
           b~wrtype,
           b~source,
           c~invoice,
           c~createdon
      FROM ztcu_sipheader AS a
      INNER JOIN ztcu_wrheader AS b
      ON a~wrno = b~wrno
      INNER JOIN ztcu_sipinvoice AS c
      ON a~sipno = c~sipno
      INTO TABLE @DATA(lt_wrstatus)
      WHERE a~sipno IN @it_sipno AND
            a~final = 'X'.

    IF sy-subrc = 0.
      SORT lt_wrstatus BY sipno.

      "Get the WF log details
      CALL METHOD zclcu_sip_utility=>get_routinglog_details
        EXPORTING
          it_sipno      = it_sipno
        IMPORTING
          et_routinglog = DATA(lt_routing).
      IF lt_routing IS NOT INITIAL.
        SORT lt_routing BY batch_no ASCENDING seqnum DESCENDING.

        "Get the list of Restoration types
        NEW zcl_ca_utility( )->get_parameter(
      EXPORTING
        i_busproc           = 'CU'             " Business Process
        i_busact            = 'TECH'           " Business Activity
        i_validdate         = sy-datum         " Parameter Validity Start Date
        i_param             = 'RESTORATION'
      CHANGING
        t_param             = lt_param         " Parameter value
      EXCEPTIONS
        invalid_busprocess  = 1                " Invalid Business Process
        invalid_busactivity = 2                " Invalid Business Activity
        OTHERS              = 3
    ).
        IF sy-subrc = 0.
          SORT lt_param BY value.
        ENDIF.

        LOOP AT lt_wrstatus ASSIGNING FIELD-SYMBOL(<ls_wrstatus>).
          APPEND INITIAL LINE TO lt_invdetails ASSIGNING FIELD-SYMBOL(<ls_invdetails>).

          IF <ls_wrstatus>-source IS NOT INITIAL.
            <ls_invdetails>-origin_system          = <ls_wrstatus>-source.
          ELSE.
            CALL METHOD me->fill_return
              EXPORTING
                iv_msgv1   = 'Origin System'
                iv_msgv2   = <ls_wrstatus>-sipno
                iv_msgtype = zif_cu_sip=>gc_error
                iv_msgno   = '22'
              CHANGING
                ct_return  = lt_return.
          ENDIF.

          IF <ls_wrstatus>-wrno IS NOT INITIAL.
            <ls_invdetails>-work_order_id          = <ls_wrstatus>-wrno.
          ELSE.
            CALL METHOD me->fill_return
              EXPORTING
                iv_msgv1   = 'Work Request'
                iv_msgv2   = <ls_wrstatus>-sipno
                iv_msgtype = zif_cu_sip=>gc_error
                iv_msgno   = '22'
              CHANGING
                ct_return  = lt_return.
          ENDIF.

          IF <ls_wrstatus>-invoice IS NOT INITIAL.
            <ls_invdetails>-invoice_request_number = <ls_wrstatus>-invoice.
          ELSE.
            CALL METHOD me->fill_return
              EXPORTING
                iv_msgv1   = 'Invoice'
                iv_msgv2   = <ls_wrstatus>-sipno
                iv_msgtype = zif_cu_sip=>gc_error
                iv_msgno   = '22'
              CHANGING
                ct_return  = lt_return.
          ENDIF.

          <ls_invdetails>-is_out_of_tolerance    = <ls_wrstatus>-outoftolerance.

          READ TABLE lt_param TRANSPORTING NO FIELDS
          WITH KEY value = <ls_wrstatus>-wrtype BINARY SEARCH.
          IF sy-subrc = 0.
            <ls_invdetails>-is_restoration = abap_true.
          ENDIF.

          "Map the comments from rotuing log table
          LOOP AT lt_routing ASSIGNING FIELD-SYMBOL(<ls_routing>)
                             WHERE batch_no = <ls_wrstatus>-sipno.
            "Get the last approved log detail
            IF lv_latest IS INITIAL.
              IF <ls_routing>-completedon IS NOT INITIAL AND
                 <ls_routing>-timecompleted IS NOT INITIAL.
                me->date_to_timestamp(
                  EXPORTING
                    iv_date      = <ls_routing>-completedon
                    iv_time      = <ls_routing>-timecompleted
                  IMPORTING
                    ev_timestamp = <ls_invdetails>-approved_timestamp
                ).
              ELSE.
                IF <ls_routing>-completedon IS INITIAL.
                  CALL METHOD me->fill_return
                    EXPORTING
                      iv_msgv1   = 'Completed On'
                      iv_msgv2   = <ls_wrstatus>-sipno
                      iv_msgtype = zif_cu_sip=>gc_error
                      iv_msgno   = '22'
                    CHANGING
                      ct_return  = lt_return.
                ELSEIF <ls_routing>-timecompleted IS INITIAL..
                  CALL METHOD me->fill_return
                    EXPORTING
                      iv_msgv1   = 'Time Completed'
                      iv_msgv2   = <ls_wrstatus>-sipno
                      iv_msgtype = zif_cu_sip=>gc_error
                      iv_msgno   = '22'
                    CHANGING
                      ct_return  = lt_return.
                ENDIF.
              ENDIF.

              lv_latest = abap_true.
            ENDIF.

            "If comments are maintained, fill this structure
            IF <ls_routing>-comments IS NOT INITIAL.
              APPEND INITIAL LINE TO lt_comments ASSIGNING FIELD-SYMBOL(<ls_comments>).
              <ls_comments>-comment = <ls_routing>-comments.

              IF <ls_routing>-completedon IS NOT INITIAL AND
                 <ls_routing>-timecompleted IS NOT INITIAL.
                me->date_to_timestamp(
                  EXPORTING
                    iv_date      = <ls_routing>-completedon
                    iv_time      = <ls_routing>-timecompleted
                  IMPORTING
                    ev_timestamp = <ls_comments>-created_timestamp
                ).
              ELSE.
                IF <ls_routing>-completedon IS INITIAL.
                  CALL METHOD me->fill_return
                    EXPORTING
                      iv_msgv1   = 'Completed On'
                      iv_msgv2   = <ls_wrstatus>-sipno
                      iv_msgtype = zif_cu_sip=>gc_error
                      iv_msgno   = '22'
                    CHANGING
                      ct_return  = lt_return.
                ELSEIF <ls_routing>-timecompleted IS INITIAL..
                  CALL METHOD me->fill_return
                    EXPORTING
                      iv_msgv1   = 'Time Completed'
                      iv_msgv2   = <ls_wrstatus>-sipno
                      iv_msgtype = zif_cu_sip=>gc_error
                      iv_msgno   = '22'
                    CHANGING
                      ct_return  = lt_return.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.

          IF lt_comments IS NOT INITIAL.
            <ls_invdetails>-comments = lt_comments.
          ENDIF.

          lw_wostatus-invoice_request_details = lt_invdetails.

          me->date_to_timestamp(
            EXPORTING
              iv_date      = sy-datum
              iv_time      = sy-uzeit
            IMPORTING
              ev_timestamp = lw_wostatus-created_timestamp
          ).

          APPEND lw_wostatus TO lw_output-ecc_work_status_update-work_order_invoice_request_com.

          IF lt_return IS INITIAL.
            "Trigger the asynchronous outbound proxy
            CREATE OBJECT lo_proxy.
            TRY.
                CALL METHOD lo_proxy->ecc_work_status_update_out
                  EXPORTING
                    output = lw_output.

              CATCH cx_ai_system_fault INTO DATA(lo_fault).
                DATA(lv_error) = lo_fault->get_text( ).
                APPEND INITIAL LINE TO et_return ASSIGNING FIELD-SYMBOL(<ls_return>).
                <ls_return>-type       = zif_cu_sip=>gc_error.
                <ls_return>-message    = lv_error.
                <ls_return>-message_v1 = <ls_wrstatus>-sipno.
                <ls_return>-message_v2 = <ls_wrstatus>-invoice.
            ENDTRY.
            COMMIT WORK.

          ELSE.
            APPEND LINES OF lt_return TO et_return.
          ENDIF.

          CLEAR: lv_latest,
                 lv_error,
                 lw_output,
                 lw_wostatus,
                 lt_return.
        ENDLOOP.
      ENDIF.
    ENDIF.

*Update SLG1 Log
    IF et_return IS NOT INITIAL.
      NEW zcl_ca_utility_applog( )->create_log(
        EXPORTING
          iv_object   = 'ZCU'
          iv_subobj   = 'SIP'
          iv_external = 'I657'
          it_logs     = et_return
      ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
