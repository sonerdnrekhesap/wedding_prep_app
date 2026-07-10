import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/home_page.dart';
import 'pages/list_modules_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/settings_page.dart';
import 'pages/wrapped_summary_page.dart';
import 'pages/budget_page.dart';
import 'services/ad_service.dart';
import 'services/app_controller.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeddingPrepApp());
}

class WeddingPrepApp extends StatefulWidget {
  const WeddingPrepApp({super.key});

  @override
  State<WeddingPrepApp> createState() => _WeddingPrepAppState();
}

class _WeddingPrepAppState extends State<WeddingPrepApp> {
  late final AppController controller;

  @override
  void initState() {
    super.initState();
    controller = AppController(
      storage: StorageService(),
      ads: AdService(),
    )..load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('tr', 'TR'),
        supportedLocales: const [
          Locale('tr', 'TR'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        title: 'Hazırlık Takibi',
        theme: AppTheme.light(),
        home: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            if (controller.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (controller.recoveredFromStartupError) {
              return _StartupRecoveryPage(controller: controller);
            }
            if (!controller.settings.hasCompletedOnboarding) {
              return const OnboardingPage();
            }
            return const MainShell();
          },
        ),
      ),
    );
  }
}

class _StartupRecoveryPage extends StatelessWidget {
  const _StartupRecoveryPage({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 42),
                const SizedBox(height: 12),
                Text(
                  'Veriler kontrol ediliyor',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.startupMessage ??
                      'Uygulama güvenli şekilde açıldı.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: controller.retryStartup,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar dene'),
                ),
                TextButton(
                  onPressed: controller.continueAfterStartupRecovery,
                  child: const Text('Güvenli modda devam et'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope bulunamadı');
    return scope!.notifier!;
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      HomePage(),
      ListModulesPage(),
      BudgetPage(),
      WrappedSummaryPage(),
      SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (next) => setState(() => index = next),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Listeler',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Bütçe',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Özet',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}
