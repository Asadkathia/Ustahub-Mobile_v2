import 'package:flutter/foundation.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/ui_v2/config/ui_config.dart';
import 'package:ustahub/app/ui_v2/ui_v2_exports.dart';

class BookingDetailsView extends StatefulWidget {
  final String? pageName;
  final String? bookingId;

  const BookingDetailsView({super.key, this.pageName, this.bookingId});

  @override
  State<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends State<BookingDetailsView> {
  String? role;

  // Controllers
  final StartWorkController startWorkController = Get.put(
    StartWorkController(),
  );
  final ProviderCompleteWorkController providerCompleteWorkController = Get.put(
    ProviderCompleteWorkController(),
  );
  final BookingDetailsController controller = Get.put(
    BookingDetailsController(),
  );

  // Notes controller for fetching and managing notes
  late final NotesController notesController;

  @override
  void initState() {
    super.initState();
    _initializeView();
  }

  void _initializeView() async {
    await _checkRole();

    // Initialize notes controller
    notesController = Get.put(
      NotesController(),
      tag: 'booking_${widget.bookingId}',
    );

    if (widget.bookingId != null) {
      controller.getBookingDetails(bookingId: widget.bookingId!);
      // Fetch notes for this booking
      notesController.setBookingId(widget.bookingId!);
    } else {
      print("Booking ID is null. Cannot fetch booking details.");
    }
  }

  Future<void> _checkRole() async {
    final userRole = await Sharedprefhelper.getRole();
    if (mounted) {
      setState(() {
        role = userRole ?? "";
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (UIConfig.useNewUI) {
      return _buildV2Scaffold();
    }
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        floatingActionButton: _buildChatButton(),
        backgroundColor: AppColors.background,
        body: Obx(
          () =>
              controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildV2Scaffold() {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: AppLocalizations.of(context)!.bookings,
      ),
      floatingActionButton: _buildV2ChatButton(),
      body: Obx(() {
        if (controller.isLoading.value ||
            controller.bookingDetails.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildV2Body();
      }),
    );
  }

  Widget _buildV2Body() {
    final booking = controller.bookingDetails.value!;
    return RefreshIndicator(
      onRefresh: () async {
        if (widget.bookingId != null) {
          await controller.getBookingDetails(bookingId: widget.bookingId!);
        }
      },
      color: AppColorsV2.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingHorizontal,
          vertical: AppSpacing.mdVertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildV2StatusCard(booking),
            SizedBox(height: AppSpacing.mdVertical),
            _buildV2ActionRow(),
            SizedBox(height: AppSpacing.mdVertical),
            _buildV2ScheduleCard(booking),
            SizedBox(height: AppSpacing.mdVertical),
            _buildV2Instructions(booking),
            SizedBox(height: AppSpacing.mdVertical),
            _buildV2WorkControls(),
            SizedBox(height: AppSpacing.mdVertical),
            SecondaryButtonV2(
              text: 'Manage notes',
              onPressed: _handleAddNote,
            ),
            SizedBox(height: AppSpacing.lgVertical * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildV2ChatButton() {
    return FloatingActionButton.extended(
      onPressed: _initiateChatWithOtherUser,
      backgroundColor: AppColorsV2.primary,
      label: Text(
        AppLocalizations.of(context)!.chat,
        style: AppTextStyles.buttonMedium,
      ),
      icon: const Icon(Icons.chat_rounded),
    );
  }

  Widget _buildV2StatusCard(BookingDetailsModelClass booking) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColorsV2.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColorsV2.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                ),
                child: Text(
                  controller.displayStatus,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColorsV2.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                booking.bookingId ?? '',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColorsV2.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.smVertical),
          Text(
            'Visit for ${booking.consumer?.name ?? ''}',
            style: AppTextStyles.heading3,
          ),
          SizedBox(height: AppSpacing.xsVertical),
          Text(
            booking.service?.name ?? '',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildV2ActionRow() {
    return Row(
      children: [
        Expanded(
          child: SecondaryButtonV2(
            text: 'Directions',
            onPressed: _handleDirections,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: SecondaryButtonV2(
            text: 'On my way',
            onPressed: _handleOnMyWay,
          ),
        ),
      ],
    );
  }

  Widget _buildV2ScheduleCard(BookingDetailsModelClass booking) {
    final formattedDate = formatDate(booking.bookingDate ?? '');
    final formattedTime = convertTo12HourFormat(booking.bookingTime ?? '');
    final addressText = controller.getFormattedAddress();

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColorsV2.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheduled time',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColorsV2.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '$formattedDate • $formattedTime',
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: AppSpacing.smVertical),
          Divider(color: AppColorsV2.borderLight),
          SizedBox(height: AppSpacing.smVertical),
          Text(
            AppLocalizations.of(context)!.address,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColorsV2.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            addressText.isEmpty ? 'No address available' : addressText,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildV2Instructions(BookingDetailsModelClass booking) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColorsV2.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructions',
            style: AppTextStyles.heading3,
          ),
          SizedBox(height: AppSpacing.xsVertical),
          Text(
            booking.note?.isNotEmpty == true
                ? booking.note!
                : 'No instructions available',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildV2WorkControls() {
    if (widget.bookingId == null) return const SizedBox.shrink();
    final canStart = controller.canStartWork;
    final canComplete = controller.canMarkComplete;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButtonV2(
          text: 'Start work',
          onPressed: canStart ? _handleStartWork : null,
        ),
        SizedBox(height: AppSpacing.sm),
        SecondaryButtonV2(
          text: 'Mark complete',
          onPressed: canComplete ? _handleMarkComplete : null,
        ),
      ],
    );
  }

  Widget _buildChatButton() {
    return FloatingActionButton.extended(
      onPressed: _initiateChatWithOtherUser,
      label: Text(
        AppLocalizations.of(context)!.chatNow,
        style: GoogleFonts.ubuntu(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      icon: const Icon(Icons.chat, color: Colors.white),
      backgroundColor: AppColors.green,
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    const TabBar(
                      tabs: [Tab(text: 'Visit'), Tab(text: 'Notes')],
                    ),
                  ),
                  pinned: true,
                ),
              ],
          body: TabBarView(children: [_buildVisitTab(), _buildNotesTab()]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(),
          SizedBox(height: 20.h),
          _buildBookingContent(),
          if (role == "provider") _buildProviderControls(),
          SizedBox(height: 14.h),
          BookingSectionTitle(title: 'Instructions'),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: SvgPicture.asset(AppVectors.back, height: 28.h, width: 28.h),
          ),
        ),
        Obx(() {
          // Use the display status from controller, fallback to pageName
          final label = controller.displayStatus.isNotEmpty && controller.displayStatus != 'Unknown'
              ? controller.displayStatus
              : widget.pageName ?? 'Loading...';
          return BookingStatusBadge(status: label);
        }),
      ],
    );
  }

  Widget _buildBookingContent() {
    return Obx(() {
      final bookingData = controller.bookingDetails.value;

      if (role == "consumer") {
        return ConsumerBookingHeader(
          bookingDetails: bookingData,
          onFavoriteTap: _handleFavoriteTap,
        ).withShimmerAi(loading: controller.isLoading.value);
      } else {
        return ProviderBookingHeader(
          bookingDetails: bookingData,
          onDirections: _handleDirections,
          onWay: _handleOnMyWay,
        );
      }
    });
  }

  Widget _buildProviderControls() {
    return Column(
      children: [
        SizedBox(height: 24.h),
        Obx(() {
          final hasBookingId = widget.bookingId != null;
          final canStart = controller.canStartWork && hasBookingId;
          final canComplete = controller.canMarkComplete && hasBookingId;
          
          debugPrint('[UI] Building controls - status: ${controller.currentStatus.value}, canStart: $canStart, canComplete: $canComplete');
          
          return WorkControlButtons(
            isStarted: controller.isStarted.value,
            isComplete: controller.isComplete.value,
            canStart: canStart,
            canComplete: canComplete,
            onStartWork: _handleStartWork,
            onMarkComplete: _handleMarkComplete,
          );
        }),
      ],
    );
  }

  Widget _buildVisitTab() {
    return Obx(
      () => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Instructions',
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                controller.bookingDetails.value?.note ??
                    "No Instructions available",
                style: GoogleFonts.ubuntu(fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddNoteSection(onAddNote: _handleAddNote, onAddPhoto: _handleAddPhoto),
        Expanded(
          child: Obx(() {
            // Show loading state
            if (notesController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            // Show error state
            if (notesController.isError.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load notes',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      notesController.errorMessage.value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => notesController.refreshNotes(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Show empty state
            if (notesController.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 48.sp,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No notes yet',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Add your first note to get started',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show notes list
            return RefreshIndicator(
              onRefresh: () => notesController.refreshNotes(),
              child: ListView.separated(
                separatorBuilder: (context, index) => const CustomDottedLine(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: notesController.notes.length,
                itemBuilder: (context, index) {
                  final data = notesController.notes.reversed.toList();
                  final note = data[index];
                  return NoteItem(
                    name:
                        note
                            .user
                            .name, // You can enhance this with actual user names
                    date: note.formattedDate,
                    note: note.note,
                    imageUrls: note.images,
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // Event Handlers
  void _initiateChatWithOtherUser() async {
    try {
      final bookingData = controller.bookingDetails.value;
      if (bookingData == null) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingChatPage(
            bookingId: bookingData.id ?? '',
            bookingNumber: bookingData.bookingId ?? '',
            counterpartyName: role == "consumer"
                ? (bookingData.provider?.name ?? 'Provider')
                : (bookingData.consumer?.name ?? 'Customer'),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to start chat: $e');
    }
  }

  Future<void> _handleFavoriteTap() async {
    final provider = controller.bookingDetails.value?.provider;
    if (provider != null && provider.id != null) {
      // Toggle locally for instant UI feedback
      controller.bookingDetails.value = controller.bookingDetails.value
          ?.copyWith(
            provider: BookingProvider(
              id: provider.id,
              name: provider.name,
              isFavorite: !(provider.isFavorite ?? false),
              averageRating: provider.averageRating,
            ),
          );
      // Call API
      await controller.favouriteProvider.favouriteToggle(
        id: provider.id.toString(),
      );
    }
  }

  void _handleDirections() {
    final bookingData = controller.bookingDetails.value;
    
    // Check if we have valid address data
    if (!controller.hasValidAddress) {
      CustomToast.error("Address not available for directions");
      debugPrint('[DIRECTIONS] No valid address available');
      return;
    }

    final address = bookingData!.address!;
    
    // Try to use coordinates first (more accurate)
    final lat = address.latitude;
    final lng = address.longitude; 
    
    if (lat != null && lat.isNotEmpty && lat != 'null' &&
        lng != null && lng.isNotEmpty && lng != 'null') {
      // Open Google Maps with coordinates
      try {
        final latitude = double.tryParse(lat);
        final longitude = double.tryParse(lng);
        
        if (latitude != null && longitude != null) {
          debugPrint('[DIRECTIONS] Opening maps with coordinates: $latitude, $longitude');
          MapsLauncher.launchCoordinates(latitude, longitude);
          return;
        }
      } catch (e) {
        debugPrint('[DIRECTIONS] Error parsing coordinates: $e');
    }
    }
    
    // Fallback to address text
    final fullAddress = controller.getFormattedAddress();
    
    if (fullAddress.isEmpty) {
      CustomToast.error("Address not available for directions");
      return;
    }

    try {
      debugPrint('[DIRECTIONS] Opening maps with address: $fullAddress');
      MapsLauncher.launchQuery(fullAddress);
    } catch (e) {
      CustomToast.error("Failed to open maps: ${e.toString()}");
      debugPrint("[DIRECTIONS] Error launching maps: $e");
    }
  }

  void _handleOnMyWay() {
    final bookingData = controller.bookingDetails.value;
    
    // Check if booking data is loaded
    if (bookingData == null || controller.isLoading.value) {
      CustomToast.error("Booking information is loading, please wait...");
      return;
    }

    // Show confirmation dialog with option to also open directions
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            "On My Way",
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notify ${bookingData.consumer?.name ?? 'the customer'} that you're on your way?",
                style: GoogleFonts.ubuntu(fontSize: 14.sp),
              ),
              if (controller.hasValidAddress) ...[
                SizedBox(height: 12.h),
                Text(
                  "Destination:",
                  style: GoogleFonts.ubuntu(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  controller.getFormattedAddress(),
            style: GoogleFonts.ubuntu(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                  ),
            ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.ubuntu(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Send notification and open directions
                CustomToast.success(
                  "Customer notified! Opening directions...",
                );
                // Open directions after a short delay
                Future.delayed(const Duration(milliseconds: 500), () {
                  _handleDirections();
                });
              },
              child: Text(
                "Notify & Navigate",
                style: GoogleFonts.ubuntu(
                  color: AppColors.green,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleStartWork() async {
    if (widget.bookingId == null) {
      CustomToast.error("Booking ID not found");
      return;
    }
    
    final status = controller.currentStatus.value;
    debugPrint('[UI] Start work clicked. Current status: $status');
    
    if (!controller.canStartWork) {
      if (status == 'pending') {
        CustomToast.error("This booking is still pending acceptance.");
      } else if (status == 'in_progress') {
        CustomToast.error("Work has already been started.");
      } else if (status == 'completed') {
        CustomToast.error("This booking is already completed.");
      } else if (status.isEmpty) {
        CustomToast.error("Loading booking status...");
        // Try refreshing the data
        await controller.getBookingDetails(bookingId: widget.bookingId!);
      } else {
        CustomToast.error("Work can only be started for accepted bookings. Current: $status");
      }
      return;
    }
    
    // Use the new controller method directly
    await controller.startWork(widget.bookingId!);
  }

  void _handleMarkComplete() async {
    if (widget.bookingId == null) {
      CustomToast.error("Booking ID not found");
      return;
    }
    
    final status = controller.currentStatus.value;
    debugPrint('[UI] Mark complete clicked. Current status: $status');
    
    if (!controller.canMarkComplete) {
      if (status == 'accepted') {
        CustomToast.error("Please start work before marking as complete.");
      } else if (status == 'completed') {
        CustomToast.error("This booking is already completed.");
      } else if (status == 'pending') {
        CustomToast.error("This booking needs to be accepted first.");
      } else if (status.isEmpty) {
        CustomToast.error("Loading booking status...");
        await controller.getBookingDetails(bookingId: widget.bookingId!);
      } else {
        CustomToast.error("Booking must be in progress to complete. Current: $status");
      }
      return;
    }
    
    // Show confirmation dialog
    _showCompleteConfirmation();
  }
  
  void _showCompleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            "Complete Booking",
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
          content: Text(
            "Are you sure you want to mark this booking as complete?",
            style: GoogleFonts.ubuntu(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.ubuntu(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await controller.completeWork(widget.bookingId!);
              },
              child: Text(
                "Complete",
                style: GoogleFonts.ubuntu(
                  color: AppColors.green,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleAddNote() {
    // Open the note view modal with booking ID
    if (widget.bookingId != null) {
      NoteViewModal.show(context, bookingId: widget.bookingId!);
    } else {
      Get.snackbar(
        'Error',
        'Booking ID not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _handleAddPhoto() {
    // Open the note view modal (same as add note since it includes photo functionality)
    if (widget.bookingId != null) {
      NoteViewModal.show(context, bookingId: widget.bookingId!);
    } else {
      Get.snackbar(
        'Error',
        'Booking ID not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.background, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

InputDecoration createInputDecoration() {
  return InputDecoration(
    contentPadding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
    hintText: 'Type a message...',
    fillColor: Colors.white,
    border: OutlineInputBorder(borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
    disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
    errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide.none),
  );
}
