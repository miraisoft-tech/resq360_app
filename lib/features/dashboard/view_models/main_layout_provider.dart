import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/nav_item.model.dart';
import 'package:resq360/features/bookings/screens/bookings_screen.dart';
import 'package:resq360/features/chat/screens/chat_screen.dart';
import 'package:resq360/features/dashboard/screens/dashboard.dart';
import 'package:resq360/features/services/screens/service_categories_screen.dart';

final dashboardViewModel = ChangeNotifierProvider<DashboardViewModel>(
  DashboardViewModel.new,
);

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this.ref);
  Ref ref;
  //
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  final PageController _pageController = PageController();
  PageController get pageController => _pageController;

  // For tab switching
  int tabIndex = 0;

  void onChanged(int newIndex, {int newTabIndex = 0}) {
    _currentIndex = newIndex;
    tabIndex = newTabIndex;
    notifyListeners();
  }

  void reset() {
    onChanged(0);
  }

  final displayNavItems = [
    NavItem(
      body: const HomeScreen(),
      selectedImgPath: AppAssets.ASSETS_NAVIGATION_HOME_SELECTED_SVG,
      unselectedImgPath: AppAssets.ASSETS_NAVIGATION_HOME_UNSELECTED_SVG,
      title: 'Home',
    ),
    NavItem(
      body: const ServiceCategoryScreen(),
      selectedImgPath: AppAssets.ASSETS_NAVIGATION_SERVICES_SELECTED_SVG,
      unselectedImgPath: AppAssets.ASSETS_NAVIGATION_SERVICES_UNSELECTED_SVG,
      title: 'Services',
    ),

    NavItem(
      body: const BookingsScreen(),
      selectedImgPath: AppAssets.ASSETS_NAVIGATION_BOOKINGS_SELECTED_SVG,
      unselectedImgPath: AppAssets.ASSETS_NAVIGATION_BOOKINGS_UNSELECTED_SVG,
      title: 'Bookings',
    ),
    NavItem(
      body: const ChatScreen(),
      selectedImgPath: AppAssets.ASSETS_NAVIGATION_CHAT_SELECTED_SVG,
      unselectedImgPath: AppAssets.ASSETS_NAVIGATION_CHAT_UNSELECTED_SVG,
      title: 'Chat',
    ),
    NavItem(
      body: const HomeScreen(),
      selectedImgPath: AppAssets.ASSETS_NAVIGATION_SETTINGS_SELECTED_SVG,
      unselectedImgPath: AppAssets.ASSETS_NAVIGATION_SETTINGS_UNSELECTED_SVG,
      title: 'Settings',
    ),
  ];
}
