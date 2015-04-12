library polymer_dependency_injection.test.test_polymer_dependency_injection;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import 'package:logging/logging.dart';
import 'package:behave/behave.dart';
import 'package:polymer_dependency_injection/polymer_dependency_injection.dart';
import 'test_data.dart';


void main() {
  configureLogging();
  initPolymer().then((v) {
    Polymer.onReady.then(runTests);
  });
}

void configureLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.forEach(print);
}

void runTests(v) {
  useHtmlConfiguration();

  Feature feature = new Feature("Can scan DOM for beans and autowires");

  feature.load(new _Steps());

  feature.scenario("A bean with an unmet DOM dependency")
    .given("a @Configuration class instance")
    .when("I call configure() on the configuration")
    .then("the configuration fails")
    .test();

  feature.scenario("A bean with a DOM dependency")
    .given("a @Configuration class instance")
    .when("I scan the DOM")
    .and("I call configure() on the configuration")
    .then("the configuration succeeds")
    .test();

  feature.scenario("A bean with a DOM dependency")
    .given("a @Configuration class instance")
    .when("I scan the DOM")
    .and("I call configure() on the configuration")
    .then("the configuration is autowired")
    .test();

  feature.scenario("A bean with a DOM dependency")
    .given("a @Configuration class instance")
    .when("I scan the DOM")
    .and("I call configure() on the configuration")
    .then("the beans are autowired")
    .test();
}

class _Steps {

  @Given("a @Configuration class instance")
  void makeConfiguration(Map<String, dynamic> context) {
    context["configuration"] = new TestConfiguration();
  }

  @When("I call configure() on the configuration")
  void callConfigure(Map<String, dynamic> context) {
    (context["configuration"] as AbstractHtmlInjectConfiguration)
      .configure();
  }

  @When("I scan the DOM")
  void scanDOM(Map<String, dynamic> context) {
    (context["configuration"] as AbstractHtmlInjectConfiguration)
      .scan(document.querySelector('body'));
  }

  @Then("the configuration fails")
  void testConfigurationFails(Map<String, dynamic> context, ContextFunction previous) {
    expect(() => previous(context), throws);
  }

  @Then("the configuration succeeds")
  void testConfigurationSucceeds(Map<String, dynamic> context, ContextFunction previous) {
    expect(() => previous(context), returnsNormally);
  }

  @Then("the configuration is autowired")
  void testContextAutowired(Map<String, dynamic> context) {
    TestConfiguration configuration = context["configuration"] as TestConfiguration;
    expect(configuration.hasBeenAutowired, isTrue);
  }

  @Then("the beans are autowired")
  void testBeanAutowired(Map<String, dynamic> context) {
    TestConfiguration configuration = context["configuration"] as TestConfiguration;
    expect(configuration.autowiredBean.hasBeenAutowired, isTrue);
  }
}

// vim: set ai et sw=2 syntax=dart :
