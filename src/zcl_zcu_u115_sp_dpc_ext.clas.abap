class ZCL_ZCU_U115_SP_DPC_EXT definition
  public
  inheriting from ZCL_ZCU_U115_SP_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_BEGIN
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_PROCESS
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM
    redefinition .
protected section.

  methods ACTIVITYSET_GET_ENTITYSET
    redefinition .
  methods APPROVALFLOWSET_GET_ENTITYSET
    redefinition .
  methods ATTACHMENTHEADER_DELETE_ENTITY
    redefinition .
  methods ATTACHMENTHEADER_GET_ENTITYSET
    redefinition .
  methods CONTRACTSEARCHHE_GET_ENTITYSET
    redefinition .
  methods HEADERSET_GET_ENTITY
    redefinition .
  methods HEADERSET_GET_ENTITYSET
    redefinition .
  methods ITEMSET_GET_ENTITYSET
    redefinition .
  methods MATERIALSEARCHHE_GET_ENTITYSET
    redefinition .
  methods ROLEBASEDUSERIDS_GET_ENTITYSET
    redefinition .
  methods SPSEARCHHELPSET_GET_ENTITYSET
    redefinition .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZCU_U115_SP_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~changeset_begin.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 22.06.2020
*&  Functional Design Name : Special Project
*&  Purpose                : Initiate the batch processing
*&  Transport Request No   : D10K935617
*****************************************************************************
    cv_defer_mode = abap_true.

  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~changeset_process.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 23.06.2020
*&  Functional Design Name : Special Project
*&  Purpose                : Save/Submit
*&  Transport Request No   : D10K935617
*****************************************************************************


    CLEAR : ct_changeset_response.
    DATA : lo_request_context      TYPE REF TO /iwbep/if_mgw_req_entity_c,
           lv_sp                   TYPE z_spno,  "z_spno
           lw_changeset_response   TYPE /iwbep/if_mgw_appl_types=>ty_s_changeset_response, "Change set Response
           lw_header               TYPE zcl_zcu_u115_sp_mpc=>ts_header,
           lw_items                TYPE zcl_zcu_u115_sp_mpc=>ts_item,
           lw_deep_struc           TYPE zscu_deep_struc,
           lw_delete               TYPE REF TO /iwbep/if_mgw_req_entity_d ##NEEDED,
           lw_routing              TYPE zcl_zcu_u115_sp_mpc=>ts_approvalflow,
           lw_media_slug           TYPE zclcu_sip_utility=>ty_s_media_slug,
           lt_media_slug           TYPE zclcu_sip_utility=>ty_t_media_slug,
           lt_attach_cs            TYPE zcl_zcu_u115_sp_mpc=>tt_attachdocument,
           lw_attachheader         TYPE zcl_zcu_u115_sp_mpc=>ts_attachmentheader,
           lt_key_tab              TYPE /iwbep/t_mgw_name_value_pair,
           lt_return               TYPE bapiret2_t,
           lt_deep_struc           TYPE zttcu_deep_struc.
    TRY.
        " START Processing changeset process operations
        IF it_changeset_request IS NOT INITIAL.
          " Handle consecutive operations with the same operation types
          LOOP AT it_changeset_request ASSIGNING FIELD-SYMBOL(<ls_request>)
                                        GROUP BY ( operation_type = <ls_request>-operation_type ) DESCENDING
                                        REFERENCE INTO DATA(lr_changeset_group).
            CASE lr_changeset_group->operation_type.
                "Post
              WHEN /iwbep/if_mgw_appl_types=>gcs_operation_type-create_entity.
                UNASSIGN:<ls_request>.

                LOOP AT  GROUP lr_changeset_group ASSIGNING <ls_request>.
                  DATA(lv_entity_type) = CAST /iwbep/if_mgw_req_entity_c( <ls_request>-request_context )->get_entity_type_name( ).
                  CASE lv_entity_type.
                      "HeaderSet
                    WHEN TEXT-001.
                      <ls_request>-entry_provider->read_entry_data(
                                                              IMPORTING es_data = lw_header ).
                      "Append to deep structure
                      lw_deep_struc-header_sp = lw_header.
                      "Check if the SIP no is already created
                      IF lw_header-spno IS INITIAL.
                        DATA(lv_create_sp) = abap_true.
                      ENDIF.
                      APPEND lw_deep_struc TO lt_deep_struc.
                      CLEAR : lw_deep_struc-header_sp.
                      "ItemSet
                    WHEN TEXT-002.
                      <ls_request>-entry_provider->read_entry_data(
                                                             IMPORTING es_data = lw_items ).
                      "Append to deep structure
                      lw_deep_struc-items_sp = lw_items.
                      APPEND lw_deep_struc TO lt_deep_struc.
                      CLEAR: lw_deep_struc-items_sp.
                    WHEN TEXT-004.
                      <ls_request>-entry_provider->read_entry_data( IMPORTING es_data = lw_routing ).
                      lw_deep_struc-routing = lw_routing.
                      APPEND lw_deep_struc TO lt_deep_struc.
                      CLEAR: lw_deep_struc-routing.
*
                    WHEN TEXT-011.
                      <ls_request>-entry_provider->read_entry_data( IMPORTING es_data = lw_attachheader ).
                      lw_deep_struc-attachheader = lw_attachheader.
                      APPEND lw_deep_struc TO lt_deep_struc.
                      CLEAR: lw_deep_struc-attachheader.

                    WHEN OTHERS.
                      "Operation not supported
                      RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
                        EXPORTING
                          textid = /iwbep/cx_mgw_tech_exception=>operation_not_supported.
                  ENDCASE.
                ENDLOOP.
                "create attachment
              WHEN /iwbep/if_mgw_appl_types=>gcs_operation_type-create_stream.
                UNASSIGN:<ls_request>.

                LOOP AT  GROUP lr_changeset_group ASSIGNING <ls_request>.
                  lv_entity_type = CAST /iwbep/if_mgw_req_entity_c( <ls_request>-request_context )->get_entity_type_name( ).
                  CASE lv_entity_type.
                    WHEN TEXT-005.      "Attachment Document
                      lw_media_slug-media_resource = <ls_request>-media_resource.
                      lw_media_slug-slug = <ls_request>-slug.
                      APPEND lw_media_slug TO lt_media_slug.
                      CLEAR : lw_media_slug.

                    WHEN OTHERS.
                      "Operation not supported
                      RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
                        EXPORTING
                          textid = /iwbep/cx_mgw_tech_exception=>operation_not_supported.
                  ENDCASE.
                ENDLOOP.
            ENDCASE.
          ENDLOOP.
          "Save all tabs
          IF lt_deep_struc IS NOT INITIAL.
            IF lv_create_sp = abap_true.
              CALL METHOD zclcu_sip_utility=>populate_uniqueid
                EXPORTING
                  iv_appindicator = 'S'
                IMPORTING
                  ev_uniqueid     = DATA(lv_uniqueno).

              lv_sp = lv_uniqueno.
            ENDIF.
            "save
            CALL METHOD zclcu_u115_utility=>batch_process
              EXPORTING
                it_deep_struc = lt_deep_struc
                iv_spno       = lv_sp
                it_media_slug = lt_media_slug
                it_key_tab    = lt_key_tab
              CHANGING
                ct_return     = lt_return
                ct_attach_cs  = lt_attach_cs.

            IF lt_return IS INITIAL.
              LOOP AT it_changeset_request INTO DATA(lw_changeset_request).
                lo_request_context ?= lw_changeset_request-request_context.
                lv_entity_type = lo_request_context->get_entity_type_name( ).

                CASE lv_entity_type.
                  WHEN TEXT-001.  "Header
                    IF lv_create_sp = abap_true.
                      lw_header-spno = lv_sp.
                    ENDIF.
                    copy_data_to_ref(
                      EXPORTING
                        is_data = lw_header
                      CHANGING
                        cr_data = lw_changeset_response-entity_data ).

                    lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                    INSERT lw_changeset_response INTO TABLE ct_changeset_response.

                  WHEN TEXT-002.
                    IF lv_create_sp = abap_true.
                      lw_items-spno = lv_sp.
                    ENDIF.
                    copy_data_to_ref(
                    EXPORTING
                      is_data = lw_items
                    CHANGING
                      cr_data = lw_changeset_response-entity_data ).

                    lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                    INSERT lw_changeset_response INTO TABLE ct_changeset_response.

                  WHEN TEXT-005.
                    copy_data_to_ref(
                    EXPORTING
                      is_data = lt_attach_cs
                    CHANGING
                      cr_data = lw_changeset_response-entity_data ).

                    lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                    INSERT lw_changeset_response INTO TABLE ct_changeset_response.
                    "Routing
                  WHEN TEXT-004.
                    IF lv_create_sp = abap_true.
                      lw_routing-uniqueno = lv_sp.
                    ENDIF.
                    copy_data_to_ref(
                    EXPORTING
                      is_data = lw_routing
                    CHANGING
                      cr_data = lw_changeset_response-entity_data ).

                    lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                    INSERT lw_changeset_response INTO TABLE ct_changeset_response.

                  WHEN TEXT-011.  "Attachmentheader
                    IF lv_create_sp = abap_true.
                      lw_header-spno = lv_sp.
                    ENDIF.
                    copy_data_to_ref(
                      EXPORTING
                        is_data = lw_attachheader
                      CHANGING
                        cr_data = lw_changeset_response-entity_data ).

                    lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                    INSERT lw_changeset_response INTO TABLE ct_changeset_response.
                  WHEN OTHERS.
                    "Operation not supported
                    RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
                      EXPORTING
                        textid = /iwbep/cx_mgw_tech_exception=>operation_not_supported.
                ENDCASE.


              ENDLOOP.
            ELSE.
              "any errors
              mo_context->get_message_container( )->add_messages_from_bapi(
                  it_bapi_messages         = lt_return
                  iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).
**Raise exception
              RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                  textid            = /iwbep/cx_mgw_busi_exception=>business_error
                  message_container = mo_context->get_message_container( ).
            ENDIF.
          ENDIF.
        ENDIF.
      CATCH /iwbep/cx_mgw_busi_exception ##NO_HANDLER.
      CATCH /iwbep/cx_mgw_tech_exception ##NO_HANDLER.

    ENDTRY.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 06.07.2020
*&  Functional Design Name : Special Project
*&  Purpose                : Validations
*&  Transport Request No   : D10K935617
*****************************************************************************
    DATA: lv_msg    TYPE bapi_msg,
          lw_userid TYPE zclcu_sip_mpc=>ts_rolebaseduserid,
          lw_return TYPE zclcu_sip_mpc=>ts_return,
          lt_userid TYPE zclcu_sip_mpc=>tt_rolebaseduserid,
          lt_return TYPE zcl_zcu_u115_sp_mpc=>tt_return.

    CONSTANTS: lc_val_mat  TYPE string VALUE 'ValidateMaterial',
               lc_contract TYPE string VALUE 'ValidateContract',
               lc_userid   TYPE string VALUE 'ValidateApprVerifier',
               lc_success  TYPE string VALUE 'S'.

    CLEAR: er_data.

    "Function Imports
    CASE iv_action_name.
      WHEN lc_val_mat.
        IF it_parameter IS NOT INITIAL.
          "Validate material
          CALL METHOD zclcu_sip_utility=>validate_material
            EXPORTING
              it_input  = it_parameter
            IMPORTING
              es_return = lw_return.
        ENDIF.
      WHEN lc_contract.
        "Validate Contract
        CALL METHOD zclcu_sip_utility=>validate_contract
          EXPORTING
            it_input  = it_parameter
          IMPORTING
            es_return = lw_return.
      WHEN lc_userid.
        CALL METHOD zclcu_sip_utility=>validate_userid
          EXPORTING
            it_input  = it_parameter
          IMPORTING
            es_return = lw_userid.

        IF lw_userid-type = lc_success.
          APPEND lw_userid TO lt_userid.
          "Valid
          copy_data_to_ref( EXPORTING is_data = lt_userid
                        CHANGING cr_data = er_data ).
        ELSE.
          "Invalid
          lv_msg = lw_userid-msg.
          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
            EXPORTING
              textid  = /iwbep/cx_mgw_busi_exception=>business_error
              message = lv_msg.
        ENDIF.
      WHEN OTHERS.
        MESSAGE e005(zcu_msg) INTO lv_msg.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid  = /iwbep/cx_mgw_busi_exception=>business_error
            message = lv_msg.
    ENDCASE.

    IF lw_return-type = lc_success.

      APPEND lw_return TO lt_return.
      CLEAR : lw_return.
      "Valid
      copy_data_to_ref( EXPORTING is_data = lt_return
                    CHANGING cr_data = er_data ).
    ELSE.
      "Invalid
      lv_msg = lw_return-msg.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = lv_msg.
    ENDIF.


  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_stream.
********************************************************************************
* Program ID:      GET_DOCUMENT
* Program Title:   Get the attachment from BUS2081 and table - ZTCU_SIP_ATTACH
* Created By:      Venkata Gopisetty/C144527
* Creation Date:   23.06.2020
* RICEFW ID:       W073
* Description:     To get attachment from BUS2081 and table - ZTCU_SIP_ATTACH
*                  Table - ZTCU_SIP_ATTACH
*********************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 18.06.2020  C144527           1        D10K935617 / Initial version
************************************************************************

**----------------------------------------------------------------------*
**Local Structures
**----------------------------------------------------------------------*
    CLEAR : er_stream, es_response_context.
    DATA : lw_stream         TYPE ty_s_media_resource,
           lw_converted_keys TYPE zcl_zcu_u115_sp_mpc=>ts_attachmentheader,
           lv_error_flag     TYPE boolean,
           lw_header         TYPE ihttpnvp.

* Get key table information
    io_tech_request_context->get_converted_keys(
      IMPORTING
        es_key_values  = lw_converted_keys ).

    "c145085
    " Get Doc Type based on Doc ID
    SELECT  filename, "#EC CI_NOFIELD
            doctype FROM ztcu_sip_attach
                INTO @DATA(lw_sip_attach)
                UP TO 1 ROWS
      WHERE docid = @lw_converted_keys-docid.
    ENDSELECT.
    IF sy-subrc <> 0.
      CLEAR: lw_converted_keys-doctype.
    ELSE.
      lw_converted_keys-doctype = lw_sip_attach-doctype.
      lw_converted_keys-filename = lw_sip_attach-filename.
      TRANSLATE lw_converted_keys-doctype TO UPPER CASE.
    ENDIF.


***Call Utility class for data
    zclcu_sip_utility=>get_document(
      IMPORTING
        ev_error_flag    =   lv_error_flag               " Single-Character Flag
        es_stream        =   lw_stream               " Media Resource information
        es_header        =   lw_header               " HTTP Framework (iHTTP) Name/Value Pair
      CHANGING
        cs_attachdeatils =  lw_converted_keys   ).     " SIP Attachment header details

    set_header( is_header = lw_header ).
    IF lv_error_flag = abap_false.
****passing DATA to entity
      copy_data_to_ref( EXPORTING is_data = lw_stream
                        CHANGING  cr_data = er_stream ).
    ENDIF.
  ENDMETHOD.


  METHOD activityset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 18.08.2020
*&  Functional Design Name : SP Application
*&  Purpose                : Get the activities based on material and plant
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset, es_response_context.
    DATA : lv_matnr TYPE matnr,
           lv_plant TYPE werks_d.

    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'Material'.
            lv_matnr = lw_filter_val-low.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lv_matnr
              IMPORTING
                output = lv_matnr.
          WHEN 'Plant'.
            lv_plant = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    "Get the activity details
    CALL METHOD zclcu_sip_utility=>get_activities
      EXPORTING
        iv_matnr = lv_matnr
        iv_plant = lv_plant
      IMPORTING
        et_data  = et_entityset.

    IF et_entityset IS INITIAL.
* Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.
  ENDMETHOD.


  METHOD approvalflowset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 15.07.2020
*&  Functional Design Name : Special Project
*&  Purpose                : Get the header details
*&  Transport Request No   : D10K935617
*****************************************************************************
    CLEAR : et_entityset, es_response_context.
    DATA : lw_approvalflow TYPE zcl_zcu_u115_sp_mpc=>ts_approvalflow,
           lv_contract     TYPE ebeln.

    CONSTANTS : lc_spno       TYPE char20 VALUE 'SPNo'.

    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN lc_spno.
            lw_approvalflow-uniqueno = lw_filter_val-low.
          WHEN 'Scenario'.
            lw_approvalflow-category = lw_filter_val-low.
          WHEN 'AppIndicator'.
            lw_approvalflow-appindicator = lw_filter_val-low.
          WHEN 'Contract'.
            lv_contract = lw_filter_val-low.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lv_contract
              IMPORTING
                output = lw_approvalflow-contract.
          WHEN 'Plant'.
            lw_approvalflow-plant = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    "Get the routing details
    CALL METHOD zclcu_sip_utility=>get_approvalflow
      EXPORTING
        is_approvalflow = lw_approvalflow
      IMPORTING
        et_data         = et_entityset.

    IF et_entityset IS INITIAL.
* Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.

  ENDMETHOD.


  METHOD attachmentheader_delete_entity.
************************************************************************
* Program ID:      GET_ATACHMENT_HEADER
* Program Title:   Get the attachment Header details
* Created By:      Venkata Gopisetty/C144527
* Creation Date:   23.06.2020
* RICEFW ID:       W073
* Description:     T0 get the attachment Header details from
*                  Table - ZTCU_SIP_ATTACH
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 18.06.2020  C144527           1        D10K935617 / Initial version
************************************************************************

*----------------------------------------------------------------------*
*Local Variables
*----------------------------------------------------------------------*
    DATA : lw_converted_keys TYPE zcl_zcu_u115_sp_mpc=>ts_attachmentheader,
           lv_error_flag     TYPE boolean,
           lv_err            TYPE string.

* Get key table information
    io_tech_request_context->get_converted_keys(
      IMPORTING
        es_key_values  = lw_converted_keys ).

***Call Utility class for data
    zclcu_sip_utility=>delete_attachdocument(
      EXPORTING
        is_attachdetails =  lw_converted_keys
      IMPORTING
        ev_error_flag    = lv_error_flag                 " Single-Character Flag
 ).               " SIP Attachment header details

    IF lv_error_flag IS NOT INITIAL.
      lv_err = TEXT-007.
****Raise Bussiness Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error_unlimited
          message_unlimited = lv_err.
    ENDIF.

  ENDMETHOD.


  METHOD attachmentheader_get_entityset.
************************************************************************
* Program ID:      ATTACHMENTHEADER_GET_ENTITYSET
* Program Title:   Get the attachment Header details
* Created By:      Venkata Gopisetty/C144527
* Creation Date:   23.06.2020
* RICEFW ID:       W073
* Description:     T0 get the attachment Header details from
*                  Table - ZTCU_SIP_ATTACH
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 18.06.2020  C144527           1        D10K935617 / Initial version
************************************************************************

*----------------------------------------------------------------------*
*Local Variables
*----------------------------------------------------------------------*
    CLEAR : et_entityset, es_response_context
    .
    DATA : lv_sp    TYPE z_spno,
           lv_docid TYPE saeardoid.

    CONSTANTS : lc_sp    TYPE string VALUE 'SPNo',
                lc_docid TYPE string VALUE 'DocId'.

    "get the SIP as filter
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN lc_sp .
            lv_sp = lw_filter_val-low.
          WHEN lc_docid.
            lv_docid = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

***Call Utility class for data
    zclcu_sip_utility=>get_atachment_header(
      EXPORTING
        iv_sipno  =   lv_sp " SIP Number
        iv_docid  =   lv_docid
      IMPORTING
        et_output =  et_entityset  ).  " TT for SIP Attachment header details

    IF et_entityset IS INITIAL.
* Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.
  ENDMETHOD.


  METHOD contractsearchhe_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 13.08.2020
*&  Functional Design Name : Special Project
*&  Purpose                : Get the contract F4
*&  Transport Request No   : D10K935617
*****************************************************************************
    CLEAR :et_entityset, es_response_context.
    DATA : lv_contract TYPE ebeln,
           lv_user     TYPE uname.
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'Contract'.
            lv_contract = lw_filter_val-low.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lv_contract
              IMPORTING
                output = lv_contract.
          WHEN 'SubmittedBy'.
            lv_user = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    "Get contracts
    CALL METHOD zclcu_u115_utility=>get_contracts_sp
      EXPORTING
        iv_contract = lv_contract
      IMPORTING
        et_data     = et_entityset.


  ENDMETHOD.


  METHOD headerset_get_entity.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 21.07.2020
*&  Functional Design Name : Special Project
*&  Purpose                : Get the header details
*&  Transport Request No   : D10K935617
*****************************************************************************
    CLEAR : er_entity, es_response_context.
    DATA : lw_header TYPE zcl_zcu_u115_sp_mpc=>ts_header,
           lt_header TYPE zcl_zcu_u115_sp_mpc=>tt_header.

    CONSTANTS : lc_sp  TYPE string VALUE 'SPNo'.

    "get the SIP number from UI
    READ TABLE it_key_tab INTO DATA(lw_key_tab) WITH KEY name = lc_sp.
    IF sy-subrc IS INITIAL.
      lw_header-spno = lw_key_tab-value.
    ENDIF.
    READ TABLE it_key_tab INTO lw_key_tab WITH KEY name = TEXT-008. "'Scenario'.
    IF sy-subrc IS INITIAL.
      lw_header-category = lw_key_tab-value.
    ENDIF.
    READ TABLE it_key_tab INTO lw_key_tab WITH KEY name = TEXT-009.
    IF sy-subrc IS INITIAL.
      lw_header-appindicator = lw_key_tab-value.
    ENDIF.
    READ TABLE it_key_tab INTO lw_key_tab WITH KEY name = TEXT-010. "'Contract'.
    IF sy-subrc IS INITIAL.
      lw_header-contract = lw_key_tab-value.
    ENDIF.

    "Get the header details .
    CALL METHOD zclcu_u115_utility=>get_header
      EXPORTING
        is_header = lw_header
      IMPORTING
        et_header = lt_header.

    READ TABLE lt_header INTO er_entity INDEX 1.
    IF sy-subrc <> 0.
      CLEAR : er_entity.
    ENDIF.


  ENDMETHOD.


  METHOD headerset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 22.06.2020
*&  Functional Design Name : Special Project
*&  Purpose                : Get the header details
*&  Transport Request No   : D10K935617
*****************************************************************************
    CLEAR : et_entityset, es_response_context.
    DATA : lw_header TYPE zcl_zcu_u115_sp_mpc=>ts_header.

    CONSTANTS : lc_sp  TYPE string VALUE 'SPNo',
                lc_sp1 TYPE string VALUE 'SPNO'.

    "get the SIP number from UI
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN lc_sp OR lc_sp1.
            lw_header-spno = lw_filter_val-low.
          WHEN 'Scenario'.
            lw_header-category = lw_filter_val-low.
          WHEN 'AppIndicator'.
            lw_header-appindicator = lw_filter_val-low.
          WHEN 'Contract'.
            lw_header-contract = lw_filter_val-low.

          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    "Get the header details .
    CALL METHOD zclcu_u115_utility=>get_header
      EXPORTING
        is_header = lw_header
      IMPORTING
        et_header = et_entityset.
    IF et_entityset IS INITIAL.
* Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.

  ENDMETHOD.


  METHOD itemset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 18.06.2020
*&  Functional Design Name : Special Project
*&  Purpose                : Get the item details
*&  Transport Request No   : D10K935617
*****************************************************************************
    CLEAR : et_entityset, es_response_context.

    DATA : lw_item TYPE zcl_zcu_u115_sp_mpc=>ts_item.

    CONSTANTS : lc_sp TYPE string VALUE 'SPNo'.

    "get the SIP number from UI
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN lc_sp.
            lw_item-spno = lw_filter_val-low.
          WHEN 'Scenario'.
            lw_item-category = lw_filter_val-low.
          WHEN 'AppIndicator'.
            lw_item-appindicator = lw_filter_val-low.
          WHEN 'Contract'.
            lw_item-contract = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.
    "Get Item details
    CALL METHOD zclcu_u115_utility=>get_items
      EXPORTING
        is_item  = lw_item
      IMPORTING
        et_items = et_entityset.
    IF et_entityset IS INITIAL.
* Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.

  ENDMETHOD.


  METHOD materialsearchhe_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 21.08.2020
*&  Functional Design Name : Ticketing Application
*&  Purpose                : Get contracts
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR :et_entityset, es_response_context.

    DATA : lw_mat   TYPE zscu_itemf4.
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'Contract'.
            lw_mat-ebeln = lw_filter_val-low.
          WHEN 'Material'.
            lw_mat-matnr = lw_filter_val-low.
          WHEN 'WRNo'.
            lw_mat-wrno = lw_filter_val-low.
          WHEN 'SPNo'.
            lw_mat-spno = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    "Get the item F4
    CALL METHOD zclcu_sip_utility=>item_searchhelp
      EXPORTING
        is_item = lw_mat
      IMPORTING
        et_data = DATA(lt_data).

    MOVE-CORRESPONDING lt_data TO et_entityset.

    IF et_entityset IS INITIAL.
* Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.
  ENDMETHOD.


  METHOD rolebaseduserids_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 26.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get user ids based on role
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR :et_entityset, es_response_context.
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'Role'.
            DATA(lv_role) = lw_filter_val-low.
            IF lv_role = 'AP'. "Approver
              DATA(lv_approver) = abap_true.
            ELSE.
              DATA(lv_verifier) = abap_true.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.
    "Get the roles based on approver/verifier
    CALL METHOD zclcu_sip_utility=>get_approver_verifier
      EXPORTING
        iv_approvers           = lv_approver
        iv_verifiers           = lv_verifier
      IMPORTING
        et_approvers_verifiers = DATA(lt_appr_verif).

    LOOP AT lt_appr_verif ASSIGNING FIELD-SYMBOL(<ls_ap_vr>).
      APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<ls_ent>).
      CLEAR : <ls_ent>.
      <ls_ent>-name = <ls_ap_vr>-name.
      <ls_ent>-role_descr = <ls_ap_vr>-role_descr.
      <ls_ent>-role_id = <ls_ap_vr>-role_id.
      <ls_ent>-usrid = <ls_ap_vr>-usrid.
    ENDLOOP.
  ENDMETHOD.


  METHOD spsearchhelpset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S P
*&  Created On             : 11.17.2020
*&  Functional Design Name : U115 - Special Project
*&  Purpose                : F4 for all special project numbers
*&  Transport Request No   : D10K936732
*****************************************************************************
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'Createdby'.
            DATA(lv_userid) = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    IF lv_userid IS NOT INITIAL.
      SELECT contract,
               createdon,
               spno,
               createdby,
               spdescr,
               sipstatus,
               plant,
               project
            FROM ztcu_spheader
            INTO TABLE @DATA(lt_sp)
            WHERE createdby = @lv_userid.
    ELSE.
      SELECT contract,
           createdon,
           spno,
           createdby,
           spdescr,
           sipstatus,
           plant,
           project
        FROM ztcu_spheader
        INTO TABLE @lt_sp.
    ENDIF.
    IF sy-subrc EQ 0.
      SORT lt_sp BY spno.
      "Get usernames
      SELECT a~bname,
             a~persnumber,
             b~name_text
              FROM usr21 AS a
              INNER JOIN adrp AS b
              ON a~persnumber = b~persnumber
              INTO TABLE @DATA(lt_name)
              FOR ALL ENTRIES IN @lt_sp
              WHERE a~bname = @lt_sp-createdby.
      IF sy-subrc = 0.
        SORT lt_name BY bname.
      ENDIF.

      LOOP AT lt_sp ASSIGNING FIELD-SYMBOL(<ls_sp>).
        APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<ls_ent>).
        MOVE-CORRESPONDING <ls_sp> TO <ls_ent>.
        READ TABLE lt_name ASSIGNING FIELD-SYMBOL(<ls_name>) WITH KEY bname = <ls_sp>-createdby BINARY SEARCH.
        IF sy-subrc EQ 0.
          <ls_ent>-username = <ls_name>-name_text.
        ENDIF.
      ENDLOOP.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
