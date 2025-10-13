import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/nav_item.model.dart';
import 'package:resq360/features/customer/bookings/screens/bookings_screen.dart';
import 'package:resq360/features/customer/chat/screens/chat_screen.dart';
import 'package:resq360/features/customer/dashboard/screens/dashboard.dart';
import 'package:resq360/features/customer/services/screens/service_categories_screen.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/provider/bookings/screens/bookings_screen.dart';
import 'package:resq360/features/provider/chat/screens/provider_chat_screen.dart';
import 'package:resq360/features/provider/dashboard/screens/provider_dashboard.dart';
import 'package:resq360/features/settings/screens/settings_screen.dart';

final dashboardViewModel = ChangeNotifierProvider<DashboardViewModel>(
  DashboardViewModel.new,
);

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this.ref);
  Ref ref;
  //

  UserType userType = UserType.customer;

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

  final customerDisplayNavItems = [
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
      body: const SettingsScreen(),
      selectedImgPath: AppAssets.ASSETS_NAVIGATION_SETTINGS_SELECTED_SVG,
      unselectedImgPath: AppAssets.ASSETS_NAVIGATION_SETTINGS_UNSELECTED_SVG,
      title: 'Settings',
    ),
  ];

  final providerDisplayNavItems = [
    NavItem(
      body: const ProviderHomeScreen(),
      selectedImgPath: AppAssets.ASSETS_NAVIGATION_HOME_SELECTED_SVG,
      unselectedImgPath: AppAssets.ASSETS_NAVIGATION_HOME_UNSELECTED_SVG,
      title: 'Home',
    ),
    NavItem(
      body: const ProviderBookingsScreen(),
      selectedImgPath: AppAssets.ASSETS_NAVIGATION_BOOKINGS_SELECTED_SVG,
      unselectedImgPath: AppAssets.ASSETS_NAVIGATION_BOOKINGS_UNSELECTED_SVG,
      title: 'Bookings',
    ),
    NavItem(
      body: const ProviderChatScreen(),
      selectedImgPath: AppAssets.ASSETS_NAVIGATION_CHAT_SELECTED_SVG,
      unselectedImgPath: AppAssets.ASSETS_NAVIGATION_CHAT_UNSELECTED_SVG,
      title: 'Chat',
    ),
    NavItem(
      body: const SettingsScreen(),
      selectedImgPath: AppAssets.ASSETS_NAVIGATION_SETTINGS_SELECTED_SVG,
      unselectedImgPath: AppAssets.ASSETS_NAVIGATION_SETTINGS_UNSELECTED_SVG,
      title: 'Settings',
    ),
  ];
}
