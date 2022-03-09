class ZCL_ZCU_W076_SIP_TICKE_DPC_EXT definition
  public
  inheriting from ZCL_ZCU_W076_SIP_TICKE_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_BEGIN
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_PROCESS
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM
    redefinition .
protected section.

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
  methods ITEMMAXIMOSET_GET_ENTITYSET
    redefinition .
  methods ITEMSET_GET_ENTITYSET
    redefinition .
  methods MATERIALSEARCHHE_GET_ENTITYSET
    redefinition .
  methods PLANTSEARCHHELPS_GET_ENTITYSET
    redefinition .
  methods ROLEBASEDUSERIDS_GET_ENTITYSET
    redefinition .
  methods SURROGATESUPERVI_GET_ENTITYSET
    redefinition .
  methods TICKETSEARCHHELP_GET_ENTITYSET
    redefinition .
  methods WRSPSEARCHHELPSE_GET_ENTITYSET
    redefinition .
  methods UICONFIGSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZCU_W076_SIP_TICKE_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~changeset_begin.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 22.06.2020
*&  Functional Design Name : Ticketing Application
*&  Purpose                : Initiate the batch processing
*&  Transport Request No   : D10K934677
*****************************************************************************
    cv_defer_mode = abap_true.

  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~changeset_process.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 23.06.2020
*&  Functional Design Name : Ticketing Application
*&  Purpose                : Save/Submit
*&  Transport Request No   : D10K934677
*****************************************************************************


    CLEAR : ct_changeset_response.
    DATA : lo_request_context    TYPE REF TO /iwbep/if_mgw_req_entity_c,
           lv_tkt                TYPE z_sipno,
           lw_changeset_response TYPE /iwbep/if_mgw_appl_types=>ty_s_changeset_response, "Change set Response
           lw_header             TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_header,
           lw_items              TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_item,
           lw_items_inactive     TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_iteminactive,
           lw_deep_struc         TYPE zscu_deep_struc,
           lw_attach_ui          TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_attachmentheader,
           lw_attachheader       TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_attachmentheader,
           lw_routing            TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_approvalflow,
           lw_media_slug         TYPE zclcu_sip_utility=>ty_s_media_slug,
           lt_key_tab            TYPE /iwbep/t_mgw_name_value_pair,
           lt_attach_cs          TYPE zclcu_sip_mpc=>tt_attachdocument,
           lt_return             TYPE bapiret2_t,
           lt_deep_struc         TYPE zttcu_deep_struc,
           lt_media_slug         TYPE zclcu_sip_utility=>ty_t_media_slug.

    TRY.
        " START Processing changeset process operations
        IF it_changeset_request IS NOT INITIAL.
          " Handle consecutive operations with the same operation types
          LOOP AT it_changeset_request ASSIGNING FIELD-SYMBOL(<ls_request>)
                                        GROUP BY ( operation_type = <ls_request>-operation_type ) ASCENDING
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
                      lw_deep_struc-header_tk = lw_header.
                      "Check if the SIP no is already created
                      IF lw_header-ticketno IS INITIAL.
                        DATA(lv_create_tkt) = abap_true.
                      ELSE.
                        lv_tkt = lw_header-ticketno.
                      ENDIF.
                      APPEND lw_deep_struc TO lt_deep_struc.
                      CLEAR : lw_deep_struc-header_tk.
                      "ItemSet
                    WHEN TEXT-002.
                      <ls_request>-entry_provider->read_entry_data(
                                                             IMPORTING es_data = lw_items ).
                      "Append to deep structure
                      lw_deep_struc-items_tk = lw_items.
                      APPEND lw_deep_struc TO lt_deep_struc.
                      CLEAR: lw_deep_struc-items_tk.
                      "InactiveItemSet
                    WHEN TEXT-014.
                      <ls_request>-entry_provider->read_entry_data(
                                                             IMPORTING es_data = lw_items_inactive ).
                      "Append to deep structure
                      lw_deep_struc-items_tk_inactive = lw_items_inactive.
                      APPEND lw_deep_struc TO lt_deep_struc.
                      CLEAR: lw_deep_struc-items_tk_inactive.
                      "ApprovalFlow
                    WHEN TEXT-004.
                      <ls_request>-entry_provider->read_entry_data( IMPORTING es_data = lw_routing ).
                      lw_deep_struc-routing = lw_routing.
                      IF lw_routing-uniqueno IS NOT INITIAL.
                        lv_tkt = lw_routing-uniqueno.
                      ENDIF.
                      APPEND lw_deep_struc TO lt_deep_struc.
                      CLEAR: lw_deep_struc-routing.
                      "AttachmentHeader
                    WHEN TEXT-013.
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
                    WHEN TEXT-012.      "Attachment Document
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
            IF lv_create_tkt = abap_true.

              CALL METHOD zclcu_sip_utility=>populate_uniqueid
                EXPORTING
                  iv_appindicator = 'T'
                IMPORTING
                  ev_uniqueid     = DATA(lv_uniqueno).
              lv_tkt = lv_uniqueno.
            ENDIF.

            CALL METHOD zclcu_w076_utility=>batch_process
              EXPORTING
                it_deep_struc = lt_deep_struc
                iv_tktno      = lv_tkt
                it_media_slug = lt_media_slug
                it_key_tab    = lt_key_tab
              CHANGING
                ct_return     = lt_return
                ct_attach_cs  = lt_attach_cs.

          ENDIF.
          IF lt_return IS INITIAL.
            LOOP AT it_changeset_request INTO DATA(lw_changeset_request).
              lo_request_context ?= lw_changeset_request-request_context.
              lv_entity_type = lo_request_context->get_entity_type_name( ).

              CASE lv_entity_type.
                WHEN TEXT-001.
                  IF lv_create_tkt = abap_true.
                    lw_header-ticketno = lv_tkt.
                  ENDIF.
                  copy_data_to_ref(
                    EXPORTING
                      is_data = lw_header
                    CHANGING
                      cr_data = lw_changeset_response-entity_data ).

                  lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                  INSERT lw_changeset_response INTO TABLE ct_changeset_response.

                WHEN TEXT-002.
                  IF lv_create_tkt = abap_true.
                    lw_items-ticketno = lv_tkt.
                  ENDIF.
                  copy_data_to_ref(
                  EXPORTING
                    is_data = lw_items
                  CHANGING
                    cr_data = lw_changeset_response-entity_data ).

                  lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                  INSERT lw_changeset_response INTO TABLE ct_changeset_response.

                WHEN TEXT-014.
                  IF lv_create_tkt = abap_true.
                    lw_items_inactive-ticketno = lv_tkt.
                  ENDIF.
                  copy_data_to_ref(
                  EXPORTING
                    is_data = lw_items_inactive
                  CHANGING
                    cr_data = lw_changeset_response-entity_data ).

                  lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                  INSERT lw_changeset_response INTO TABLE ct_changeset_response.

                WHEN TEXT-012.
                  IF lv_create_tkt = abap_true.
                    lw_attach_ui-uniqueno = lv_tkt.
                  ENDIF.
                  copy_data_to_ref(
                  EXPORTING
                    is_data = lw_attach_ui
                  CHANGING
                    cr_data = lw_changeset_response-entity_data ).

                  lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                  INSERT lw_changeset_response INTO TABLE ct_changeset_response.
                  "Routing
                WHEN TEXT-004.
                  IF lv_create_tkt = abap_true.
                    lw_routing-uniqueno = lv_tkt.
                  ENDIF.
                  copy_data_to_ref(
                  EXPORTING
                    is_data = lw_routing
                  CHANGING
                    cr_data = lw_changeset_response-entity_data ).

                  lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                  INSERT lw_changeset_response INTO TABLE ct_changeset_response.

                  "Attachment Header
                WHEN TEXT-013.
                  IF lv_create_tkt = abap_true.
                    lw_routing-uniqueno = lv_tkt.
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
      CATCH /iwbep/cx_mgw_busi_exception ##NO_HANDLER.
      CATCH /iwbep/cx_mgw_tech_exception ##NO_HANDLER.

    ENDTRY.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.
************************************************************************
* Program ID:      CREATE_ATTACHMENT
* Program Title:   To create Attachments for SIP
* Created By:      Venkata Gopisetty/C144527
* Creation Date:   23.06.2020
* RICEFW ID:       W073
* Description:     To Create SIP Atatchments linked to BUS2081
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 18.06.2020  C144527           1        D10K934677 / Initial version
************************************************************************

*----------------------------------------------------------------------*
*Local Variables
*----------------------------------------------------------------------*
    DATA : lw_tkt_attach TYPE zscu_sip_attach,
           lv_error_flag TYPE boolean,
           lv_err        TYPE string.

*****Constants
    CONSTANTS : lc_tkt       TYPE string VALUE 'TicketNo'.


****Gte keys from Entityset
    READ TABLE it_key_tab INTO DATA(lw_key_tab) WITH KEY name = lc_tkt.
    IF sy-subrc EQ 0.
      lw_tkt_attach-uniqueno = lw_key_tab-value.
    ENDIF.

***To get the File name and Extension
    SPLIT iv_slug AT '>' INTO lw_tkt_attach-filename lw_tkt_attach-doctype lw_tkt_attach-description.

***Call Utility class for data
    zclcu_sip_utility=>create_document(
      EXPORTING
        iv_content       = is_media_resource-value
      IMPORTING
        ev_error_flag    =  lv_error_flag                " Single-Character Flag
      CHANGING
        cs_attachdeatils =   lw_tkt_attach  ).             " SIP Attachment header details


    IF lv_error_flag IS NOT INITIAL.
      lv_err = TEXT-011.
****Raise Bussiness Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error_unlimited
          message_unlimited = lv_err.
    ENDIF.

****passing DATA to entity
    copy_data_to_ref( EXPORTING is_data = lw_tkt_attach
                        CHANGING  cr_data = er_entity ).
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 06.07.2020
*&  Functional Design Name : Ticketing Application
*&  Purpose                : Validations
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: lv_msg       TYPE bapi_msg,
          lv_datakey   TYPE z_workflowid,
          lw_return    TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_return,
          lw_approvers TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_auditlog_approvers,
          lt_return    TYPE zcl_zcu_w076_sip_ticke_mpc=>tt_return.

    CONSTANTS: lc_val_mat         TYPE string VALUE 'ValidateMaterial',
               lc_contract        TYPE string VALUE 'ValidateContract',
               lc_updatestatusfpc TYPE string VALUE 'UpdateStatusFPC',
               lc_getapprovers    TYPE string VALUE 'GetApprovers',
               lc_validateaccess  TYPE string VALUE 'ValidateAccess',
               lc_success         TYPE string VALUE 'S'.

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

      WHEN lc_updatestatusfpc.
        CALL METHOD zclcu_sip_utility=>update_status_fpc
          EXPORTING
            it_input  = it_parameter
          IMPORTING
            es_return = lw_return.

      WHEN lc_getapprovers.
        READ TABLE it_parameter ASSIGNING FIELD-SYMBOL(<ls_parameter>) WITH KEY name = 'TKTNo'. "#EC CI_STDSEQ
        IF sy-subrc EQ 0.
          lv_datakey = <ls_parameter>-value.
        ENDIF.

        IF lv_datakey IS NOT INITIAL.
          CALL METHOD zclcu_sip_utility=>get_approvers_auditlog
            EXPORTING
              iv_datakey   = lv_datakey
            IMPORTING
              ev_approvers = DATA(lv_approvers).

          lw_approvers-tktno = lv_datakey.
          lw_approvers-approvers = lv_approvers.

          copy_data_to_ref( EXPORTING is_data = lw_approvers
                CHANGING cr_data = er_data ).

        ELSE.
          MESSAGE e005(zcu_msg) INTO lv_msg.
          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
            EXPORTING
              textid  = /iwbep/cx_mgw_busi_exception=>business_error
              message = lv_msg.
        ENDIF.

      WHEN lc_validateaccess.
        "Validate Access
        CALL METHOD zclcu_sip_utility=>validate_tkt_access
          EXPORTING
            it_input  = it_parameter
          IMPORTING
            es_return = lw_return.

        APPEND lw_return TO lt_return.
        "Valid
        copy_data_to_ref( EXPORTING is_data = lt_return
                      CHANGING cr_data = er_data ).

        DATA(lv_validateaccess) = abap_true.

      WHEN OTHERS.
        MESSAGE e005(zcu_msg) INTO lv_msg.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid  = /iwbep/cx_mgw_busi_exception=>business_error
            message = lv_msg.
    ENDCASE.

    IF lv_datakey IS INITIAL AND
       lv_validateaccess IS INITIAL.

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
* 18.06.2020  C144527           1        D10K934677 / Initial version
************************************************************************

**----------------------------------------------------------------------*
**Local Structures
**----------------------------------------------------------------------*
    CLEAR : er_stream, es_response_context.

    DATA : lw_stream         TYPE ty_s_media_resource,
           lw_header         TYPE ihttpnvp,
           lv_error_flag     TYPE boolean,
           lw_converted_keys TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_attachmentheader.


* Get key table information
    io_tech_request_context->get_converted_keys(
      IMPORTING
        es_key_values  = lw_converted_keys ).


* Get Doc Type based on Doc ID
    SELECT  filename, "#EC CI_NOFIELD
            doctype FROM ztcu_sip_attach
                INTO @DATA(ls_sip_attach)
            UP TO 1 ROWS
      WHERE docid = @lw_converted_keys-docid.
      ENDSELECT.
    IF sy-subrc <> 0.
      CLEAR: lw_converted_keys-doctype.
    ELSE.
      lw_converted_keys-doctype = ls_sip_attach-doctype.
      lw_converted_keys-filename = ls_sip_attach-filename.
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


  METHOD approvalflowset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 15.07.2020
*&  Functional Design Name : Ticketing Application
*&  Purpose                : Get the header details
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset, es_response_context.

    DATA : lw_approvalflow TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_approvalflow.

    CONSTANTS : lc_tktno       TYPE char20 VALUE 'UniqueNo'.

    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN lc_tktno.
            lw_approvalflow-uniqueno = lw_filter_val-low.
          WHEN 'Contract'.
            lw_approvalflow-contract = lw_filter_val-low.
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
* 18.06.2020  C144527           1        D10K934677 / Initial version
************************************************************************

*----------------------------------------------------------------------*
*Local Variables
*----------------------------------------------------------------------*
    DATA : lw_converted_keys TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_attachmentheader,
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
* 18.06.2020  C144527           1        D10K934677 / Initial version
************************************************************************

*----------------------------------------------------------------------*
*Local Variables
*----------------------------------------------------------------------*
    CLEAR : et_entityset, es_response_context.

    DATA : lv_tkt TYPE z_sipno,
           lv_docid TYPE saeardoid.

    CONSTANTS : lc_tkt   TYPE string VALUE 'TicketNo',
                lc_docid TYPE string VALUE 'DocId'.

    "get the tkt as filter
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN lc_tkt .
            lv_tkt = lw_filter_val-low.
          WHEN lc_docid.
            lv_docid = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

***Call Utility class for data
    zclcu_sip_utility=>get_atachment_header(
      EXPORTING
        iv_sipno  =   lv_tkt  " SIP Number
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
*&  Created On             : 26.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get contracts
*&  Transport Request No   : D10K934677
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
    CALL METHOD zclcu_sip_utility=>get_contractsf4
      EXPORTING
        iv_contract    = lv_contract
        iv_submittedby = lv_user
      IMPORTING
        et_data        = et_entityset.

    IF et_entityset IS INITIAL.
* Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.

  ENDMETHOD.


  METHOD headerset_get_entity.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 21.07.2020
*&  Functional Design Name : Ticketing Application
*&  Purpose                : Get the header details
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : er_entity, es_response_context.
    DATA : lw_header TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_header,
           lt_header TYPE zcl_zcu_w076_sip_ticke_mpc=>tt_header.

    CONSTANTS : lc_tkt  TYPE string VALUE 'TicketNo'.

    "get the SIP number from UI
    READ TABLE it_key_tab INTO DATA(lw_key_tab) WITH KEY name = lc_tkt.
    IF sy-subrc IS INITIAL.
      lw_header-ticketno = lw_key_tab-value.
    ENDIF.
    READ TABLE it_key_tab INTO lw_key_tab WITH KEY name = text-008. "'Scenario'.
    IF sy-subrc IS INITIAL.
      lw_header-category = lw_key_tab-value.
    ENDIF.
    READ TABLE it_key_tab INTO lw_key_tab WITH KEY name = text-009.
    IF sy-subrc IS INITIAL.
      lw_header-appindicator = lw_key_tab-value.
    ENDIF.
    READ TABLE it_key_tab INTO lw_key_tab WITH KEY name = text-010. "'Contract'.
    IF sy-subrc IS INITIAL.
      lw_header-contract = lw_key_tab-value.
    ENDIF.

    "Get the header details .
    CALL METHOD zclcu_w076_utility=>get_header
      EXPORTING
        is_header = lw_header
      IMPORTING
        et_header = lt_header.


    READ TABLE lt_header INTO er_entity INDEX 1.
    IF sy-subrc EQ 0.
      CLEAR : er_entity.
    ENDIF.

  ENDMETHOD.


  METHOD headerset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 22.06.2020
*&  Functional Design Name : Ticket Application
*&  Purpose                : Get the header details
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset, es_response_context.
    DATA : lw_header TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_header.

    CONSTANTS : lc_tkt  TYPE string VALUE 'TicketNo'.

    "get the SIP number from UI
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN lc_tkt.
            lw_header-ticketno = lw_filter_val-low.
          WHEN 'Scenario'.
            lw_header-category = lw_filter_val-low.
          WHEN 'AppIndicator'.
            lw_header-appindicator = lw_filter_val-low.
          WHEN 'Contract'.
            lw_header-contract = lw_filter_val-low.
          WHEN 'WRNo'.
            lw_header-wrno = lw_filter_val-low.
          WHEN 'SPNo'.
            lw_header-spno = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    "Get the header details .
    CALL METHOD zclcu_w076_utility=>get_header
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


  METHOD itemmaximoset_get_entityset.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 18.06.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Maximo item details
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset, es_response_context.

    DATA : lv_wrno TYPE z_wrno.

    "get the SIP number from UI
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'WorkRequestNo'.
            lv_wrno = lw_filter_val-low.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    "Get Item details
    CALL METHOD zclcu_sip_utility=>get_wr_maximo
      EXPORTING
        iv_wrno   = lv_wrno
      IMPORTING
        et_maximo = et_entityset.

    SORT et_entityset BY linenum ASCENDING.

  ENDMETHOD.


  METHOD itemset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 18.06.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the item details
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset, es_response_context.

    DATA : lw_item TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_item.

    CONSTANTS : lc_tkt TYPE string VALUE 'TicketNo'.

    "get the SIP number from UI
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN lc_tkt.
            lw_item-ticketno = lw_filter_val-low.
          WHEN 'Scenario'.
            lw_item-category = lw_filter_val-low.
          WHEN 'AppIndicator'.
            lw_item-appindicator = lw_filter_val-low.
          WHEN 'Contract'.
            lw_item-contract = lw_filter_val-low.
          WHEN 'WRNo'.
            lw_item-wrno = lw_filter_val-low.
          WHEN 'SPNo'.
            lw_item-spno = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.
    "Get Item details
    CALL METHOD zclcu_w076_utility=>get_items
      EXPORTING
        is_item  = lw_item
      IMPORTING
        et_items = et_entityset.

    SORT et_entityset BY linenum.

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
          WHEN 'Category'.
            lw_mat-category = lw_filter_val-low.
          WHEN 'TicketNo'.
            lw_mat-ticketno = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    "Get the item F4
    CALL METHOD zclcu_sip_utility=>item_searchhelp
      EXPORTING
        is_item         = lw_mat
        iv_appindicator = 'T'
      IMPORTING
        et_data         = DATA(lt_data).

    MOVE-CORRESPONDING lt_data TO et_entityset.

    IF et_entityset IS INITIAL.
* Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.
  ENDMETHOD.


  METHOD plantsearchhelps_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 21.08.2020
*&  Functional Design Name : Ticketing Application
*&  Purpose                : Get Plants
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR :et_entityset, es_response_context.

    zclcu_sip_utility=>plant_searchhelp(
      EXPORTING
        iv_application     = 'W076'
      IMPORTING
        et_plantsearchhelp = DATA(lt_plantsearchhelp)
    ).

    IF lt_plantsearchhelp IS INITIAL.
* Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.
    ELSE.
      MOVE-CORRESPONDING lt_plantsearchhelp TO et_entityset.
    ENDIF.

  ENDMETHOD.


  METHOD rolebaseduserids_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 26.07.2020
*&  Functional Design Name : FPC Application
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
            IF lv_role = 'I1'. "Inspector 1
              DATA(lv_insp1) = abap_true.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    IF lv_insp1 IS INITIAL.
      lv_insp1 = abap_true.
    ENDIF.

    "Get the roles based on approver/verifier
    CALL METHOD zclcu_sip_utility=>get_approver_verifier
      EXPORTING
        iv_inspector1          = lv_insp1
      IMPORTING
        et_approvers_verifiers = DATA(lt_appr_verif).

    LOOP AT lt_appr_verif ASSIGNING FIELD-SYMBOL(<ls_ap_vr>).
      APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<ls_ent>).
      CLEAR : <ls_ent>.
      <ls_ent>-name       = <ls_ap_vr>-name.
      <ls_ent>-role_descr = <ls_ap_vr>-role_descr.
      <ls_ent>-role_id    = <ls_ap_vr>-role_id.
      <ls_ent>-usrid      = <ls_ap_vr>-usrid.
    ENDLOOP.

  ENDMETHOD.


  METHOD surrogatesupervi_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 26.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the supervisor/surrogate details
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset, es_response_context.

    DATA : lv_userid TYPE sldstring.

    "get the SIP number from UI
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'LoginUser'.
            lv_userid = lw_filter_val-low.
        ENDCASE.
      ENDIF.
    ENDLOOP.
    "Get supsur details
    CALL METHOD zclcu_sip_utility=>get_surrogate_supervisor
      EXPORTING
        iv_userid = lv_userid
        iv_wftype = 'W073'
      IMPORTING
        et_data   = et_entityset.


    IF et_entityset IS INITIAL.
*      RAISE EXCEPTION
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.
  ENDMETHOD.


  METHOD ticketsearchhelp_get_entityset.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi K
*&  Created On             : 02.09.2020
*&  Functional Design Name : W076 - TKT Application
*&  Purpose                : Get previous FPC's for a Contract or WR or SP
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA ls_ticket TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_ticketsearchhelp.

    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'Category'.
            ls_ticket-category = lw_filter_val-low.
          WHEN 'Wrno'.
            ls_ticket-wrno = lw_filter_val-low.
          WHEN 'Contract'.
            ls_ticket-contract = lw_filter_val-low.
          WHEN 'Spno'.
            ls_ticket-spno = lw_filter_val-low.
          WHEN 'Createdby'.
            ls_ticket-createdby = lw_filter_val-low.
          WHEN 'Sipstatus'.
            ls_ticket-sipstatus = lw_filter_val-low.
          WHEN 'TicketNo'.
            ls_ticket-ticketno = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    CALL METHOD zclcu_w076_utility=>get_tickets
      EXPORTING
        is_ticket  = ls_ticket
      IMPORTING
        et_tickets = et_entityset.

    IF et_entityset IS INITIAL.
* Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.
  ENDMETHOD.


  METHOD uiconfigset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 18.06.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the UI config details
*&  Transport Request No   : D10K934677
*****************************************************************************
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'Role'.
            DATA(lv_role) = lw_filter_val-low.
          WHEN 'Appindicator'.
            DATA(lv_appind) = lw_filter_val-low.
          WHEN 'Scenario'.
            DATA(lv_cat) = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.


    SELECT * FROM
      ztcu_sipconfig
      INTO TABLE @et_entityset
      WHERE role = @lv_role
      AND appindicator = @lv_appind
      AND scenario = @lv_cat.
  ENDMETHOD.


  METHOD wrspsearchhelpse_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 21.08.2020
*&  Functional Design Name : Ticketing
*&  Purpose                : Get WR and SPs
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset, es_response_context.

    DATA : lw_wrsp TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_wrspsearchhelp,
           lv_user     TYPE uname.

    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'Flag'.
            lw_wrsp-flag = lw_filter_val-low.
          WHEN 'WRSPNo'.
            lw_wrsp-wr_spno = lw_filter_val-low.
           WHEN 'Submittedby'.
            lv_user = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    "Get the routing details
    CALL METHOD zclcu_sip_utility=>wr_sp_searchhelp
      EXPORTING
        is_input = lw_wrsp
        iv_submittedby = lv_user
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
ENDCLASS.
