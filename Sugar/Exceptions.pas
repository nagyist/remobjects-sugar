﻿namespace RemObjects.Oxygene.Sugar;

interface

type 
  SugarException = public class({$IF NOUGAT}Foundation.NSException{$ELSE}Exception{$ENDIF})
  public
    constructor;
    constructor(aMessage: String);
    constructor(aFormat: String; params aParams: array of Object);
  {$IF NOUGAT}
    property Message: String read reason;
  {$ENDIF}
  end;

  SugarNotImplementedException = public class(SugarException);

  SugarNotSupportedException = public class (SugarException);

  SugarArgumentException = public class (SugarException);

  SugarArgumentNullException = public class(SugarException);
  //public
    //constructor(aMessage: String);
  //end;
  
  SugarArgumentOutOfRangeException = public class (SugarException);

  SugarFormatException = public class(SugarException);

  SugarIOException = public class(SugarException);

  SugarStackEmptyException = public class (SugarException);

  SugarInvalidOperationException = public class (SugarException);

  SugarKeyNotFoundException = public class (SugarException);

  {$IF NOUGAT}
  SugarNSErrorException = public class(SugarException)
  public
    method initWithError(aError: Foundation.NSError): id;
    class method exceptionWithError(aError: Foundation.NSError): id;
  end;
  {$ENDIF}

  ErrorMessage = public static class
  public
    class const FORMAT_ERROR = "Input string was not in a correct format";
    class const FILE_EXISTS = "File {0} already exists";
    class const FOLDER_EXISTS = "Folder {0} already exists";
    class const OUT_OF_RANGE_ERROR = "Range ({0},{1}) exceeds data length {2}";
    class const NEGATIVE_VALUE_ERROR = "{0} can not be negative";
    class const ARG_OUT_OF_RANGE_ERROR = "{0} argument was out of range of valid values.";
    class const ARG_NULL_ERROR = "Argument {0} can not be nil";
  end;

implementation

{$IF NOUGAT}
method SugarNSErrorException.initWithError(aError: Foundation.NSError): id;
begin
  result := inherited initWithName('NSError') reason(aError.description) userInfo(aError.userInfo);
end;

class method SugarNSErrorException.exceptionWithError(aError: Foundation.NSError): id;
begin
  result := inherited exceptionWithName('NSError') reason(aError.description) userInfo(aError.userInfo);
end;
{$ENDIF}

constructor SugarException;
begin
  constructor("SugarException");
end;

constructor SugarException(aMessage: String);
begin
  {$IF NOUGAT}
  inherited initWithName('SugarException') reason(aMessage) userInfo(nil);
  {$ELSE}
  inherited constructor(aMessage);
  {$ENDIF}
end;

constructor SugarException(aFormat: String; params aParams: array of Object);
begin
  constructor(String.Format(aFormat, aParams));
end;

{constructor SugarArgumentNullException(aMessage: String);
begin
  inherited constructor(ErrorMessage.ARG_NULL_ERROR, aMessage)
end;}

end.
