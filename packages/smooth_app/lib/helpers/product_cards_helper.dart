import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_ui_library/smooth_ui_library.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

String getProductName(Product product, AppLocalizations appLocalizations) =>
    product.productName ?? appLocalizations.unknownProductName;

/// Padding to be used while building the SmoothCard on any Product card.
const EdgeInsets SMOOTH_CARD_PADDING =
    EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0);

/// A SmoothCard on Product cards using default margin and padding.
Widget buildProductSmoothCard({
  Widget? header,
  required Widget body,
  EdgeInsets? padding = EdgeInsets.zero,
  EdgeInsets? margin = const EdgeInsets.symmetric(
    horizontal: SMALL_SPACE,
  ),
}) {
  return SmoothCard(
    margin: margin,
    padding: padding,
    header: header,
    child: body,
  );
}

// used to be in now defunct `AttributeListExpandable`
List<Attribute> getPopulatedAttributes(
  final Product product,
  final List<String> attributeIds,
) {
  final List<Attribute> result = <Attribute>[];
  final Map<String, Attribute> attributes = product.getAttributes(attributeIds);
  for (final String attributeId in attributeIds) {
    Attribute? attribute = attributes[attributeId];
// Some attributes selected in the user preferences might be unavailable for some products
    if (attribute == null) {
      continue;
    } else if (attribute.id == Attribute.ATTRIBUTE_ADDITIVES) {
// TODO(stephanegigandet): remove that cheat when additives are more standard
      final List<String>? additiveNames = product.additives?.names;
      attribute = Attribute(
        id: attribute.id,
        title: attribute.title,
        iconUrl: attribute.iconUrl,
        descriptionShort: additiveNames == null ? '' : additiveNames.join(', '),
      );
    }
    result.add(attribute);
  }
  return result;
}

Widget dummyAddButton(
  final String label, {
  final IconData? iconData,
  final Function()? onPressed,
}) =>
    SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(iconData ?? Icons.add),
        label: Text(label),
        onPressed: onPressed ?? () {},
      ),
    );
