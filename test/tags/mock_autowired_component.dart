library polymer_dependency_injection.test.mock_autowired_component;

import 'package:polymer/polymer.dart';
import 'package:dependency_injection/dependency_injection.dart';
import 'mock_component.dart';

@CustomTag('mock-autowired-component')
@component
class MockAutowiredComponent extends PolymerElement {

  @autowired MockComponent component;

  MockAutowiredComponent.created() : super.created();

  bool get hasBeenAutowired => component != null;
}

// vim: set ai et sw=2 syntax=dart :
