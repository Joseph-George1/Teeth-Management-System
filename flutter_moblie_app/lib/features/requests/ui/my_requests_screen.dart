import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoutha_mobile_app/core/di/dependency_injection.dart';
import 'package:thoutha_mobile_app/core/theming/colors.dart';
import 'package:thoutha_mobile_app/features/requests/data/logic/my_requests_cubit.dart';
import 'package:thoutha_mobile_app/features/requests/data/models/case_request_model.dart';
import 'package:thoutha_mobile_app/features/requests/data/logic/my_requests_state.dart';
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

import 'package:thoutha_mobile_app/features/requests/ui/edit_request_screen.dart';
import 'package:thoutha_mobile_app/features/doctor/drawer_doctor/doctor_drawer_screen.dart';
import 'package:thoutha_mobile_app/core/routing/routes.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:showcaseview/showcaseview.dart';
import 'package:thoutha_mobile_app/tour/tour_config.dart';
import 'package:thoutha_mobile_app/tour/tour_service.dart';
import 'package:thoutha_mobile_app/tour/tour_widgets.dart';

import 'package:thoutha_mobile_app/core/widgets/app_shimmer.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MyRequestsCubit>()..loadRequests(),
      child: MyRequestsView(),
    );
  }
}

class MyRequestsView extends StatefulWidget {
  const MyRequestsView({super.key});

  @override
  State<MyRequestsView> createState() => _MyRequestsViewState();
}

class _MyRequestsViewState extends State<MyRequestsView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isTourStarted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pushReplacementNamed(Routes.doctorHomeScreen);
      },
      child: ShowCaseWidget(
        onComplete: (index, key) {
          TourService.onDismiss(key)();
        },
        builder: (context) {
          if (!_isTourStarted) {
            _isTourStarted = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) TourService.startTourForScreen(context, 'my_requests');
            });
          }
          return Scaffold(
            key: _scaffoldKey,
            drawer: const DoctorDrawer(selectedIndex: 6),
            backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          toolbarHeight: 70,
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, size: 24),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          titleSpacing: 0,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                L10nDoctor.myRequests.tr(),
                style: textTheme.titleLarge?.copyWith(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8),
              Image.asset(
                'assets/images/splash-logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        body: BlocConsumer<MyRequestsCubit, MyRequestsState>(
          listenWhen: (previous, current) =>
              current is MyRequestsDeleteSuccess ||
              current is MyRequestsDeleteError ||
              current is MyRequestsEmpty, // أضفنا الحالة الفارغة أيضاً
          listener: (context, state) {
            // لا نغلق الحوار إلا إذا كانت الحالة ناتجة عن عملية حذف (نجاح أو فشل)
            // أو إذا تم حذف آخر عنصر وتحولت الحالة إلى فارغة
            if (state is MyRequestsDeleteSuccess || state is MyRequestsDeleteError) {
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            }

            if (state is MyRequestsDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(L10nHomeScreen.theRequestHasBeen.tr(),
                      style: TextStyle(fontFamily: 'Cairo')),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is MyRequestsDeleteError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message,
                      style: TextStyle(fontFamily: 'Cairo')),
                  backgroundColor: Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
      );
    },
    ),
    );
  }

  Widget _buildBody(BuildContext context, MyRequestsState state) {
    if (state is MyRequestsLoading) {
      return _buildShimmerLoading(context);
    }

    if (state is MyRequestsError) {
      return _buildErrorState(context, state.message);
    }

    if (state is MyRequestsEmpty) {
      return _buildEmptyState(context);
    }

    List<CaseRequestModel>? requests;
    if (state is MyRequestsSuccess) requests = state.requests;
    if (state is MyRequestsDeleteSuccess) requests = state.requests;
    if (state is MyRequestsDeleteError) requests = state.requests;

    if (requests == null || requests.isEmpty) {
      return _buildEmptyState(context);
    }

    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Showcase.withWidget(
                height: 150,
                width: 280,
              key: TourConfig.myRequestsTitleKey,
              container: CustomTourTooltip(
                title: 'طلباتي',
                description: 'هنا تجد جميع طلبات الحالات التي قمت بنشرها',
                onNext: () => ShowCaseWidget.of(context).next(),
                onSkipTap: () {
                  if (context.mounted) ShowCaseWidget.of(context).dismiss();
                },
              ),
              child: Text(
                L10nDoctor.myRequests.tr(),
                textAlign: TextAlign.start,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  height: 1.5,
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          RefreshIndicator(
            onRefresh: () => context.read<MyRequestsCubit>().loadRequests(),
            color: ColorsManager.mainBlue,
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final card = _RequestCard(request: requests![index], isFirst: index == 0);
                if (index == 0) {
                  return Showcase.withWidget(
                height: 150,
                width: 280,
                    key: TourConfig.myRequestsCardKey,
                    container: CustomTourTooltip(
                      title: 'بيانات الطلب',
                      description: 'تظهر هنا تفاصيل الحالة والجامعة والموعد المحدد',
                      onNext: () => ShowCaseWidget.of(context).next(),
                      onSkipTap: () {
                        if (context.mounted) ShowCaseWidget.of(context).dismiss();
                      },
                    ),
                    child: card,
                  );
                }
                return card;
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            L10nDoctor.myRequests.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          Text(
            L10nRequests.thereAreNoRequests.tr(),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 12),
          Text(
            L10nRequests.allMedicalOrdersYou.tr(),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          Text(
            L10nRequests.youCanManageYour.tr(),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          _buildInstructionRow(
            icon: Icons.edit_note_rounded,
            iconColor: Colors.blue,
            text: L10nRequests.clickEditToUpdate.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 10),
          _buildInstructionRow(
            icon: Icons.delete_sweep_rounded,
            iconColor: Colors.red.shade400,
            text: L10nRequests.clickDeleteOrderTo.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 24),
          Text(
            L10nRequests.importantNote.tr(),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          _buildInstructionRow(
            icon: Icons.info_outline_rounded,
            iconColor: Colors.orange,
            text: L10nRequests.ifAPatientBooks.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 10),
          _buildInstructionRow(
            icon: Icons.link_off_rounded,
            iconColor: Colors.red,
            text: L10nRequests.whenYouDeleteAn.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: () => context.read<MyRequestsCubit>().loadRequests(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.mainBlue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                L10nRequests.refreshThePage.tr(),
                style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow({
    required IconData icon,
    required Color iconColor,
    required String text,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              height: 1.6,
              color: isDark ? Colors.white60 : Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 150, height: 30),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) => _buildRequestShimmer(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestShimmer(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 60, color: Colors.red.shade400),
            SizedBox(height: 16),
            Text(
              L10nRequests.somethingWentWrong.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<MyRequestsCubit>().loadRequests(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.mainBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(L10nDoctor.retry.tr(),
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final CaseRequestModel request;
  final bool isFirst;
  const _RequestCard({required this.request, this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Upper section with colored background and doctor info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.2) : null,
              gradient: LinearGradient(
                colors: [
                  ColorsManager.layerBlur2.withValues(alpha: isDark ? 0.15 : 0.3),
                  ColorsManager.layerBlur1.withValues(alpha: isDark ? 0.1 : 0.2),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Name and Category (Right side)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            request.doctorFullName,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF021433),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 6, color: isDark ? Colors.blueAccent : ColorsManager.mainBlue),
                            SizedBox(width: 4),
                            Text(
                              request.categoryName,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: isDark ? Colors.blueAccent : ColorsManager.mainBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Request ID Badge (Left side)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#${request.id}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : ColorsManager.mainBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Info Grid (2x2)
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        label: L10nDoctor.theUniversity.tr(),
                        value: request.doctorUniversityName,
                        icon: Icons.home_work_outlined,
                        isDark: isDark,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoBox(
                        label: L10nHomeScreen.governorate.tr(),
                        value: request.doctorCityName,
                        icon: Icons.location_on,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        label: L10nHomeScreen.today.tr(),
                        value: request.formattedDate,
                        icon: Icons.calendar_today,
                        isDark: isDark,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoBox(
                        label: L10nHomeScreen.theHour.tr(),
                        value: request.formattedTime,
                        icon: Icons.access_time_filled,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                // Description Box
                if (request.description.isNotEmpty && request.description != 'No details') ...[
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : ColorsManager.moreLighterGray,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              L10nHomeScreen.caseDetails.tr(),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.blue[300] : Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          request.description,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            height: 1.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 20),

                // Buttons Section
                Row(
                  children: [
                    Expanded(
                      child: isFirst ? Showcase.withWidget(
                height: 150,
                width: 280,
                        key: TourConfig.myRequestsEditKey,
                        container: CustomTourTooltip(
                          title: 'تعديل الطلب',
                          description: 'يمكنك تعديل تفاصيل الحالة أو الموعد في أي وقت',
                          onNext: () => ShowCaseWidget.of(context).next(),
                          onSkipTap: () {
                            if (context.mounted) ShowCaseWidget.of(context).dismiss();
                          },
                        ),
                        child: OutlinedButton.icon(
                          onPressed: () => _navigateToEdit(context, request),
                          icon: Icon(Icons.edit_note_rounded, size: 20),
                          label: Text(L10nRequests.modifyTheRequest.tr(),
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue.shade700,
                            side: BorderSide(color: Colors.blue.shade200),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ) : OutlinedButton.icon(
                        onPressed: () => _navigateToEdit(context, request),
                        icon: Icon(Icons.edit_note_rounded, size: 20),
                        label: Text(L10nRequests.modifyTheRequest.tr(),
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue.shade700,
                          side: BorderSide(color: Colors.blue.shade200),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: isFirst ? Showcase.withWidget(
                height: 150,
                width: 280,
                        key: TourConfig.myRequestsDeleteKey,
                        container: CustomTourTooltip(
                          title: 'حذف الطلب',
                          description: 'إذا لم تعد الحالة متاحة، يمكنك حذفها من هنا',
                          onNext: () => ShowCaseWidget.of(context).next(),
                          onSkipTap: () {
                            if (context.mounted) ShowCaseWidget.of(context).dismiss();
                          },
                          isLast: true,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _showDeleteDialog(context, request),
                          icon: Icon(Icons.delete_sweep_rounded,
                              size: 20, color: Colors.white),
                          label: Text(L10nHomeScreen.deleteTheRequest.tr(),
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ) : ElevatedButton.icon(
                        onPressed: () => _showDeleteDialog(context, request),
                        icon: Icon(Icons.delete_sweep_rounded,
                            size: 20, color: Colors.white),
                        label: Text(L10nHomeScreen.deleteTheRequest.tr(),
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : ColorsManager.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ColorsManager.mainBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: ColorsManager.mainBlue),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value.isEmpty ? L10nDoctor.undefined.tr() : value,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context, CaseRequestModel request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditRequestScreen(request: request),
      ),
    ).then((result) {
      // Refresh requests list if changes were saved
      if (result == true && context.mounted) {
        context.read<MyRequestsCubit>().loadRequests();
      }
    });
  }

  void _showDeleteDialog(BuildContext context, CaseRequestModel request) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade600),
              SizedBox(width: 10),
              Text(L10nRequests.confirmDeletion.tr(),
                  style: TextStyle(
                      fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            L10nRequests.areYouSureYou.tr(),
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(L10nBooking.cancellation.tr(),
                  style: TextStyle(
                      fontFamily: 'Cairo', color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                final cubit = context.read<MyRequestsCubit>();
                
                Navigator.of(ctx).pop(); // إغلاق حوار التأكيد
                
                // إظهار حوار التحميل
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CircularProgressIndicator(color: ColorsManager.mainBlue),
                  ),
                );

                // تنفيذ الحذف (الـ Listener سيتكفل بالإغلاق)
                cubit.deleteRequest(request);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(L10nRequests.deleteNow.tr(),
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
            ),
          ],
        ),
    );
  }
}
