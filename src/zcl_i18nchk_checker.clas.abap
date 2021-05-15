"! <p class="shorttext synchronized" lang="en">I18n translation checker</p>
CLASS zcl_i18nchk_checker DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS:
      "! <p class="shorttext synchronized" lang="en">Creates new instance of i18n checker</p>
      constructor
        IMPORTING
          bsp_name_range   TYPE zif_i18nchk_ty_global=>ty_bsp_range
          source_language  TYPE laiso
          target_languages TYPE zif_i18nchk_ty_global=>ty_i18n_languages
        RAISING
          zcx_i18nchk_error,
      "! <p class="shorttext synchronized" lang="en">Starts check for missing/incomplete translations</p>
      check_translations,
      "! <p class="shorttext synchronized" lang="en">Returns i18n check result</p>
      get_check_result
        RETURNING
          VALUE(result) TYPE zif_i18nchk_ty_global=>ty_check_results.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      c_app_manifest     TYPE string VALUE 'manifest.json',
      c_app_i18n_prefix  TYPE string VALUE 'i18n',
      c_lib_i18n_prefix  TYPE string VALUE 'messagebundle',
      c_i18n_file_suffix TYPE string VALUE '.properties',
      c_library_manifest TYPE string VALUE '.library',

      BEGIN OF c_messages,
        language_missing TYPE string VALUE 'The language {0} is missing for file {1}',
      END OF c_messages.

    TYPES:
      BEGIN OF ty_i18n_file_group,
        path  TYPE string,
        files TYPE zif_i18nchk_ty_global=>ty_i18n_files_int,
      END OF ty_i18n_file_group,

      ty_i18n_file_groups TYPE STANDARD TABLE OF ty_i18n_file_group WITH EMPTY KEY,

      BEGIN OF ty_i18n_translation,
        file  TYPE zif_i18nchk_ty_global=>ty_i18n_file,
        texts TYPE zif_i18nchk_ty_global=>ty_i18n_texts,
      END OF ty_i18n_translation,

      ty_i18n_translations TYPE STANDARD TABLE OF ty_i18n_translation WITH EMPTY KEY,

      BEGIN OF ty_i18n_info,
        path         TYPE string,
        language_key TYPE string,
        content      TYPE string_table,
      END OF ty_i18n_info,

      ty_i18n_infos TYPE STANDARD TABLE OF ty_i18n_info WITH KEY path,

      BEGIN OF ty_i18n_map,
        app_name   TYPE o2appl-applname,
        i18n_infos TYPE ty_i18n_infos,
      END OF          ty_i18n_map,

      ty_i18n_maps TYPE STANDARD TABLE OF ty_i18n_map WITH KEY app_name,

      BEGIN OF ty_ui5_bsp,
        name               TYPE o2appl-applname,
        description        TYPE o2applt-text,
        id                 TYPE string,
        i18n_map_entries   TYPE /ui5/ui5_rep_path_map_t,
        manifest_map_entry TYPE /ui5/ui5_rep_path_map_s,
        library_map_entry  TYPE /ui5/ui5_rep_path_map_s,
        is_app             TYPE abap_bool,
      END OF ty_ui5_bsp.

    DATA:
      repo_reader                TYPE REF TO zif_i18nchk_repo_reader,
      current_repo_access        TYPE REF TO zif_i18nchk_rep_access,
      repo_access_factory        TYPE REF TO zif_i18nchk_rep_access_factory,
      bsp_name_range             TYPE zif_i18nchk_ty_global=>ty_bsp_range,
      source_language            TYPE sy-langu,
      target_languages           TYPE RANGE OF string,
      all_languages              TYPE RANGE OF string,
      ui5_apps                   TYPE TABLE OF ty_ui5_bsp,
      check_results              TYPE zif_i18nchk_ty_global=>ty_check_results,
      current_check_result       TYPE zif_i18nchk_ty_global=>ty_check_result,
      i18n_comment_pattern_range TYPE zif_i18nchk_ty_global=>ty_comment_patterns.

    METHODS:
      read_ui5_repositories,
      validate_ui5_repositories,
      validate_translations
        IMPORTING
          ui5_bsp TYPE ty_ui5_bsp,
      get_i18n_file_language
        IMPORTING
          is_app        TYPE abap_bool
          file_name     TYPE string
        RETURNING
          VALUE(result) TYPE string,
      get_relevant_i18n_files
        IMPORTING
          map_entries   TYPE /ui5/ui5_rep_path_map_t
          is_app        TYPE abap_bool
        RETURNING
          VALUE(result) TYPE ty_i18n_file_groups,
      check_file_existence
        IMPORTING
          file_group    TYPE ty_i18n_file_group
          is_app        TYPE abap_bool
        RETURNING
          VALUE(result) TYPE abap_bool,
      "! <p class="shorttext synchronized" lang="en">Returns texts of i18n file</p>
      get_i18n_file_texts
        IMPORTING
          file          TYPE zif_i18nchk_ty_global=>ty_i18n_file_int
        RETURNING
          VALUE(result) TYPE zif_i18nchk_ty_global=>ty_i18n_texts.
ENDCLASS.



CLASS zcl_i18nchk_checker IMPLEMENTATION.


  METHOD constructor.
    me->repo_reader = NEW zcl_i18nchk_repo_reader( ).
    me->repo_access_factory = NEW zcl_i18nchk_rep_access_factory( ).
    me->source_language = source_language.
    me->bsp_name_range = bsp_name_range.
    me->target_languages = VALUE #( FOR language IN target_languages ( sign = 'I' option = 'EQ' low = language ) ).
    IF source_language IN me->target_languages.
      RAISE EXCEPTION TYPE zcx_i18nchk_error
        EXPORTING
          text = |Source language '{ source_language }' is included in list of target language|.
    ENDIF.
    all_languages = VALUE #( BASE me->target_languages ( sign = 'I' option = 'EQ' low = source_language ) ).
    i18n_comment_pattern_range = VALUE zif_i18nchk_ty_global=>ty_comment_patterns(
      ( sign = 'I' option = 'CP' low = '##*' ) ).
  ENDMETHOD.


  METHOD check_translations.
    read_ui5_repositories( ).
    validate_ui5_repositories( ).
  ENDMETHOD.


  METHOD get_check_result.
    result = check_results.
  ENDMETHOD.


  METHOD validate_ui5_repositories.

    LOOP AT ui5_apps ASSIGNING FIELD-SYMBOL(<ui5_app>).
      current_repo_access = repo_access_factory->create_repo_access( <ui5_app>-name ).
      <ui5_app>-description = current_repo_access->get_bsp_description( ).
      TRY.
          DATA(mapping_entries) = current_repo_access->get_ui5_app_map_entries( ).
        CATCH /ui5/cx_ui5_rep ##NO_HANDLER.
          CONTINUE.
      ENDTRY.

      CHECK mapping_entries IS NOT INITIAL.

      <ui5_app>-manifest_map_entry = VALUE #( mapping_entries[ path = c_app_manifest ] OPTIONAL ).
      <ui5_app>-library_map_entry =  VALUE #( mapping_entries[ path = c_library_manifest ] OPTIONAL ).
      <ui5_app>-is_app = xsdbool( <ui5_app>-library_map_entry IS INITIAL ).
      <ui5_app>-i18n_map_entries = VALUE #(
        FOR <map_entry> IN mapping_entries
        WHERE ( path CP COND #(
                          WHEN <ui5_app>-is_app = abap_true THEN |{ c_app_i18n_prefix }*{ c_i18n_file_suffix }|
                          ELSE |{ c_lib_i18n_prefix }*{ c_i18n_file_suffix }| ) )
        ( <map_entry> ) ).

      CLEAR current_check_result.
      current_check_result-bsp_name = <ui5_app>-name.

      validate_translations( ui5_bsp = <ui5_app> ).

      IF current_check_result-i18n_results IS NOT INITIAL.
        check_results = VALUE #( BASE check_results ( current_check_result ) ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD validate_translations.

    DATA(i18n_file_groups) = get_relevant_i18n_files(
      map_entries = ui5_bsp-i18n_map_entries
      is_app      = ui5_bsp-is_app ).

    LOOP AT i18n_file_groups ASSIGNING FIELD-SYMBOL(<i18n_file_group>).

      LOOP AT <i18n_file_group>-files ASSIGNING FIELD-SYMBOL(<i18n_file>).
        DATA(i18n_texts) = get_i18n_file_texts( file = <i18n_file> ).
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_relevant_i18n_files.
    DATA: last_path  TYPE string,
          file_group TYPE ty_i18n_file_group.

    LOOP AT map_entries ASSIGNING FIELD-SYMBOL(<i18n_map_entry>).
      DATA(last_path_offset) = find( val = <i18n_map_entry>-path sub = '/' occ = -1 ).

      CHECK last_path_offset > 0.
      DATA(path) = <i18n_map_entry>-path(last_path_offset).

      IF last_path <> path AND file_group IS NOT INITIAL.
        IF check_file_existence( file_group = file_group is_app = is_app ).
          result = VALUE #( BASE result ( file_group ) ).
        ENDIF.
        CLEAR file_group.
      ENDIF.

      file_group-path = path.
      last_path = path.
      DATA(filename_offset) = last_path_offset + 1.

      DATA(file_name) = <i18n_map_entry>-path+filename_offset.
      DATA(language) = get_i18n_file_language(
        is_app    = is_app
        file_name = file_name ).

      CHECK language IN all_languages.

      file_group-files = VALUE #( BASE file_group-files
       ( rep_map = <i18n_map_entry>
         name     = file_name
         path     = path
         language = language ) ).
    ENDLOOP.

    IF file_group-files IS NOT INITIAL.
      IF check_file_existence( file_group = file_group is_app = is_app ).
        result = VALUE #( BASE result ( file_group ) ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD check_file_existence.
    result = abap_true.
    IF lines( file_group-files ) = lines( all_languages ).
      RETURN.
    ENDIF.

    " a language file is missing, add the appropriate message to the check result
    LOOP AT all_languages INTO DATA(language_key).
      IF NOT line_exists( file_group-files[ language = language_key-low ] ).
        CLEAR result.

        DATA(language_missing_msg) = c_messages-language_missing.
        REPLACE FIRST OCCURRENCE OF '{0}' IN language_missing_msg WITH language_key-low.
        DATA(file_name) = |{ file_group-path }/| && COND #(
          WHEN is_app = abap_true THEN |{ c_app_i18n_prefix }{ c_i18n_file_suffix }|
          ELSE |{ c_lib_i18n_prefix }{ c_i18n_file_suffix }| ).

        REPLACE FIRST OCCURRENCE OF '{1}' IN language_missing_msg
          WITH file_name.
        APPEND VALUE #( message = language_missing_msg ) TO current_check_result-i18n_results.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_i18n_file_language.
    DATA(pattern) = COND #(
      WHEN is_app = abap_true THEN c_app_i18n_prefix ELSE c_lib_i18n_prefix ) &&
      '_(\w+)\.'.

    FIND FIRST OCCURRENCE OF REGEX pattern IN file_name
     RESULTS DATA(match).

    IF match IS NOT INITIAL.
      DATA(language_match) = match-submatches[ 1 ].
      result = file_name+language_match-offset(language_match-length).
    ENDIF.
  ENDMETHOD.


  METHOD read_ui5_repositories.
    DATA(bsp_names) = repo_reader->read( bsp_name_range = bsp_name_range ).

    ui5_apps = value #( for bsp_name in bsp_names ( name = bsp_name ) ).
  ENDMETHOD.


  METHOD get_i18n_file_texts.
    DATA(contents) = current_repo_access->get_file_content(
      map_entry             = file-rep_map
      remove_comments       = abap_true
      comment_pattern_range = i18n_comment_pattern_range ).

    result = zcl_i18nchk_i18n_file_utility=>convert_to_key_value_pairs( contents ).
  ENDMETHOD.

ENDCLASS.