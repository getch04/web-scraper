import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/theme.dart';
import '../models/settings_isar.dart';
import '../providers/settings_provider.dart';

class NotificationSettingsPage extends HookConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.primaryGradient.createShader(bounds),
          child: const Text(
            'Notification Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.surfaceColor.withOpacity(0.9),
                AppTheme.surfaceColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: settings.when(
        data: (settings) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.surfaceColor,
                  AppTheme.surfaceColor.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient.scale(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.textLight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppTheme.textLight,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Notification Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.surfaceColor.withOpacity(0.9),
                          AppTheme.surfaceColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                      ),
                    ),
                    child: SwitchListTile.adaptive(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        'Enable Notifications',
                        style: TextStyle(
                          color: AppTheme.textLight.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      value: settings.notificationsEnabled,
                      onChanged: (value) => ref
                          .read(settingsProvider.notifier)
                          .toggleNotifications(value),
                      activeColor: AppTheme.primaryBlue,
                      inactiveThumbColor: AppTheme.textLight.withOpacity(0.3),
                      inactiveTrackColor: AppTheme.textLight.withOpacity(0.1),
                    ),
                  ),
                  if (settings.notificationsEnabled) ...[
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.surfaceColor.withOpacity(0.9),
                            AppTheme.surfaceColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue:
                                    settings.frequencyValue.toString(),
                                keyboardType: TextInputType.number,
                                style:
                                    const TextStyle(color: AppTheme.textLight),
                                decoration: const InputDecoration(
                                  labelText: 'Check Every',
                                  labelStyle:
                                      TextStyle(color: AppTheme.textLight),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppTheme.primaryBlue, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppTheme.primaryBlue, width: 2),
                                  ),
                                ),
                                onChanged: (value) {
                                  final intValue = int.tryParse(value);
                                  if (intValue != null && intValue > 0) {
                                    ref
                                        .read(settingsProvider.notifier)
                                        .updateFrequencyValue(intValue);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<TimeUnit>(
                                decoration: const InputDecoration(
                                  labelText: 'Unit',
                                  labelStyle:
                                      TextStyle(color: AppTheme.textLight),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppTheme.primaryBlue, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppTheme.primaryBlue, width: 2),
                                  ),
                                ),
                                dropdownColor: AppTheme.surfaceColor,
                                value: settings.frequencyUnit,
                                items: TimeUnit.values
                                    .map((unit) => DropdownMenuItem(
                                          value: unit,
                                          child: Text(
                                            unit.displayName,
                                            style: const TextStyle(
                                              color: AppTheme.textLight,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    ref
                                        .read(settingsProvider.notifier)
                                        .updateFrequencyUnit(value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        loading: () => Center(
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const CircularProgressIndicator(
              color: AppTheme.textLight,
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: const TextStyle(
                  color: AppTheme.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
