import XCTest
@testable import SwiftGraphQl
import SwiftParse

final class ParserTests: XCTestCase, ParserHelpers {
  func testScratch() {
    let tokens: [StreamToken] = [.leftCurly, .name("test"), .rightCurly]
    let parser = accept(StreamToken.leftCurly) ~ accept(StreamToken.name("test")) ~ accept(StreamToken.rightCurly)
    
    let result = parser(ArraySlice(tokens))
    XCTAssertNotNil(try? result.get())
  }
//  func testParser() {
//    do {
//      try GraphQlParser(source: "test")
//    } catch {
//      XCTFail("Failed to parse")
//    }
//    XCTAssertNil(doc)
//    XCTAssertEqual(doc, [ExecutableDefinition.opDefinition(OperationDefinition([Selection.field(Field(alias: nil, name: "test", arguments: [], directives: [], selectionSet: []))]))])
//  }

  func testName() {
    assertParsed(GraphQlDocumentParser.name,
                 input: [.name("test")],
                 val: "test",
                 remaining: [])
  }
  func testIntValue() {
    assertParsed(GraphQlDocumentParser.intValue,
                 input: [StreamToken.intValue(0)],
                 val: Value.int(0),
                 remaining: [])
  }
  func testFloatValue() {
    assertParsed(GraphQlDocumentParser.floatValue,
                 input: [StreamToken.floatValue(1.5)],
                 val: Value.float(1.5),
                 remaining: [])
  }
  func testStringValue() {
    assertParsed(GraphQlDocumentParser.stringValue,
                 input: [StreamToken.stringValue("test")],
                 val: Value.string("test"),
                 remaining: [])
  }
  func testBooleanValue() {
    assertParsed(GraphQlDocumentParser.booleanValue,
                 input: [StreamToken.booleanValue(false)],
                 val: Value.boolean(false),
                 remaining: [])
  }
  func testNullValue() {
    assertParsed(GraphQlDocumentParser.nullValue,
                 input: [StreamToken.nullValue],
                 val: Value.null,
                 remaining: [])
  }
  func testEnumValue() {
    assertParsed(GraphQlDocumentParser.enumValue,
                 input: [.name("test")],
                 val: Value.enumArm("test"),
                 remaining: [])
  }
  func testEmptyList() {
    assertParsed(GraphQlDocumentParser.emptyList,
                 input: [StreamToken.leftBracket,
                         StreamToken.rightBracket],
                 val: [],
                 remaining: [])
  }
  func testValueListOne() {
    assertParsed(GraphQlDocumentParser.valueList,
                 input: [StreamToken.intValue(0)],
                 val: [Value.int(0)], remaining: [])
  }
  func testValueListTwo() {
    assertParsed(GraphQlDocumentParser.valueList,
                 input: [
                   StreamToken.intValue(0),
                   StreamToken.comma,
                   StreamToken.intValue(1)
                 ],
                 val: [Value.int(0), Value.int(1)],
                 remaining: [])
  }
  func testNonEmptyList() {
    assertParsed(GraphQlDocumentParser.nonEmptyList,
                 input: [
                    StreamToken.leftBracket,
                    StreamToken.intValue(0),
                    StreamToken.comma,
                    StreamToken.intValue(1),
                    StreamToken.rightBracket
                 ],
                 val: [
                   Value.int(0),
                   Value.int(1)
                 ],
                 remaining: [])
  }
  func testListValue() {
    assertParsed(GraphQlDocumentParser.listValue,
                 input: [
                   StreamToken.leftBracket,
                   StreamToken.rightBracket
                 ],
                 val: Value.list([]),
                 remaining: [])
                
    assertParsed(GraphQlDocumentParser.listValue,
                 input: [
                    StreamToken.leftBracket,
                    StreamToken.intValue(0),
                    StreamToken.comma,
                    StreamToken.intValue(1),
                    StreamToken.rightBracket
                 ],
                 val: Value.list([
                   Value.int(0),
                   Value.int(1)
                 ]),
                 remaining: [])
  }
  func testEmptyObject() {
    assertParsed(GraphQlDocumentParser.emptyObject,
                 input: [
                  StreamToken.leftCurly,
                  StreamToken.rightCurly
                 ],
                 val: Value.object([String:Value]()),
                 remaining: [])
  }
  func testKeyValueList() {
    assertParsed(GraphQlDocumentParser.keyValueList,
                 input: [
                  StreamToken.name("key"),
                  StreamToken.colon,
                  StreamToken.stringValue("value"),
                  StreamToken.comma,
                  StreamToken.name("key2"),
                  StreamToken.colon,
                  StreamToken.stringValue("value2")
                 ],
                 val: Value.object([
                  "key": Value.string("value"),
                  "key2": Value.string("value2")
                 ]),
                 remaining: [])
    
  }
  
  func testObjectValue() {
    assertParsed(GraphQlDocumentParser.objectValue,
                 input: [StreamToken.leftCurly, StreamToken.rightCurly],
                 val: Value.object([String:Value]()),
                 remaining: [])
    
    assertParsed(GraphQlDocumentParser.objectValue,
                 input: [
                  StreamToken.leftCurly,
                  StreamToken.name("key"),
                  StreamToken.colon,
                  StreamToken.stringValue("value"),
                  StreamToken.rightCurly
                 ],
                 val: Value.object([
                  "key": Value.string("value"),
                 ]),
                 remaining: [])
  }
  func testDirectiveName() {
    assertParsed(GraphQlDocumentParser.directiveName,
                 input: [StreamToken.directive("test")],
                 val: "test",
                 remaining: [])
  }
  func testArgument() {
    assertParsed(GraphQlDocumentParser.argument,
                 input: [
                  StreamToken.name("name"),
                  StreamToken.colon,
                  StreamToken.stringValue("value")
                 ],
                 val: Argument(name: "name", value: Value.string("value")),
                 remaining: [])
  }
  func testArgumentList() {
    assertParsed(GraphQlDocumentParser.argument,
                 input: [
                  StreamToken.name("name"),
                  StreamToken.colon,
                  StreamToken.stringValue("value")
                 ],
                 val: Argument(name: "name", value: Value.string("value")),
                 remaining: [])
  }
  
  func testConstValue() {
    assertParsed(GraphQlDocumentParser.constValue, input: [StreamToken.intValue(0)], val: Value.int(0), remaining: [])
    
    assertParsed(GraphQlDocumentParser.constValue,
                 input: [
                  StreamToken.leftBracket,
                  StreamToken.rightBracket
                 ],
                 val: Value.list([]),
                 remaining: [])
    
    assertParsed(GraphQlDocumentParser.constValue,
                  input: [
                   StreamToken.leftCurly,
                   StreamToken.rightCurly
                  ],
                  val: Value.object([String:Value]()),
                  remaining: [])
  }
  func testArguments() {
    assertParsed(GraphQlDocumentParser.arguments,
                 input: [
                  StreamToken.leftParen,
                  StreamToken.name("test"),
                  StreamToken.colon,
                  StreamToken.intValue(0),
                  StreamToken.rightParen],
                 val: [Argument(name: "test", value: Value.int(0))],
                 remaining: [])
  }
  func testDirective() {
    // @test
    assertParsed(GraphQlDocumentParser.directive,
                  input: [
                   StreamToken.directive("test")],
                  val: Directive(name: "test", arguments: []),
                  remaining: [])
            
    // @test(key: 0)
    assertParsed(GraphQlDocumentParser.directive,
                 input: [
                  StreamToken.directive("test"),
                  StreamToken.leftParen,
                  StreamToken.name("key"),
                  StreamToken.colon,
                  StreamToken.intValue(0),
                  StreamToken.rightParen],
                 val: Directive(name: "test", arguments: [Argument(name: "key", value: Value.int(0))]),
                 remaining: [])
  }
  func testNamedType() {
    // Test
    assertParsed(GraphQlDocumentParser.namedType,
                 input: [StreamToken.name("Test")],
                 val: Type.named("Test"),
                 remaining: [])
  }
  func testListType() {
    // [Test]
    assertParsed(GraphQlDocumentParser.listType,
                 input: [
                  StreamToken.leftBracket,
                  StreamToken.name("Test"),
                  StreamToken.rightBracket],
                 val: Type.list(Type.named("Test")),
                 remaining: [])
  }
  func testNonNullType() {
    // Test!
    assertParsed(GraphQlDocumentParser.nonNullType,
                 input: [
                  StreamToken.name("Test"),
                  StreamToken.exclamation],
                 val: Type.required(Type.named("Test")),
                 remaining: [])
  }
  func testVariable() {
    // $var
    assertParsed(GraphQlDocumentParser.variable,
                 input: [StreamToken.variable("var")],
                 val: "var",
                 remaining: [])
  }
  func testVariableDefinition() {
    // var: Type
    assertParsed(GraphQlDocumentParser.variableDefinition,
                 input: [
                  StreamToken.variable("var"),
                  StreamToken.colon,
                  StreamToken.name("String")],
                 val: VariableDefinition(
                  name: "var",
                  type: Type.named("String"),
                  defaultValue: nil,
                  directives: []),
                 remaining: [])
        
    // var: Type = "test"
    assertParsed(GraphQlDocumentParser.variableDefinition,
                 input: [
                  StreamToken.variable("var"),
                  StreamToken.colon,
                  StreamToken.name("String"),
                  StreamToken.assignment,
                  StreamToken.stringValue("test")],
                 val: VariableDefinition(
                  name: "var",
                  type: Type.named("String"),
                  defaultValue: Value.string("test"),
                  directives: []),
                 remaining: [])
    
    // var: Type @directive
    assertParsed(GraphQlDocumentParser.variableDefinition,
                 input: [
                  StreamToken.variable("var"),
                  StreamToken.colon,
                  StreamToken.name("String"),
                  StreamToken.directive("directive")],
                 val: VariableDefinition(
                  name: "var",
                  type: Type.named("String"),
                  defaultValue: nil,
                  directives: [Directive(name: "directive", arguments: [])]),
                 remaining: [])
  }
  func testVariableDefinitions() {
    assertParsed(GraphQlDocumentParser.variableList,
                 input: [
                  StreamToken.variable("var1"),
                  StreamToken.colon,
                  StreamToken.name("String"),
                  StreamToken.comma,
                  StreamToken.variable("var2"),
                  StreamToken.colon,
                  StreamToken.name("Int"),
                  StreamToken.assignment,
                  StreamToken.intValue(0)],
                 val: [
                  VariableDefinition(name: "var1",
                                     type: Type.named("String"),
                                     defaultValue: nil,
                                     directives: []),
                  VariableDefinition(name: "var2",
                                     type: Type.named("Int"),
                                     defaultValue: Value.int(0),
                                     directives: [])],
                 remaining: [])
  }
  func testAlias() {
    assertParsed(GraphQlDocumentParser.alias,
                 input: [
                  StreamToken.name("otherName"),
                  StreamToken.colon],
                 val: "otherName",
                 remaining: [])
  }
  func testFragmentSpread() {
    assertParsed(GraphQlDocumentParser.fragmentSpread,
                 input: [
                  StreamToken.ellipsis,
                  StreamToken.name("FragmentName")],
                 val: Selection.fragmentSpread("FragmentName", []),
                 remaining: [])
  }
  func testInlineFragment() {
    
  }
  func testSelection() {
    
  }
  func testSelectionSet() {
    
  }
  func testField() {
    // test
    let field = GraphQlDocumentParser.field()
    
    assertParsed(field,
                 input: [StreamToken.name("test")],
                 val: Field(name: "test"),
                 remaining: [])
    
    // another_name: test
    assertParsed(field,
                 input: [
                  StreamToken.name("anotherName"),
                  StreamToken.colon,
                  StreamToken.name("test")],
                 val: Field(
                  name: "test",
                  alias: "anotherName"),
                 remaining: [])
    
    // test @directive(name: "value")
    assertParsed(field,
                 input: [
                  StreamToken.name("test"),
                  StreamToken.directive("directive"),
                  StreamToken.leftParen, StreamToken.name("name"),
                  StreamToken.colon,
                  StreamToken.stringValue("value"),
                  StreamToken.rightParen],
                 val: Field(
                  name: "test",
                  directives: [
                    Directive(
                      name: "directive",
                      arguments: [
                        Argument(
                          name: "name",
                          value: Value.string("value"))])],
                  selectionSet: []),
                 remaining: [])
    
    // field { subfield }
    assertParsed(field,
                 input: [
                  StreamToken.name("field"),
                  StreamToken.leftCurly,
                  StreamToken.name("subfield"),
                  StreamToken.rightCurly],
                 val: Field(name: "field", selectionSet: [Selection.field(Field(name: "subfield"))]),
                 remaining: [])
    
    // field(name: 0)
    assertParsed(field,
    input: [
     StreamToken.name("field"),
     StreamToken.leftParen,
     StreamToken.name("name"),
     StreamToken.colon,
     StreamToken.intValue(0),
     StreamToken.rightParen],
    val: Field(name: "field", arguments: [Argument(name: "name", value: Value.int(0))]),
    remaining: [])
  }
  
  static var allTests = [
      ("testName", testName),
  ]
}


