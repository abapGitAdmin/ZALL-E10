class ZCL_BITWISE definition
  public
  final
  create public .

public section.

*"* public components of class ZCL_BITWISE
*"* do not include other source files here!!!
*"* protected components of class ZCL_BITSHIFT
*"* do not include other source files here!!!
  class-methods CLASS_CONSTRUCTOR .
  class-methods LEFT_SHIFT_X
    importing
      !VALUE type RAW4
      !POSITIONS type I
    returning
      value(RETURNING) type RAW4 .
  class-methods LEFT_SHIFT_I
    importing
      !VALUE type I
      !POSITIONS type I
    returning
      value(RETURNING) type I .
  class-methods RIGHT_SHIFT_X
    importing
      !VALUE type RAW4
      !POSITIONS type I
    returning
      value(RETURNING) type RAW4 .
  class-methods RIGHT_SHIFT_I
    importing
      !VALUE type I
      !POSITIONS type I
    returning
      value(RETURNING) type I .
  class-methods UNSIGNED_RIGHT_SHIFT_X
    importing
      !VALUE type RAW4
      !POSITIONS type I
    returning
      value(RETURNING) type RAW4 .
  class-methods UNSIGNED_RIGHT_SHIFT_I
    importing
      !VALUE type I
      !POSITIONS type I
    returning
      value(RETURNING) type I .
  class-methods ADD_X
    importing
      !A type RAW4
      !B type RAW4
    returning
      value(RETURNING) type RAW4 .
  class-methods ADD_I
    importing
      !A type I
      !B type I
    returning
      value(RETURNING) type I .
  class-methods SUBTRACT_X
    importing
      !A type RAW4
      !B type RAW4
    returning
      value(RETURNING) type RAW4 .
  class-methods SUBTRACT_I
    importing
      !A type I
      !B type I
    returning
      value(RETURNING) type I .
  class-methods MULTIPLY_X
    importing
      !A type RAW4
      !B type RAW4
    returning
      value(RETURNING) type RAW4 .
  class-methods MULTIPLY_I
    importing
      !A type I
      !B type I
    returning
      value(RETURNING) type I .
protected section.
private section.

  constants:
*"* private components of class ZCL_BITWISE
*"* do not include other source files here!!!
    H_00000001 type X LENGTH 4 value '00000001' ##NO_TEXT.
  constants:
    H_3FFFFFFF type X LENGTH 4 value '3FFFFFFF' ##NO_TEXT.
  constants:
    H_40000000 type X length 4 value '40000000' ##NO_TEXT.
  constants:
    H_7FFFFFFF type X length 4 value '7FFFFFFF' ##NO_TEXT.
  constants:
    H_80000000 type X length 4 value '80000000' ##NO_TEXT.
  class-data:
    POWER_OF_2 type STANDARD TABLE OF I .
ENDCLASS.



CLASS ZCL_BITWISE IMPLEMENTATION.


method add_i.
  data byte_a type x length 4.
  data byte_b type x length 4.
  byte_a = a.
  byte_b = b.
  returning = add_x( a = byte_a b = byte_b ).
endmethod.


method add_x.
  data result type x length 4.
  try.
      " First try regular addition
      result = a + b.
    catch cx_sy_arithmetic_overflow.
      " Overflow occured, perform bitwise addition
      data carry type x length 4.
      carry = a bit-and b.
      result = a bit-xor b.
      while carry <> 0.
        data shiftedcarry type x length 4.
        shiftedcarry = left_shift_x( value = carry positions = 1 ).
        carry = result bit-and shiftedcarry.
        result = result bit-xor shiftedcarry.
      endwhile.
  endtry.
  returning = result.
endmethod.


method class_constructor.
  append 2 to power_of_2.
  append 4 to power_of_2.
  append 8 to power_of_2.
  append 16 to power_of_2.
  append 32 to power_of_2.
  append 64 to power_of_2.
  append 128 to power_of_2.
  append 256 to power_of_2.
  append 512 to power_of_2.
  append 1024 to power_of_2.
  append 2048 to power_of_2.
  append 4096 to power_of_2.
  append 8192 to power_of_2.
  append 16384 to power_of_2.
  append 32768 to power_of_2.
  append 65536 to power_of_2.
  append 131072 to power_of_2.
  append 262144 to power_of_2.
  append 524288 to power_of_2.
  append 1048576 to power_of_2.
  append 2097152 to power_of_2.
  append 4194304 to power_of_2.
  append 8388608 to power_of_2.
  append 16777216 to power_of_2.
  append 33554432 to power_of_2.
  append 67108864 to power_of_2.
  append 134217728 to power_of_2.
  append 268435456 to power_of_2.
  append 536870912 to power_of_2.
  append 1073741824 to power_of_2.
endmethod.


method left_shift_i.
  if positions = 0.
    returning = value.
    return.
  endif.
  data byte_value type x length 4.
  byte_value = value.
  returning = left_shift_x( value = byte_value positions = positions ).
endmethod.


method left_shift_x.
  if positions = 0.
    returning = value.
    return.
  endif.
  data positions_to_shift type i.
  positions_to_shift = positions mod 32.
  if positions_to_shift > 0.
    data result type x length 4.
    try.
        " First try regular multiplication
        data a type i.
        read table power_of_2 into a index positions_to_shift.
        result = value * a.
      catch cx_sy_arithmetic_overflow.
        " Overflow occured, perform bitwise multiplication
        data calc_value type x length 4.
        calc_value = value.
        data b type x length 4.
        do positions_to_shift times.
          b = calc_value bit-and h_40000000.
          calc_value = calc_value bit-and h_3fffffff.
          calc_value = calc_value * 2.
          if b <> 0.
            calc_value = calc_value bit-or h_80000000.
          endif.
        enddo.
        result = calc_value.
    endtry.
    returning = result.
    return.
  else.
    returning = value.
    return.
  endif.
endmethod.


method multiply_i.
  data byte_a type x length 4.
  data byte_b type x length 4.
  byte_a = a.
  byte_b = b.
  returning = multiply_x( a = byte_a b = byte_b ).
endmethod.


method multiply_x.
  data result type x length 4.
  try.
      " First try regular multiplication
      result = a * b.
    catch cx_sy_arithmetic_overflow.
      " Overflow occured, perform bitwise multiplication
      data calc_a type x length 4.
      data calc_b type x length 4.
      calc_a = a.
      calc_b = b.
      result = 0.
      while calc_b <> 0.
        data calc_c type x length 4.
        calc_c = calc_b bit-and h_00000001.
        if calc_c <> 0.
          result = add_x( a = result b = calc_a ).
        endif.
        calc_a = left_shift_x( value = calc_a positions = 1 ).
        calc_b = unsigned_right_shift_x( value = calc_b positions = 1 ).
      endwhile.
  endtry.
  returning = result.
endmethod.


method right_shift_i.
  if positions = 0.
    returning = value.
    return.
  endif.
  data byte_value type x length 4.
  byte_value = value.
  returning = right_shift_x( value = byte_value positions = positions ).
endmethod.


method right_shift_x.
  if positions = 0.
    returning = value.
    return.
  endif.
  data positions_to_shift type i.
  positions_to_shift = positions mod 32.
  if positions_to_shift = 31.
    if value < 0.
      returning = -1.
      return.
    else.
      returning = 0.
      return.
    endif.
  elseif positions_to_shift > 0.
    data a type i.
    read table power_of_2 into a index positions_to_shift.
    returning = value div a.
    return.
  else.
    returning = value.
    return.
  endif.
endmethod.


method subtract_i.
  data byte_a type x length 4.
  data byte_b type x length 4.
  byte_a = a.
  byte_b = b.
  returning = subtract_x( a = byte_a b = byte_b ).
endmethod.


method subtract_x.
  data result type x length 4.
  try.
      " First try regular subtraction
      result = a - b.
    catch cx_sy_arithmetic_overflow.
      " Overflow occured, perform bitwise subtraction
      " a - b is the same as a + (-1 * b)
      data b_negated type x length 4.
      if b = -2147483648.
        b_negated = b.
      else.
        b_negated = b * -1.
      endif.
      result = add_x( a = a b = b_negated ).
  endtry.
  returning = result.
endmethod.


method unsigned_right_shift_i.
  if positions = 0.
    returning = value.
    return.
  endif.
  data byte_value type x length 4.
  byte_value = value.
  returning = unsigned_right_shift_x( value = byte_value positions = positions ).
endmethod.


method unsigned_right_shift_x.
  if positions = 0.
    returning = value.
    return.
  endif.
  data positions_to_shift type i.
  positions_to_shift = positions mod 32.
  if positions_to_shift > 0.
    data calc_value type x length 4.
    data a type x length 4.
    data b type x length 4.
    calc_value = value.
    a = calc_value bit-and h_7fffffff.
    a = right_shift_x( value = a positions = positions_to_shift ).
    b = calc_value bit-and h_80000000.
    b = right_shift_x( value = b positions = positions_to_shift ).
    returning = a - b.
    return.
  else.
    returning = value.
    return.
  endif.
endmethod.
ENDCLASS.
