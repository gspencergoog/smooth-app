import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

/// Next button showed at the bottom of the onboarding flow.
class NextButton extends StatelessWidget {
  const NextButton(this.currentPage);

  final OnboardingPage currentPage;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    // Side padding is 8% of total width.
    final double sidePadding = screenSize.width * .08;
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      padding: EdgeInsets.symmetric(
        vertical: VERY_LARGE_SPACE,
        horizontal: sidePadding,
      ),
      child: Row(children: <Widget>[
        Expanded(
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: SmoothTheme.getColor(
                Theme.of(context).colorScheme,
                SmoothTheme.MATERIAL_COLORS[SmoothTheme.COLOR_TAG_BLUE]!,
                ColorDestination.BUTTON_BACKGROUND,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SMALL_SPACE),
              ),
              primary: Colors.white,
            ),
            onPressed: () {
              OnboardingFlowNavigator(userPreferences).navigateToPage(
                  context, OnboardingFlowNavigator.getNextPage(currentPage));
            },
            child: Text(
              appLocalizations.next_label,
              style: Theme.of(context)
                  .textTheme
                  .headline3!
                  .apply(color: Colors.white),
            ),
          ),
        ),
      ]),
    );
  }
}
