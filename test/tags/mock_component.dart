library polymer_dependency_injection.test.mock_component;

import 'package:polymer/polymer.dart';
import 'package:dependency_injection/dependency_injection.dart';

@CustomTag('mock-component')
@component
class MockComponent extends PolymerElement {

  MockComponent.created() : super.created();
}

// vim: set ai et sw=2 syntax=dart :
