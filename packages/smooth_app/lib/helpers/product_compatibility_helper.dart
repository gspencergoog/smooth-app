import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';

enum ProductCompatibility {
  UNKNOWN,
  INCOMPATIBLE,
  BAD_COMPATIBILITY,
  NEUTRAL_COMPATIBILITY,
  GOOD_COMPATIBILITY,
}

class ProductCompatibilityResult {
  ProductCompatibilityResult(
      this.averageAttributeMatch, this.productCompatibility);
  final num averageAttributeMatch;
  final ProductCompatibility productCompatibility;
}

const int _BAD_COMPATIBILITY_UPPER_THRESHOLD = 33;
const int _NEUTRAL_COMPATIBILITY_UPPER_THRESHOLD = 66;

// Defines the weight of an attribute while computing the average match score
// for the product. The weight depends upon it's importance set in user prefs.
const Map<String, int> attributeImportanceWeight = <String, int>{
  PreferenceImportance.ID_MANDATORY: 4,
  PreferenceImportance.ID_VERY_IMPORTANT: 1, // same as important from now on
  PreferenceImportance.ID_IMPORTANT: 1,
  PreferenceImportance.ID_NOT_IMPORTANT: 0,
};

Color getProductCompatibilityHeaderBackgroundColor(
    ProductCompatibility compatibility) {
  switch (compatibility) {
    case ProductCompatibility.UNKNOWN:
      return Colors.grey;
    case ProductCompatibility.INCOMPATIBLE:
      return Colors.red;
    case ProductCompatibility.BAD_COMPATIBILITY:
      return Colors.orangeAccent;
    case ProductCompatibility.NEUTRAL_COMPATIBILITY:
      return Colors.amber;
    case ProductCompatibility.GOOD_COMPATIBILITY:
      return Colors.green;
  }
}

String getProductCompatibilityHeaderTextWidget(
  final ProductCompatibility compatibility,
  final AppLocalizations appLocalizations,
) {
  switch (compatibility) {
    case ProductCompatibility.UNKNOWN:
      return appLocalizations.product_compatibility_unknown;
    case ProductCompatibility.INCOMPATIBLE:
      return appLocalizations.product_compatibility_incompatible;
    case ProductCompatibility.BAD_COMPATIBILITY:
      return appLocalizations.product_compatibility_bad;
    case ProductCompatibility.NEUTRAL_COMPATIBILITY:
      return appLocalizations.product_compatibility_neutral;
    case ProductCompatibility.GOOD_COMPATIBILITY:
      return appLocalizations.product_compatibility_good;
  }
}

ProductCompatibilityResult getProductCompatibility(
  ProductPreferences productPreferences,
  Product product,
) {
  double averageAttributeMatch = 0.0;
  int numAttributesComputed = 0;
  if (product.attributeGroups != null) {
    for (final AttributeGroup group in product.attributeGroups!) {
      if (group.attributes != null) {
        for (final Attribute attribute in group.attributes!) {
          final String importanceLevel =
              productPreferences.getImportanceIdForAttributeId(attribute.id!);
          // Check whether any mandatory attribute is incompatible
          if (importanceLevel == PreferenceImportance.ID_MANDATORY &&
              getAttributeEvaluation(attribute) ==
                  AttributeEvaluation.VERY_BAD) {
            return ProductCompatibilityResult(
                0, ProductCompatibility.INCOMPATIBLE);
          }
          if (!attributeImportanceWeight.containsKey(importanceLevel)) {
            // Unknown attribute importance level. (This should ideally never happen).
            // TODO(jasmeetsingh): [importanceLevel] should be an enum not a string.
            continue;
          }
          if (attributeImportanceWeight[importanceLevel] == 0.0) {
            // Skip attributes that are not important
            continue;
          }
          if (!isMatchAvailable(attribute)) {
            continue;
          }
          averageAttributeMatch +=
              attribute.match! * attributeImportanceWeight[importanceLevel]!;
          numAttributesComputed++;
        }
      }
    }
  }
  if (numAttributesComputed == 0) {
    return ProductCompatibilityResult(0, ProductCompatibility.INCOMPATIBLE);
  }
  averageAttributeMatch /= numAttributesComputed;
  if (averageAttributeMatch < _BAD_COMPATIBILITY_UPPER_THRESHOLD) {
    return ProductCompatibilityResult(
        averageAttributeMatch, ProductCompatibility.BAD_COMPATIBILITY);
  }
  if (averageAttributeMatch < _NEUTRAL_COMPATIBILITY_UPPER_THRESHOLD) {
    return ProductCompatibilityResult(
        averageAttributeMatch, ProductCompatibility.NEUTRAL_COMPATIBILITY);
  }
  return ProductCompatibilityResult(
      averageAttributeMatch, ProductCompatibility.GOOD_COMPATIBILITY);
}

String getSubtitle(
  final ProductCompatibilityResult compatibility,
  final AppLocalizations appLocalizations,
) {
  if (compatibility.productCompatibility == ProductCompatibility.UNKNOWN) {
    return appLocalizations.unknown;
  }
  if (compatibility.productCompatibility == ProductCompatibility.INCOMPATIBLE) {
    return appLocalizations.incompatible;
  }
  return appLocalizations
      .pct_match(compatibility.averageAttributeMatch.toStringAsFixed(0));
}
