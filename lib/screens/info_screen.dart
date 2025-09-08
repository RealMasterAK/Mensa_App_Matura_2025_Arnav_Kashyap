import 'package:flutter/cupertino.dart';
import '../utils/app_localizations.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const mensaName = 'Mensa KSWE';
    const mensaLocation = 'Löwenscheune, Bern';
    const openingWeekdays = '11:30 - 14:00';
    const openingSaturday = 'Geschlossen';
    const openingSunday = 'Geschlossen';

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          AppLocalizations.of(context).aboutMensa,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeBlue
                            .withValues(red: 0, green: 0, blue: 0, alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.house,
                        size: 40,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      mensaName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      mensaLocation,
                      style: TextStyle(
                        fontSize: 17,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Opening Hours Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).openingHours,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildOpeningHoursRow(
                              AppLocalizations.of(context).mondayFriday,
                              openingWeekdays),
                          _buildDivider(),
                          _buildOpeningHoursRow(
                              AppLocalizations.of(context).saturday,
                              openingSaturday),
                          _buildDivider(),
                          _buildOpeningHoursRow(
                              AppLocalizations.of(context).sunday,
                              openingSunday),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Features Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).appFeatures,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      icon: CupertinoIcons.square,
                      title: AppLocalizations.of(context).dailyMenusFeature,
                      description:
                          AppLocalizations.of(context).dailyMenusDescription,
                      color: CupertinoColors.transparent,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      icon: CupertinoIcons.heart,
                      title: AppLocalizations.of(context).vegetarianOptions,
                      description: AppLocalizations.of(context)
                          .vegetarianOptionsDescription,
                      color: CupertinoColors.systemGreen,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      icon: CupertinoIcons.exclamationmark_triangle,
                      title: AppLocalizations.of(context).allergenInfo,
                      description:
                          AppLocalizations.of(context).allergenInfoDescription,
                      color: CupertinoColors.systemOrange,
                    ),
                  ],
                ),
              ),
            ),

            // App Info Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).appInformation,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: const [
                          _StaticInfoRow(label: 'Version', value: '1.0.0'),
                          _StaticDivider(),
                          _StaticInfoRow(
                              label: 'Entwickler', value: 'Mensa KSWE'),
                          _StaticDivider(),
                          _StaticInfoRow(label: 'Plattform', value: 'Flutter'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contact Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kontakt',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildContactRow(
                            icon: CupertinoIcons.mail,
                            title: 'E-Mail',
                            subtitle: 'info@mensa-kswe.ch',
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildContactRow(
                            icon: CupertinoIcons.globe,
                            title: 'Website',
                            subtitle: 'www.mensa-kswe.ch',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpeningHoursRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 17,
              color: CupertinoColors.label,
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: hours == 'Geschlossen'
                  ? CupertinoColors.systemRed
                  : CupertinoColors.activeBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(red: 0, green: 0, blue: 0, alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.all(16),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: CupertinoColors.activeBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            color: CupertinoColors.systemGrey,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.5,
      color: CupertinoColors.separator,
      margin: const EdgeInsets.only(left: 16),
    );
  }
}

class _StaticInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _StaticInfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 17, color: CupertinoColors.label),
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.activeBlue),
          ),
        ],
      ),
    );
  }
}

class _StaticDivider extends StatelessWidget {
  const _StaticDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      color: CupertinoColors.separator,
      margin: const EdgeInsets.only(left: 16),
    );
  }
}
