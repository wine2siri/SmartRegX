import 'package:flutter_test/flutter_test.dart';
import 'package:smart_regex/services/regex_validator.dart';
import 'package:smart_regex/services/regex_explainer.dart';

void main() {
  group('RegexValidator', () {
    test('valid regex returns null', () {
      expect(RegexValidator.validate(r'\d+'), isNull);
      expect(RegexValidator.validate('^\\d{3}-\\d{8}\$'), isNull);
      expect(RegexValidator.validate('[a-z]+'), isNull);
    });

    test('invalid regex returns error', () {
      expect(RegexValidator.validate('[['), isNotNull);
      expect(RegexValidator.validate('*abc'), isNotNull);
    });

    test('empty string returns null', () {
      expect(RegexValidator.validate(''), isNull);
    });
  });

  group('RegexExplainer', () {
    test('explains anchors', () {
      final result = RegexExplainer.explain('^abc\$');
      expect(result, contains('开头'));
      expect(result, contains('结尾'));
    });

    test('explains shorthand classes', () {
      expect(RegexExplainer.explain(r'\d'), contains('数字'));
      expect(RegexExplainer.explain(r'\w'), contains('字母数字下划线'));
      expect(RegexExplainer.explain(r'\s'), contains('空白符'));
    });

    test('explains quantifiers', () {
      expect(RegexExplainer.explain('a+'), contains('1次或多次'));
      expect(RegexExplainer.explain('a*'), contains('0次或多次'));
      expect(RegexExplainer.explain('a?'), contains('0次或1次'));
    });

    test('explains character classes', () {
      expect(RegexExplainer.explain('[a-z]'), contains('a到z'));
    });

    test('explains complex regex', () {
      final result = RegexExplainer.explain(r'^\d{3}-\d{8}$');
      expect(result, contains('开头'));
      expect(result, contains('数字'));
      expect(result, contains('结尾'));
    });

    test('empty string returns empty', () {
      expect(RegexExplainer.explain(''), equals(''));
    });
  });
}
