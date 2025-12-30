import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/landing/about_screen.dart';
import '../screens/landing/news_screen.dart';
import '../screens/landing/join_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/member_screen.dart';
import '../screens/settings/account_settings_screen.dart';
import '../screens/polls/add_poll_screen.dart';
import '../screens/polls/answer_poll_screen.dart';
import '../screens/polls/view_poll_screen.dart';
import '../screens/polls/own_polls_screen.dart';
import '../screens/polls/participated_polls_screen.dart';
import '../screens/circles/add_circle_screen.dart';
import '../screens/circles/answer_circle_screen.dart';
import '../screens/circles/view_circle_screen.dart';
import '../screens/circles/own_circles_screen.dart';
import '../screens/circles/participated_circles_screen.dart';
import '../screens/social/follow_screen.dart';
import '../screens/coming_soon/projects_screen.dart';
import '../screens/coming_soon/messages_screen.dart';

/// Route names for navigation.
class Routes {
  // Public routes
  static const String landing = '/';
  static const String about = '/about';
  static const String news = '/news';
  static const String join = '/join';
  static const String login = '/login';
  static const String forgotPassword = '/forgot';

  // Protected routes
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';

  // Polls
  static const String addPoll = '/polls/add';
  static const String viewPoll = '/polls/:id';
  static const String answerPoll = '/polls/:id/answer';
  static const String ownPolls = '/polls/mine';
  static const String participatedPolls = '/polls/participated';

  // Circles
  static const String addCircle = '/circles/add';
  static const String viewCircle = '/circles/:id';
  static const String answerCircle = '/circles/:id/join';
  static const String ownCircles = '/circles/mine';
  static const String participatedCircles = '/circles/participated';

  // Social
  static const String follow = '/follow';
  static const String member = '/user/:uid';

  // Coming Soon
  static const String projects = '/projects';
  static const String messages = '/messages';
}

/// App router configuration using GoRouter.
class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: Routes.landing,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isOnPublicRoute = _publicRoutes.contains(state.matchedLocation);
        final isOnAuthRoute = state.matchedLocation == Routes.login ||
            state.matchedLocation == Routes.forgotPassword;

        // Redirect logged-in users away from auth routes
        if (isLoggedIn && isOnAuthRoute) {
          return Routes.home;
        }

        // Redirect non-logged-in users to login for protected routes
        if (!isLoggedIn && !isOnPublicRoute && !isOnAuthRoute) {
          return Routes.login;
        }

        return null;
      },
      routes: [
        // Public routes
        GoRoute(
          path: Routes.landing,
          builder: (context, state) => const LandingScreen(),
        ),
        GoRoute(
          path: Routes.about,
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: Routes.news,
          builder: (context, state) => const NewsScreen(),
        ),
        GoRoute(
          path: Routes.join,
          builder: (context, state) => const JoinScreen(),
        ),
        GoRoute(
          path: Routes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: Routes.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // Protected routes
        GoRoute(
          path: Routes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: Routes.home,
          builder: (context, state) {
            final tabIndex = state.uri.queryParameters['tab'];
            return HomeScreen(
              initialTabIndex: tabIndex != null ? int.tryParse(tabIndex) ?? 0 : 0,
            );
          },
        ),
        GoRoute(
          path: Routes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: Routes.editProfile,
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: Routes.settings,
          builder: (context, state) => const AccountSettingsScreen(),
        ),

        // Polls routes
        GoRoute(
          path: Routes.addPoll,
          builder: (context, state) => const AddPollScreen(),
        ),
        GoRoute(
          path: '/polls/:id',
          builder: (context, state) => ViewPollScreen(
            pollId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/polls/:id/answer',
          builder: (context, state) => AnswerPollScreen(
            pollId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: Routes.ownPolls,
          builder: (context, state) => const OwnPollsScreen(),
        ),
        GoRoute(
          path: Routes.participatedPolls,
          builder: (context, state) => const ParticipatedPollsScreen(),
        ),

        // Circles routes
        GoRoute(
          path: Routes.addCircle,
          builder: (context, state) => const AddCircleScreen(),
        ),
        GoRoute(
          path: '/circles/:id',
          builder: (context, state) => ViewCircleScreen(
            circleId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/circles/:id/join',
          builder: (context, state) => AnswerCircleScreen(
            circleId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: Routes.ownCircles,
          builder: (context, state) => const OwnCirclesScreen(),
        ),
        GoRoute(
          path: Routes.participatedCircles,
          builder: (context, state) => const ParticipatedCirclesScreen(),
        ),

        // Social routes
        GoRoute(
          path: Routes.follow,
          builder: (context, state) => const FollowScreen(),
        ),
        GoRoute(
          path: '/user/:uid',
          builder: (context, state) => MemberScreen(
            userId: state.pathParameters['uid']!,
          ),
        ),

        // Coming Soon routes
        GoRoute(
          path: Routes.projects,
          builder: (context, state) => const ProjectsScreen(),
        ),
        GoRoute(
          path: Routes.messages,
          builder: (context, state) => const MessagesScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(state.matchedLocation),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(Routes.landing),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const Set<String> _publicRoutes = {
    Routes.landing,
    Routes.about,
    Routes.news,
    Routes.join,
    Routes.login,
    Routes.forgotPassword,
  };
}
