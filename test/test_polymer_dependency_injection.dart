library polymer_dependency_injection.test.test_polymer_dependency_injection;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import 'test_data.dart';

final String nl = "\n     ";

void main() {
  initPolymer().run(runTests);
}

void runTests() {
  useHtmlConfiguration();

  group('Given a @Configuration class instance${nl}', () {
    TestConfiguration configuration;

    setUp(() {
      configuration = new TestConfiguration();
    });
    test('When I configure the instance${nl} Then the configuration fails',
      () {
        expect(() => configuration.configure(), throws);
      }
    );
    test('When I scan the DOM${nl} And configure the instance${nl} Then the configuration succeeds',
      () {
        expect(triggerConfiguration(configuration), returnsNormally);
      }
    );
    test('When I scan the DOM${nl} And configure the instance${nl} Then the configuration is autowired',
      () => when(triggerConfiguration(configuration)).then(configurationHasBeenAutowired)
    );
    test('When I scan the DOM${nl} And configure the instance${nl} Then the beans are autowired',
      () => when(triggerConfiguration(configuration)).then(beansHaveBeenAutowired)
    );
  });
}

typedef dynamic Clause();

Future<dynamic> given(Clause clause) => new Future.value(clause());
Future<dynamic> when(Clause clause) => new Future.value(clause());

Clause triggerConfiguration(TestConfiguration configuration) =>
  () {
    configuration.scan(document.querySelector('body'));
    configuration.configure();
    return configuration;
  };

void configurationHasBeenAutowired(TestConfiguration configuration) {
  expect(configuration.hasBeenAutowired, isTrue);
}

void beansHaveBeenAutowired(TestConfiguration configuration) {
  expect(configuration.autowiredBean.hasBeenAutowired, isTrue);
}

// vim: set ai et sw=2 syntax=dart :
