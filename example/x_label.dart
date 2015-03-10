library polymer_dependency_injection.example.label;

import 'package:polymer/polymer.dart';
import 'package:dependency_injection/dependency_injection.dart';
import 'interfaces.dart';

@CustomTag('x-label')
@component
class LabelTag extends PolymerElement implements Incrementable {

  @published int count;

  LabelTag.created() : super.created();

  void increment() {
    count++;
  }
}

// vim: set ai et sw=2 syntax=dart :
