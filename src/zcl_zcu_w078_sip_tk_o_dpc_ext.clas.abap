class ZCL_ZCU_W078_SIP_TK_O_DPC_EXT definition
  public
  inheriting from ZCL_ZCU_W078_SIP_TK_O_DPC
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
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET_DELTA
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
  methods LOGGEDUSERSET_GET_ENTITYSET
    redefinition .
  methods MATERIALSEARCHHE_GET_ENTITYSET
    redefinition .
  methods PLANTSEARCHHELPS_GET_ENTITYSET
    redefinition .
  methods ROLEBASEDUSERIDS_GET_ENTITYSET
    redefinition .
  methods STATESET_GET_ENTITYSET
    redefinition .
  methods SURROGATESUPERVI_GET_ENTITYSET
    redefinition .
  methods TICKETSEARCHHELP_GET_ENTITYSET
    redefinition .
  methods WRSPSEARCHHELPSE_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZCU_W078_SIP_TK_O_DPC_EXT IMPLEMENTATION.


  METHOD wrspsearchhelpse_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 21.08.2020
*&  Functional Design Name : Ticketing
*&  Purpose                : Get WR and SPs
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset, es_response_context.
    DATA : lo_dp_facade   TYPE REF TO /iwbep/if_mgw_dp_facade,
           lv_delta_token TYPE string.

    "Get the routing details
    CALL METHOD zclcu_w076_offline_utility=>get_wrspf4
      IMPORTING
        et_data = et_entityset.

** Start of Changes by C139565 for 297627
*    IF et_entityset IS INITIAL.
** Raise Exception
*      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*        EXPORTING
*          textid  = /iwbep/cx_mgw_busi_exception=>business_error
*          message = TEXT-006.
*
*    ENDIF.
** End of Changes by C139565 for 297627
*   get the data provider facade
*    TRY.
*        lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
*      CATCH /iwbep/cx_mgw_tech_exception.
*        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception.
*    ENDTRY.
**  * call the delta token functionality
*    TRY.
*        CALL METHOD /iwbep/cl_query_result_log=>create_update_log_entry_hash
*          EXPORTING
*            io_tech_request_context  = io_tech_request_context
*            io_dp_facade             = lo_dp_facade
*            ir_service_document_name = mr_service_document_name
*            ir_service_version       = mr_service_version
*            it_entityset             = et_entityset
*          CHANGING
*            ev_delta_token           = lv_delta_token.
*      CATCH /iwbep/cx_qrl_locked.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_locked.
*      CATCH /iwbep/cx_qrl_delta_unavailabl.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_delta_unavailabl.
*    ENDTRY.
**  * export the delta token
*    es_response_context-deltatoken = lv_delta_token.
  ENDMETHOD.


  METHOD ticketsearchhelp_get_entityset.
*****************************************************************************
*&  Created By             : Sneha Chaudhari
*&  Created On             : 23.03.2021
*&  Functional Design Name : W078 - Offline TKT Application
*&  Purpose                : Get previous FPC's for a Contract or WR or SP
*&  Transport Request No   : D10K941579
*****************************************************************************
    SELECT *
    FROM ztcu_tktheader
    INTO TABLE @DATA(lt_tkthdr)
    WHERE createdby = @sy-uname.
    IF sy-subrc EQ 0.
      et_entityset[] = lt_tkthdr[].
    ENDIF.
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

**    Start of changes by C139565, Dt:03/12/2021
    TYPES:BEGIN OF lty_surrogate_supervisor,
            userid      TYPE string,
            suruserid   TYPE string,
            surusername TYPE string,
            supuserid   TYPE string,
            supusername TYPE string,
            escalation  TYPE n LENGTH 3,
          END OF lty_surrogate_supervisor .
**    End of changes by C139565, Dt:03/12/2021

    DATA : lv_userid    TYPE sldstring,
           lv_user      TYPE char12,  "Added by C139565, Dt: 03/12/2021
           lt_data_sur  TYPE STANDARD TABLE OF lty_surrogate_supervisor, "Added by C139565, Dt:03/12/2021
           lw_entityset LIKE LINE OF et_entityset. "Added by C139565, Dt:03/12/2021

    "Get the logged user and vendors
    SELECT  uname
      FROM ztcu_sip_users
      INTO TABLE @DATA(lt_users)
*      WHERE validfrom LE @sy-datum  "Commented by C139565 for 297627, Dt:03/16/2021
      WHERE uname = @sy-uname    "Added by C139565 for 297627, Dt:03/16/2021
      AND validfrom LE @sy-datum "Added by C139565 for 297627, Dt:03/16/2021
      AND validto GE @sy-datum.
    IF sy-subrc EQ 0.
      SORT lt_users BY uname.
    ENDIF.
    LOOP AT lt_users INTO DATA(lw_usr).
      lv_userid = lw_usr-uname.
      "Get supsur details
      CALL METHOD zclcu_sip_utility=>get_surrogate_supervisor
        EXPORTING
          iv_userid = lv_userid
          iv_wftype = 'W073'
        IMPORTING
          et_data   = DATA(lt_data).
*      APPEND LINES OF lt_data TO et_entityset. "Commented by C139565, Dt: 03/12/2021
      APPEND LINES OF lt_data TO lt_data_sur. "Added by C139565, Dt: 03/12/2021
    ENDLOOP.

**      Start of changes by C139565, Dt:03/12/2021
    LOOP AT lt_data_sur ASSIGNING FIELD-SYMBOL(<lfs_data>).
      lv_user = <lfs_data>-userid.
      lw_entityset-userid = lv_user.
      lw_entityset-suruserid = <lfs_data>-suruserid.
      lw_entityset-surusername = <lfs_data>-surusername.
      lw_entityset-supuserid = <lfs_data>-supuserid.
      lw_entityset-supusername = <lfs_data>-supusername.
      lw_entityset-escalation = <lfs_data>-escalation.
      APPEND lw_entityset TO et_entityset.
      CLEAR: lv_user, lw_entityset.
    ENDLOOP.
    CLEAR: lt_data_sur.
**      End of Changes by C139565, Dt:03/12/2021

** Start of Changes by C139565 for 297627
*    IF et_entityset IS INITIAL.
**      RAISE EXCEPTION
*      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*        EXPORTING
*          textid  = /iwbep/cx_mgw_busi_exception=>business_error
*          message = TEXT-006.
*
*    ENDIF.
** End of Changes by C139565 for 297627
  ENDMETHOD.


  METHOD stateset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S P
*&  Created On             : 05.10.2020
*&  Functional Design Name : W073/W076/U115
*&  Purpose                : Get state dropdown values
*&  Transport Request No   : D10K934677
*****************************************************************************
    SELECT land1,
           bland,
           bezei
      FROM t005u
      INTO TABLE @et_entityset
      WHERE ( bezei = 'Wisconsin' OR bezei = 'Minnesota' OR bezei = 'Illinois' OR bezei = 'Michigan' )
      AND spras = @sy-langu.

    IF sy-subrc EQ 0.
      SORT et_entityset BY bland.
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
      DATA : lo_dp_facade   TYPE REF TO /iwbep/if_mgw_dp_facade,
         lv_delta_token TYPE string.

    "Get the roles based on approver/verifier
    CALL METHOD zclcu_w076_offline_utility=>get_apprverifier
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
*   get the data provider facade
*    TRY.
*        lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
*      CATCH /iwbep/cx_mgw_tech_exception.
*        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception.
*    ENDTRY.
**  * call the delta token functionality
*    TRY.
*        CALL METHOD /iwbep/cl_query_result_log=>create_update_log_entry_hash
*          EXPORTING
*            io_tech_request_context  = io_tech_request_context
*            io_dp_facade             = lo_dp_facade
*            ir_service_document_name = mr_service_document_name
*            ir_service_version       = mr_service_version
*            it_entityset             = et_entityset
*          CHANGING
*            ev_delta_token           = lv_delta_token.
*      CATCH /iwbep/cx_qrl_locked.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_locked.
*      CATCH /iwbep/cx_qrl_delta_unavailabl.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_delta_unavailabl.
*    ENDTRY.
**  * export the delta token
*    es_response_context-deltatoken = lv_delta_token.
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

*    DATA : lv_plant TYPE werks_d.
*    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
*      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
*      IF sy-subrc IS INITIAL.
*        CASE lw_filter_opt-property.
*          WHEN 'Plant' OR 'WERKS'.
*            lv_plant = lw_filter_val-low.
*          WHEN 'Description' OR 'NAME1'.
*            DATA(lv_desc) = lw_filter_val-low.
*          WHEN OTHERS.
*        ENDCASE.
*      ENDIF.
*    ENDLOOP.
*
**-----Fetch plant data from T001W table
*    IF lv_plant IS NOT INITIAL.
*      SELECT werks,
*             name1
*             FROM t001w
*             INTO TABLE @DATA(lt_entityset)
*             WHERE werks = @lv_plant.
*    ELSEIF lv_desc IS NOT INITIAL.
*      SELECT  werks,
*              name1
*              FROM t001w
*              INTO TABLE @lt_entityset
*              WHERE name1 = @lv_desc.
*    ELSE.
*      SELECT werks,
*              name1
*              FROM t001w
*              INTO TABLE @lt_entityset.
*    ENDIF.

    zclcu_sip_utility=>plant_searchhelp(
      EXPORTING
        iv_application     = 'W076'
      IMPORTING
        et_plantsearchhelp = DATA(lt_plantsearchhelp)
    ).

    IF lt_plantsearchhelp IS INITIAL.
** Start of Changes by C139565 for 297627
* Raise Exception
*      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*        EXPORTING
*          textid  = /iwbep/cx_mgw_busi_exception=>business_error
*          message = TEXT-006.
** End of Changes by C139565 for 297627
    ELSE.
      MOVE-CORRESPONDING lt_plantsearchhelp TO et_entityset.
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
    DATA : lo_dp_facade   TYPE REF TO /iwbep/if_mgw_dp_facade,
           lv_delta_token TYPE string.

    "Get the item F4
    CALL METHOD zclcu_w076_offline_utility=>get_matf4
      IMPORTING
        et_data = DATA(lt_data).

    MOVE-CORRESPONDING lt_data TO et_entityset.

** Start of Changes by C139565 for 297627
*    IF et_entityset IS INITIAL.
** Raise Exception
*      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*        EXPORTING
*          textid  = /iwbep/cx_mgw_busi_exception=>business_error
*          message = TEXT-006.
*
*    ENDIF.
** End of Changes by C139565 for 297627
**   get the data provider facade
*    TRY.
*        lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
*      CATCH /iwbep/cx_mgw_tech_exception.
*        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception.
*    ENDTRY.
**  * call the delta token functionality
*    TRY.
*        CALL METHOD /iwbep/cl_query_result_log=>create_update_log_entry_hash
*          EXPORTING
*            io_tech_request_context  = io_tech_request_context
*            io_dp_facade             = lo_dp_facade
*            ir_service_document_name = mr_service_document_name
*            ir_service_version       = mr_service_version
*            it_entityset             = et_entityset
*          CHANGING
*            ev_delta_token           = lv_delta_token.
*      CATCH /iwbep/cx_qrl_locked.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_locked.
*      CATCH /iwbep/cx_qrl_delta_unavailabl.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_delta_unavailabl.
*    ENDTRY.
**  * export the delta token
*    es_response_context-deltatoken = lv_delta_token.

ENDMETHOD.


  METHOD loggeduserset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S P
*&  Created On             : 15.01.2021
*&  Functional Design Name : U118/W076 - Offline
*&  Purpose                : Get logged User id
*&  Transport Request No   : D10K937421
*****************************************************************************
    DATA : lw_data TYPE zcl_zcu_w078_sip_tkt_o_mpc=>ts_loggeduser.
    DATA : lo_dp_facade   TYPE REF TO /iwbep/if_mgw_dp_facade,
           lv_delta_token TYPE string.

    lw_data-userid = sy-uname.
    "Get usernames
    SELECT a~bname,
           a~persnumber,
           b~name_text
            FROM usr21 AS a
            INNER JOIN adrp AS b
            ON a~persnumber = b~persnumber
            INTO @DATA(lv_name)
            UP TO 1 ROWS
            WHERE a~bname = @sy-uname.
      ENDSELECT.
    lw_data-username = lv_name.
    APPEND lw_data TO et_entityset.
    CLEAR : lw_data.

**    *   get the data provider facade
*    TRY.
*        lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
*      CATCH /iwbep/cx_mgw_tech_exception.
*        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception.
*    ENDTRY.
**  * call the delta token functionality
*    TRY.
*        CALL METHOD /iwbep/cl_query_result_log=>create_update_log_entry_hash
*          EXPORTING
*            io_tech_request_context  = io_tech_request_context
*            io_dp_facade             = lo_dp_facade
*            ir_service_document_name = mr_service_document_name
*            ir_service_version       = mr_service_version
*            it_entityset             = et_entityset
*          CHANGING
*            ev_delta_token           = lv_delta_token.
*      CATCH /iwbep/cx_qrl_locked.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_locked.
*      CATCH /iwbep/cx_qrl_delta_unavailabl.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_delta_unavailabl.
*    ENDTRY.
**  * export the delta token
*    es_response_context-deltatoken = lv_delta_token.
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
    DATA : lo_dp_facade   TYPE REF TO /iwbep/if_mgw_dp_facade,
           lv_delta_token TYPE string.

    "Get Item details
    CALL METHOD zclcu_w076_offline_utility=>get_items
      IMPORTING
        et_items = et_entityset.

    SORT et_entityset BY linenum.
**   get the data provider facade
*    TRY.
*        lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
*      CATCH /iwbep/cx_mgw_tech_exception.
*        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception.
*    ENDTRY.
**  * call the delta token functionality
*    TRY.
*        CALL METHOD /iwbep/cl_query_result_log=>create_update_log_entry_hash
*          EXPORTING
*            io_tech_request_context  = io_tech_request_context
*            io_dp_facade             = lo_dp_facade
*            ir_service_document_name = mr_service_document_name
*            ir_service_version       = mr_service_version
*            it_entityset             = et_entityset
*          CHANGING
*            ev_delta_token           = lv_delta_token.
*      CATCH /iwbep/cx_qrl_locked.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_locked.
*      CATCH /iwbep/cx_qrl_delta_unavailabl.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_delta_unavailabl.
*    ENDTRY.
**  * export the delta token
*    es_response_context-deltatoken = lv_delta_token.

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

    "Get Item details
    CALL METHOD zclcu_w076_offline_utility=>get_wr_maximo
      IMPORTING
        et_maximo = et_entityset.

    SORT et_entityset BY linenum ASCENDING.

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
    DATA : lo_dp_facade   TYPE REF TO /iwbep/if_mgw_dp_facade,
           lv_delta_token TYPE string.

    "Get the header details .
    CALL METHOD zclcu_w076_offline_utility=>get_header
      IMPORTING
        et_header = et_entityset.

** Start of Changes by C139565 for 297627
*    IF et_entityset IS INITIAL.
** Raise Exception
*      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*        EXPORTING
*          textid  = /iwbep/cx_mgw_busi_exception=>business_error
*          message = TEXT-006.
*
*    ENDIF.
** End of Changes by C139565 for 297627
*   get the data provider facade
*    TRY.
*        lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
*      CATCH /iwbep/cx_mgw_tech_exception.
*        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception.
*    ENDTRY.
**  * call the delta token functionality
*    TRY.
*        CALL METHOD /iwbep/cl_query_result_log=>create_update_log_entry_hash
*          EXPORTING
*            io_tech_request_context  = io_tech_request_context
*            io_dp_facade             = lo_dp_facade
*            ir_service_document_name = mr_service_document_name
*            ir_service_version       = mr_service_version
*            it_entityset             = et_entityset
*          CHANGING
*            ev_delta_token           = lv_delta_token.
*      CATCH /iwbep/cx_qrl_locked.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_locked.
*      CATCH /iwbep/cx_qrl_delta_unavailabl.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_delta_unavailabl.
*    ENDTRY.
**  * export the delta token
*    es_response_context-deltatoken = lv_delta_token.

**Start of Changes by c139565 for 297627, Dt:04/07/2021
DATA: lv_record TYPE z_record_offl.
IF et_entityset IS NOT INITIAL.
   lv_record = 1.
  LOOP AT et_entityset ASSIGNING FIELD-SYMBOL(<lfs_entityset>).
    <lfs_entityset>-record_no = lv_record.
    lv_record = lv_record + 1.
  ENDLOOP.
ENDIF.
**End of Changes by c139565 for 297627, Dt:04/07/2021
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
    DATA : lw_header TYPE ZCL_ZCU_W078_SIP_TKT_O_mpc=>ts_header,
           lt_header TYPE ZCL_ZCU_W078_SIP_TKT_O_mpc=>tt_header.

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
*    CALL METHOD zclcu_w076_utility=>get_header
*      EXPORTING
*        is_header = lw_header
*      IMPORTING
*        et_header = lt_header.


    READ TABLE lt_header INTO er_entity INDEX 1.
    IF sy-subrc EQ 0.
      CLEAR : er_entity.
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

    DATA : lo_dp_facade   TYPE REF TO /iwbep/if_mgw_dp_facade,
           lv_delta_token TYPE string.
    "Get contracts
    CALL METHOD zclcu_w076_offline_utility=>get_contractf4
      IMPORTING
        et_data = et_entityset.

** Start of Changes by C139565 for 297627
*    IF et_entityset IS INITIAL.
** Raise Exception
*      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*        EXPORTING
*          textid  = /iwbep/cx_mgw_busi_exception=>business_error
*          message = TEXT-006.
*
*    ENDIF.
** End of Changes by C139565 for 297627
*   get the data provider facade
*    TRY.
*        lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
*      CATCH /iwbep/cx_mgw_tech_exception.
*        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception.
*    ENDTRY.
**  * call the delta token functionality
*    TRY.
*        CALL METHOD /iwbep/cl_query_result_log=>create_update_log_entry_hash
*          EXPORTING
*            io_tech_request_context  = io_tech_request_context
*            io_dp_facade             = lo_dp_facade
*            ir_service_document_name = mr_service_document_name
*            ir_service_version       = mr_service_version
*            it_entityset             = et_entityset
*          CHANGING
*            ev_delta_token           = lv_delta_token.
*      CATCH /iwbep/cx_qrl_locked.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_locked.
*      CATCH /iwbep/cx_qrl_delta_unavailabl.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_delta_unavailabl.
*    ENDTRY.
**  * export the delta token
*    es_response_context-deltatoken = lv_delta_token.
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

    DATA : lv_tkt   TYPE z_sipno,
           lv_docid TYPE saeardoid.

    SELECT uniqueno,
           docid
        FROM ztcu_sip_attach
        INTO TABLE @DATA(lt_attach)
        WHERE createdby = @sy-uname. "Added by C139565 for 297627, Dt:03/16/2021
    IF sy-subrc EQ 0.
      SORT lt_attach BY uniqueno docid.
    ENDIF.
    LOOP AT lt_attach INTO DATA(lw_attach).
***Call Utility class for data
      zclcu_sip_utility=>get_atachment_header(
        EXPORTING
          iv_sipno  =   lw_attach-uniqueno
          iv_docid  =   lw_attach-docid
        IMPORTING
          et_output =  DATA(lt_data)  ).  " TT for SIP Attachment header details
      APPEND LINES OF lt_data TO et_entityset.
      CLEAR lt_data.
    ENDLOOP.

** Start of Changes by C139565 for 297627
*    IF et_entityset IS INITIAL.
** Raise Exception
*      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*        EXPORTING
*          textid  = /iwbep/cx_mgw_busi_exception=>business_error
*          message = TEXT-006.
*
*    ENDIF.
** End of Changes by C139565 for 297627
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
    DATA : lw_converted_keys TYPE ZCL_ZCU_W078_SIP_TKT_O_mpc=>ts_attachmentheader,
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


  METHOD approvalflowset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 15.07.2020
*&  Functional Design Name : Ticketing Application
*&  Purpose                : Get the header details
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset, es_response_context.

    DATA : lo_dp_facade   TYPE REF TO /iwbep/if_mgw_dp_facade,
           lv_delta_token TYPE string.

    CALL METHOD zclcu_w076_offline_utility=>get_approvalflow
      IMPORTING
        et_data = et_entityset.

** Start of Comments by C139565 for 297627
*    IF et_entityset IS INITIAL.
** Raise Exception
*      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*        EXPORTING
*          textid  = /iwbep/cx_mgw_busi_exception=>business_error
*          message = TEXT-006.
*
*    ENDIF.
** End of Comments by C139565 for 297627
**    *   get the data provider facade
*    TRY.
*        lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
*      CATCH /iwbep/cx_mgw_tech_exception.
*        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception.
*    ENDTRY.
**  * call the delta token functionality
*    TRY.
*        CALL METHOD /iwbep/cl_query_result_log=>create_update_log_entry_hash
*          EXPORTING
*            io_tech_request_context  = io_tech_request_context
*            io_dp_facade             = lo_dp_facade
*            ir_service_document_name = mr_service_document_name
*            ir_service_version       = mr_service_version
*            it_entityset             = et_entityset
*          CHANGING
*            ev_delta_token           = lv_delta_token.
*      CATCH /iwbep/cx_qrl_locked.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_locked.
*      CATCH /iwbep/cx_qrl_delta_unavailabl.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_delta_unavailabl.
*    ENDTRY.
**  * export the delta token
*    es_response_context-deltatoken = lv_delta_token.
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
           lw_converted_keys TYPE ZCL_ZCU_W078_SIP_TKT_O_mpc=>ts_attachmentheader.


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


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entityset_delta.
*****************************************************************************
*&  Created By             : Kripa S P
*&  Created On             : 15.01.2021
*&  Functional Design Name : U118 - Survey app Offline
*&  Purpose                : Get survey question
*&  Transport Request No   : D10K937421
*****************************************************************************
*    DATA:
*      lt_return          TYPE TABLE OF bapiret2,
*      lv_entity_set_name TYPE string,
*      lt_survey          TYPE zcl_zcu_u118_sip_surve_mpc=>tt_surveyquestion,
*      lv_delta_token     TYPE string,
*      lt_filters         TYPE /iwbep/t_mgw_select_option,
*      lo_dp_facade       TYPE REF TO /iwbep/if_mgw_dp_facade,
*      ls_paging          TYPE /iwbep/s_mgw_paging,
*      ls_key             TYPE /iwbep/t_mgw_name_value_pair,
*      lt_nav             TYPE /iwbep/t_mgw_navigation_path,
*      lt_order           TYPE /iwbep/t_mgw_sorting_order,
*      lv_filt            TYPE string,
*      lv_search          TYPE string.
*
*    lv_entity_set_name = io_tech_request_context->get_entity_set_name( ).
*
*    IF lv_entity_set_name = 'ApprovalFlowSet'.
*      TRY.
*          CALL METHOD me->approvalflowset_get_entityset
*            EXPORTING
*              iv_entity_name           = 'ApprovalFlow'
*              iv_entity_set_name       = 'ApprovalFlowSet'
*              iv_source_name           = 'ApprovalFlow'
*              is_paging                = ls_paging
*              it_key_tab               = ls_key
*              it_filter_select_options = lt_filters
*              it_navigation_path       = lt_nav
*              it_order                 = lt_order
*              iv_filter_string         = lv_filt
*              iv_search_string         = lv_search
*            IMPORTING
*              et_entityset             = DATA(lt_appflw).
*        CATCH /iwbep/cx_mgw_busi_exception .
*        CATCH /iwbep/cx_mgw_tech_exception .
*      ENDTRY.
*    ELSEIF lv_entity_set_name = 'ContractSearchHelpSet'.
*      TRY.
*          CALL METHOD me->contractsearchhe_get_entityset
*            EXPORTING
*              iv_entity_name           = 'ContractSearchHelp'
*              iv_entity_set_name       = 'ContractSearchHelpSet'
*              iv_source_name           = 'ContractSearchHelp'
*              is_paging                = ls_paging
*              it_key_tab               = ls_key
*              it_filter_select_options = lt_filters
*              it_navigation_path       = lt_nav
*              it_order                 = lt_order
*              iv_filter_string         = lv_filt
*              iv_search_string         = lv_search
*            IMPORTING
*              et_entityset             = DATA(lt_cont).
*        CATCH /iwbep/cx_mgw_busi_exception .
*        CATCH /iwbep/cx_mgw_tech_exception .
*      ENDTRY.
*    ELSEIF lv_entity_set_name = 'HeaderSet'.
*      TRY.
*          CALL METHOD me->headerset_get_entityset
*            EXPORTING
*              iv_entity_name           = 'Header'
*              iv_entity_set_name       = 'HeaderSet'
*              iv_source_name           = 'Header'
*              is_paging                = ls_paging
*              it_key_tab               = ls_key
*              it_filter_select_options = lt_filters
*              it_navigation_path       = lt_nav
*              it_order                 = lt_order
*              iv_filter_string         = lv_filt
*              iv_search_string         = lv_search
*            IMPORTING
*              et_entityset             = DATA(lt_hdr).
*        CATCH /iwbep/cx_mgw_busi_exception .
*        CATCH /iwbep/cx_mgw_tech_exception .
*      ENDTRY.
*    ELSEIF lv_entity_set_name = 'ItemSet'.
*      TRY.
*          CALL METHOD me->itemset_get_entityset
*            EXPORTING
*              iv_entity_name           = 'Item'
*              iv_entity_set_name       = 'ItemSet'
*              iv_source_name           = 'Item'
*              is_paging                = ls_paging
*              it_key_tab               = ls_key
*              it_filter_select_options = lt_filters
*              it_navigation_path       = lt_nav
*              it_order                 = lt_order
*              iv_filter_string         = lv_filt
*              iv_search_string         = lv_search
*            IMPORTING
*              et_entityset             = DATA(lt_itm).
*        CATCH /iwbep/cx_mgw_busi_exception .
*        CATCH /iwbep/cx_mgw_tech_exception .
*      ENDTRY.
*    ELSEIF lv_entity_set_name = 'MaterialSearchHelpSet'.
*      TRY.
*          CALL METHOD me->materialsearchhe_get_entityset
*            EXPORTING
*              iv_entity_name           = 'MaterialSearchHelp'
*              iv_entity_set_name       = 'MaterialSearchHelpSet'
*              iv_source_name           = 'MaterialSearchHelp'
*              is_paging                = ls_paging
*              it_key_tab               = ls_key
*              it_filter_select_options = lt_filters
*              it_navigation_path       = lt_nav
*              it_order                 = lt_order
*              iv_filter_string         = lv_filt
*              iv_search_string         = lv_search
*            IMPORTING
*              et_entityset             = DATA(lt_mat).
*        CATCH /iwbep/cx_mgw_busi_exception .
*        CATCH /iwbep/cx_mgw_tech_exception .
*      ENDTRY.
*    ELSEIF lv_entity_set_name = 'RoleBasedUserIDSet'.
*      TRY.
*          CALL METHOD me->rolebaseduserids_get_entityset
*            EXPORTING
*              iv_entity_name           = 'RoleBasedUserID'
*              iv_entity_set_name       = 'RoleBasedUserIDSet'
*              iv_source_name           = 'RoleBasedUserID'
*              is_paging                = ls_paging
*              it_key_tab               = ls_key
*              it_filter_select_options = lt_filters
*              it_navigation_path       = lt_nav
*              it_order                 = lt_order
*              iv_filter_string         = lv_filt
*              iv_search_string         = lv_search
*            IMPORTING
*              et_entityset             = DATA(lt_role).
*        CATCH /iwbep/cx_mgw_busi_exception .
*        CATCH /iwbep/cx_mgw_tech_exception .
*      ENDTRY.
*    ELSEIF lv_entity_set_name = 'WRSPSearchHelpSet'.
*      TRY.
*          CALL METHOD me->wrspsearchhelpse_get_entityset
*            EXPORTING
*              iv_entity_name           = 'WRSPSearchHelp'
*              iv_entity_set_name       = 'WRSPSearchHelpSet'
*              iv_source_name           = 'WRSPSearchHelp'
*              is_paging                = ls_paging
*              it_key_tab               = ls_key
*              it_filter_select_options = lt_filters
*              it_navigation_path       = lt_nav
*              it_order                 = lt_order
*              iv_filter_string         = lv_filt
*              iv_search_string         = lv_search
*            IMPORTING
*              et_entityset             = DATA(lt_wrsp).
*        CATCH /iwbep/cx_mgw_busi_exception .
*        CATCH /iwbep/cx_mgw_tech_exception .
*      ENDTRY.
*    ENDIF.
*
**
***   get the data provider facade
*    TRY.
*        lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
*      CATCH /iwbep/cx_mgw_tech_exception.
*        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception.
*    ENDTRY.
**   call the delta token functionality
*    TRY.
*        CALL METHOD /iwbep/cl_query_result_log=>create_update_log_entry_hash
*          EXPORTING
*            io_tech_request_context  = io_tech_request_context
*            io_dp_facade             = lo_dp_facade
*            ir_service_document_name = mr_service_document_name
*            ir_service_version       = mr_service_version
*            it_entityset             = lt_survey
*          IMPORTING
*            et_entityset             = lt_survey
*          CHANGING
*            ev_delta_token           = lv_delta_token.
*      CATCH /iwbep/cx_qrl_locked.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_locked.
*      CATCH /iwbep/cx_qrl_delta_unavailabl.
*        RAISE EXCEPTION TYPE /iwbep/cx_qrl_delta_unavailabl.
*    ENDTRY.
**   export the delta token
*    es_response_context-deltatoken = lv_delta_token.
**   export the changed entity set
*    IF  lv_entity_set_name = 'HeaderSet'.
*      copy_data_to_ref( EXPORTING
*                         is_data = lt_hdr
*                        CHANGING
*                         cr_data = er_entityset ).
*    ELSEIF lv_entity_set_name = 'ItemSet'.
*      copy_data_to_ref( EXPORTING
*                       is_data = lt_itm
*                      CHANGING
*                       cr_data = er_entityset ).
*    ELSEIF lv_entity_set_name = 'MaterialSearchHelpSet'.
*      copy_data_to_ref( EXPORTING
*                     is_data = lt_mat
*                    CHANGING
*                     cr_data = er_entityset ).
*    ELSEIF lv_entity_set_name = 'ContractSearchHelpSet'.
*      copy_data_to_ref( EXPORTING
*                   is_data = lt_cont
*                  CHANGING
*                   cr_data = er_entityset ).
*    ELSEIF lv_entity_set_name = 'RoleBasedUserIDSet'.
*      copy_data_to_ref( EXPORTING
*                 is_data = lt_role
*                CHANGING
*                 cr_data = er_entityset ).
*    ELSEIF lv_entity_set_name = 'ApprovalFlowSet'.
*      copy_data_to_ref( EXPORTING
*               is_data = lt_appflw
*              CHANGING
*               cr_data = er_entityset ).
*    ELSEIF lv_entity_set_name = 'WRSPSearchHelpSet'.
*      copy_data_to_ref( EXPORTING
*             is_data = lt_wrsp
*            CHANGING
*             cr_data = er_entityset ).
*    ENDIF.
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
          lw_return    TYPE ZCL_ZCU_W078_SIP_TKT_O_mpc=>ts_return,
*          lw_approvers TYPE ZCL_ZCU_W078_SIP_TKT_O_mpc=>ts_auditlog_approvers,
          lt_return    TYPE ZCL_ZCU_W078_SIP_TKT_O_mpc=>tt_return.

    CONSTANTS: lc_val_mat         TYPE string VALUE 'ValidateMaterial',
               lc_contract        TYPE string VALUE 'ValidateContract',
               lc_updatestatusfpc TYPE string VALUE 'UpdateStatusFPC',
               lc_getapprovers    TYPE string VALUE 'GetApprovers',
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

*        IF lv_datakey IS NOT INITIAL.
*          CALL METHOD zclcu_sip_utility=>get_approvers_auditlog
*            EXPORTING
*              iv_datakey   = lv_datakey
*            IMPORTING
*              ev_approvers = DATA(lv_approvers).
*
*          lw_approvers-tktno = lv_datakey.
*          lw_approvers-approvers = lv_approvers.
*
*          copy_data_to_ref( EXPORTING is_data = lw_approvers
*                CHANGING cr_data = er_data ).
*
*        ELSE.
*          MESSAGE e005(zcu_msg) INTO lv_msg.
*          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*            EXPORTING
*              textid  = /iwbep/cx_mgw_busi_exception=>business_error
*              message = lv_msg.
*        ENDIF.

      WHEN OTHERS.
        MESSAGE e005(zcu_msg) INTO lv_msg.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid  = /iwbep/cx_mgw_busi_exception=>business_error
            message = lv_msg.
    ENDCASE.

    IF lv_datakey IS INITIAL.
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


  METHOD /iwbep/if_mgw_appl_srv_runtime~changeset_process.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 23.06.2020
*&  Functional Design Name : Ticketing Application
*&  Purpose                : Save/Submit
*&  Transport Request No   : D10K934677
*****************************************************************************


    CLEAR : ct_changeset_response.
    DATA : lo_proxy              TYPE REF TO zclco_ecc_field_progress_captu,
           lo_request_context    TYPE REF TO /iwbep/if_mgw_req_entity_c,
           lv_tkt                TYPE z_sipno,
           lw_changeset_response TYPE /iwbep/if_mgw_appl_types=>ty_s_changeset_response, "Change set Response
           lw_header             TYPE zcl_zcu_w078_sip_tkt_o_mpc=>ts_header,
           lw_items              TYPE zcl_zcu_w078_sip_tkt_o_mpc=>ts_item,
           lw_items_inactive     TYPE zcl_zcu_w078_sip_tkt_o_mpc=>ts_iteminactive,
           lw_deep_struc         TYPE zscu_deep_struc,
           lw_attach_ui          TYPE zcl_zcu_w078_sip_tkt_o_mpc=>ts_attachmentheader,
           lw_attachheader       TYPE zcl_zcu_w078_sip_tkt_o_mpc=>ts_attachmentheader,
           lw_routing            TYPE zcl_zcu_w078_sip_tkt_o_mpc=>ts_approvalflow,
           lw_bpm                TYPE zcl_zcu_w078_sip_tkt_o_mpc=>ts_bpm,
           lw_bpm_out            TYPE zclecc_field_progress_capture,
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
                      lw_deep_struc-header_tk_offl = lw_header ##ENH_OK.
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
                      lw_deep_struc-item_tk_offl = lw_items.
                      APPEND lw_deep_struc TO lt_deep_struc.
                      CLEAR: lw_deep_struc-item_tk_offl.
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

                    WHEN 'BPM'.    "Trigger BPM from ECC
                      <ls_request>-entry_provider->read_entry_data( IMPORTING es_data = lw_bpm ).

                      MOVE-CORRESPONDING lw_bpm TO lw_bpm_out-ecc_field_progress_capture-field_progress_capture_request.
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

            CALL METHOD zclcu_w076_offline_utility=>batch_process
              EXPORTING
                it_deep_struc = lt_deep_struc
                iv_tktno      = lv_tkt
                it_media_slug = lt_media_slug
                it_key_tab    = lt_key_tab
              CHANGING
                ct_return     = lt_return
                ct_attach_cs  = lt_attach_cs.

          ENDIF.

          IF lt_return IS INITIAL AND lw_bpm_out IS NOT INITIAL.
            IF lv_create_tkt = abap_true.
              lw_bpm_out-ecc_field_progress_capture-field_progress_capture_request-fpcnumber = lv_uniqueno.
            ELSE.
              lw_bpm_out-ecc_field_progress_capture-field_progress_capture_request-fpcnumber = lw_header-ticketno.
            ENDIF.
            "Trigger the asynchronous outbound proxy
            CREATE OBJECT lo_proxy.
            TRY.
                CALL METHOD lo_proxy->ecc_field_progress_capture_out
                  EXPORTING
                    output = lw_bpm_out.

              CATCH cx_ai_system_fault INTO DATA(lo_fault).
                DATA(lv_error) = lo_fault->get_text( ).
                APPEND INITIAL LINE TO lt_return ASSIGNING FIELD-SYMBOL(<ls_return>).
                <ls_return>-type       = zif_cu_sip=>gc_error.
                <ls_return>-message    = lv_error.
            ENDTRY.
            COMMIT WORK.
          ENDIF.
          IF lt_return IS INITIAL .
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

                WHEN 'BPM'.
                  lw_bpm-fpcnumber = lw_header-ticketno.
                  copy_data_to_ref(
                EXPORTING
                  is_data = lw_bpm
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
ENDCLASS.
