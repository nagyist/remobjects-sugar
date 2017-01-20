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
  Sugar;

type
  XmlElement = public class (XmlNode)
  private
    {$IF NOT TOFFEE}
    property Element: {$IF COOPER}Element{$ELSEIF ECHOES}XElement{$ENDIF}
                      read Node as{$IF COOPER}Element{$ELSEIF ECHOES}XElement{$ENDIF};
    {$ENDIF}
    {$IF TOFFEE}
    method CopyNS(aNode: XmlAttribute);
    {$ENDIF}
  public
    {$IF ECHOES}
    property Name: String read Element.Name.ToString; override;
    property LocalName: String read Element.Name.LocalName; override;
    property Value: String read Element.Value write Element.Value; override;
    {$ENDIF}
    property NodeType: XmlNodeType read XmlNodeType.Element; override;

    { Children }

    method AddChild(aNode: XmlNode);
    method RemoveChild(aNode: XmlNode);
    method ReplaceChild(aNode: XmlNode; WithNode: XmlNode);

    { Attributes }

    method GetAttribute(aName: String): String;
    method GetAttribute(aLocalName, NamespaceUri: String): String;
    method GetAttributeNode(aName: String): XmlAttribute;
    method GetAttributeNode(aLocalName, NamespaceUri: String): XmlAttribute;

    method SetAttribute(aName, aValue: String);
    method SetAttribute(aLocalName, NamespaceUri, aValue: String);
    method SetAttributeNode(Node: XmlAttribute);

    method RemoveAttribute(aName: String);
    method RemoveAttribute(aLocalName, NamespaceUri: String);
    method RemoveAttributeNode(Node: XmlAttribute);

    method HasAttribute(aName: String): Boolean;
    method HasAttribute(aLocalName, NamespaceUri: String): Boolean;

    property Attributes[aName: String]: XmlAttribute read GetAttributeNode(aName);
    method GetAttributes: array of XmlAttribute;

    { Elements }
    //method GetElements(): array of XmlElement;
    method GetElementsByTagName(aName: String): array of XmlElement;
    method GetElementsByTagName(aLocalName, NamespaceUri: String): array of XmlElement;

    method GetFirstElementWithName(aName: String): XmlElement;
  end;

implementation

method XmlElement.GetAttributes: array of XmlAttribute;
begin
  {$IF COOPER}
  var ItemsCount: Integer := Element.Attributes.Length;
  var lItems: array of XmlAttribute := new XmlAttribute[ItemsCount];
  for i: Integer := 0 to ItemsCount-1 do
    lItems[i] := new XmlAttribute(Element.Attributes.Item(i));

  exit lItems;
  {$ELSEIF ECHOES}
  var items := Element.Attributes:ToArray;
  if items = nil then
    exit new XmlAttribute[0];

  result := new XmlAttribute[items.Length];
  for i: Integer := 0 to items.Length-1 do
    result[i] := new XmlAttribute(items[i]);
  {$ELSEIF TOFFEE}
  var List := new Sugar.Collections.List<XmlAttribute>;
  var ChildPtr := Node^.properties;
  while ChildPtr <> nil do begin
    List.Add(new XmlAttribute(^libxml.__struct__xmlNode(ChildPtr), OwnerDocument));
    ChildPtr := ^libxml.__struct__xmlAttr(ChildPtr^.next);
  end;

  result := List.ToArray;
  {$ENDIF}
end;

method XmlElement.AddChild(aNode: XmlNode);
begin
  SugarArgumentNullException.RaiseIfNil(aNode, "Node");

  if aNode.OwnerDocument <> nil then
    if not aNode.OwnerDocument.Equals(self.OwnerDocument) then
      raise new SugarInvalidOperationException("Unable to insert node that is owned by other document");

  {$IF COOPER}
  if aNode.NodeType = XmlNodeType.Attribute then
    SetAttributeNode(XmlAttribute(aNode))
  else
    Element.appendChild(aNode.Node);
  {$ELSEIF ECHOES}
  if aNode.Node.Parent <> nil then
    RemoveChild(aNode);

  Element.Add(aNode.Node);
  {$ELSEIF TOFFEE}
  if aNode.Node^.parent <> nil then
    libxml.xmlUnlinkNode(libxml.xmlNodePtr(aNode.Node));

  var NewNode := libxml.xmlAddChild(libxml.xmlNodePtr(Node), libxml.xmlNodePtr(aNode.Node));
  aNode.Node := ^libxml.__struct__xmlNode(NewNode);
  {$ENDIF}
end;

method XmlElement.RemoveChild(aNode: XmlNode);
begin
  {$IF COOPER}
  Element.removeChild(aNode.Node);
  {$ELSEIF ECHOES}
  (aNode.Node as XNode):&Remove;
  {$ELSEIF TOFFEE}
  libxml.xmlUnlinkNode(libxml.xmlNodePtr(aNode.Node));
  //libxml.xmlFreeNode(libxml.xmlNodePtr(aNode.Node));
  {$ENDIF}
end;

method XmlElement.ReplaceChild(aNode: XmlNode; WithNode: XmlNode);
begin
  if aNode.Parent = nil then
    raise new SugarInvalidOperationException("Unable to replace element without parent");

  {$IF COOPER}
  Element.replaceChild(WithNode.Node, aNode.Node);
  {$ELSEIF ECHOES}
  if WithNode.Node.Parent <> nil then
    RemoveChild(WithNode);

  (aNode.Node as XNode):ReplaceWith(WithNode.Node);
  {$ELSEIF TOFFEE}
  libxml.xmlReplaceNode(libxml.xmlNodePtr(aNode.Node), libxml.xmlNodePtr(WithNode.Node));
  {$ENDIF}
end;

method XmlElement.GetAttribute(aName: String): String;
begin
  exit GetAttributeNode(aName):Value;
end;

method XmlElement.GetAttribute(aLocalName: String; NamespaceUri: String): String;
begin
  exit GetAttributeNode(aLocalName, NamespaceUri):Value;
end;

method XmlElement.GetAttributeNode(aName: String): XmlAttribute;
begin
  if aName = nil then
    exit nil;

  var Attr := {$IF COOPER}Element.GetAttributeNode(aName){$ELSEIF ECHOES}Element.Attribute(System.String(aName))
              {$ELSEIF TOFFEE}libxml.xmlHasProp(libxml.xmlNodePtr(Node), XmlChar.FromString(aName)){$ENDIF};

  if Attr = nil then
    exit nil;

  exit new XmlAttribute({$IF TOFFEE}^libxml.__struct__xmlNode(Attr), OwnerDocument{$ELSE}Attr{$ENDIF});
end;

method XmlElement.GetAttributeNode(aLocalName: String; NamespaceUri: String): XmlAttribute;
begin
  SugarArgumentNullException.RaiseIfNil(aLocalName, "LocalName");
  SugarArgumentNullException.RaiseIfNil(NamespaceUri, "NamespaceUri");

  var Attr := {$IF COOPER} Element.getAttributeNodeNS(NamespaceUri, aLocalName)
              {$ELSEIF ECHOES}Element.Attribute(XNamespace(NamespaceUri) + aLocalName)
              {$ELSEIF TOFFEE}libxml.xmlHasNsProp(libxml.xmlNodePtr(Node), XmlChar.FromString(aLocalName), XmlChar.FromString(NamespaceUri)){$ENDIF};

  if Attr = nil then
    exit nil;

  exit new XmlAttribute({$IF TOFFEE}^libxml.__struct__xmlNode(Attr), OwnerDocument{$ELSE}Attr{$ENDIF});
end;

method XmlElement.SetAttribute(aName: String; aValue: String);
begin
  SugarArgumentNullException.RaiseIfNil(aName, "Name");

  if aValue = nil then begin
    RemoveAttribute(aName);
    exit;
  end;

  {$IF COOPER}
  Element.SetAttribute(aName, aValue);
  {$ELSEIF ECHOES}
  Element.SetAttributeValue(aName, aValue);
  {$ELSEIF TOFFEE}
  libxml.xmlSetProp(libxml.xmlNodePtr(Node), XmlChar.FromString(aName), XmlChar.FromString(aValue));
  {$ENDIF}
end;

method XmlElement.SetAttribute(aLocalName: String; NamespaceUri: String; aValue: String);
begin
  SugarArgumentNullException.RaiseIfNil(aLocalName, "LocalName");
  SugarArgumentNullException.RaiseIfNil(NamespaceUri, "NamespaceUri");

  if aValue = nil then begin
    RemoveAttribute(aLocalName, NamespaceUri);
    exit;
  end;

  {$IF COOPER}
  Element.setAttributeNS(NamespaceUri, aLocalName, aValue);
  {$ELSEIF ECHOES}
  Element.SetAttributeValue(XNamespace(NamespaceUri) + aLocalName, aValue);
  {$ELSEIF TOFFEE}
  var ns := libxml.xmlSearchNsByHref(libxml.xmlDocPtr(Node^.doc), libxml.xmlNodePtr(Node), XmlChar.FromString(NamespaceUri));

  //no namespace with specified uri
  if ns = nil then
    raise new SugarException("Namespace with specified URI not found");

  libxml.xmlSetNsProp(libxml.xmlNodePtr(Node), ns, XmlChar.FromString(aLocalName), XmlChar.FromString(aValue));
  {$ENDIF}
end;

method XmlElement.SetAttributeNode(Node: XmlAttribute);
begin
  if Node.Parent <> nil then
    raise new SugarInvalidOperationException("Unable to insert attribute that is already owned by other element");

  {$IF COOPER}
  Element.setAttributeNode(Node.Node as Attr);
  {$ELSEIF ECHOES}
  var Existing := Element.Attribute(XAttribute(Node.Node).Name);

  if Existing <> nil then
    Existing.Remove;

  Element.Add(Node.Node);
  {$ELSEIF TOFFEE}
  AddChild(Node);
  CopyNS(Node);
  {$ENDIF}
end;

method XmlElement.RemoveAttribute(aName: String);
begin
  if aName = nil then
    exit;

  {$IF COOPER}
  Element.RemoveAttribute(aName);
  {$ELSEIF ECHOES}
  Element.SetAttributeValue(aName, nil);
  {$ELSEIF TOFFEE}
  libxml.xmlUnsetProp(libxml.xmlNodePtr(Node), XmlChar.FromString(aName));
  {$ENDIF}
end;

method XmlElement.RemoveAttribute(aLocalName: String; NamespaceUri: String);
begin
  SugarArgumentNullException.RaiseIfNil(aLocalName, "LocalName");
  SugarArgumentNullException.RaiseIfNil(NamespaceUri, "NamespaceUri");

  {$IF COOPER}
  Element.removeAttributeNS(NamespaceUri, aLocalName);
  {$ELSEIF ECHOES}
  Element.SetAttributeValue(XNamespace(NamespaceUri) + aLocalName, nil);
  {$ELSEIF TOFFEE}
  var Attr := libxml.xmlHasNsProp(libxml.xmlNodePtr(Node), XmlChar.FromString(aLocalName), XmlChar.FromString(NamespaceUri));

  if Attr = nil then
    exit;

  libxml.xmlRemoveProp(Attr);
  {$ENDIF}
end;

method XmlElement.RemoveAttributeNode(Node: XmlAttribute);
begin
  SugarArgumentNullException.RaiseIfNil(Node, "Node");

  if Node.OwnerElement = nil then
    raise new SugarInvalidOperationException("Unable to remove attribute that has no parent element");

  if not Node.OwnerElement.Equals(self) then
    raise new SugarInvalidOperationException("Unable to remove attribute that does not belong to this element");

  {$IF COOPER}
  Element.removeAttributeNode(Node.Node as Attr);
  {$ELSEIF ECHOES}
  XAttribute(Node.Node).Remove;
  {$ELSEIF TOFFEE}
  libxml.xmlRemoveProp(libxml.xmlAttrPtr(Node.Node));
  {$ENDIF}
end;

method XmlElement.HasAttribute(aName: String): Boolean;
begin
  if aName = nil then
    exit false;

  exit GetAttributeNode(aName) <> nil;
end;

method XmlElement.HasAttribute(aLocalName: String; NamespaceUri: String): Boolean;
begin
  exit GetAttributeNode(aLocalName, NamespaceUri) <> nil;
end;

method XmlElement.GetElementsByTagName(aLocalName: String; NamespaceUri: String): array of XmlElement;
begin
  {$IF COOPER}
  var items := Element.GetElementsByTagNameNS(NamespaceUri, aLocalName);
  if items = nil then
    exit [];

  result := new XmlElement[items.length];
  for i: Integer := 0 to items.length-1 do
    result[i] := new XmlElement(items.Item(i));
  {$ELSEIF ECHOES}
  var ns: XNamespace := System.String(NamespaceUri);
  var items := Element.DescendantsAndSelf(ns + aLocalName).ToArray;
  result := new XmlElement[items.Length];
  for I: Integer := 0 to items.Length - 1 do
    result[I] := new XmlElement(items[I]);
  {$ELSEIF TOFFEE}
  exit new XmlNodeList(self).ElementsByName(aLocalName, NamespaceUri);
  {$ENDIF}
end;

method XmlElement.GetElementsByTagName(aName: String): array of XmlElement;
begin
  {$IF COOPER}
  var items := Element.GetElementsByTagName(aName);
  if items = nil then
    exit [];

  result := new XmlElement[items.length];
  for i: Integer := 0 to items.length-1 do
    result[i] := new XmlElement(items.Item(i));
  {$ELSEIF ECHOES}
  var items := Element.DescendantsAndSelf(System.String(aName)).ToArray;
  result := new XmlElement[items.Length];
  for I: Integer := 0 to items.Length - 1 do
    result[I] := new XmlElement(items[I]);
  {$ELSEIF TOFFEE}
  exit new XmlNodeList(self).ElementsByName(aName);
  {$ENDIF}
end;

{$IF TOFFEE}
method XmlElement.CopyNS(aNode: XmlAttribute);
begin
  //nothing to copy
  if aNode.Node^.ns = nil then
    exit;

  //if nodes ns list is empty
  if Node^.nsDef = nil then begin
    Node^.nsDef := aNode.Node^.ns; //this ns will be our first element
    exit;
  end;

  var curr := ^libxml.__struct__xmlNs(aNode.Node^.ns);
  var prev := ^libxml.__struct__xmlNs(Node^.nsDef);

  while prev <> nil do begin
    //check if same ns already exists
    if ((prev^.prefix = nil) and (curr^.prefix = nil)) or (libxml.xmlStrEqual(prev^.prefix, curr^.prefix) = 1) then begin
      //if its a same ns
      if libxml.xmlStrEqual(prev^.href, curr^.href) = 1 then
        aNode.Node^.ns := libxml.xmlNsPtr(prev) //use existing
      else
        aNode.Node^.ns := nil; //else this ns is wrong
        //maybe should be exception here

      //we must release this ns
      libxml.xmlFreeNs(libxml.xmlNsPtr(curr));
      exit;
    end;

    prev := ^libxml.__struct__xmlNs(prev^.next);
  end;

  //set new ns as a last element in the list
  prev^.next := curr;
end;
{$ENDIF}

method XmlElement.GetFirstElementWithName(aName: String): XmlElement;
begin
  for item in ChildNodes do
    if (item is XmlElement) and item.Name.EqualsIgnoringCaseInvariant(aName) then exit XmlElement(item);
  exit nil;
end;

end.