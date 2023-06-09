*"* use this source file for your ABAP unit test classes
CONSTANTS:
  c_test_app1 TYPE o2applname VALUE 'BSP_APP',
  c_test_app2 TYPE o2applname VALUE 'BSP_APP2'.

TYPES:
  BEGIN OF ty_repo_content,
    file    TYPE string,
    content TYPE string_table,
  END OF ty_repo_content,

  BEGIN OF ty_repo,
    name        TYPE o2applname,
    files       TYPE TABLE OF ty_repo_content WITH EMPTY KEY,
    map_entries TYPE /ui5/ui5_rep_path_map_t,
  END OF ty_repo,

  ty_repos TYPE STANDARD TABLE OF ty_repo WITH EMPTY KEY.


CLASS lcl_repo_reader DEFINITION.

  PUBLIC SECTION.
    INTERFACES:
      zif_i18nchk_repo_reader.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_repo_reader IMPLEMENTATION.

  METHOD zif_i18nchk_repo_reader~read.
    DATA: bsp_apps TYPE TABLE OF o2applname.

    bsp_apps = VALUE #( ( c_test_app1 ) ( c_test_app2 ) ).

    result = VALUE #( FOR bsp_app IN bsp_apps WHERE ( table_line IN bsp_name_range ) ( bsp_name = bsp_app ) ).
  ENDMETHOD.

ENDCLASS.


CLASS lcl_repo_access DEFINITION.

  PUBLIC SECTION.
    INTERFACES:
      zif_i18nchk_rep_access.
    METHODS:
      constructor
        IMPORTING
          repo TYPE ty_repo.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      repo TYPE ty_repo.
ENDCLASS.

CLASS lcl_repo_access IMPLEMENTATION.

  METHOD constructor.
    me->repo = repo.
  ENDMETHOD.

  METHOD zif_i18nchk_rep_access~get_bsp_description ##NEEDED.
  ENDMETHOD.

  METHOD zif_i18nchk_rep_access~get_file_content.
    result = VALUE #( repo-files[ file = map_entry-path ]-content OPTIONAL ).
  ENDMETHOD.

  METHOD zif_i18nchk_rep_access~get_ui5_app_map_entries.
    result = repo-map_entries.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_repo_access_factory DEFINITION.

  PUBLIC SECTION.
    INTERFACES:
      zif_i18nchk_rep_access_factory.
    METHODS:
      constructor
        IMPORTING
          repos TYPE ty_repos.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      repos TYPE ty_repos.
ENDCLASS.

CLASS lcl_repo_access_factory IMPLEMENTATION.

  METHOD constructor.
    me->repos = repos.
  ENDMETHOD.

  METHOD zif_i18nchk_rep_access_factory~create_repo_access.
    result = NEW lcl_repo_access( repo = VALUE #( repos[ name = bsp_name ] OPTIONAL ) ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_abap_unit DEFINITION DEFERRED.
CLASS zcl_i18nchk_checker DEFINITION LOCAL FRIENDS ltcl_abap_unit.

CLASS ltcl_abap_unit DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    METHODS:
      constructor.
  PRIVATE SECTION.
    DATA:
      test_data  TYPE ty_repos,
      test_data2 TYPE ty_repos,
      test_data3 TYPE ty_repos,
      test_data4 TYPE ty_repos,
      cut        TYPE REF TO zcl_i18nchk_checker,
      ignored_entries_double type ref to zif_i18nchk_ign_entry_reader.

    METHODS: setup,
      test_missing_file FOR TESTING,
      test_missing_default_file FOR TESTING,
      test_missing_key FOR TESTING,
      test_same_key_value FOR TESTING.
ENDCLASS.

CLASS ltcl_abap_unit IMPLEMENTATION.


  METHOD constructor.
    test_data = VALUE #(
     ( name = c_test_app1
       map_entries = VALUE #(
         ( internal_rep = 'B' path = 'i18n/i18n.properties' )
         ( internal_rep = 'B' path = 'i18n/i18n_en.properties' ) )
       files = VALUE #(
         ( file    = 'manifest.json' )
         ( file    = 'i18n/i18n.properties' )
         ( file    = 'i18n/i18n_en.properties' ) ) ) ).

    test_data2 = VALUE #(
     ( name = c_test_app1
       map_entries = VALUE #(
         ( internal_rep = 'B' path = 'i18n/i18n_en.properties' ) )
       files = VALUE #(
         ( file    = 'manifest.json' )
         ( file    = 'i18n/i18n_en.properties' ) ) ) ).

    test_data3 = VALUE #(
     ( name = c_test_app1
       map_entries = VALUE #(
         ( internal_rep = 'B' path = 'i18n/i18n.properties' )
         ( internal_rep = 'B' path = 'i18n/i18n_en.properties' )
         ( internal_rep = 'B' path = 'i18n/i18n_de.properties' ) )
       files = VALUE #(
         ( file    = 'manifest.json' )
         ( file    = 'i18n/i18n.properties'
           content = VALUE #(
             ( |dialog_title = Warning| ) ) )
         ( file    = 'i18n/i18n_en.properties'
           content = VALUE #(
             ( |dialog_title = Warning| ) ) )
         ( file    = 'i18n/i18n_de.properties' ) ) ) ).

    test_data4 = VALUE #(
     ( name = c_test_app1
       map_entries = VALUE #(
         ( internal_rep = 'B' path = 'i18n/i18n.properties' )
         ( internal_rep = 'B' path = 'i18n/i18n_de.properties' ) )
       files = VALUE #(
         ( file    = 'manifest.json' )
         ( file    = 'i18n/i18n.properties'
           content = VALUE #(
             ( |button = Click| ) ) )
         ( file    = 'i18n/i18n_de.properties'
           content = VALUE #(
             ( |button = Click| ) ) ) ) ) ).
  ENDMETHOD.


  METHOD setup.
    ignored_entries_double ?= cl_abap_testdouble=>create( object_name = 'ZIF_I18NCHK_IGN_ENTRY_READER' ).
  ENDMETHOD.


  METHOD test_missing_file.
    TRY.
        cut = NEW zcl_i18nchk_checker(
          bsp_name_range   = VALUE #( ( sign = 'I' option = 'EQ' low = c_test_app1 ) )
          target_languages = VALUE #( ( `de` ) ) ).
      CATCH zcx_i18nchk_error INTO DATA(error).
    ENDTRY.
    cl_abap_unit_assert=>assert_not_bound( act = error ).

    cut->repo_access_factory = NEW lcl_repo_access_factory( test_data ).
    cut->repo_reader = NEW lcl_repo_reader( ).
    cut->ignored_entries_reader = ignored_entries_double.

    cut->check_translations( ).

    DATA(check_results) = cut->get_check_result( ).

    cl_abap_unit_assert=>assert_not_initial( act = check_results ).
    cl_abap_unit_assert=>assert_true( act = xsdbool(
      line_exists( check_results[
        bsp_name = c_test_app1 ]-i18n_results[ message_type = zif_i18nchk_c_msg_types=>missing_i18n_file ] ) ) ).

  ENDMETHOD.


  METHOD test_missing_default_file.
    TRY.
        cut = NEW zcl_i18nchk_checker(
          bsp_name_range   = VALUE #( ( sign = 'I' option = 'EQ' low = c_test_app1 ) )
          target_languages = VALUE #( ( `en` ) ) ).
      CATCH zcx_i18nchk_error INTO DATA(error).
    ENDTRY.
    cl_abap_unit_assert=>assert_not_bound( act = error ).

    cut->repo_access_factory = NEW lcl_repo_access_factory( test_data2 ).
    cut->repo_reader = NEW lcl_repo_reader( ).
    cut->ignored_entries_reader = ignored_entries_double.

    cut->check_translations( ).

    DATA(check_results) = cut->get_check_result( ).

    cl_abap_unit_assert=>assert_not_initial( act = check_results ).
    cl_abap_unit_assert=>assert_true( act = xsdbool(
      line_exists( check_results[
        bsp_name = c_test_app1 ]-i18n_results[ message_type = zif_i18nchk_c_msg_types=>missing_default_i18n_file ] ) ) ).
  ENDMETHOD.


  METHOD test_missing_key.
    TRY.
        cut = NEW zcl_i18nchk_checker(
          bsp_name_range   = VALUE #( ( sign = 'I' option = 'EQ' low = c_test_app1 ) )
          target_languages = VALUE #( ( `de` ) ) ).
      CATCH zcx_i18nchk_error INTO DATA(error).
    ENDTRY.
    cl_abap_unit_assert=>assert_not_bound( act = error ).

    cut->repo_access_factory = NEW lcl_repo_access_factory( test_data3 ).
    cut->repo_reader = NEW lcl_repo_reader( ).
    cut->ignored_entries_reader = ignored_entries_double.

    cut->check_translations( ).

    DATA(check_results) = cut->get_check_result( ).

    cl_abap_unit_assert=>assert_not_initial( act = check_results ).
    cl_abap_unit_assert=>assert_true( act = xsdbool(
      line_exists( check_results[
        bsp_name = c_test_app1 ]-i18n_results[ message_type = zif_i18nchk_c_msg_types=>missing_i18n_key ] ) ) ).

  ENDMETHOD.


  METHOD test_same_key_value.
    TRY.
        cut = NEW zcl_i18nchk_checker(
          bsp_name_range   = VALUE #( ( sign = 'I' option = 'EQ' low = c_test_app1 ) )
          target_languages = VALUE #( ( `de` ) ) ).
      CATCH zcx_i18nchk_error INTO DATA(error).
    ENDTRY.
    cl_abap_unit_assert=>assert_not_bound( act = error ).

    cut->repo_access_factory = NEW lcl_repo_access_factory( test_data4 ).
    cut->repo_reader = NEW lcl_repo_reader( ).
    cut->ignored_entries_reader = ignored_entries_double.

    cut->check_translations( ).

    DATA(check_results) = cut->get_check_result( ).

    cl_abap_unit_assert=>assert_not_initial( act = check_results ).
    cl_abap_unit_assert=>assert_true( act = xsdbool(
      line_exists( check_results[
        bsp_name = c_test_app1 ]-i18n_results[ message_type = zif_i18nchk_c_msg_types=>i18n_key_with_same_value ] ) ) ).
  ENDMETHOD.

ENDCLASS.
