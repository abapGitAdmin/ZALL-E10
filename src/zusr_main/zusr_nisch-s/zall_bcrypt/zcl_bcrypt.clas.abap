class ZCL_BCRYPT definition
  public
  final
  create public .

public section.

  methods CRYPT_RAW
    importing
      value(IT_PASSWORDB) type XSTRING_TABLE
      value(IT_SALT) type XSTRING_TABLE
      !IV_ROUNDS type INT4
      value(IT_CDATA) type INT4_TABLE
    returning
      value(RT_RETURN) type XSTRING_TABLE .
  class-methods HASHPW
    importing
      !IV_PASSWORD type STRING
      !IV_SALT type STRING
    returning
      value(RV_HASH) type STRING .
  class-methods CLASS_CONSTRUCTOR .
  class-methods CHECKPW
    importing
      !IV_PLAINTEXT type STRING
      !IV_HASHED type STRING
    returning
      value(RV_MATCH) type ABAP_BOOL .
  class-methods GENSALT
    importing
      !LOG_ROUNDS type INT4 optional
    returning
      value(RV_STRING) type STRING .
protected section.

  methods KEY
    importing
      !IT_KEY type XSTRING_TABLE .
  class-methods ENCODE_BASE64
    importing
      !IT_D type XSTRING_TABLE
      !IV_LEN type INT4
    returning
      value(RV_STRING) type STRING .
  methods INIT_KEY .
  methods EKSKEY
    changing
      !CT_DATA type XSTRING_TABLE
      !CT_KEY type XSTRING_TABLE .
  class-methods CHAR_64
    importing
      !IV_CHAR type C
    returning
      value(RV_INT) type I .
  class-methods DECODE_BASE64
    importing
      !IV_STRING type STRING
      !IV_MAXOLEN type INT4
    returning
      value(RT_DECODE) type XSTRINGTAB .
  class-methods STREAMTOWORD
    importing
      !IV_DATA type XSTRING_TABLE
    changing
      !CT_OFFP type INT4_TABLE
    returning
      value(RV_RETURN) type INT4 .
  methods ENCIPHER
    importing
      !IV_OFF type INT4
    changing
      !CT_LR type INT4_TABLE .
private section.

  constants BCRYPT_SALT_LEN type I value 16 ##NO_TEXT.
  constants BLOWFISH_NUM_ROUNDS type I value 16 ##NO_TEXT.
  constants GENSALT_DEFAULT_LOG2_ROUNDS type I value 10 ##NO_TEXT.
  class-data:
    base64_code         TYPE TABLE OF c .
  class-data:
    bf_crypt_ciphertext TYPE TABLE OF xstring .
  class-data:
    index_64            TYPE TABLE OF i .
  class-data:
    p_orig              TYPE TABLE OF xstring .
  class-data:
    p                   TYPE TABLE OF xstring .
  class-data:
    s_orig              TYPE TABLE OF xstring .
  class-data:
    s                   TYPE TABLE OF xstring .
  class-data M_EMPTY_BYTE type X value 00 ##NO_TEXT.

  class-methods BIT_AND
    importing
      value(IV_BIT1) type XSTRING
      value(IV_BIT2) type XSTRING
    returning
      value(RV_RESULT) type XSTRING .
  class-methods BIT_OR
    importing
      value(IV_BIT1) type XSTRING
      value(IV_BIT2) type XSTRING
    returning
      value(RV_RESULT) type XSTRING .
  class-methods GET_BYTES
    importing
      !IV_STRING type STRING
    returning
      value(RT_BYTES) type XSTRING_TABLE .
  class-methods CHAR_TO_INT
    importing
      !IV_CHAR type C
    returning
      value(RV_INT) type I .
ENDCLASS.



CLASS ZCL_BCRYPT IMPLEMENTATION.


  METHOD bit_and.

    IF xstrlen( iv_bit1 ) < xstrlen( iv_bit2 ).
      DATA(bool) = abap_true.
    ENDIF.

    WHILE xstrlen( iv_bit1 ) > xstrlen( iv_bit2 ).
      iv_bit2 = '00' && iv_bit2.
    ENDWHILE.

    WHILE xstrlen( iv_bit2 ) > xstrlen( iv_bit1 ).
      iv_bit1 = '00' && iv_bit1.
    ENDWHILE.

    rv_result = iv_bit1 BIT-AND iv_bit2.

  ENDMETHOD.


  METHOD bit_or.

    IF xstrlen( iv_bit1 ) < xstrlen( iv_bit2 ).
      DATA(bool) = abap_true.
    ENDIF.

    WHILE xstrlen( iv_bit1 ) > xstrlen( iv_bit2 ).
      iv_bit2 = '00' && iv_bit2.
    ENDWHILE.

    WHILE xstrlen( iv_bit2 ) > xstrlen( iv_bit1 ).
      iv_bit1 = '00' && iv_bit1.
    ENDWHILE.

    rv_result = iv_bit1 BIT-OR iv_bit2.

  ENDMETHOD.


  METHOD char_64.

    DATA(lv_index) = char_to_int( iv_char ) + 1.

    READ TABLE index_64 INDEX lv_index INTO rv_int.

    IF sy-subrc <> 0.

      rv_int = -1.

    ENDIF.

  ENDMETHOD.


  METHOD char_to_int.

    DATA(lo_converter) = cl_abap_conv_out_ce=>create( encoding = 'UTF-8' endian = 'L' ).

    lo_converter->write( data = iv_char ).

    rv_int = lo_converter->get_buffer( ).

  ENDMETHOD.


  METHOD checkpw.

    DATA:
      lt_hashed_bytes TYPE TABLE OF xstring,
      lt_try_bytes    TYPE TABLE OF xstring,
      lv_try_string   TYPE string.

    rv_match = abap_true.

    lv_try_string  = hashpw( iv_password = iv_plaintext iv_salt = iv_hashed ).
    lt_hashed_bytes = get_bytes( iv_hashed ).
    lt_try_bytes = get_bytes( lv_try_string ).

    IF ( lines( lt_hashed_bytes ) <> lines( lt_try_bytes ) ).
      rv_match = abap_false.
    ENDIF.

    LOOP AT lt_try_bytes ASSIGNING FIELD-SYMBOL(<byte>).
      IF ( <byte> <> lt_hashed_bytes[ sy-tabix ] ).
        rv_match = abap_false.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD class_constructor.

    DATA lt_xtring TYPE TABLE OF xstring.

    base64_code = VALUE #(
    ( '.' ) ( '/' ) ( 'A' ) ( 'B' ) ( 'C' ) ( 'D' ) ( 'E' ) ( 'F' ) ( 'G' ) ( 'H' ) ( 'I' ) ( 'J' )
    ( 'K' ) ( 'L' ) ( 'M' ) ( 'N' ) ( 'O' ) ( 'P' ) ( 'Q' ) ( 'R' ) ( 'S' ) ( 'T' ) ( 'U' ) ( 'V' )
    ( 'W' ) ( 'X' ) ( 'Y' ) ( 'Z' ) ( 'a' ) ( 'b' ) ( 'c' ) ( 'd' ) ( 'e' ) ( 'f' ) ( 'g' ) ( 'h' )
    ( 'i' ) ( 'j' ) ( 'k' ) ( 'l' ) ( 'm' ) ( 'n' ) ( 'o' ) ( 'p' ) ( 'q' ) ( 'r' ) ( 's' ) ( 't' )
    ( 'u' ) ( 'v' ) ( 'w' ) ( 'x' ) ( 'y' ) ( 'z' ) ( '0' ) ( '1' ) ( '2' ) ( '3' ) ( '4' ) ( '5' )
    ( '6' ) ( '7' ) ( '8' ) ( '9' ) ).

    bf_crypt_ciphertext = VALUE #(
    ( CONV #( '4F727068' ) ) ( CONV #( '65616E42' ) ) ( CONV #( '65686F6C' ) ) ( CONV #( '64657253' ) )
    ( CONV #( '63727944' ) ) ( CONV #( '6F756274' ) ) ).

    index_64 = VALUE #(
    ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 )
    ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 )
    ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 )
    ( -1 ) ( -1 ) ( -1 ) ( -1 ) (  0 ) (  1 ) ( 54 ) ( 55 ) ( 56 ) ( 57 ) ( 58 ) ( 59 ) ( 60 ) ( 61 )
    ( 62 ) ( 63 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) (  2 ) (  3 ) (  4 ) (  5 ) (  6 )
    (  7 ) (  8 ) (  9 ) ( 10 ) ( 11 ) ( 12 ) ( 13 ) ( 14 ) ( 15 ) ( 16 ) ( 17 ) ( 18 ) ( 19 ) ( 20 )
    ( 21 ) ( 22 ) ( 23 ) ( 24 ) ( 25 ) ( 26 ) ( 27 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( -1 ) ( 28 )
    ( 29 ) ( 30 ) ( 31 ) ( 32 ) ( 33 ) ( 34 ) ( 35 ) ( 36 ) ( 37 ) ( 38 ) ( 39 ) ( 40 ) ( 41 ) ( 42 )
    ( 43 ) ( 44 ) ( 45 ) ( 46 ) ( 47 ) ( 48 ) ( 49 ) ( 50 ) ( 51 ) ( 52 ) ( 53 ) ( -1 ) ( -1 ) ( -1 )
    ( -1 ) ( -1 ) ).

    p_orig = VALUE #(
    ( CONV #( '243F6A88' ) ) ( CONV #( '85A308D3' ) ) ( CONV #( '13198A2E' ) ) ( CONV #( '03707344' ) )
    ( CONV #( 'A4093822' ) ) ( CONV #( '299F31D0' ) ) ( CONV #( '082EFA98' ) ) ( CONV #( 'EC4E6C89' ) )
    ( CONV #( '452821E6' ) ) ( CONV #( '38D01377' ) ) ( CONV #( 'BE5466CF' ) ) ( CONV #( '34E90C6C' ) )
    ( CONV #( 'C0AC29B7' ) ) ( CONV #( 'C97C50DD' ) ) ( CONV #( '3F84D5B5' ) ) ( CONV #( 'B5470917' ) )
    ( CONV #( '9216D5D9' ) ) ( CONV #( '8979FB1B' ) ) ).

    lt_xtring = VALUE #(
    ( CONV #( 'D1310BA6' ) ) ( CONV #( '98DFB5AC' ) ) ( CONV #( '2FFD72DB' ) ) ( CONV #( 'D01ADFB7' ) )
    ( CONV #( 'B8E1AFED' ) ) ( CONV #( '6A267E96' ) ) ( CONV #( 'BA7C9045' ) ) ( CONV #( 'F12C7F99' ) )
    ( CONV #( '24A19947' ) ) ( CONV #( 'B3916CF7' ) ) ( CONV #( '0801F2E2' ) ) ( CONV #( '858EFC16' ) )
    ( CONV #( '636920D8' ) ) ( CONV #( '71574E69' ) ) ( CONV #( 'A458FEA3' ) ) ( CONV #( 'F4933D7E' ) )
    ( CONV #( '0D95748F' ) ) ( CONV #( '728EB658' ) ) ( CONV #( '718BCD58' ) ) ( CONV #( '82154AEE' ) )
    ( CONV #( '7B54A41D' ) ) ( CONV #( 'C25A59B5' ) ) ( CONV #( '9C30D539' ) ) ( CONV #( '2AF26013' ) )
    ( CONV #( 'C5D1B023' ) ) ( CONV #( '286085F0' ) ) ( CONV #( 'CA417918' ) ) ( CONV #( 'B8DB38EF' ) )
    ( CONV #( '8E79DCB0' ) ) ( CONV #( '603A180E' ) ) ( CONV #( '6C9E0E8B' ) ) ( CONV #( 'B01E8A3E' ) )
    ( CONV #( 'D71577C1' ) ) ( CONV #( 'BD314B27' ) ) ( CONV #( '78AF2FDA' ) ) ( CONV #( '55605C60' ) )
    ( CONV #( 'E65525F3' ) ) ( CONV #( 'AA55AB94' ) ) ( CONV #( '57489862' ) ) ( CONV #( '63E81440' ) )
    ( CONV #( '55CA396A' ) ) ( CONV #( '2AAB10B6' ) ) ( CONV #( 'B4CC5C34' ) ) ( CONV #( '1141E8CE' ) )
    ( CONV #( 'A15486AF' ) ) ( CONV #( '7C72E993' ) ) ( CONV #( 'B3EE1411' ) ) ( CONV #( '636FBC2A' ) )
    ( CONV #( '2BA9C55D' ) ) ( CONV #( '741831F6' ) ) ( CONV #( 'CE5C3E16' ) ) ( CONV #( '9B87931E' ) )
    ( CONV #( 'AFD6BA33' ) ) ( CONV #( '6C24CF5C' ) ) ( CONV #( '7A325381' ) ) ( CONV #( '28958677' ) )
    ( CONV #( '3B8F4898' ) ) ( CONV #( '6B4BB9AF' ) ) ( CONV #( 'C4BFE81B' ) ) ( CONV #( '66282193' ) )
    ( CONV #( '61D809CC' ) ) ( CONV #( 'FB21A991' ) ) ( CONV #( '487CAC60' ) ) ( CONV #( '5DEC8032' ) )
    ( CONV #( 'EF845D5D' ) ) ( CONV #( 'E98575B1' ) ) ( CONV #( 'DC262302' ) ) ( CONV #( 'EB651B88' ) )
    ( CONV #( '23893E81' ) ) ( CONV #( 'D396ACC5' ) ) ( CONV #( '0F6D6FF3' ) ) ( CONV #( '83F44239' ) )
    ( CONV #( '2E0B4482' ) ) ( CONV #( 'A4842004' ) ) ( CONV #( '69C8F04A' ) ) ( CONV #( '9E1F9B5E' ) )
    ( CONV #( '21C66842' ) ) ( CONV #( 'F6E96C9A' ) ) ( CONV #( '670C9C61' ) ) ( CONV #( 'ABD388F0' ) )
    ( CONV #( '6A51A0D2' ) ) ( CONV #( 'D8542F68' ) ) ( CONV #( '960FA728' ) ) ( CONV #( 'AB5133A3' ) )
    ( CONV #( '6EEF0B6C' ) ) ( CONV #( '137A3BE4' ) ) ( CONV #( 'BA3BF050' ) ) ( CONV #( '7EFB2A98' ) )
    ( CONV #( 'A1F1651D' ) ) ( CONV #( '39AF0176' ) ) ( CONV #( '66CA593E' ) ) ( CONV #( '82430E88' ) )
    ( CONV #( '8CEE8619' ) ) ( CONV #( '456F9FB4' ) ) ( CONV #( '7D84A5C3' ) ) ( CONV #( '3B8B5EBE' ) )
    ( CONV #( 'E06F75D8' ) ) ( CONV #( '85C12073' ) ) ( CONV #( '401A449F' ) ) ( CONV #( '56C16AA6' ) )
    ( CONV #( '4ED3AA62' ) ) ( CONV #( '363F7706' ) ) ( CONV #( '1BFEDF72' ) ) ( CONV #( '429B023D' ) )
    ( CONV #( '37D0D724' ) ) ( CONV #( 'D00A1248' ) ) ( CONV #( 'DB0FEAD3' ) ) ( CONV #( '49F1C09B' ) )
    ( CONV #( '075372C9' ) ) ( CONV #( '80991B7B' ) ) ( CONV #( '25D479D8' ) ) ( CONV #( 'F6E8DEF7' ) )
    ( CONV #( 'E3FE501A' ) ) ( CONV #( 'B6794C3B' ) ) ( CONV #( '976CE0BD' ) ) ( CONV #( '04C006BA' ) )
    ( CONV #( 'C1A94FB6' ) ) ( CONV #( '409F60C4' ) ) ( CONV #( '5E5C9EC2' ) ) ( CONV #( '196A2463' ) )
    ( CONV #( '68FB6FAF' ) ) ( CONV #( '3E6C53B5' ) ) ( CONV #( '1339B2EB' ) ) ( CONV #( '3B52EC6F' ) )
    ( CONV #( '6DFC511F' ) ) ( CONV #( '9B30952C' ) ) ( CONV #( 'CC814544' ) ) ( CONV #( 'AF5EBD09' ) )
    ( CONV #( 'BEE3D004' ) ) ( CONV #( 'DE334AFD' ) ) ( CONV #( '660F2807' ) ) ( CONV #( '192E4BB3' ) )
    ( CONV #( 'C0CBA857' ) ) ( CONV #( '45C8740F' ) ) ( CONV #( 'D20B5F39' ) ) ( CONV #( 'B9D3FBDB' ) )
    ( CONV #( '5579C0BD' ) ) ( CONV #( '1A60320A' ) ) ( CONV #( 'D6A100C6' ) ) ( CONV #( '402C7279' ) )
    ( CONV #( '679F25FE' ) ) ( CONV #( 'FB1FA3CC' ) ) ( CONV #( '8EA5E9F8' ) ) ( CONV #( 'DB3222F8' ) )
    ( CONV #( '3C7516DF' ) ) ( CONV #( 'FD616B15' ) ) ( CONV #( '2F501EC8' ) ) ( CONV #( 'AD0552AB' ) )
    ( CONV #( '323DB5FA' ) ) ( CONV #( 'FD238760' ) ) ( CONV #( '53317B48' ) ) ( CONV #( '3E00DF82' ) )
    ( CONV #( '9E5C57BB' ) ) ( CONV #( 'CA6F8CA0' ) ) ( CONV #( '1A87562E' ) ) ( CONV #( 'DF1769DB' ) )
    ( CONV #( 'D542A8F6' ) ) ( CONV #( '287EFFC3' ) ) ( CONV #( 'AC6732C6' ) ) ( CONV #( '8C4F5573' ) )
    ( CONV #( '695B27B0' ) ) ( CONV #( 'BBCA58C8' ) ) ( CONV #( 'E1FFA35D' ) ) ( CONV #( 'B8F011A0' ) )
    ( CONV #( '10FA3D98' ) ) ( CONV #( 'FD2183B8' ) ) ( CONV #( '4AFCB56C' ) ) ( CONV #( '2DD1D35B' ) )
    ( CONV #( '9A53E479' ) ) ( CONV #( 'B6F84565' ) ) ( CONV #( 'D28E49BC' ) ) ( CONV #( '4BFB9790' ) )
    ( CONV #( 'E1DDF2DA' ) ) ( CONV #( 'A4CB7E33' ) ) ( CONV #( '62FB1341' ) ) ( CONV #( 'CEE4C6E8' ) )
    ( CONV #( 'EF20CADA' ) ) ( CONV #( '36774C01' ) ) ( CONV #( 'D07E9EFE' ) ) ( CONV #( '2BF11FB4' ) )
    ( CONV #( '95DBDA4D' ) ) ( CONV #( 'AE909198' ) ) ( CONV #( 'EAAD8E71' ) ) ( CONV #( '6B93D5A0' ) )
    ( CONV #( 'D08ED1D0' ) ) ( CONV #( 'AFC725E0' ) ) ( CONV #( '8E3C5B2F' ) ) ( CONV #( '8E7594B7' ) )
    ( CONV #( '8FF6E2FB' ) ) ( CONV #( 'F2122B64' ) ) ( CONV #( '8888B812' ) ) ( CONV #( '900DF01C' ) )
    ( CONV #( '4FAD5EA0' ) ) ( CONV #( '688FC31C' ) ) ( CONV #( 'D1CFF191' ) ) ( CONV #( 'B3A8C1AD' ) )
    ( CONV #( '2F2F2218' ) ) ( CONV #( 'BE0E1777' ) ) ( CONV #( 'EA752DFE' ) ) ( CONV #( '8B021FA1' ) )
    ( CONV #( 'E5A0CC0F' ) ) ( CONV #( 'B56F74E8' ) ) ( CONV #( '18ACF3D6' ) ) ( CONV #( 'CE89E299' ) )
    ( CONV #( 'B4A84FE0' ) ) ( CONV #( 'FD13E0B7' ) ) ( CONV #( '7CC43B81' ) ) ( CONV #( 'D2ADA8D9' ) )
    ( CONV #( '165FA266' ) ) ( CONV #( '80957705' ) ) ( CONV #( '93CC7314' ) ) ( CONV #( '211A1477' ) )
    ( CONV #( 'E6AD2065' ) ) ( CONV #( '77B5FA86' ) ) ( CONV #( 'C75442F5' ) ) ( CONV #( 'FB9D35CF' ) )
    ( CONV #( 'EBCDAF0C' ) ) ( CONV #( '7B3E89A0' ) ) ( CONV #( 'D6411BD3' ) ) ( CONV #( 'AE1E7E49' ) )
    ( CONV #( '00250E2D' ) ) ( CONV #( '2071B35E' ) ) ( CONV #( '226800BB' ) ) ( CONV #( '57B8E0AF' ) )
    ( CONV #( '2464369B' ) ) ( CONV #( 'F009B91E' ) ) ( CONV #( '5563911D' ) ) ( CONV #( '59DFA6AA' ) )
    ( CONV #( '78C14389' ) ) ( CONV #( 'D95A537F' ) ) ( CONV #( '207D5BA2' ) ) ( CONV #( '02E5B9C5' ) )
    ( CONV #( '83260376' ) ) ( CONV #( '6295CFA9' ) ) ( CONV #( '11C81968' ) ) ( CONV #( '4E734A41' ) )
    ( CONV #( 'B3472DCA' ) ) ( CONV #( '7B14A94A' ) ) ( CONV #( '1B510052' ) ) ( CONV #( '9A532915' ) )
    ( CONV #( 'D60F573F' ) ) ( CONV #( 'BC9BC6E4' ) ) ( CONV #( '2B60A476' ) ) ( CONV #( '81E67400' ) )
    ( CONV #( '08BA6FB5' ) ) ( CONV #( '571BE91F' ) ) ( CONV #( 'F296EC6B' ) ) ( CONV #( '2A0DD915' ) )
    ( CONV #( 'B6636521' ) ) ( CONV #( 'E7B9F9B6' ) ) ( CONV #( 'FF34052E' ) ) ( CONV #( 'C5855664' ) )
    ( CONV #( '53B02D5D' ) ) ( CONV #( 'A99F8FA1' ) ) ( CONV #( '08BA4799' ) ) ( CONV #( '6E85076A' ) )
    ( CONV #( '4B7A70E9' ) ) ( CONV #( 'B5B32944' ) ) ( CONV #( 'DB75092E' ) ) ( CONV #( 'C4192623' ) )
    ( CONV #( 'AD6EA6B0' ) ) ( CONV #( '49A7DF7D' ) ) ( CONV #( '9CEE60B8' ) ) ( CONV #( '8FEDB266' ) )
    ( CONV #( 'ECAA8C71' ) ) ( CONV #( '699A17FF' ) ) ( CONV #( '5664526C' ) ) ( CONV #( 'C2B19EE1' ) )
    ( CONV #( '193602A5' ) ) ( CONV #( '75094C29' ) ) ( CONV #( 'A0591340' ) ) ( CONV #( 'E4183A3E' ) )
    ( CONV #( '3F54989A' ) ) ( CONV #( '5B429D65' ) ) ( CONV #( '6B8FE4D6' ) ) ( CONV #( '99F73FD6' ) )
    ( CONV #( 'A1D29C07' ) ) ( CONV #( 'EFE830F5' ) ) ( CONV #( '4D2D38E6' ) ) ( CONV #( 'F0255DC1' ) )
    ( CONV #( '4CDD2086' ) ) ( CONV #( '8470EB26' ) ) ( CONV #( '6382E9C6' ) ) ( CONV #( '021ECC5E' ) )
    ( CONV #( '09686B3F' ) ) ( CONV #( '3EBAEFC9' ) ) ( CONV #( '3C971814' ) ) ( CONV #( '6B6A70A1' ) )
    ( CONV #( '687F3584' ) ) ( CONV #( '52A0E286' ) ) ( CONV #( 'B79C5305' ) ) ( CONV #( 'AA500737' ) )
    ( CONV #( '3E07841C' ) ) ( CONV #( '7FDEAE5C' ) ) ( CONV #( '8E7D44EC' ) ) ( CONV #( '5716F2B8' ) )
    ( CONV #( 'B03ADA37' ) ) ( CONV #( 'F0500C0D' ) ) ( CONV #( 'F01C1F04' ) ) ( CONV #( '0200B3FF' ) )
    ( CONV #( 'AE0CF51A' ) ) ( CONV #( '3CB574B2' ) ) ( CONV #( '25837A58' ) ) ( CONV #( 'DC0921BD' ) )
    ( CONV #( 'D19113F9' ) ) ( CONV #( '7CA92FF6' ) ) ( CONV #( '94324773' ) ) ( CONV #( '22F54701' ) )
    ( CONV #( '3AE5E581' ) ) ( CONV #( '37C2DADC' ) ) ( CONV #( 'C8B57634' ) ) ( CONV #( '9AF3DDA7' ) )
    ( CONV #( 'A9446146' ) ) ( CONV #( '0FD0030E' ) ) ( CONV #( 'ECC8C73E' ) ) ( CONV #( 'A4751E41' ) )
    ( CONV #( 'E238CD99' ) ) ( CONV #( '3BEA0E2F' ) ) ( CONV #( '3280BBA1' ) ) ( CONV #( '183EB331' ) )
    ( CONV #( '4E548B38' ) ) ( CONV #( '4F6DB908' ) ) ( CONV #( '6F420D03' ) ) ( CONV #( 'F60A04BF' ) )
    ( CONV #( '2CB81290' ) ) ( CONV #( '24977C79' ) ) ( CONV #( '5679B072' ) ) ( CONV #( 'BCAF89AF' ) )
    ( CONV #( 'DE9A771F' ) ) ( CONV #( 'D9930810' ) ) ( CONV #( 'B38BAE12' ) ) ( CONV #( 'DCCF3F2E' ) )
    ( CONV #( '5512721F' ) ) ( CONV #( '2E6B7124' ) ) ( CONV #( '501ADDE6' ) ) ( CONV #( '9F84CD87' ) )
    ( CONV #( '7A584718' ) ) ( CONV #( '7408DA17' ) ) ( CONV #( 'BC9F9ABC' ) ) ( CONV #( 'E94B7D8C' ) )
    ( CONV #( 'EC7AEC3A' ) ) ( CONV #( 'DB851DFA' ) ) ( CONV #( '63094366' ) ) ( CONV #( 'C464C3D2' ) )
    ( CONV #( 'EF1C1847' ) ) ( CONV #( '3215D908' ) ) ( CONV #( 'DD433B37' ) ) ( CONV #( '24C2BA16' ) )
    ( CONV #( '12A14D43' ) ) ( CONV #( '2A65C451' ) ) ( CONV #( '50940002' ) ) ( CONV #( '133AE4DD' ) )
    ( CONV #( '71DFF89E' ) ) ( CONV #( '10314E55' ) ) ( CONV #( '81AC77D6' ) ) ( CONV #( '5F11199B' ) )
    ( CONV #( '043556F1' ) ) ( CONV #( 'D7A3C76B' ) ) ( CONV #( '3C11183B' ) ) ( CONV #( '5924A509' ) )
    ( CONV #( 'F28FE6ED' ) ) ( CONV #( '97F1FBFA' ) ) ( CONV #( '9EBABF2C' ) ) ( CONV #( '1E153C6E' ) )
    ( CONV #( '86E34570' ) ) ( CONV #( 'EAE96FB1' ) ) ( CONV #( '860E5E0A' ) ) ( CONV #( '5A3E2AB3' ) )
    ( CONV #( '771FE71C' ) ) ( CONV #( '4E3D06FA' ) ) ( CONV #( '2965DCB9' ) ) ( CONV #( '99E71D0F' ) )
    ( CONV #( '803E89D6' ) ) ( CONV #( '5266C825' ) ) ( CONV #( '2E4CC978' ) ) ( CONV #( '9C10B36A' ) )
    ( CONV #( 'C6150EBA' ) ) ( CONV #( '94E2EA78' ) ) ( CONV #( 'A5FC3C53' ) ) ( CONV #( '1E0A2DF4' ) )
    ( CONV #( 'F2F74EA7' ) ) ( CONV #( '361D2B3D' ) ) ( CONV #( '1939260F' ) ) ( CONV #( '19C27960' ) )
    ( CONV #( '5223A708' ) ) ( CONV #( 'F71312B6' ) ) ( CONV #( 'EBADFE6E' ) ) ( CONV #( 'EAC31F66' ) )
    ( CONV #( 'E3BC4595' ) ) ( CONV #( 'A67BC883' ) ) ( CONV #( 'B17F37D1' ) ) ( CONV #( '018CFF28' ) )
    ( CONV #( 'C332DDEF' ) ) ( CONV #( 'BE6C5AA5' ) ) ( CONV #( '65582185' ) ) ( CONV #( '68AB9802' ) )
    ( CONV #( 'EECEA50F' ) ) ( CONV #( 'DB2F953B' ) ) ( CONV #( '2AEF7DAD' ) ) ( CONV #( '5B6E2F84' ) )
    ( CONV #( '1521B628' ) ) ( CONV #( '29076170' ) ) ( CONV #( 'ECDD4775' ) ) ( CONV #( '619F1510' ) )
    ( CONV #( '13CCA830' ) ) ( CONV #( 'EB61BD96' ) ) ( CONV #( '0334FE1E' ) ) ( CONV #( 'AA0363CF' ) )
    ( CONV #( 'B5735C90' ) ) ( CONV #( '4C70A239' ) ) ( CONV #( 'D59E9E0B' ) ) ( CONV #( 'CBAADE14' ) )
    ( CONV #( 'EECC86BC' ) ) ( CONV #( '60622CA7' ) ) ( CONV #( '9CAB5CAB' ) ) ( CONV #( 'B2F3846E' ) )
    ( CONV #( '648B1EAF' ) ) ( CONV #( '19BDF0CA' ) ) ( CONV #( 'A02369B9' ) ) ( CONV #( '655ABB50' ) )
    ( CONV #( '40685A32' ) ) ( CONV #( '3C2AB4B3' ) ) ( CONV #( '319EE9D5' ) ) ( CONV #( 'C021B8F7' ) )
    ( CONV #( '9B540B19' ) ) ( CONV #( '875FA099' ) ) ( CONV #( '95F7997E' ) ) ( CONV #( '623D7DA8' ) )
    ( CONV #( 'F837889A' ) ) ( CONV #( '97E32D77' ) ) ( CONV #( '11ED935F' ) ) ( CONV #( '16681281' ) )
    ( CONV #( '0E358829' ) ) ( CONV #( 'C7E61FD6' ) ) ( CONV #( '96DEDFA1' ) ) ( CONV #( '7858BA99' ) )
    ( CONV #( '57F584A5' ) ) ( CONV #( '1B227263' ) ) ( CONV #( '9B83C3FF' ) ) ( CONV #( '1AC24696' ) )
    ( CONV #( 'CDB30AEB' ) ) ( CONV #( '532E3054' ) ) ( CONV #( '8FD948E4' ) ) ( CONV #( '6DBC3128' ) )
    ( CONV #( '58EBF2EF' ) ) ( CONV #( '34C6FFEA' ) ) ( CONV #( 'FE28ED61' ) ) ( CONV #( 'EE7C3C73' ) )
    ( CONV #( '5D4A14D9' ) ) ( CONV #( 'E864B7E3' ) ) ( CONV #( '42105D14' ) ) ( CONV #( '203E13E0' ) )
    ( CONV #( '45EEE2B6' ) ) ( CONV #( 'A3AAABEA' ) ) ( CONV #( 'DB6C4F15' ) ) ( CONV #( 'FACB4FD0' ) )
    ( CONV #( 'C742F442' ) ) ( CONV #( 'EF6ABBB5' ) ) ( CONV #( '654F3B1D' ) ) ( CONV #( '41CD2105' ) )
    ( CONV #( 'D81E799E' ) ) ( CONV #( '86854DC7' ) ) ( CONV #( 'E44B476A' ) ) ( CONV #( '3D816250' ) )
    ( CONV #( 'CF62A1F2' ) ) ( CONV #( '5B8D2646' ) ) ( CONV #( 'FC8883A0' ) ) ( CONV #( 'C1C7B6A3' ) )
    ( CONV #( '7F1524C3' ) ) ( CONV #( '69CB7492' ) ) ( CONV #( '47848A0B' ) ) ( CONV #( '5692B285' ) )
    ( CONV #( '095BBF00' ) ) ( CONV #( 'AD19489D' ) ) ( CONV #( '1462B174' ) ) ( CONV #( '23820E00' ) )
    ( CONV #( '58428D2A' ) ) ( CONV #( '0C55F5EA' ) ) ( CONV #( '1DADF43E' ) ) ( CONV #( '233F7061' ) )
    ( CONV #( '3372F092' ) ) ( CONV #( '8D937E41' ) ) ( CONV #( 'D65FECF1' ) ) ( CONV #( '6C223BDB' ) )
    ( CONV #( '7CDE3759' ) ) ( CONV #( 'CBEE7460' ) ) ( CONV #( '4085F2A7' ) ) ( CONV #( 'CE77326E' ) )
    ( CONV #( 'A6078084' ) ) ( CONV #( '19F8509E' ) ) ( CONV #( 'E8EFD855' ) ) ( CONV #( '61D99735' ) )
    ( CONV #( 'A969A7AA' ) ) ( CONV #( 'C50C06C2' ) ) ( CONV #( '5A04ABFC' ) ) ( CONV #( '800BCADC' ) )
    ( CONV #( '9E447A2E' ) ) ( CONV #( 'C3453484' ) ) ( CONV #( 'FDD56705' ) ) ( CONV #( '0E1E9EC9' ) )
    ( CONV #( 'DB73DBD3' ) ) ( CONV #( '105588CD' ) ) ( CONV #( '675FDA79' ) ) ( CONV #( 'E3674340' ) )
    ( CONV #( 'C5C43465' ) ) ( CONV #( '713E38D8' ) ) ( CONV #( '3D28F89E' ) ) ( CONV #( 'F16DFF20' ) )
    ( CONV #( '153E21E7' ) ) ( CONV #( '8FB03D4A' ) ) ( CONV #( 'E6E39F2B' ) ) ( CONV #( 'DB83ADF7' ) ) ).

    APPEND LINES OF lt_xtring TO s_orig.

    lt_xtring = VALUE #(
    ( CONV #( 'E93D5A68' ) ) ( CONV #( '948140F7' ) ) ( CONV #( 'F64C261C' ) ) ( CONV #( '94692934' ) )
    ( CONV #( '411520F7' ) ) ( CONV #( '7602D4F7' ) ) ( CONV #( 'BCF46B2E' ) ) ( CONV #( 'D4A20068' ) )
    ( CONV #( 'D4082471' ) ) ( CONV #( '3320F46A' ) ) ( CONV #( '43B7D4B7' ) ) ( CONV #( '500061AF' ) )
    ( CONV #( '1E39F62E' ) ) ( CONV #( '97244546' ) ) ( CONV #( '14214F74' ) ) ( CONV #( 'BF8B8840' ) )
    ( CONV #( '4D95FC1D' ) ) ( CONV #( '96B591AF' ) ) ( CONV #( '70F4DDD3' ) ) ( CONV #( '66A02F45' ) )
    ( CONV #( 'BFBC09EC' ) ) ( CONV #( '03BD9785' ) ) ( CONV #( '7FAC6DD0' ) ) ( CONV #( '31CB8504' ) )
    ( CONV #( '96EB27B3' ) ) ( CONV #( '55FD3941' ) ) ( CONV #( 'DA2547E6' ) ) ( CONV #( 'ABCA0A9A' ) )
    ( CONV #( '28507825' ) ) ( CONV #( '530429F4' ) ) ( CONV #( '0A2C86DA' ) ) ( CONV #( 'E9B66DFB' ) )
    ( CONV #( '68DC1462' ) ) ( CONV #( 'D7486900' ) ) ( CONV #( '680EC0A4' ) ) ( CONV #( '27A18DEE' ) )
    ( CONV #( '4F3FFEA2' ) ) ( CONV #( 'E887AD8C' ) ) ( CONV #( 'B58CE006' ) ) ( CONV #( '7AF4D6B6' ) )
    ( CONV #( 'AACE1E7C' ) ) ( CONV #( 'D3375FEC' ) ) ( CONV #( 'CE78A399' ) ) ( CONV #( '406B2A42' ) )
    ( CONV #( '20FE9E35' ) ) ( CONV #( 'D9F385B9' ) ) ( CONV #( 'EE39D7AB' ) ) ( CONV #( '3B124E8B' ) )
    ( CONV #( '1DC9FAF7' ) ) ( CONV #( '4B6D1856' ) ) ( CONV #( '26A36631' ) ) ( CONV #( 'EAE397B2' ) )
    ( CONV #( '3A6EFA74' ) ) ( CONV #( 'DD5B4332' ) ) ( CONV #( '6841E7F7' ) ) ( CONV #( 'CA7820FB' ) )
    ( CONV #( 'FB0AF54E' ) ) ( CONV #( 'D8FEB397' ) ) ( CONV #( '454056AC' ) ) ( CONV #( 'BA489527' ) )
    ( CONV #( '55533A3A' ) ) ( CONV #( '20838D87' ) ) ( CONV #( 'FE6BA9B7' ) ) ( CONV #( 'D096954B' ) )
    ( CONV #( '55A867BC' ) ) ( CONV #( 'A1159A58' ) ) ( CONV #( 'CCA92963' ) ) ( CONV #( '99E1DB33' ) )
    ( CONV #( 'A62A4A56' ) ) ( CONV #( '3F3125F9' ) ) ( CONV #( '5EF47E1C' ) ) ( CONV #( '9029317C' ) )
    ( CONV #( 'FDF8E802' ) ) ( CONV #( '04272F70' ) ) ( CONV #( '80BB155C' ) ) ( CONV #( '05282CE3' ) )
    ( CONV #( '95C11548' ) ) ( CONV #( 'E4C66D22' ) ) ( CONV #( '48C1133F' ) ) ( CONV #( 'C70F86DC' ) )
    ( CONV #( '07F9C9EE' ) ) ( CONV #( '41041F0F' ) ) ( CONV #( '404779A4' ) ) ( CONV #( '5D886E17' ) )
    ( CONV #( '325F51EB' ) ) ( CONV #( 'D59BC0D1' ) ) ( CONV #( 'F2BCC18F' ) ) ( CONV #( '41113564' ) )
    ( CONV #( '257B7834' ) ) ( CONV #( '602A9C60' ) ) ( CONV #( 'DFF8E8A3' ) ) ( CONV #( '1F636C1B' ) )
    ( CONV #( '0E12B4C2' ) ) ( CONV #( '02E1329E' ) ) ( CONV #( 'AF664FD1' ) ) ( CONV #( 'CAD18115' ) )
    ( CONV #( '6B2395E0' ) ) ( CONV #( '333E92E1' ) ) ( CONV #( '3B240B62' ) ) ( CONV #( 'EEBEB922' ) )
    ( CONV #( '85B2A20E' ) ) ( CONV #( 'E6BA0D99' ) ) ( CONV #( 'DE720C8C' ) ) ( CONV #( '2DA2F728' ) )
    ( CONV #( 'D0127845' ) ) ( CONV #( '95B794FD' ) ) ( CONV #( '647D0862' ) ) ( CONV #( 'E7CCF5F0' ) )
    ( CONV #( '5449A36F' ) ) ( CONV #( '877D48FA' ) ) ( CONV #( 'C39DFD27' ) ) ( CONV #( 'F33E8D1E' ) )
    ( CONV #( '0A476341' ) ) ( CONV #( '992EFF74' ) ) ( CONV #( '3A6F6EAB' ) ) ( CONV #( 'F4F8FD37' ) )
    ( CONV #( 'A812DC60' ) ) ( CONV #( 'A1EBDDF8' ) ) ( CONV #( '991BE14C' ) ) ( CONV #( 'DB6E6B0D' ) )
    ( CONV #( 'C67B5510' ) ) ( CONV #( '6D672C37' ) ) ( CONV #( '2765D43B' ) ) ( CONV #( 'DCD0E804' ) )
    ( CONV #( 'F1290DC7' ) ) ( CONV #( 'CC00FFA3' ) ) ( CONV #( 'B5390F92' ) ) ( CONV #( '690FED0B' ) )
    ( CONV #( '667B9FFB' ) ) ( CONV #( 'CEDB7D9C' ) ) ( CONV #( 'A091CF0B' ) ) ( CONV #( 'D9155EA3' ) )
    ( CONV #( 'BB132F88' ) ) ( CONV #( '515BAD24' ) ) ( CONV #( '7B9479BF' ) ) ( CONV #( '763BD6EB' ) )
    ( CONV #( '37392EB3' ) ) ( CONV #( 'CC115979' ) ) ( CONV #( '8026E297' ) ) ( CONV #( 'F42E312D' ) )
    ( CONV #( '6842ADA7' ) ) ( CONV #( 'C66A2B3B' ) ) ( CONV #( '12754CCC' ) ) ( CONV #( '782EF11C' ) )
    ( CONV #( '6A124237' ) ) ( CONV #( 'B79251E7' ) ) ( CONV #( '06A1BBE6' ) ) ( CONV #( '4BFB6350' ) )
    ( CONV #( '1A6B1018' ) ) ( CONV #( '11CAEDFA' ) ) ( CONV #( '3D25BDD8' ) ) ( CONV #( 'E2E1C3C9' ) )
    ( CONV #( '44421659' ) ) ( CONV #( '0A121386' ) ) ( CONV #( 'D90CEC6E' ) ) ( CONV #( 'D5ABEA2A' ) )
    ( CONV #( '64AF674E' ) ) ( CONV #( 'DA86A85F' ) ) ( CONV #( 'BEBFE988' ) ) ( CONV #( '64E4C3FE' ) )
    ( CONV #( '9DBC8057' ) ) ( CONV #( 'F0F7C086' ) ) ( CONV #( '60787BF8' ) ) ( CONV #( '6003604D' ) )
    ( CONV #( 'D1FD8346' ) ) ( CONV #( 'F6381FB0' ) ) ( CONV #( '7745AE04' ) ) ( CONV #( 'D736FCCC' ) )
    ( CONV #( '83426B33' ) ) ( CONV #( 'F01EAB71' ) ) ( CONV #( 'B0804187' ) ) ( CONV #( '3C005E5F' ) )
    ( CONV #( '77A057BE' ) ) ( CONV #( 'BDE8AE24' ) ) ( CONV #( '55464299' ) ) ( CONV #( 'BF582E61' ) )
    ( CONV #( '4E58F48F' ) ) ( CONV #( 'F2DDFDA2' ) ) ( CONV #( 'F474EF38' ) ) ( CONV #( '8789BDC2' ) )
    ( CONV #( '5366F9C3' ) ) ( CONV #( 'C8B38E74' ) ) ( CONV #( 'B475F255' ) ) ( CONV #( '46FCD9B9' ) )
    ( CONV #( '7AEB2661' ) ) ( CONV #( '8B1DDF84' ) ) ( CONV #( '846A0E79' ) ) ( CONV #( '915F95E2' ) )
    ( CONV #( '466E598E' ) ) ( CONV #( '20B45770' ) ) ( CONV #( '8CD55591' ) ) ( CONV #( 'C902DE4C' ) )
    ( CONV #( 'B90BACE1' ) ) ( CONV #( 'BB8205D0' ) ) ( CONV #( '11A86248' ) ) ( CONV #( '7574A99E' ) )
    ( CONV #( 'B77F19B6' ) ) ( CONV #( 'E0A9DC09' ) ) ( CONV #( '662D09A1' ) ) ( CONV #( 'C4324633' ) )
    ( CONV #( 'E85A1F02' ) ) ( CONV #( '09F0BE8C' ) ) ( CONV #( '4A99A025' ) ) ( CONV #( '1D6EFE10' ) )
    ( CONV #( '1AB93D1D' ) ) ( CONV #( '0BA5A4DF' ) ) ( CONV #( 'A186F20F' ) ) ( CONV #( '2868F169' ) )
    ( CONV #( 'DCB7DA83' ) ) ( CONV #( '573906FE' ) ) ( CONV #( 'A1E2CE9B' ) ) ( CONV #( '4FCD7F52' ) )
    ( CONV #( '50115E01' ) ) ( CONV #( 'A70683FA' ) ) ( CONV #( 'A002B5C4' ) ) ( CONV #( '0DE6D027' ) )
    ( CONV #( '9AF88C27' ) ) ( CONV #( '773F8641' ) ) ( CONV #( 'C3604C06' ) ) ( CONV #( '61A806B5' ) )
    ( CONV #( 'F0177A28' ) ) ( CONV #( 'C0F586E0' ) ) ( CONV #( '006058AA' ) ) ( CONV #( '30DC7D62' ) )
    ( CONV #( '11E69ED7' ) ) ( CONV #( '2338EA63' ) ) ( CONV #( '53C2DD94' ) ) ( CONV #( 'C2C21634' ) )
    ( CONV #( 'BBCBEE56' ) ) ( CONV #( '90BCB6DE' ) ) ( CONV #( 'EBFC7DA1' ) ) ( CONV #( 'CE591D76' ) )
    ( CONV #( '6F05E409' ) ) ( CONV #( '4B7C0188' ) ) ( CONV #( '39720A3D' ) ) ( CONV #( '7C927C24' ) )
    ( CONV #( '86E3725F' ) ) ( CONV #( '724D9DB9' ) ) ( CONV #( '1AC15BB4' ) ) ( CONV #( 'D39EB8FC' ) )
    ( CONV #( 'ED545578' ) ) ( CONV #( '08FCA5B5' ) ) ( CONV #( 'D83D7CD3' ) ) ( CONV #( '4DAD0FC4' ) )
    ( CONV #( '1E50EF5E' ) ) ( CONV #( 'B161E6F8' ) ) ( CONV #( 'A28514D9' ) ) ( CONV #( '6C51133C' ) )
    ( CONV #( '6FD5C7E7' ) ) ( CONV #( '56E14EC4' ) ) ( CONV #( '362ABFCE' ) ) ( CONV #( 'DDC6C837' ) )
    ( CONV #( 'D79A3234' ) ) ( CONV #( '92638212' ) ) ( CONV #( '670EFA8E' ) ) ( CONV #( '406000E0' ) )
    ( CONV #( '3A39CE37' ) ) ( CONV #( 'D3FAF5CF' ) ) ( CONV #( 'ABC27737' ) ) ( CONV #( '5AC52D1B' ) )
    ( CONV #( '5CB0679E' ) ) ( CONV #( '4FA33742' ) ) ( CONV #( 'D3822740' ) ) ( CONV #( '99BC9BBE' ) )
    ( CONV #( 'D5118E9D' ) ) ( CONV #( 'BF0F7315' ) ) ( CONV #( 'D62D1C7E' ) ) ( CONV #( 'C700C47B' ) )
    ( CONV #( 'B78C1B6B' ) ) ( CONV #( '21A19045' ) ) ( CONV #( 'B26EB1BE' ) ) ( CONV #( '6A366EB4' ) )
    ( CONV #( '5748AB2F' ) ) ( CONV #( 'BC946E79' ) ) ( CONV #( 'C6A376D2' ) ) ( CONV #( '6549C2C8' ) )
    ( CONV #( '530FF8EE' ) ) ( CONV #( '468DDE7D' ) ) ( CONV #( 'D5730A1D' ) ) ( CONV #( '4CD04DC6' ) )
    ( CONV #( '2939BBDB' ) ) ( CONV #( 'A9BA4650' ) ) ( CONV #( 'AC9526E8' ) ) ( CONV #( 'BE5EE304' ) )
    ( CONV #( 'A1FAD5F0' ) ) ( CONV #( '6A2D519A' ) ) ( CONV #( '63EF8CE2' ) ) ( CONV #( '9A86EE22' ) )
    ( CONV #( 'C089C2B8' ) ) ( CONV #( '43242EF6' ) ) ( CONV #( 'A51E03AA' ) ) ( CONV #( '9CF2D0A4' ) )
    ( CONV #( '83C061BA' ) ) ( CONV #( '9BE96A4D' ) ) ( CONV #( '8FE51550' ) ) ( CONV #( 'BA645BD6' ) )
    ( CONV #( '2826A2F9' ) ) ( CONV #( 'A73A3AE1' ) ) ( CONV #( '4BA99586' ) ) ( CONV #( 'EF5562E9' ) )
    ( CONV #( 'C72FEFD3' ) ) ( CONV #( 'F752F7DA' ) ) ( CONV #( '3F046F69' ) ) ( CONV #( '77FA0A59' ) )
    ( CONV #( '80E4A915' ) ) ( CONV #( '87B08601' ) ) ( CONV #( '9B09E6AD' ) ) ( CONV #( '3B3EE593' ) )
    ( CONV #( 'E990FD5A' ) ) ( CONV #( '9E34D797' ) ) ( CONV #( '2CF0B7D9' ) ) ( CONV #( '022B8B51' ) )
    ( CONV #( '96D5AC3A' ) ) ( CONV #( '017DA67D' ) ) ( CONV #( 'D1CF3ED6' ) ) ( CONV #( '7C7D2D28' ) )
    ( CONV #( '1F9F25CF' ) ) ( CONV #( 'ADF2B89B' ) ) ( CONV #( '5AD6B472' ) ) ( CONV #( '5A88F54C' ) )
    ( CONV #( 'E029AC71' ) ) ( CONV #( 'E019A5E6' ) ) ( CONV #( '47B0ACFD' ) ) ( CONV #( 'ED93FA9B' ) )
    ( CONV #( 'E8D3C48D' ) ) ( CONV #( '283B57CC' ) ) ( CONV #( 'F8D56629' ) ) ( CONV #( '79132E28' ) )
    ( CONV #( '785F0191' ) ) ( CONV #( 'ED756055' ) ) ( CONV #( 'F7960E44' ) ) ( CONV #( 'E3D35E8C' ) )
    ( CONV #( '15056DD4' ) ) ( CONV #( '88F46DBA' ) ) ( CONV #( '03A16125' ) ) ( CONV #( '0564F0BD' ) )
    ( CONV #( 'C3EB9E15' ) ) ( CONV #( '3C9057A2' ) ) ( CONV #( '97271AEC' ) ) ( CONV #( 'A93A072A' ) )
    ( CONV #( '1B3F6D9B' ) ) ( CONV #( '1E6321F5' ) ) ( CONV #( 'F59C66FB' ) ) ( CONV #( '26DCF319' ) )
    ( CONV #( '7533D928' ) ) ( CONV #( 'B155FDF5' ) ) ( CONV #( '03563482' ) ) ( CONV #( '8ABA3CBB' ) )
    ( CONV #( '28517711' ) ) ( CONV #( 'C20AD9F8' ) ) ( CONV #( 'ABCC5167' ) ) ( CONV #( 'CCAD925F' ) )
    ( CONV #( '4DE81751' ) ) ( CONV #( '3830DC8E' ) ) ( CONV #( '379D5862' ) ) ( CONV #( '9320F991' ) )
    ( CONV #( 'EA7A90C2' ) ) ( CONV #( 'FB3E7BCE' ) ) ( CONV #( '5121CE64' ) ) ( CONV #( '774FBE32' ) )
    ( CONV #( 'A8B6E37E' ) ) ( CONV #( 'C3293D46' ) ) ( CONV #( '48DE5369' ) ) ( CONV #( '6413E680' ) )
    ( CONV #( 'A2AE0810' ) ) ( CONV #( 'DD6DB224' ) ) ( CONV #( '69852DFD' ) ) ( CONV #( '09072166' ) )
    ( CONV #( 'B39A460A' ) ) ( CONV #( '6445C0DD' ) ) ( CONV #( '586CDECF' ) ) ( CONV #( '1C20C8AE' ) )
    ( CONV #( '5BBEF7DD' ) ) ( CONV #( '1B588D40' ) ) ( CONV #( 'CCD2017F' ) ) ( CONV #( '6BB4E3BB' ) )
    ( CONV #( 'DDA26A7E' ) ) ( CONV #( '3A59FF45' ) ) ( CONV #( '3E350A44' ) ) ( CONV #( 'BCB4CDD5' ) )
    ( CONV #( '72EACEA8' ) ) ( CONV #( 'FA6484BB' ) ) ( CONV #( '8D6612AE' ) ) ( CONV #( 'BF3C6F47' ) )
    ( CONV #( 'D29BE463' ) ) ( CONV #( '542F5D9E' ) ) ( CONV #( 'AEC2771B' ) ) ( CONV #( 'F64E6370' ) )
    ( CONV #( '740E0D8D' ) ) ( CONV #( 'E75B1357' ) ) ( CONV #( 'F8721671' ) ) ( CONV #( 'AF537D5D' ) )
    ( CONV #( '4040CB08' ) ) ( CONV #( '4EB4E2CC' ) ) ( CONV #( '34D2466A' ) ) ( CONV #( '0115AF84' ) )
    ( CONV #( 'E1B00428' ) ) ( CONV #( '95983A1D' ) ) ( CONV #( '06B89FB4' ) ) ( CONV #( 'CE6EA048' ) )
    ( CONV #( '6F3F3B82' ) ) ( CONV #( '3520AB82' ) ) ( CONV #( '011A1D4B' ) ) ( CONV #( '277227F8' ) )
    ( CONV #( '611560B1' ) ) ( CONV #( 'E7933FDC' ) ) ( CONV #( 'BB3A792B' ) ) ( CONV #( '344525BD' ) )
    ( CONV #( 'A08839E1' ) ) ( CONV #( '51CE794B' ) ) ( CONV #( '2F32C9B7' ) ) ( CONV #( 'A01FBAC9' ) )
    ( CONV #( 'E01CC87E' ) ) ( CONV #( 'BCC7D1F6' ) ) ( CONV #( 'CF0111C3' ) ) ( CONV #( 'A1E8AAC7' ) )
    ( CONV #( '1A908749' ) ) ( CONV #( 'D44FBD9A' ) ) ( CONV #( 'D0DADECB' ) ) ( CONV #( 'D50ADA38' ) )
    ( CONV #( '0339C32A' ) ) ( CONV #( 'C6913667' ) ) ( CONV #( '8DF9317C' ) ) ( CONV #( 'E0B12B4F' ) )
    ( CONV #( 'F79E59B7' ) ) ( CONV #( '43F5BB3A' ) ) ( CONV #( 'F2D519FF' ) ) ( CONV #( '27D9459C' ) )
    ( CONV #( 'BF97222C' ) ) ( CONV #( '15E6FC2A' ) ) ( CONV #( '0F91FC71' ) ) ( CONV #( '9B941525' ) )
    ( CONV #( 'FAE59361' ) ) ( CONV #( 'CEB69CEB' ) ) ( CONV #( 'C2A86459' ) ) ( CONV #( '12BAA8D1' ) )
    ( CONV #( 'B6C1075E' ) ) ( CONV #( 'E3056A0C' ) ) ( CONV #( '10D25065' ) ) ( CONV #( 'CB03A442' ) )
    ( CONV #( 'E0EC6E0E' ) ) ( CONV #( '1698DB3B' ) ) ( CONV #( '4C98A0BE' ) ) ( CONV #( '3278E964' ) )
    ( CONV #( '9F1F9532' ) ) ( CONV #( 'E0D392DF' ) ) ( CONV #( 'D3A0342B' ) ) ( CONV #( '8971F21E' ) )
    ( CONV #( '1B0A7441' ) ) ( CONV #( '4BA3348C' ) ) ( CONV #( 'C5BE7120' ) ) ( CONV #( 'C37632D8' ) )
    ( CONV #( 'DF359F8D' ) ) ( CONV #( '9B992F2E' ) ) ( CONV #( 'E60B6F47' ) ) ( CONV #( '0FE3F11D' ) )
    ( CONV #( 'E54CDA54' ) ) ( CONV #( '1EDAD891' ) ) ( CONV #( 'CE6279CF' ) ) ( CONV #( 'CD3E7E6F' ) )
    ( CONV #( '1618B166' ) ) ( CONV #( 'FD2C1D05' ) ) ( CONV #( '848FD2C5' ) ) ( CONV #( 'F6FB2299' ) )
    ( CONV #( 'F523F357' ) ) ( CONV #( 'A6327623' ) ) ( CONV #( '93A83531' ) ) ( CONV #( '56CCCD02' ) )
    ( CONV #( 'ACF08162' ) ) ( CONV #( '5A75EBB5' ) ) ( CONV #( '6E163697' ) ) ( CONV #( '88D273CC' ) )
    ( CONV #( 'DE966292' ) ) ( CONV #( '81B949D0' ) ) ( CONV #( '4C50901B' ) ) ( CONV #( '71C65614' ) )
    ( CONV #( 'E6C6C7BD' ) ) ( CONV #( '327A140A' ) ) ( CONV #( '45E1D006' ) ) ( CONV #( 'C3F27B9A' ) )
    ( CONV #( 'C9AA53FD' ) ) ( CONV #( '62A80F00' ) ) ( CONV #( 'BB25BFE2' ) ) ( CONV #( '35BDD2F6' ) )
    ( CONV #( '71126905' ) ) ( CONV #( 'B2040222' ) ) ( CONV #( 'B6CBCF7C' ) ) ( CONV #( 'CD769C2B' ) )
    ( CONV #( '53113EC0' ) ) ( CONV #( '1640E3D3' ) ) ( CONV #( '38ABBD60' ) ) ( CONV #( '2547ADF0' ) )
    ( CONV #( 'BA38209C' ) ) ( CONV #( 'F746CE76' ) ) ( CONV #( '77AFA1C5' ) ) ( CONV #( '20756060' ) )
    ( CONV #( '85CBFE4E' ) ) ( CONV #( '8AE88DD8' ) ) ( CONV #( '7AAAF9B0' ) ) ( CONV #( '4CF9AA7E' ) )
    ( CONV #( '1948C25C' ) ) ( CONV #( '02FB8A8C' ) ) ( CONV #( '01C36AE4' ) ) ( CONV #( 'D6EBE1F9' ) )
    ( CONV #( '90D4F869' ) ) ( CONV #( 'A65CDEA0' ) ) ( CONV #( '3F09252D' ) ) ( CONV #( 'C208E69F' ) )
    ( CONV #( 'B74E6132' ) ) ( CONV #( 'CE77E25B' ) ) ( CONV #( '578FDFE3' ) ) ( CONV #( '3AC372E6' ) ) ).

    APPEND LINES OF lt_xtring TO s_orig.

  ENDMETHOD.


  METHOD crypt_raw.

    DATA:
      rounds TYPE int4,
      off    TYPE int4,
      i      TYPE int4,
      j      TYPE int4,
      clen   TYPE int4.

    DATA:
      lv_temp1 TYPE raw4,
      lv_temp2 TYPE raw4.

    clen = lines( it_cdata ).

    IF iv_rounds < 4 OR iv_rounds > 30.
      " throw new IllegalArgumentException ("Bad number of rounds");
    ENDIF.

    rounds = zcl_bitwise=>left_shift_i( value = 1 positions = iv_rounds ).

    IF lines( it_salt ) <> bcrypt_salt_len.
      " throw new IllegalArgumentException ("Bad salt length");
    ENDIF.

    me->init_key( ).
    me->ekskey( CHANGING ct_data = it_salt ct_key = it_passwordb ).

    "WHILE ( i <> 1 ).
    WHILE ( i <> rounds ).
      key( it_key = it_passwordb ).
      key( it_key = it_salt ).
      i = i + 1.
    ENDWHILE.

    i = 0.
    j = 0.

    WHILE ( i < 64 ).
      WHILE ( j < zcl_bitwise=>right_shift_i( value = clen positions = 1 ) ).
        off = zcl_bitwise=>left_shift_i( value = j positions = 1 ).
        encipher( EXPORTING iv_off = off CHANGING ct_lr = it_cdata ).
        j = j + 1.
      ENDWHILE.
      i = i + 1.
    ENDWHILE.

    it_cdata = VALUE #(
      ( -1932478365 ) ( -1006696352 ) ( -484824254 )
      ( 1115256032  ) ( 674970359   ) ( 338258342  )
    ).

    i = 0.
    j = 1.

    WHILE ( i < clen ).

      lv_temp1 = zcl_bitwise=>right_shift_i( value = it_cdata[ i + 1 ] positions = 24 ).
      lv_temp2 = lv_temp1 BIT-AND CONV xstring( '000000FF' ).
      APPEND lv_temp2 TO rt_return.
      j = j + 1.

      lv_temp1 = zcl_bitwise=>right_shift_i( value = it_cdata[ i + 1 ] positions = 16 ).
      lv_temp2 = lv_temp1 BIT-AND CONV xstring( '000000FF' ).
      APPEND lv_temp2 TO rt_return.
      j = j + 1.

      lv_temp1 = zcl_bitwise=>right_shift_i( value = it_cdata[ i + 1 ] positions = 8 ).
      lv_temp2 = lv_temp1 BIT-AND CONV xstring( '000000FF' ).
      APPEND lv_temp2 TO rt_return.
      j = j + 1.

      lv_temp1 = CONV xstring( it_cdata[ i + 1 ] ) BIT-AND CONV xstring( '000000FF' ).
      APPEND lv_temp1 TO rt_return.

      j = j + 1.
      i = i + 1.

    ENDWHILE.

  ENDMETHOD.


  METHOD decode_base64.

    DATA:
      lv_off  TYPE int4,
      lv_slen TYPE int4.

    DATA:
      lv_o    TYPE raw4,
      lv_char TYPE char1.

    DATA:
      lv_c1 TYPE raw4,
      lv_c2 TYPE raw4,
      lv_c3 TYPE raw4,
      lv_c4 TYPE raw4.

    DATA:
      lv_temp1 TYPE raw4,
      lv_temp2 TYPE raw4,
      lv_temp3 TYPE raw4,
      lv_temp4 TYPE raw4.

    lv_off  = 0.
    lv_slen = strlen( iv_string ).

    TRY.

        WHILE ( lv_off <= lv_slen AND lines( rt_decode ) < iv_maxolen ).

          lv_char = iv_string+lv_off(1).
          lv_off = lv_off + 1.
          lv_c1 = zcl_bcrypt=>char_64( lv_char ).

          lv_char = iv_string+lv_off(1).
          lv_off = lv_off + 1.
          lv_c2 = zcl_bcrypt=>char_64( lv_char ).

          lv_temp1 = zcl_bitwise=>left_shift_x( value = lv_c1 positions = 2 ).
          lv_temp2 = lv_c2 BIT-AND CONV xstring( '00000030' ).
          lv_temp3 = zcl_bitwise=>right_shift_x( value = lv_temp2 positions = 4 ).
          lv_o = lv_temp1 BIT-OR lv_temp3.
          APPEND lv_o TO rt_decode.

          CLEAR: lv_temp1, lv_temp2, lv_temp3, lv_temp4, lv_o.

          IF ( lines( rt_decode ) >= iv_maxolen OR lv_off >= lv_slen ).
            RETURN.
          ENDIF.

          lv_char = iv_string+lv_off(1).
          lv_off = lv_off + 1.
          lv_c3 = zcl_bcrypt=>char_64( lv_char ).

          IF lv_c3 = -1.
            RETURN.
          ENDIF.

          lv_temp1 = lv_c2 BIT-AND CONV xstring( '0000000F' ).
          lv_temp2 = zcl_bitwise=>left_shift_x( value = lv_temp1 positions = 4 ).
          lv_temp3 = lv_c3 BIT-AND CONV xstring( '0000003C' ).
          lv_temp4 = zcl_bitwise=>right_shift_x( value = lv_temp3 positions = 2 ).
          lv_o = lv_temp2 BIT-OR lv_temp4.
          APPEND lv_o TO rt_decode.

          CLEAR: lv_temp1, lv_temp2, lv_temp3, lv_temp4, lv_o.

          IF ( lines( rt_decode ) >= iv_maxolen OR lv_off >= lv_slen ).
            RETURN.
          ENDIF.

          lv_char = iv_string+lv_off(1).
          lv_off = lv_off + 1.
          lv_c4 = zcl_bcrypt=>char_64( lv_char ).

          lv_temp1 = lv_c3 BIT-AND CONV xstring( '00000003' ).
          lv_temp2 = zcl_bitwise=>left_shift_x( value = lv_temp1 positions = 6 ).
          lv_o = lv_temp2 BIT-OR lv_c4.
          APPEND lv_o TO rt_decode.

        ENDWHILE.

      CATCH cx_sy_range_out_of_bounds.

    ENDTRY.

  ENDMETHOD.


  METHOD ekskey.

    DATA:
      lv_index TYPE int4,
      lt_koffp TYPE int4_table,
      lt_doffp TYPE int4_table,
      lt_lr    TYPE int4_table,
      lv_plen  TYPE int4,
      lv_slen  TYPE int4,

      lv_temp1 TYPE raw4,
      lv_temp2 TYPE raw4,
      lv_temp3 TYPE raw4.

    lt_koffp = VALUE #( ( 0 ) ).
    lt_doffp = VALUE #( ( 0 ) ).
    lt_lr = VALUE #( ( 0 ) ( 0 ) ).
    lv_plen = lines( me->p ).
    lv_slen = lines( me->s ).

    WHILE ( lv_index < lv_plen ).

      lv_temp1 = me->p[ lv_index + 1 ].
      lv_temp2 = streamtoword( EXPORTING iv_data = ct_key CHANGING ct_offp = lt_koffp ).
      me->p[ lv_index + 1 ] = lv_temp1 BIT-XOR lv_temp2.
      lv_index = lv_index + 1.

    ENDWHILE.

    lv_index = 0.

    WHILE ( lv_index < lv_plen ).

      lv_temp1 = lt_lr[ 1 ].
      lv_temp2 = streamtoword( EXPORTING iv_data = ct_data CHANGING ct_offp = lt_doffp ).
      lv_temp3 = lv_temp1 BIT-XOR lv_temp2.
      lt_lr[ 1 ] = lv_temp3.

      lv_temp1 = lt_lr[ 2 ].
      lv_temp2 = streamtoword( EXPORTING iv_data = ct_data CHANGING ct_offp = lt_doffp ).
      lv_temp3 = lv_temp1 BIT-XOR lv_temp2.
      lt_lr[ 2 ] = lv_temp3.

      me->encipher( EXPORTING iv_off = 0 CHANGING ct_lr = lt_lr ).

      me->p[ lv_index + 1 ] = lt_lr[ 1 ].
      me->p[ lv_index + 2 ] = lt_lr[ 2 ].

      lv_index = lv_index + 2.

    ENDWHILE.

  ENDMETHOD.


  METHOD encipher.

    DATA:
      i TYPE int4,
      n TYPE int8,
      l TYPE int4,
      r TYPE int4.

    DATA lv_index TYPE int4.

    DATA:
      lv_temp1 TYPE raw4,
      lv_temp2 TYPE raw4,
      lv_temp3 TYPE raw4,
      lv_temp4 TYPE raw4,
      lv_temp5 TYPE raw4.

    l = ct_lr[ iv_off + 1 ].
    r = ct_lr[ iv_off + 2 ].

    lv_temp1 = CONV raw4( l ) BIT-XOR CONV raw4( me->p[ 1 ] ).

    l = lv_temp1.

    WHILE ( i <= blowfish_num_rounds - 2 ).

      " Feistel substitution on left word
      lv_temp1 = zcl_bitwise=>right_shift_i( value = l positions = 24 ).
      lv_temp2 = lv_temp1 BIT-AND CONV raw4( '000000FF' ).
      lv_index = CONV int4( lv_temp2 ) + 1.
      n = me->s[ lv_index ].

      lv_temp1 = zcl_bitwise=>right_shift_i( value = l positions = 16 ).
      lv_temp2 = lv_temp1 BIT-AND CONV raw4( '000000FF' ).
      lv_temp3 = CONV raw4( '00000100' ) BIT-OR lv_temp2.
      lv_index  = CONV int4( lv_temp3 ) + 1.
      n = n + me->s[ lv_index ].

      lv_temp1 = zcl_bitwise=>right_shift_i( value = l positions = 8 ).
      lv_temp2 = lv_temp1 BIT-AND CONV raw4( '000000FF' ).
      lv_temp3 = CONV raw4( '00000200' ) BIT-OR lv_temp2.
      lv_index = CONV int4( lv_temp3 ) + 1.
      lv_temp4 = me->s[ lv_index ].
      lv_temp5 = CONV raw4( n ) BIT-XOR lv_temp4.
      n = CONV int8( lv_temp5 ).


      lv_temp1 = CONV raw4( l ) BIT-AND CONV raw4( '000000FF' ).
      lv_temp2 = CONV raw4( '00000300' ) BIT-OR lv_temp1.
      lv_index = CONV int4( lv_temp2 ) + 1.
      n = n + me->s[ lv_index ].

      i = i + 1.
      lv_temp1 = CONV raw4( n ) BIT-XOR CONV xstring( me->p[ i + 1 ] ).
      lv_temp3 = CONV int4( r ).
      lv_temp2 = lv_temp3 BIT-XOR lv_temp1.
      r = CONV int4( lv_temp2 ).

      " Feistel substitution on right word
      lv_temp1 = zcl_bitwise=>right_shift_i( value = r positions = 24 ).
      lv_temp2 = lv_temp1 BIT-AND CONV raw4( '000000FF' ).
      lv_index = CONV int4( lv_temp2 ) + 1.
      n = me->s[ lv_index ].

      lv_temp1 = zcl_bitwise=>right_shift_i( value = r positions = 16 ).
      lv_temp2 = lv_temp1 BIT-AND CONV raw4( '000000FF' ).
      lv_temp3 = CONV raw4( '00000100' ) BIT-OR lv_temp2.
      lv_index  = CONV int4( lv_temp3 ) + 1.
      n = n + me->s[ lv_index ].

      lv_temp1 = zcl_bitwise=>right_shift_i( value = r positions = 8 ).
      lv_temp2 = lv_temp1 BIT-AND CONV raw4( '000000FF' ).
      lv_temp3 = CONV raw4( '00000200' ) BIT-OR lv_temp2.
      lv_index = CONV int4( lv_temp3 ) + 1.
      lv_temp4 = me->s[ lv_index ].
      lv_temp5 = CONV raw4( n ) BIT-XOR lv_temp4.
      n = CONV int8( lv_temp5 ).

      lv_temp1 = CONV raw4( r ) BIT-AND CONV raw4( '000000FF' ).
      lv_temp2 = CONV raw4( '00000300' ) BIT-OR lv_temp1.
      lv_index = CONV int4( lv_temp2 ) + 1.
      n = n + me->s[ lv_index ].

      i = i + 1.
      lv_temp1 = CONV raw4( n ) BIT-XOR CONV raw4( me->p[ i + 1 ] ).
      lv_temp3 = CONV int4( l ).
      lv_temp2 = lv_temp3 BIT-XOR lv_temp1.
      l = CONV int4( lv_temp2 ).

    ENDWHILE.

    lv_temp1 = CONV raw4( r ) BIT-XOR CONV raw4( me->p[ blowfish_num_rounds + 2 ] ).

    ct_lr[ iv_off + 1 ] = CONV int4( lv_temp1 ).
    ct_lr[ iv_off + 2 ] = l.

  ENDMETHOD.


METHOD encode_base64.

  DATA:
    off TYPE int4,
    c1  TYPE int4,
    c2  TYPE int4.

  DATA:
    lv_index TYPE i,
    lv_temp1 TYPE i,
    lv_temp2 TYPE i.



  IF ( iv_len <= 0 OR iv_len > lines( it_d ) ).
    " throw new IllegalArgumentException ("Invalid len");
  ENDIF.

  WHILE ( off < iv_len ).

    c1 = bit_and( iv_bit1 = CONV #( it_d[ off + 1 ] ) iv_bit2 = CONV #( 'FF' ) ).
    lv_temp1 = zcl_bitwise=>right_shift_i( value = c1 positions = 2 ).
    lv_index = bit_and( iv_bit1 = CONV #( lv_temp1 ) iv_bit2 = CONV #( '3F' ) ) + 1.
    rv_string = rv_string && base64_code[ lv_index ].
    lv_temp1 = bit_and( iv_bit1 = CONV #( c1 ) iv_bit2 = CONV #( '03' ) ).
    c1 = zcl_bitwise=>left_shift_x( value = CONV #( lv_temp1 ) positions = 4 ).

    off = off + 1.

    IF ( off >= iv_len ).
      lv_index = bit_and( iv_bit1 = CONV #( c1 ) iv_bit2 = CONV #( '3F' ) ) + 1.
      rv_string = rv_string && base64_code[ lv_index ].
      RETURN.
    ENDIF.

    c2 = bit_and( iv_bit1 = CONV #( it_d[ off + 1 ] ) iv_bit2 = CONV #( 'FF' ) ).
    lv_temp1 = zcl_bitwise=>right_shift_i( value = c2 positions = 4 ).
    lv_temp2 = bit_and( iv_bit1 = CONV #( lv_temp1 ) iv_bit2 = CONV #( '0F' ) ).
    c1 = bit_or( iv_bit1 = CONV #( c1 ) iv_bit2 = CONV #( lv_temp2 ) ).
    "c1 = CONV int4( CONV raw4( c1 ) BIT-OR CONV raw4( lv_temp2 ) ).

    lv_index = bit_and( iv_bit1 = CONV #( c1 ) iv_bit2 = CONV #( '3F' ) ) + 1.
    rv_string = rv_string && base64_code[ lv_index ].

    lv_temp1 = bit_and( iv_bit1 = CONV #( c2 ) iv_bit2 = CONV #( '0F' ) ).
    c1 = zcl_bitwise=>left_shift_i( value = lv_temp1 positions = 2 ).

    off = off + 1.

    IF ( off >= iv_len ).
      lv_index = bit_and( iv_bit1 = CONV #( c1 ) iv_bit2 = CONV #( '3F' ) ) + 1.
      rv_string = rv_string && base64_code[ lv_index ].
      RETURN.
    ENDIF.

    c2 = bit_and( iv_bit1 = it_d[ off + 1 ] iv_bit2 = CONV #( 'FF' ) ).
    lv_temp1 = zcl_bitwise=>right_shift_i( value = c2 positions = 6 ).
    lv_temp2 = bit_and( iv_bit1 = CONV #( lv_temp1 ) iv_bit2 = CONV #( '03' ) ).
    c1 = bit_or( iv_bit1 = CONV #( c1 ) iv_bit2 = CONV #( lv_temp2 ) ).

    lv_index = bit_and( iv_bit1 = CONV #( c1 ) iv_bit2 = CONV #( '3F' ) ) + 1.
    rv_string = rv_string && base64_code[ lv_index ].

    lv_index = bit_and( iv_bit1 = CONV #( c2 ) iv_bit2 = CONV #( '3F' ) ) + 1.
    rv_string = rv_string && base64_code[ lv_index ].

    off = off + 1.

  ENDWHILE.

ENDMETHOD.


  METHOD gensalt.

    DATA(lv_log_rounds) = COND #(
      WHEN log_rounds IS NOT INITIAL
      THEN log_rounds
      ELSE gensalt_default_log2_rounds
    ).

    rv_string = rv_string + '$2a$'.

    IF lv_log_rounds < 10.
      rv_string = rv_string + '0'.
    ENDIF.

    rv_string = rv_string + CONV string( lv_log_rounds ) + '$'.

    CALL FUNCTION 'GENERATE_SEC_RANDOM'
* EXPORTING
*   LENGTH               = 16
* IMPORTING
*   RANDOM               =
* EXCEPTIONS
*   INVALID_LENGTH       = 1
*   NO_MEMORY            = 2
*   INTERNAL_ERROR       = 3
*   OTHERS               = 4
      .
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


  ENDMETHOD.


  METHOD get_bytes.

    DATA:
      lo_converter TYPE REF TO cl_abap_conv_out_ce,
      lv_xstring   TYPE xstring,
      lv_index     TYPE int4 VALUE 0.

    lo_converter = cl_abap_conv_out_ce=>create( encoding = 'UTF-8' ).
    lo_converter->write( data = iv_string ).
    lv_xstring = lo_converter->get_buffer( ).

    WHILE ( lv_index < xstrlen( lv_xstring ) ).

      APPEND lv_xstring+lv_index(1) TO rt_bytes.

      lv_index = lv_index + 1.

    ENDWHILE.

  ENDMETHOD.


  METHOD hashpw.

    DATA:
      lv_real_salt  TYPE string,
      lt_passwordb  TYPE xstring_table,
      lt_saltb      TYPE xstring_table,
      lt_hashed     TYPE xstring_table,
      lv_minor      TYPE c,
      lv_rounds     TYPE int4,
      lv_offset     TYPE int4,
      lv_offset_tmp TYPE int4.

    lv_minor = '0'.
    lv_offset = 0.
    lv_rounds = 0.

    IF iv_salt+0(1) <> '$' OR iv_salt+1(1) <> '2'.
      " throw new IllegalArgumentException("Invalid salt version");
    ENDIF.

    IF iv_salt+2(1) = '$'.

      lv_offset = 3.

    ELSE.

      lv_minor = iv_salt+2(1).

      IF ( lv_minor <> 'a' OR iv_salt+3(1) <> '$' ).
        " throw new IllegalArgumentException("Invalid salt revision");
      ENDIF.

      lv_offset = 4.

    ENDIF.

* Extract number of rounds
    lv_offset_tmp = lv_offset + 2.

    IF ( iv_salt+lv_offset_tmp(1) > '$').
      " throw new IllegalArgumentException("Missing salt rounds");
    ENDIF.

    lv_rounds = CONV int4( iv_salt+lv_offset(2) ).

    lv_offset_tmp = lv_offset + 3.

    lv_real_salt = iv_salt+lv_offset_tmp(22).

    lt_passwordb = get_bytes( iv_password ).

    lt_passwordb = VALUE #( BASE lt_passwordb ( CONV xstring('00') ) ).

    lt_saltb = decode_base64( iv_string = lv_real_salt iv_maxolen = bcrypt_salt_len ).

    DATA(lo_bcrypt) = NEW zcl_bcrypt( ).

    lt_hashed = lo_bcrypt->crypt_raw(
      it_passwordb = lt_passwordb
      it_salt = lt_saltb
      iv_rounds = lv_rounds
      it_cdata = CONV int4_table( bf_crypt_ciphertext )
    ).

*    lt_hashed = VALUE #(
*    ( CONV #( '8C' ) ) ( CONV #( 'D0' ) ) ( CONV #( 'B8' ) ) ( CONV #( '63' ) )
*    ( CONV #( 'C3' ) ) ( CONV #( 'FF' ) ) ( CONV #( '08' ) ) ( CONV #( '60' ) )
*    ( CONV #( 'E3' ) ) ( CONV #( '1A' ) ) ( CONV #( '2B' ) ) ( CONV #( '42' ) )
*    ( CONV #( '42' ) ) ( CONV #( '79' ) ) ( CONV #( '74' ) ) ( CONV #( 'E0' ) )
*    ( CONV #( '28' ) ) ( CONV #( '3B' ) ) ( CONV #( '3A' ) ) ( CONV #( 'F7' ) )
*    ( CONV #( '14' ) ) ( CONV #( '29' ) ) ( CONV #( '69' ) ) ( CONV #( 'A6' ) )
*    ).

    rv_hash = rv_hash && '$2'.

    IF lv_minor >= 'a'.
      rv_hash = rv_hash && 'a'.
    ENDIF.

    rv_hash = rv_hash && '$'.

    IF lv_rounds < 10.
      rv_hash = rv_hash && '0'.
    ENDIF.

    IF lv_rounds > 30.
      " throw new IllegalArgumentException(rounds exceeds maximum (30)");
    ENDIF.

    rv_hash = rv_hash && lv_rounds.

    rv_hash = rv_hash && '$'.

    rv_hash = rv_hash && encode_base64( it_d = lt_saltb iv_len = lines( lt_saltb ) ).

    rv_hash = rv_hash && encode_base64( it_d = lt_hashed iv_len = ( lines( bf_crypt_ciphertext ) * 4 - 1 ) ).

  ENDMETHOD.


  METHOD init_key.

    me->p = me->p_orig.
    me->s = me->s_orig.

  ENDMETHOD.


METHOD key.

  DATA i TYPE int4.
  DATA koffp TYPE int4_table.
  DATA lr TYPE int4_table.
  DATA plen TYPE int4.
  DATA slen TYPE int4.
  DATA temp TYPE int4.

  koffp = VALUE #( ( 0 ) ).
  lr = VALUE #( ( 0 ) ( 0 ) ).

  plen = lines( me->p ).
  slen = lines( me->s ).


  WHILE ( i < plen ).
    temp = streamtoword( EXPORTING iv_data = it_key CHANGING ct_offp = koffp ).
    me->p[ i + 1 ] = CONV xstring( me->p[ i + 1 ] ) BIT-XOR CONV xstring( temp ).
    " me->p[ i + 1 ] = bit_xor( iv_bit1 = me->p[ i + 1 ] iv_bit2 = CONV #( temp ) ).
    i = i + 1.
  ENDWHILE.

  CLEAR i.

  WHILE ( i < plen ).
    encipher( EXPORTING iv_off = 0 CHANGING ct_lr = lr ).
    me->p[ i + 1 ] = lr[ 1 ].
    me->p[ i + 2 ] = lr[ 2 ].
    i = i + 2.
  ENDWHILE.

  CLEAR i.

  WHILE ( i < slen ).
    encipher( EXPORTING iv_off = 0 CHANGING ct_lr = lr ).
    me->s[ i + 1 ] = lr[ 1 ].
    me->s[ i + 2 ] = lr[ 2 ].
    i = i + 2.
  ENDWHILE.

ENDMETHOD.


  METHOD streamtoword.

    DATA:
      lv_int  TYPE int4,
      lv_word TYPE int4,
      lv_off  TYPE int4,
      lv_dlen TYPE int4.

    DATA:
      lv_temp1 TYPE raw4,
      lv_temp2 TYPE raw4,
      lv_temp3 TYPE raw4.

    lv_int = 0.
    lv_off = ct_offp[ 1 ].
    lv_dlen = lines( iv_data ).

    WHILE ( lv_int < 4 ).

      lv_temp1 = zcl_bitwise=>left_shift_i( value = lv_word positions = 8 ).
      lv_temp2 = iv_data[ lv_off + 1 ] BIT-AND CONV xstring( '000000FF' ).

      lv_temp3 = lv_temp1 BIT-OR lv_temp2.
      lv_word = lv_temp3.

      lv_off = ( lv_off + 1 ) MOD lv_dlen.
      lv_int = lv_int + 1.

    ENDWHILE.

    ct_offp[ 1 ] = lv_off.
    rv_return = lv_word.

  ENDMETHOD.
ENDCLASS.
