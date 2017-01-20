﻿namespace Sugar.Xml;

interface

uses
  {$IF COOPER}
  org.w3c.dom,
  {$ELSEIF ECHOES}
  System.Xml.Linq,
  System.Linq,
  {$ELSEIF TOFFEE}
  Foundation,
  {$ENDIF}
  Sugar,
  Sugar.IO;

type
  XmlDocument = public class (XmlNode)
  private
    {$IF COOPER}
    class method ParseXml(Content: String; BaseUri: String): not nullable XmlDocument;
    property Doc: Document read Node as Document;
    {$ELSEIF ECHOES}
    property Doc: XDocument read Node as XDocument;
    {$ELSEIF TOFFEE}
    property Doc: ^libxml.__struct__xmlDoc read ^libxml.__struct__xmlDoc(Node);
    method GetDocumentElement: XmlElement;
    method GetDocumentType: XmlDocumentType;
    {$ENDIF}
    method GetElement(Name: String): XmlElement;
  public
    {$IF ECHOES}
    property DocumentElement: XmlElement read iif(Doc.Root = nil, nil, new XmlElement(Doc.Root));
    property DocumentType: XmlDocumentType read iif(Doc.DocumentType = nil, nil, new XmlDocumentType(Doc.DocumentType));
    {$ELSEIF COOPER}
    property DocumentElement: XmlElement read iif(Doc.DocumentElement = nil, nil, new XmlElement(Doc.DocumentElement));
    property DocumentType: XmlDocumentType read iif(Doc.Doctype = nil, nil, new XmlDocumentType(Doc.Doctype));
    {$ELSEIF TOFFEE}
    property DocumentElement: XmlElement read GetDocumentElement;
    property DocumentType: XmlDocumentType read GetDocumentType;
    {$ENDIF}
    property NodeType: XmlNodeType read XmlNodeType.Document; override;

    property Element[Name: String]: XmlElement read GetElement; default;

    method AddChild(Node: XmlNode);
    method RemoveChild(Node: XmlNode);
    method ReplaceChild(Node: XmlNode; WithNode: XmlNode);

    method CreateAttribute(Name: String): XmlAttribute;
    method CreateAttribute(QualifiedName: String; NamespaceUri: String): XmlAttribute;
    method CreateXmlNs(Prefix: String; NamespaceUri: String): XmlAttribute;
    method CreateCDataSection(Data: String): XmlCDataSection;
    method CreateComment(Data: String): XmlComment;
    method CreateElement(Name: String): XmlElement;
    method CreateElement(QualifiedName: String; NamespaceUri: String): XmlElement;
    method CreateProcessingInstruction(Target, Data: String): XmlProcessingInstruction;
    method CreateTextNode(Data: String): XmlText;

    method GetElementsByTagName(Name: String): array of XmlElement;
    method GetElementsByTagName(LocalName, NamespaceUri: String): array of XmlElement;

    class method FromFile(aFile: File): not nullable XmlDocument;
    class method FromBinary(aBinary: Binary): not nullable XmlDocument;
    class method FromString(aString: String): not nullable XmlDocument;
    class method CreateDocument: not nullable XmlDocument;

    method Save(aFile: File);
    method Save(aFile: File; XmlDeclaration: XmlDocumentDeclaration);
    method Save(aFile: File; Version: String; Encoding: String; Standalone: Boolean);
    {$IF TOFFEE}finalizer;{$ENDIF}
  end;

  XmlDocumentDeclaration = public class
  public
    constructor; empty;
    constructor(aVersion: String; anEncoding: String; aStandalone: Boolean);

    property Encoding: String read write;
    property Standalone: Boolean read write;
    property StandaloneString: String read iif(Standalone, "yes", "no");
    property Version: String read write;
  end;

  {$IF WINDOWS_PHONE OR NETFX_CORE}
  UTF8StringWriter = private class (System.IO.StringWriter)
  public
    property Encoding: System.Text.Encoding read System.Text.Encoding.UTF8; override;
  end;
  {$ENDIF}

implementation

{$IF COOPER}
method XmlDocument.GetElement(Name: String): XmlElement;
begin
  var Items := GetElementsByTagName(Name);
  if length(Items) = 0 then
    exit nil;

  exit Items[0];
end;

method XmlDocument.CreateAttribute(Name: String): XmlAttribute;
begin
  exit new XmlAttribute(Doc.CreateAttribute(Name));
end;

method XmlDocument.CreateAttribute(QualifiedName: String; NamespaceUri: String): XmlAttribute;
begin
  exit new XmlAttribute(Doc.CreateAttributeNS(NamespaceUri, QualifiedName));
end;

method XmlDocument.CreateXmlNs(Prefix: String; NamespaceUri: String): XmlAttribute;
begin
  SugarArgumentNullException.RaiseIfNil(Prefix, "Prefix");
  SugarArgumentNullException.RaiseIfNil(NamespaceUri, "NamesapceUri");

  var Attr := Doc.createAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:"+Prefix);
  Attr.TextContent := NamespaceUri;
  exit new XmlAttribute(Attr);
end;

method XmlDocument.CreateCDataSection(Data: String): XmlCDataSection;
begin
  exit new XmlCDataSection(Doc.CreateCDATASection(Data));
end;

method XmlDocument.CreateComment(Data: String): XmlComment;
begin
  exit new XmlComment(Doc.CreateComment(Data));
end;

method XmlDocument.CreateElement(Name: String): XmlElement;
begin
  exit new XmlElement(Doc.CreateElement(Name));
end;

method XmlDocument.CreateElement(QualifiedName: String; NamespaceUri: String): XmlElement;
begin
  exit new XmlElement(Doc.CreateElementNS(NamespaceUri, QualifiedName));
end;

method XmlDocument.CreateProcessingInstruction(Target: String; Data: String): XmlProcessingInstruction;
begin
  exit new XmlProcessingInstruction(Doc.CreateProcessingInstruction(Target, Data));
end;

method XmlDocument.CreateTextNode(Data: String): XmlText;
begin
  exit new XmlText(Doc.CreateTextNode(Data));
end;

method XmlDocument.GetElementsByTagName(Name: String): array of XmlElement;
begin
  if Name = nil then
    exit [];

  var items := Doc.GetElementsByTagName(Name);
  if items = nil then
    exit [];

  result := new XmlElement[items.length];
  for i: Integer := 0 to items.length-1 do
    result[i] := new XmlElement(items.Item(i));
end;

method XmlDocument.GetElementsByTagName(LocalName: String; NamespaceUri: String): array of XmlElement;
begin
  if Name = nil then
    exit [];

  var items := Doc.GetElementsByTagNameNS(NamespaceUri, LocalName);
  if items = nil then
    exit [];

  result := new XmlElement[items.length];
  for i: Integer := 0 to items.length-1 do
    result[i] := new XmlElement(items.Item(i));
end;

class method XmlDocument.ParseXml(Content: String; BaseUri: String): not nullable XmlDocument;
begin
  SugarArgumentNullException.RaiseIfNil(Content, "Content");

  //java can not ignore insignificant whitespaces, do a manual cleanup
  Content := java.lang.String(Content).replaceAll(">\s+<", "><");

  var Factory := javax.xml.parsers.DocumentBuilderFactory.newInstance;
  //handle namespaces
  Factory.NamespaceAware := true;
  Factory.Validating := false;

  var Builder := Factory.newDocumentBuilder();
  var Input := new org.xml.sax.InputSource(new java.io.StringReader(Content));
  if BaseUri <> nil then
    Input.SystemId := BaseUri;

  Builder.setEntityResolver(new class org.xml.sax.EntityResolver(resolveEntity := method (publicId: java.lang.String; systemId: java.lang.String): org.xml.sax.InputSource
  begin
    if (publicId <> nil) or (systemId <> nil) then
      exit new org.xml.sax.InputSource(new java.io.ByteArrayInputStream(new SByte[0]))
    else
      exit nil;
  end
  ));

  var Document := Builder.parse(Input);

  //Normalize text content
  Document.normalize;

  exit new XmlDocument(Document);
end;

class method XmlDocument.FromFile(aFile: File): not nullable XmlDocument;
begin
  var Handle := aFile.Open(FileOpenMode.ReadOnly);
  try
    var Bin := Handle.Read(Handle.Length);
    exit ParseXml(new String(Bin.ToArray, Encoding.UTF8), aFile.FullPath);
  finally
    Handle.Close;
  end;
end;

class method XmlDocument.FromBinary(aBinary: Binary): not nullable XmlDocument;
begin
  exit ParseXml(new String(aBinary.ToArray, Encoding.UTF8), nil);
end;

class method XmlDocument.FromString(aString: String): not nullable XmlDocument;
begin
  exit ParseXml(aString, nil);
end;

class method XmlDocument.CreateDocument: not nullable XmlDocument;
begin
  var Factory := javax.xml.parsers.DocumentBuilderFactory.newInstance;
  Factory.NamespaceAware := true;
  var Builder := Factory.newDocumentBuilder();
  exit new XmlDocument(Builder.newDocument());
end;

method XmlDocument.Save(aFile: File);
begin
  Save(aFile, nil);
end;

method XmlDocument.Save(aFile: File; Version: String; Encoding: String; Standalone: Boolean);
begin
  Save(aFile, new XmlDocumentDeclaration(Version, Encoding, Standalone));
end;

method XmlDocument.Save(aFile: File; XmlDeclaration: XmlDocumentDeclaration);
begin
  var Factory := javax.xml.transform.TransformerFactory.newInstance();
  var Transformer := Factory.newTransformer();
  var Source: javax.xml.transform.dom.DOMSource := new javax.xml.transform.dom.DOMSource(Doc);

  Transformer.setOutputProperty(javax.xml.transform.OutputKeys.INDENT, "yes");
  Transformer.setOutputProperty(javax.xml.transform.OutputKeys.METHOD, "xml");
  Transformer.setOutputProperty(javax.xml.transform.OutputKeys.OMIT_XML_DECLARATION, "no");

  if Doc.Doctype <> nil then begin
    Transformer.setOutputProperty(javax.xml.transform.OutputKeys.DOCTYPE_PUBLIC, Doc.Doctype.PublicId);
    Transformer.setOutputProperty(javax.xml.transform.OutputKeys.DOCTYPE_SYSTEM, Doc.Doctype.SystemId);
  end;

  if XmlDeclaration <> nil then begin
    Transformer.setOutputProperty(javax.xml.transform.OutputKeys.ENCODING, XmlDeclaration.Encoding);
    Transformer.setOutputProperty(javax.xml.transform.OutputKeys.VERSION, XmlDeclaration.Version);
    Transformer.setOutputProperty(javax.xml.transform.OutputKeys.STANDALONE, XmlDeclaration.StandaloneString);
    Doc.XmlStandalone := XmlDeclaration.Standalone;
  end;

  var Stream := new javax.xml.transform.stream.StreamResult(aFile);
  Transformer.transform(Source, Stream);
end;

method XmlDocument.AddChild(Node: XmlNode);
begin
  SugarArgumentNullException.RaiseIfNil(Node, "Node");

  if not (Node.NodeType in [XmlNodeType.Comment, XmlNodeType.Element, XmlNodeType.ProcessingInstruction]) then
    raise new SugarInvalidOperationException("Unable to insert node. Only elements, comments and processing instructions allowed.");

  Doc.appendChild(Node.Node);
end;

method XmlDocument.RemoveChild(Node: XmlNode);
begin
  Doc.removeChild(Node.Node);
end;

method XmlDocument.ReplaceChild(Node: XmlNode; WithNode: XmlNode);
begin
  Doc.replaceChild(WithNode.Node, Node.Node);
end;
{$ELSEIF ECHOES}
method XmlDocument.AddChild(Node: XmlNode);
begin
  Doc.Add(Node.Node);
end;

method XmlDocument.CreateAttribute(Name: String): XmlAttribute;
begin
  var Attr := new XAttribute(System.String(Name), "");
  exit new XmlAttribute(Attr);
end;

method XmlDocument.CreateAttribute(QualifiedName: String; NamespaceUri: String): XmlAttribute;
begin
  var lIndex := QualifiedName.IndexOf(":");

  if lIndex <> -1 then
    QualifiedName := QualifiedName.Substring(lIndex+1, QualifiedName.Length - lIndex - 1);

  var ns: XNamespace := System.String(NamespaceUri);
  var Attr := new XAttribute(ns + QualifiedName, "");
  exit new XmlAttribute(Attr);
end;

method XmlDocument.CreateXmlNs(Prefix: String; NamespaceUri: String): XmlAttribute;
begin
  var Attr := new XAttribute(XNamespace.Xmlns + Prefix, NamespaceUri);
  exit new XmlAttribute(Attr);
end;

method XmlDocument.CreateCDataSection(Data: String): XmlCDataSection;
begin
  var CData := new XCData(Data);
  exit new XmlCDataSection(CData);
end;

method XmlDocument.CreateComment(Data: String): XmlComment;
begin
  var Comment := new XComment(Data);
  exit new XmlComment(Comment);
end;

class method XmlDocument.CreateDocument: not nullable XmlDocument;
begin
  var Doc := new XDocument;
  exit new XmlDocument(Doc);
end;

method XmlDocument.CreateElement(Name: String): XmlElement;
begin
  var el := new XElement(System.String(Name));
  exit new XmlElement(el);
end;

method XmlDocument.CreateElement(QualifiedName: String; NamespaceUri: String): XmlElement;
begin
  var ns: XNamespace := System.String(NamespaceUri);
  var el := new XElement(ns + QualifiedName);
  exit new XmlElement(el);
end;

method XmlDocument.CreateProcessingInstruction(Target: String; Data: String): XmlProcessingInstruction;
begin
  var pi := new XProcessingInstruction(Target, Data);
  exit new XmlProcessingInstruction(pi);
end;

method XmlDocument.CreateTextNode(Data: String): XmlText;
begin
  var text := new XText(Data);
  exit new XmlText(text);
end;

method XmlDocument.GetElement(Name: String): XmlElement;
begin
  var Items := GetElementsByTagName(Name);
  if length(Items) = 0 then
    exit nil;

  exit Items[0];
end;

method XmlDocument.GetElementsByTagName(LocalName: String; NamespaceUri: String): array of XmlElement;
begin
  if DocumentElement = nil then
    exit [];

  exit DocumentElement.GetElementsByTagName(LocalName, NamespaceUri);
end;

method XmlDocument.GetElementsByTagName(Name: String): array of XmlElement;
begin
  if DocumentElement = nil then
    exit [];

  exit DocumentElement.GetElementsByTagName(Name);
end;

class method XmlDocument.FromFile(aFile: File): not nullable XmlDocument;
begin
  {$IF WINDOWS_PHONE OR NETFX_CORE}
  var Handle := aFile.Open(FileOpenMode.ReadOnly);
  try
    var Content := new String(Handle.Read(Handle.Length).ToArray, Encoding.UTF8);
    var reader := new System.IO.StringReader(Content);
    var document := XDocument.Load(reader, LoadOptions.SetBaseUri);
    exit new XmlDocument(document);
  finally
    Handle.Close;
  end;
  {$ELSE}
  var document := XDocument.Load(System.String(aFile), LoadOptions.SetBaseUri);
  result := new XmlDocument(document);
  {$ENDIF}
end;

class method XmlDocument.FromBinary(aBinary: Binary): not nullable XmlDocument;
begin
  var ms := System.IO.MemoryStream(aBinary);
  var Position := ms.Position;
  ms.Position := 0;
  try
    var document := XDocument.Load(ms, LoadOptions.SetBaseUri);
    result := new XmlDocument(document);
  finally
    ms.Position := Position;
  end;
end;

class method XmlDocument.FromString(aString: String): not nullable XmlDocument;
begin
  var document := XDocument.Parse(aString);
  result := new XmlDocument(document);
end;

method XmlDocument.RemoveChild(Node: XmlNode);
begin
  (Node.Node as XNode):&Remove;
end;

method XmlDocument.ReplaceChild(Node: XmlNode; WithNode: XmlNode);
begin
  (Node.Node as XNode):ReplaceWith(WithNode.Node);
end;

method XmlDocument.Save(aFile: File);
begin
  Save(aFile, nil);
end;

method XmlDocument.Save(aFile: File; Version: String; Encoding: String; Standalone: Boolean);
begin
  Save(aFile, new XmlDocumentDeclaration(Version, Encoding, Standalone));
end;

method XmlDocument.Save(aFile: File; XmlDeclaration: XmlDocumentDeclaration);
begin
  if XmlDeclaration <> nil then
    Doc.Declaration := new XDeclaration(XmlDeclaration.Version, XmlDeclaration.Encoding, XmlDeclaration.StandaloneString);

  {$IF WINDOWS_PHONE OR NETFX_CORE}
  var sb := new StringBuilder;
  var writer := new UTF8StringWriter(sb);
  Doc.Save(writer);
  var Handle := aFile.Open(FileOpenMode.ReadWrite);
  try
    Handle.Length := 0;
    Handle.Write(Encoding.UTF8.GetBytes(sb.ToString));
  finally
    Handle.Close;
  end;
  {$ELSEIF ECHOES}
  Doc.Save(aFile);
  {$ENDIF}
end;
{$ELSEIF TOFFEE}
method XmlDocument.AddChild(Node: XmlNode);
begin
  SugarArgumentNullException.RaiseIfNil(Node, "Node");

  if not (Node.NodeType in [XmlNodeType.Comment, XmlNodeType.Element, XmlNodeType.ProcessingInstruction]) then
    raise new SugarInvalidOperationException("Unable to insert node. Only elements, comments and processing instructions allowed.");

  if (DocumentElement <> nil) and (Node.NodeType = XmlNodeType.Element) then
    raise new SugarInvalidOperationException("Unable to insert node. Root element already exists");

  var NewNode := libxml.xmlAddChild(libxml.xmlNodePtr(Doc), libxml.xmlNodePtr(Node.Node));

  if NewNode = nil then
    raise new SugarInvalidOperationException("Unable to insert node {0} to a document", Node.Name);

  Node.Node := ^libxml.__struct__xmlNode(NewNode);
end;

method XmlDocument.CreateAttribute(Name: String): XmlAttribute;
begin
  SugarArgumentNullException.RaiseIfNil(Name, "Name");

  if libxml.xmlValidateName(XmlChar.FromString(Name), 0) <> 0 then
    raise new SugarArgumentException("Invalid attribute name {0}", Name);

  var NewObj := libxml.xmlNewProp(nil, XmlChar.FromString(Name), XmlChar.FromString(""));

  if NewObj = nil then
    raise new SugarInvalidOperationException("Unable to create attribute {0}", Name);

  exit new XmlAttribute(^libxml.__struct__xmlNode(NewObj), self);
end;

method XmlDocument.CreateAttribute(QualifiedName: String; NamespaceUri: String): XmlAttribute;
begin
  SugarArgumentNullException.RaiseIfNil(QualifiedName, "QualifiedName");
  SugarArgumentNullException.RaiseIfNil(NamespaceUri, "NamespaceUri");

  var prefix: ^libxml.xmlChar;
  var local := libxml.xmlSplitQName2(XmlChar.FromString(QualifiedName), var prefix);

  if local = nil then
    raise new SugarFormatException("Element name is not qualified name");

  //create a new namespace definition
  var ns := libxml.xmlNewNs(nil, XmlChar.FromString(NamespaceUri), prefix);
  //create a new property and set reference to a namespace
  var NewObj := libxml.xmlNewNsProp(nil, ns, local, XmlChar.FromString(""));
  //This attribute MUST be added to a node, or we end up with namespace not being released
  if NewObj = nil then
    exit nil;
  exit new XmlAttribute(^libxml.__struct__xmlNode(NewObj), self);
end;

method XmlDocument.CreateXmlNs(Prefix: String; NamespaceUri: String): XmlAttribute;
begin
  SugarArgumentNullException.RaiseIfNil(Prefix, "Prefix");
  SugarArgumentNullException.RaiseIfNil(NamespaceUri, "NamespaceUri");

  if Prefix.StartsWith("<") or Prefix.StartsWith("&") then
    raise new SugarArgumentException("Invalid attribute prefix {0}", Prefix);

  var ns := libxml.xmlNewNs(nil, XmlChar.FromString("http://www.w3.org/2000/xmlns/"), XmlChar.FromString("xmlns"));
  var NewObj := libxml.xmlNewNsProp(nil, ns, XmlChar.FromString(Prefix), XmlChar.FromString(NamespaceUri));

  if NewObj = nil then
    exit nil;

  exit new XmlAttribute(^libxml.__struct__xmlNode(NewObj), self);
end;

method XmlDocument.CreateCDataSection(Data: String): XmlCDataSection;
begin
  var NewObj := libxml.xmlNewCDataBlock(libxml.xmlDocPtr(Doc), XmlChar.FromString(Data), Data.length);
  if NewObj = nil then
    exit nil;

  exit new XmlCDataSection(^libxml.__struct__xmlNode(NewObj), self);
end;

method XmlDocument.CreateComment(Data: String): XmlComment;
begin
  var NewObj := libxml.xmlNewComment(XmlChar.FromString(Data));
  if NewObj = nil then
    exit nil;

  exit new XmlComment(^libxml.__struct__xmlNode(NewObj), self);
end;

class method XmlDocument.CreateDocument: not nullable XmlDocument;
begin
  var NewObj := libxml.xmlNewDoc(XmlChar.FromString("1.0"));
  result := new XmlDocument(^libxml.__struct__xmlNode(NewObj), nil);
  result.OwnerDocument := result;
end;

method XmlDocument.CreateElement(Name: String): XmlElement;
begin
  var NewObj := libxml.xmlNewDocRawNode(libxml.xmlDocPtr(Node), nil, XmlChar.FromString(Name), nil);
  if NewObj = nil then
    exit nil;

  exit new XmlElement(^libxml.__struct__xmlNode(NewObj), self);
end;

method XmlDocument.CreateElement(QualifiedName: String; NamespaceUri: String): XmlElement;
begin
  var prefix: ^libxml.xmlChar;
  var local := libxml.xmlSplitQName2(XmlChar.FromString(QualifiedName), var prefix);

  if local = nil then
    raise new SugarFormatException("Element name is not qualified name");

  var NewObj := libxml.xmlNewDocRawNode(libxml.xmlDocPtr(Node), nil, local, nil);
  if NewObj = nil then
    exit nil;

  var ns := libxml.xmlNewNs(NewObj, XmlChar.FromString(NamespaceUri), prefix);
  libxml.xmlSetNs(NewObj, ns);

  exit new XmlElement(^libxml.__struct__xmlNode(NewObj), self);
end;

method XmlDocument.CreateProcessingInstruction(Target: String; Data: String): XmlProcessingInstruction;
begin
  var NewObj := libxml.xmlNewPI(XmlChar.FromString(Target), XmlChar.FromString(Data));
  if NewObj = nil then
    exit nil;

  exit new XmlProcessingInstruction(^libxml.__struct__xmlNode(NewObj), self);
end;

method XmlDocument.CreateTextNode(Data: String): XmlText;
begin
  var NewObj := libxml.xmlNewText(XmlChar.FromString(Data));
  if NewObj = nil then
    exit nil;

  exit new XmlText(^libxml.__struct__xmlNode(NewObj), self);
end;

method XmlDocument.GetElement(Name: String): XmlElement;
begin
  var Items := GetElementsByTagName(Name);
  if length(Items) = 0 then
    exit nil;

  exit Items[0];
end;

method XmlDocument.GetElementsByTagName(LocalName: String; NamespaceUri: String): array of XmlElement;
begin
  exit new XmlNodeList(self).ElementsByName(LocalName, NamespaceUri);
end;

method XmlDocument.GetElementsByTagName(Name: String): array of XmlElement;
begin
  exit new XmlNodeList(self).ElementsByName(Name);
end;

class method XmlDocument.FromFile(aFile: File): not nullable XmlDocument;
begin
  var NewObj := libxml.xmlReadFile(NSString(aFile), "UTF-8", libxml.xmlParserOption.XML_PARSE_NOBLANKS);
  if NewObj = nil then
    raise new Exception("Could not parse XML Document");

  result := new XmlDocument(^libxml.__struct__xmlNode(NewObj), nil);
  result.OwnerDocument := result;
end;

class method XmlDocument.FromBinary(aBinary: Binary): not nullable XmlDocument;
begin
  var NewObj := libxml.xmlReadMemory(^AnsiChar(NSMutableData(aBinary).bytes), aBinary.Length, "", "UTF-8", libxml.xmlParserOption.XML_PARSE_NOBLANKS);
  if NewObj = nil then
    raise new Exception("Could not parse XML Document");

  result := new XmlDocument(^libxml.__struct__xmlNode(NewObj), nil);
  result.OwnerDocument := result;
end;

class method XmlDocument.FromString(aString: String): not nullable XmlDocument;
begin
  var Data := NSString(aString).dataUsingEncoding(NSStringEncoding.NSUTF8StringEncoding);
  exit FromBinary(Binary(Data));
end;

method XmlDocument.RemoveChild(Node: XmlNode);
begin
  SugarArgumentNullException.RaiseIfNil(Node, "Node");
  libxml.xmlUnlinkNode(libxml.xmlNodePtr(Node.Node));
  libxml.xmlFreeNode(libxml.xmlNodePtr(Node.Node));
end;

method XmlDocument.ReplaceChild(Node: XmlNode; WithNode: XmlNode);
begin
  SugarArgumentNullException.RaiseIfNil(Node, "Node");
  SugarArgumentNullException.RaiseIfNil(WithNode, "WithNode");

  if (Node.NodeType = XmlNodeType.Element) and (WithNode.NodeType <> XmlNodeType.Element) then
    raise new SugarInvalidOperationException("Unable to replace root node with non element node");

  if not (WithNode.NodeType in [XmlNodeType.Comment, XmlNodeType.Element, XmlNodeType.ProcessingInstruction]) then
    raise new SugarInvalidOperationException("Unable to replace node. Only elements, comments and processing instructions allowed.");

  if libxml.xmlReplaceNode(libxml.xmlNodePtr(Node.Node), libxml.xmlNodePtr(WithNode.Node)) = nil then
    raise new SugarInvalidOperationException("Unable to replace node {0} with node {1}", Node.Name, WithNode.Name);
end;

method XmlDocument.Save(aFile: File);
begin
  Save(aFile, nil);
end;

method XmlDocument.Save(aFile: File; Version: String; Encoding: String; Standalone: Boolean);
begin
  Save(aFile, new XmlDocumentDeclaration(Version := Version, Encoding := Encoding, Standalone := Standalone));
end;

method XmlDocument.Save(aFile: File; XmlDeclaration: XmlDocumentDeclaration);
begin
  if XmlDeclaration <> nil then begin
    Doc^.standalone := Integer(XmlDeclaration.Standalone);
    libxml.xmlSaveFormatFileEnc(NSString(aFile), libxml.xmlDocPtr(Node), NSString(XmlDeclaration.Encoding), 1);
    exit;
  end;

  libxml.xmlSaveFormatFile(NSString(aFile), libxml.xmlDocPtr(Node), 1);
end;

method XmlDocument.GetDocumentElement: XmlElement;
begin
  var Root := libxml.xmlDocGetRootElement(libxml.xmlDocPtr(Doc));
  if Root = nil then
    exit nil;

  exit new XmlElement(^libxml.__struct__xmlNode(Root), self);
end;

method XmlDocument.GetDocumentType: XmlDocumentType;
begin
  if Doc^.intSubset = nil then
    exit nil;

  exit new XmlDocumentType(^libxml.__struct__xmlNode(Doc^.intSubset), self);
end;

finalizer XmlDocument;
begin
  if Doc <> nil then
    libxml.xmlFreeDoc(libxml.xmlDocPtr(Doc));
end;
{$ENDIF}

{ XmlDocumentDeclaration }

constructor XmlDocumentDeclaration(aVersion: String; anEncoding: String; aStandalone: Boolean);
begin
  Version := aVersion;
  Encoding := anEncoding;
  Standalone := aStandalone;
end;

end.