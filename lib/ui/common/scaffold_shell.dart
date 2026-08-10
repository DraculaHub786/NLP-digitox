import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/app_constants.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/ui/common/glass_nav_bar.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/treated_background_image.dart';
import 'package:nlp_digitox/ui/controllers/tab_controller_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

@immutable
class NavbarItem {
  final IconData icon;
  final IconData filledIcon;
  final String? titleText;
  final Widget Function(double collapsingPercentage)? titleBuilder;
  final Widget? fab;
  final Widget sliverBody;
  final Widget? appBarBg;
  final List<Widget>? actions;

  const NavbarItem({
    required this.icon,
    required this.filledIcon,
    required this.sliverBody,
    this.titleText,
    this.titleBuilder,
    this.fab,
    this.appBarBg,
    this.actions,
  }) : assert(titleText != null || titleBuilder != null,
            "Title and TitleBuilder both can't be null, Specify at least one of them");
}

/// Global Scaffold navigation bar and tab bar used throughout the app for consistent ui/ux
class ScaffoldShell extends StatefulWidget {
  const ScaffoldShell({
    super.key,
    this.initialTab,
    this.canGoBack = true,
    this.appBarExpandedHeight = 200,
    this.bodyPadding = const EdgeInsets.symmetric(horizontal: 12),
    required this.items,
  });

  final int? initialTab;
  final bool canGoBack;
  final double appBarExpandedHeight;
  final EdgeInsets bodyPadding;
  final List<NavbarItem> items;

  @override
  State<ScaffoldShell> createState() => _ScaffoldShellState();
}

class _ScaffoldShellState extends State<ScaffoldShell>
    with SingleTickerProviderStateMixin {
  final _isBottomNavVisible = ValueNotifier<bool>(true);
  final _appBarScrollOffSet = ValueNotifier<double>(0);
  late final TabController _tabController;

  late final bool _haveMultiTabs = widget.items.length > 1;
  int _selectedTabIndex = 0;
  double _wholeScreenScrollOffSet = 0;

  @override
  void initState() {
    super.initState();

    /// Resolve initial tab index
    _selectedTabIndex = (widget.initialTab ?? 0) % widget.items.length;

    /// Handle tab controller
    _tabController = TabController(
      length: widget.items.length,
      initialIndex: _selectedTabIndex,
      vsync: this,
    );

    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _selectedTabIndex = _tabController.index;
          _isBottomNavVisible.value = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          widget.items[_selectedTabIndex].fab ?? const SizedBox.shrink(),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: _haveMultiTabs ? _bottomNavBar() : null,
      // The blurred botanical photograph sits behind every tab so glass
      // cards read against real texture (matches the Leafora reference).
      body: Stack(
        children: [
          const TreatedBackgroundImage(child: SizedBox.expand()),
          TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: List.generate(
              widget.items.length,
              (i) => NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    /// Add app bar offset if current scroll offset is from body
                    final currentOffset = notification.metrics.pixels +
                        (notification.depth == 1
                            ? _appBarScrollOffSet.value
                            : 0);

                    /// Show/Hide bottom bar
                    if (currentOffset >= widget.appBarExpandedHeight &&
                        (currentOffset >= _wholeScreenScrollOffSet + 1)) {
                      _isBottomNavVisible.value = false;
                    } else if (currentOffset <=
                        _wholeScreenScrollOffSet - 1) {
                      _isBottomNavVisible.value = true;
                    }

                    /// Cache offset for whole screen
                    _wholeScreenScrollOffSet = currentOffset == 0
                        ? _wholeScreenScrollOffSet
                        : currentOffset;

                    /// Cache offset for just the app bar only
                    if (notification.depth == 0) {
                      _appBarScrollOffSet.value = currentOffset == 0
                          ? _appBarScrollOffSet.value
                          : currentOffset;
                    }
                  }
                  return false;
                },
                child: NestedScrollView(
                  physics: const BouncingScrollPhysics(),
                  headerSliverBuilder: (_, innerBoxIsScrolled) =>
                      [_sliverAppBar(i, innerBoxIsScrolled)],
                  body: TabControllerProvider(
                    controller: _tabController,
                    child: Padding(
                      padding: widget.bodyPadding,
                      child: widget.items[i].sliverBody,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliverAppBar(
    int tabIndex,
    bool innerBoxIsScrolled,
  ) {
    final navItem = widget.items[tabIndex];
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AnimatedBuilder(
      animation: _appBarScrollOffSet,
      builder: (context, constraints) {
        // Calculate the scroll percentage
        final percentage = (_appBarScrollOffSet.value /
                (widget.appBarExpandedHeight - kToolbarHeight))
            .clamp(0.0, 1.0);

        // Interpolate the color for the AppBar
        final appBarColor = Color.lerp(
          Theme.of(context).colorScheme.surface,
          Theme.of(context).colorScheme.secondaryContainer,
          percentage,
        );

        // Interpolate left padding for the AppBar's title
        final leftPadding = widget.canGoBack ? 44 * percentage : 0.0;

        return SliverAppBar(
          expandedHeight: widget.appBarExpandedHeight,
          collapsedHeight: kToolbarHeight,
          pinned: !_haveMultiTabs,
          stretch: true,
          primary: true,
          backgroundColor: _haveMultiTabs
              ? Theme.of(context).colorScheme.surface
              : appBarColor,
          surfaceTintColor:
              _haveMultiTabs ? Theme.of(context).colorScheme.surfaceTint : null,
          automaticallyImplyLeading: false,
          actions: [
            ...navItem.actions ?? [],
            widget.bodyPadding.right.hBox,
          ],
          leading: widget.canGoBack
              ? IconButton(
                  icon: Icon(
                    FluentIcons.chevron_left_24_filled,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  onPressed: () => context.popOrPushReplace(AppRoutes.homePath),
                )
              : null,
          flexibleSpace: FlexibleSpaceBar(
            expandedTitleScale: 1.75,
            background: innerBoxIsScrolled ? null : navItem.appBarBg,
            collapseMode: CollapseMode.parallax,
            titlePadding: EdgeInsets.only(
              bottom: 13,
              left: isRtl ? 0 : widget.bodyPadding.left + leftPadding,
              right: isRtl ? widget.bodyPadding.right + leftPadding : 0,
            ),
            title: navItem.titleBuilder?.call(1 - percentage) ??
                AppBarTitle(titleText: navItem.titleText!),
          ),
        );
      },
    );
  }

  Widget _bottomNavBar() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isBottomNavVisible,
      builder: (context, isVisible, child) => GlassNavBar(
        selectedIndex: _selectedTabIndex,
        isVisible: isVisible,
        onDestinationSelected: (index) => _tabController.animateTo(
          index,
          duration: AppConstants.defaultAnimDuration,
          curve: AppConstants.defaultCurve,
        ),
        items: [
          for (final item in widget.items)
            PillNavItem(
              icon: item.icon,
              filledIcon: item.filledIcon,
              label: item.titleText ?? "",
            ),
        ],
      ),
    );
  }
}

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({
    super.key,
    required this.titleText,
  });

  final String titleText;

  @override
  Widget build(BuildContext context) {
    return Skeleton.leaf(
      child: StyledText(
        titleText.isEmpty ? "Title" : titleText,
        fontSize: 24,
        maxLines: 2,
        fontWeight: FontWeight.w600,
        isHeadline: true,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
