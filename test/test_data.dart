import 'package:polymer_dependency_injection/polymer_dependency_injection.dart';
import 'tags/mock_autowired_component.dart';
import 'tags/mock_component.dart';

class TestConfiguration extends AbstractHtmlInjectConfiguration {
  @autowired MockAutowiredComponent autowiredBean;
  @autowired MockComponent bean;

  bool get hasBeenAutowired => autowiredBean != null && bean != null;
}

// vim: set ai et sw=2 syntax=dart :
