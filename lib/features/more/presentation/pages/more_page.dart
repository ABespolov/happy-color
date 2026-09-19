import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/core/widgets/page_header.dart';
import 'package:happy_color/core/widgets/sheet_sliver.dart';
import 'package:happy_color/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  static const supportEmail = 'abespolov@protonmail.com';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: PageHeader.background,
      child: CustomScrollView(
        slivers: [
          SheetSliver(
            topHeight: PageHeader.heightOf(context),
            top: PageHeader(title: l10n.moreTab),
            headerHeight: 8,
            header: const SizedBox.shrink(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _ContactCard(
                    title: l10n.contactUs,
                    email: supportEmail,
                    copiedMessage: l10n.emailCopied,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: _AppVersion(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.title,
    required this.email,
    required this.copiedMessage,
  });

  final String title;
  final String email;
  final String copiedMessage;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _writeToUs(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.mail_outline, color: AppColors.ink),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.ink),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the mail app, and falls back to the clipboard where there is none.
  Future<void> _writeToUs(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await launchUrl(Uri(scheme: 'mailto', path: email));
    if (opened) return;
    await Clipboard.setData(ClipboardData(text: email));
    messenger.showSnackBar(SnackBar(content: Text(copiedMessage)));
  }
}

/// Version and build number of the installed app.
class _AppVersion extends StatelessWidget {
  const _AppVersion();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) => Center(
        child: Text(switch (snapshot.data) {
          final info? => l10n.appVersion(info.version, info.buildNumber),
          null => '',
        }, style: const TextStyle(fontSize: 14, color: AppColors.ink)),
      ),
    );
  }
}
