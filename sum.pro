; $Header: /var/tmp/portage/local-tools/acdb-idl-1.1/work/acdb-idl-1.1/userlib/sum.pro,v 1.5 2002/02/06 18:49:08 eroc Exp $

function  sum,array,dimension,double=double,nan=nan

;+
; NAME:
;   sum
; PURPOSE:
;   Total up an array over one of its dimensions.
; CATEGORY:
;   arrays, math
; CALLING SEQUENCE:
;   result = sum(array, dimension)
; FUNCTION RETURN VALUE:
;   byte, integer, long, float, double, complex, dcomplex: array
;   The result is an array with all the dimensions of the input array except 
;   for the dimension specified, each element of which is the total of the 
;   corresponding vector in the input array. If the inpt is double, complex, 
;   or dcomplex, the result is of the same type. Otherwise, the result is 
;   float. The result is an array with one less dimension than the input.
;   For example, if the dimensions of Array are N1, N2, N3, and Dimension is 1,
;   the dimensions of the result are (N1, N3).
; INPUT PARAMETERS:
;   array = (number array) array to be summed. This can be of any basic type
;           except string
;   dimension = (number) dimension over which to sum, starting at zero
; OPTIONAL INPUT PARAMETERS:
; INPUT/OUTPUT PARAMETERS:
; OPTIONAL INPUT/OUTPUT PARAMETERS:
; OUTPUT PARAMETERS:
; OPTIONAL OUTPUT PARAMETERS:
; INPUT KEYWORDS:
;   double = (flag) if set, perform the summations in double precision
;   nan = (flag) if set, check for occurrences of the IEEE floating-point 
;         value NaN in the input data. Elements with the value NaN are treated 
;         as missing data. Use the !values.f_nan value to set missing data
; INPUT/OUTPUT KEYWORDS:
; OUTPUT KEYWORDS:
; COMMON BLOCKS:
; REQUIRED ROUTINES:
; @ FILES:
; RESTRICTIONS:
;   Dimension specified must be valid for the array passed; otherwise the
;   input array is returned as the output array. Type cannot be string or
;   structure.
; SIDE EFFECTS:
; DIAGNOSTIC INFORMATION:
; PROCEDURE:
; EXAMPLES:
;   If A is an array with dimensions of (3,4,5), then the command 
;   B = SUM(A,1) is equivalent to
;
;			B = FLTARR(3,5)
;			FOR J = 0,4 DO BEGIN
;				FOR I = 0,2 DO BEGIN
;					B(I,J) = TOTAL( A(I,*,J) )
;				ENDFOR
;			ENDFOR
; REFERENCE:
; FURTHER INFORMATION:
; RELATED FUNCTIONS AND PROCEDURES:
;   avg
; MODIFICATION HISTORY:
;   1986-07-00:William Thompson:written
;   1991-02-06:lait:mod for idl v2
;   1991-05-07:lait:got it working right!
;   1993-10-27:nash:complete rewrite to speed up code (30% faster).
;                   fixed error in old code that used fix instead of long in 
;                   the last else block.
;   1998-03-24:nash:fixed so that dcomplexarr can be averaged.
;   2002-02-05:nash:now just calls the builtin function 'total'
;-

; *****must have two parameters only
  if  (n_params(0) ne 2)  then  begin
    message,/cont,'Must be called with two parameters: ARRAY, DIMENSION'
    return,array
  endif

; *****must be an array
  ndim = size(array,/n_dimensions)
  if  (ndim eq 0)  then  begin
    message,/cont,'ARRAY must be an array'
    return,array
  endif

; *****dimension must not be out of range
  if  (dimension ge ndim)  then  begin
    message,/cont,'DIMENSION must be less than '+strcompress(ndim,/rem)
    return,array
  endif

; *****error handling
  catch,err
  if  (err ne 0)  then  begin
    message,/cont,!err_string
    return,array
  endif

; *****just call the builtin 'total' function
  return,total(array,dimension+1,double=double,nan=nan)
end
