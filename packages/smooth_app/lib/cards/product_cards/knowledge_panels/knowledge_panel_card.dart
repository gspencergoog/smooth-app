import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_element_card.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_summary_card.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

class KnowledgePanelCard extends StatelessWidget {
  const KnowledgePanelCard({
    required this.panel,
    required this.allPanels,
  });

  final KnowledgePanel panel;
  final KnowledgePanels allPanels;

  @override
  Widget build(BuildContext context) {
    // If [expanded] = true, render all panel elements (including summary), otherwise just renders panel summary.
    if (panel.expanded ?? false) {
      final List<Widget> elementWidgets = <Widget>[];
      elementWidgets.add(KnowledgePanelSummaryCard(panel));
      for (final KnowledgePanelElement element in panel.elements!) {
        elementWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: VERY_SMALL_SPACE),
            child: KnowledgePanelElementCard(
              knowledgePanelElement: element,
              allPanels: allPanels,
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: elementWidgets,
      );
    }
    return KnowledgePanelSummaryCard(panel);
  }
}
