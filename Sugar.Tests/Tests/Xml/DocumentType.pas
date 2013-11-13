﻿namespace Sugar.Test;

interface

{$HIDE W0} //supress case-mismatch errors

uses
  RemObjects.Oxygene.Sugar,
  RemObjects.Oxygene.Sugar.Xml,
  RemObjects.Oxygene.Sugar.TestFramework;

type
  DocumentTypeTest = public class (Testcase)
  private
    Doc: XmlDocument;
    Data: XmlDocumentType;
  public
    method Setup; override;
    method Name;
    method LocalName;
    method InternalSubset;
    method PublicId;
    method SystemId;
    method NodeType;
    method AccessFromDocument;
    method Childs;
    method Value;
  end;

implementation

method DocumentTypeTest.Setup;
begin
  Doc := XmlDocument.FromString(XmlTestData.DTDXml);
  Assert.IsNotNull(Doc);
  Data := Doc.FirstChild as XmlDocumentType;
  Assert.IsNotNull(Data);
end;

method DocumentTypeTest.InternalSubset;
begin
  {$IF NOT ANDROID}
  Assert.IsNotNull(Data.InternalSubset);
  Assert.CheckBool(true, Data.InternalSubset.Contains("<!ELEMENT to (#PCDATA)>"));
  Assert.CheckBool(true, Data.InternalSubset.Contains("<!ELEMENT from (#PCDATA)>"));
  Assert.CheckBool(true, Data.InternalSubset.Contains("<!ELEMENT heading (#PCDATA)>"));
  Assert.CheckBool(true, Data.InternalSubset.Contains("<!ELEMENT body (#PCDATA)>"));

  Doc := XmlDocument.FromString(XmlTestData.CharXml);
  Assert.IsNotNull(Doc);
  Assert.IsNotNull(Doc.DocumentType);
  Assert.IsNotNull(Doc.DocumentType.InternalSubset);
  Assert.CheckString("", Doc.DocumentType.InternalSubset);
  {$ELSE}
  {$WARNING Android parser does not process internal subset}
  {$ENDIF}
end;

method DocumentTypeTest.PublicId;
begin
  Assert.IsNotNull(Data.PublicId);
  Assert.CheckString("", Data.PublicId);

  Doc := XmlDocument.FromString(XmlTestData.CharXml);
  Assert.IsNotNull(Doc);
  Assert.IsNotNull(Doc.DocumentType);
  Assert.IsNotNull(Doc.DocumentType.PublicId);
  Assert.CheckString("-//W3C//DTD XHTML 1.0 Transitional//EN", Doc.DocumentType.PublicId);
end;

method DocumentTypeTest.SystemId;
begin
  Assert.IsNotNull(Data.SystemId);
  Assert.CheckString("", Data.SystemId);

  Doc := XmlDocument.FromString(XmlTestData.CharXml);
  Assert.IsNotNull(Doc);
  Assert.IsNotNull(Doc.DocumentType);
  Assert.IsNotNull(Doc.DocumentType.SystemId);
  Assert.CheckString("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd", Doc.DocumentType.SystemId);
end;

method DocumentTypeTest.NodeType;
begin
  Assert.CheckBool(true, Data.NodeType = XmlNodeType.DocumentType);
end;

method DocumentTypeTest.AccessFromDocument;
begin
  Assert.IsNotNull(Doc.DocumentType);
  Assert.CheckBool(true, Doc.DocumentType.Equals(Data));
end;

method DocumentTypeTest.Name;
begin
  Assert.IsNotNull(Data.Name);
  Assert.CheckString("note", Data.Name);
end;

method DocumentTypeTest.LocalName;
begin
  Assert.IsNotNull(Data.LocalName);
  Assert.CheckString("note", Data.LocalName);
end;

method DocumentTypeTest.Childs;
begin
  Assert.CheckInt(0, Data.ChildCount);
  Assert.IsNull(Data.FirstChild);
  Assert.IsNull(Data.LastChild);
  Assert.CheckInt(0, length(Data.ChildNodes));
  {$WARNING Disabled due to bug #}
  //Assert.IsException(->Data.Item[0]);
end;

method DocumentTypeTest.Value;
begin
  {$IF NOT ANDROID}
  Assert.IsNotNull(Data.Value);
  Assert.CheckBool(true, Data.Value.Contains("<!ELEMENT to (#PCDATA)>"));
  Data.Value := "UNKNOWN";
  Assert.CheckBool(true, Data.Value.Contains("<!ELEMENT to (#PCDATA)>"));
  {$ENDIF}
end;

end.
