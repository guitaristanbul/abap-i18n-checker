"! <p class="shorttext synchronized" lang="en">REST Resource for executing i18n check</p>
CLASS zcl_i18nchk_exec_chk_res DEFINITION
  PUBLIC
  INHERITING FROM cl_rest_resource
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      if_rest_resource~get
        REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF c_parameters,
        default_language             TYPE string VALUE 'defLang',
        compare_against_default_file TYPE string VALUE 'compAgainstDef',
        target_language              TYPE string VALUE 'trgtLang',
        show_excluded                TYPE string VALUE 'showExcluded',
        bsp_name                     TYPE string VALUE 'bspName',
      END OF c_parameters.
ENDCLASS.



CLASS zcl_i18nchk_exec_chk_res IMPLEMENTATION.


  METHOD if_rest_resource~get.
    DATA: bsp_name_range   TYPE zif_i18nchk_ty_global=>ty_bsp_range,
          target_languages TYPE string_table.

    DATA(default_language) = mo_request->get_uri_query_parameter( iv_name = c_parameters-default_language ).

    DATA(show_excluded_entries) = COND #(
      WHEN mo_request->get_uri_query_parameter( iv_name = c_parameters-show_excluded ) = 'true' THEN abap_true ).

    DATA(compare_against_default) = COND #(
      WHEN mo_request->get_uri_query_parameter(
             iv_name = c_parameters-compare_against_default_file ) = 'true' THEN abap_true ).

    target_languages = VALUE #(
      FOR keyvalue IN mo_request->get_uri_query_parameters( iv_name = c_parameters-target_language )
      ( keyvalue-value ) ).

    bsp_name_range = VALUE #(
      FOR keyvalue IN mo_request->get_uri_query_parameters(
                        iv_name    = c_parameters-bsp_name
                        iv_encoded = abap_false )
      ( sign   = 'I'
        option = COND #( WHEN keyvalue-value CS '*' THEN 'CP' ELSE 'EQ' )
        low    = CONV #( keyvalue-value ) ) ).

    " execute the checks
    DATA(i18n_checker) = NEW zcl_i18nchk_checker(
      bsp_name_range            = bsp_name_range
      consider_ignored_messages = show_excluded_entries
      default_language          = default_language
      compare_against_def_file  = compare_against_default
      target_languages          = target_languages ).

    TRY.
        i18n_checker->check_translations( ).
      CATCH zcx_i18nchk_error INTO DATA(error).
        mo_response->set_status( 500 ).
        mo_response->set_reason( error->get_text( ) ).
        RETURN.
    ENDTRY.


    DATA(entity) = mo_response->create_entity( ).
    DATA(json) =  /ui2/cl_json=>serialize(
      data             = i18n_checker->get_check_result( )
      pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
      compress         = abap_false ).
    entity->set_string_data( json ).
    mo_response->set_status( 200 ).
  ENDMETHOD.


ENDCLASS.
