﻿namespace Sugar.Xml;

interface

uses
  {$IF COOPER}
  org.w3c.dom,
  {$ELSEIF ECHOES}
  System.Xml.Linq,
  {$ELSEIF TOFFEE}
  Foundation,
  {$ENDIF}
  Sugar;

type
{$IF COOPER OR ECHOES}
  XmlProcessingInstruction = public class (XmlNode)
  private
    property ProcessingInstruction: {$IF COOPER}ProcessingInstruction{$ELSEIF ECHOES}XProcessingInstruction{$ENDIF}
                                    read Node as {$IF COOPER}ProcessingInstruction{$ELSEIF ECHOES}XProcessingInstruction{$ENDIF};
    {$IF COOPER}method SetData(aValue: String);{$ENDIF}
  public
    {$IF ECHOES}
    property Name: String read "#processinginstruction"; override;
    property Value: String read ProcessingInstruction.Data write ProcessingInstruction.Data; override;
    {$ENDIF}
    property Data: String read ProcessingInstruction.Data write {$IF COOPER}SetData{$ELSE}ProcessingInstruction.Data{$ENDIF};
    property Target: String read ProcessingInstruction.Target;
    property NodeType: XmlNodeType read XmlNodeType.ProcessingInstruction; override;
  end;
{$ELSEIF TOFFEE}
  XmlProcessingInstruction = public class (XmlNode)
  public
    property Data: String read Value write Value;
    property Target: String read Name;
    property NodeType: XmlNodeType read XmlNodeType.ProcessingInstruction; override;
  end;
{$ENDIF}
implementation

{$IF COOPER}
method XmlProcessingInstruction.SetData(aValue: String);
begin
  SugarArgumentNullException.RaiseIfNil(aValue, "Value");
  ProcessingInstruction.Data := aValue;
end;
{$ENDIF}

end.