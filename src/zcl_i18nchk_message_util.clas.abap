"! <p class="shorttext synchronized" lang="en">Message util</p>
CLASS zcl_i18nchk_message_util DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Splits text into sy-msg variables</p>
      split_string_to_symsg
        IMPORTING
          text TYPE string,
      "! <p class="shorttext synchronized" lang="en">Fills text with placeholder values</p>
      "! Placeholders are identified by a number inside curly brackets, e.g. {0}
      fill_text
        IMPORTING
          text               TYPE string
          placeholder_values TYPE string_table
        RETURNING
          VALUE(result)      TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_i18nchk_message_util IMPLEMENTATION.


  METHOD split_string_to_symsg.

    DATA: offset TYPE i.

    DATA(rest_text) = text.

    DATA(msgv1) = rest_text.
    SHIFT rest_text LEFT BY 50 PLACES.
    DATA(msgv2) = rest_text.
    SHIFT rest_text LEFT BY 50 PLACES.
    DATA(msgv3) = rest_text.
    SHIFT rest_text LEFT BY 50 PLACES.
    DATA(msgv4) = rest_text.

    IF strlen( rest_text ) > 50.
      FIND ALL OCCURRENCES OF REGEX '.\s.' IN SECTION LENGTH 47 OF msgv4 MATCH OFFSET offset.
      IF sy-subrc = 0.
        offset = offset + 1.
        msgv4 = msgv4(offset).

        msgv4 = |{ msgv4 }...|.
      ENDIF.
    ENDIF.

    MESSAGE e001(00) WITH msgv1 msgv2 msgv3 msgv4 INTO DATA(msg).
  ENDMETHOD.


  METHOD fill_text.

    result = text.

    LOOP AT placeholder_values INTO DATA(placeholder_value).
      REPLACE ALL OCCURRENCES OF |\{{ sy-tabix }\}| IN result WITH placeholder_value.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
