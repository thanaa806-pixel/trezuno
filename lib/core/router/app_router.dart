import 'package:go_router/go_router.dart';

import 'package:trezuno/features/onboarding/presentation/onboarding_screen.dart';
import 'package:trezuno/features/dashboard/presentation/dashboard_screen.dart';
import 'package:trezuno/features/products/presentation/product_list/product_list_screen.dart';
import 'package:trezuno/features/products/presentation/product_details/product_details_screen.dart';
import 'package:trezuno/features/products/presentation/add_product/add_product_screen.dart';
import 'package:trezuno/features/warranty_calendar/presentation/warranty_calendar_screen.dart';
import 'package:trezuno/features/notifications/presentation/notifications_screen.dart';
import 'package:trezuno/features/settings/presentation/settings_screen.dart';
import 'package:trezuno/features/privacy_policy/presentation/privacy_policy_screen.dart';

/// Application routes for Trezuno.
final GoRouter appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      name: OnboardingScreen.routeName,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      name: DashboardScreen.routeName,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/products',
      name: ProductsScreen.routeName,
      builder: (context, state) => const ProductsScreen(),
    ),
    GoRoute(
      path: '/add-product',
      name: AddProductScreen.routeName,
      builder: (context, state) => const AddProductScreen(),
    ),
    GoRoute(
      path: '/product-details/:productId',
      name: ProductDetailsScreen.routeName,
      builder: (context, state) {
        final productId = state.pathParameters['productId'] ?? '';
        return ProductDetailsScreen(productId: productId);
      },
    ),
    GoRoute(
      path: '/warranty-calendar',
      name: WarrantyCalendarScreen.routeName,
      builder: (context, state) => const WarrantyCalendarScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: NotificationsScreen.routeName,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: SettingsScreen.routeName,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      name: PrivacyPolicyScreen.routeName,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
  ],
);
