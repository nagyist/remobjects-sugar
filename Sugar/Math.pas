﻿namespace Sugar;

interface

type

  {$IF COOPER}
  Math = public class mapped to java.lang.Math
  public
    class method Abs(d: Double): Double; mapped to abs(d);
    class method Abs(i: Int64): Int64;
    class method Abs(i: Integer): Integer;
    class method Acos(d: Double): Double; mapped to acos(d);
    class method Asin(d: Double): Double; mapped to asin(d);
    class method Atan(d: Double): Double; mapped to atan(d);
    class method Atan2(x,y: Double): Double;
    class method Ceiling(a: Double): Double; mapped to ceil(a);
    class method Cos(d: Double): Double; mapped to cos(d);
    class method Cosh(d: Double): Double; mapped to cosh(d);
    class method Exp(d: Double): Double; mapped to exp(d);
    class method Floor(d: Double): Double; mapped to floor(d);
    class method IEEERemainder(x, y: Double): Double; mapped to IEEEremainder(x, y);
    class method Log(d: Double): Double; mapped to log(d);
    class method Log10(d: Double): Double; mapped to log10(d);
    class method Max(a,b: Double): Double; mapped to max(a,b);
    class method Max(a,b: Integer): Integer; mapped to max(a,b);
    class method Max(a,b: Int64): Int64; mapped to max(a,b);
    class method Min(a,b: Double): Double; mapped to min(a,b);
    class method Min(a,b: Integer): Integer; mapped to min(a,b);
    class method Min(a,b: Int64): Int64; mapped to min(a,b);
    class method Pow(x, y: Double): Double;
    class method Round(a: Double): Int64;
    class method Sign(d: Double): Integer;
    class method Sin(d: Double): Double; mapped to sin(d);
    class method Sinh(d: Double): Double; mapped to sinh(d);
    class method Sqrt(d: Double): Double; mapped to sqrt(d);
    class method Tan(d: Double): Double; mapped to tan(d);
    class method Tanh(d: Double): Double; mapped to tanh(d);
    class method Truncate(d: Double): Double;
  {$ENDIF}
  {$IF ECHOES}
  Math = public class mapped to System.Math
  public
    class method Abs(d: Double): Double; mapped to Abs(d);
    class method Abs(i: Int64): Int64; mapped to Abs(i);
    class method Abs(i: Integer): Integer; mapped to Abs(i);
    class method Acos(d: Double): Double; mapped to Acos(d);
    class method Asin(d: Double): Double; mapped to Asin(d);
    class method Atan(d: Double): Double; mapped to Atan(d);
    class method Atan2(x,y: Double): Double; mapped to Atan2(x,y);
    class method Ceiling(d: Double): Double; mapped to Ceiling(d);
    class method Cos(d: Double): Double; mapped to Cos(d);
    class method Cosh(d: Double): Double; mapped to Cosh(d);
    class method Exp(d: Double): Double; mapped to Exp(d);
    class method Floor(d: Double): Double; mapped to Floor(d);
    class method IEEERemainder(x, y: Double): Double; mapped to IEEERemainder(x, y);
    class method Log(d: Double): Double; mapped to Log(d);
    class method Log10(d: Double): Double; mapped to Log10(d);
    class method Max(a,b: Double): Double; mapped to Max(a,b);
    class method Max(a,b: Integer): Integer; mapped to Max(a,b);
    class method Max(a,b: Int64): Int64; mapped to Max(a,b);
    class method Min(a,b: Double): Double; mapped to Min(a,b);
    class method Min(a,b: Integer): Integer; mapped to Min(a,b);
    class method Min(a,b: Int64): Int64; mapped to Min(a,b);
    class method Pow(x, y: Double): Double; mapped to Pow(x,y);
    class method Round(a: Double): Int64;
    class method Sign(d: Double): Integer; mapped to Sign(d);
    class method Sin(d: Double): Double; mapped to Sin(d);
    class method Sinh(d: Double): Double; mapped to Sinh(d);
    class method Sqrt(d: Double): Double; mapped to Sqrt(d);
    class method Tan(d: Double): Double; mapped to Tan(d);
    class method Tanh(d: Double): Double; mapped to Tanh(d);
    class method Truncate(d: Double): Double; mapped to Truncate(d);
  {$ENDIF}
  {$IF TOFFEE}
  Math = public class mapped to Object
  public
    class method Abs(value: Double): Double;
    class method Abs(i: Int64): Int64;
    class method Abs(i: Integer): Integer;
    class method Acos(d: Double): Double;
    class method Asin(d: Double): Double;
    class method Atan(d: Double): Double;
    class method Atan2(x,y: Double): Double;
    class method Ceiling(d: Double): Double;
    class method Cos(d: Double): Double;
    class method Cosh(d: Double): Double;
    class method Exp(d: Double): Double;
    class method Floor(d: Double): Double;
    class method IEEERemainder(x, y: Double): Double;
    class method Log(a: Double): Double;
    class method Log10(a: Double): Double;
    class method Max(a,b: Double): Double;
    class method Max(a,b: Integer): Integer;
    class method Max(a,b: Int64): Int64;
    class method Min(a,b: Double): Double;
    class method Min(a,b: Integer): Integer;
    class method Min(a,b: Int64): Int64;
    class method Pow(x, y: Double): Double;
    class method Round(a: Double): Int64;
    class method Sign(d: Double): Integer;
    class method Sin(x: Double): Double;
    class method Sinh(x: Double): Double;
    class method Sqrt(d: Double): Double;
    class method Tan(d: Double): Double;
    class method Tanh(d: Double): Double;
    class method Truncate(d: Double): Double;
  {$ENDIF}
  end;

implementation

{$IF COOPER}
class method Math.Truncate(d: Double): Double;
begin
  exit iif(d < 0, mapped.ceil(d), mapped.floor(d));
end;

class method Math.Abs(i: Int64): Int64;
begin
  if i = Consts.MinInt64 then
    raise new SugarArgumentException("Value can not equals minimum value of Int64");

  exit mapped.abs(i);
end;

class method Math.Abs(i: Integer): Integer;
begin
  if i = Consts.MinInteger then
    raise new SugarArgumentException("Value can not equals minimum value of Int32");

  exit mapped.abs(i);
end;

class method Math.Atan2(x: Double; y: Double): Double;
begin
  if Consts.IsInfinity(x) and Consts.IsInfinity(y) then
    exit Consts.NaN;

  exit mapped.atan2(x,y);
end;

class method Math.Pow(x: Double; y: Double): Double;
begin
  {$IF ANDROID}
  if (x = -1) and Consts.IsInfinity(y) then
    exit Consts.NaN;

  exit mapped.pow(x, y);
  {$ELSE}
  exit mapped.pow(x, y);
  {$ENDIF}
end;
{$ENDIF}

class method Math.Round(a: Double): Int64;
begin
  if Consts.IsNaN(a) or Consts.IsInfinity(a) then
    raise new SugarArgumentException("Value can not be rounded to Int64");

  exit Int64(Floor(a + 0.499999999999999999));
end;

{$IF COOPER or TOFFEE}
class method Math.Sign(d: Double): Integer;
begin
  if Consts.IsNaN(d) then
    raise new SugarArgumentException("Value can not be NaN");

  if d > 0 then exit 1;
  if d < 0 then exit -1;
  exit 0;
end;
{$ENDIF}

{$IF TOFFEE}
class method Math.Pow(x, y: Double): Double;
begin
  if (x = -1) and Consts.IsInfinity(y) then
    exit Consts.NaN;

  exit rtl.pow(x,y);
end;

class method Math.Acos(d: Double): Double;
begin
  exit rtl.acos(d);
end;

class method Math.Cos(d: Double): Double;
begin
  exit rtl.cos(d);
end;

class method Math.Ceiling(d: Double): Double;
begin
  exit rtl.ceil(d);
end;

class method Math.Cosh(d: Double): Double;
begin
  exit rtl.cosh(d);
end;

class method Math.Asin(d: Double): Double;
begin
  exit rtl.asin(d);
end;

class method Math.Atan(d: Double): Double;
begin
  exit rtl.atan(d);
end;

class method Math.Atan2(x,y: Double): Double;
begin
  if Consts.IsInfinity(x) and Consts.IsInfinity(y) then
    exit Consts.NaN;

  exit rtl.atan2(x,y);
end;

class method Math.Abs(value: Double): Double;
begin
  exit rtl.fabs(value);
end;

class method Math.Exp(d: Double): Double;
begin
  exit rtl.exp(d);
end;

class method Math.Floor(d: Double): Double;
begin
  exit rtl.floor(d);
end;

class method Math.IEEERemainder(x,y: Double): Double;
begin
  exit rtl.remainder(x,y);
end;

class method Math.Log(a: Double): Double;
begin
  exit rtl.log(a);
end;

class method Math.Log10(a: Double): Double;
begin
  exit rtl.log10(a);
end;

class method Math.Max(a,b: Int64): Int64;
begin
  exit iif(a > b, a, b);
end;

class method Math.Min(a,b: Int64): Int64;
begin
  exit iif(a < b, a, b);
end;

class method Math.Sin(x: Double): Double;
begin
  exit rtl.sin(x);
end;

class method Math.Sinh(x: Double): Double;
begin
  exit rtl.sinh(x);
end;

class method Math.Sqrt(d: Double): Double;
begin
  exit rtl.sqrt(d);
end;

class method Math.Tan(d: Double): Double;
begin
  exit rtl.tan(d);
end;

class method Math.Tanh(d: Double): Double;
begin
  exit rtl.tanh(d);
end;

class method Math.Truncate(d: Double): Double;
begin
  exit rtl.trunc(d);
end;

class method Math.Abs(i: Int64): Int64;
begin
  if i = Consts.MinInt64 then
    raise new SugarArgumentException("Value can not equals minimum value of Int64");

  exit rtl.llabs(i);
end;

class method Math.Abs(i: Integer): Integer;
begin
  if i = Consts.MinInteger then
    raise new SugarArgumentException("Value can not equals minimum value of Int32");

  exit rtl.abs(i);
end;

class method Math.Max(a: Double; b: Double): Double;
begin
  if Consts.IsNaN(a) or Consts.IsNaN(b) then
    exit Consts.NaN;

  exit iif(a > b, a, b);
end;

class method Math.Max(a: Integer; b: Integer): Integer;
begin
  exit iif(a > b, a, b);
end;

class method Math.Min(a: Double; b: Double): Double;
begin
  if Consts.IsNaN(a) or Consts.IsNaN(b) then
    exit Consts.NaN;

  exit iif(a < b, a, b);
end;

class method Math.Min(a: Integer; b: Integer): Integer;
begin
  exit iif(a < b, a, b);
end;
{$ENDIF}

end.