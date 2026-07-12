import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/features/booking/booking_flow_notifier.dart';
import 'package:terminba_mobile/features/booking/booking_flow_state.dart';
import 'package:terminba_mobile/model/reservation_response.dart';
import 'package:terminba_mobile/model/user_review.dart';
import 'package:terminba_mobile/providers/facility_provider.dart';
import 'package:terminba_mobile/providers/payment_provider.dart';
import 'package:terminba_mobile/providers/reservation_provider.dart';
import 'package:terminba_mobile/providers/user_review_provider.dart';
import 'package:terminba_mobile/screens/reservation/date_time_slot_screen.dart';
import 'package:terminba_mobile/widgets/reservation_ticket_card.dart';
import 'package:terminba_mobile/model/facility.dart';
import 'package:terminba_mobile/model/facility_review.dart';
import 'package:terminba_mobile/providers/facility_review_provider.dart';
import 'package:terminba_mobile/screens/write_facility_review_screen.dart';
import 'package:terminba_mobile/screens/write_user_review_screen.dart';
import 'package:terminba_mobile/screens/facility_reviews_screen.dart';
import 'package:terminba_mobile/screens/create_player_search_post_screen.dart';
import 'package:terminba_mobile/model/play_request_response.dart';
import 'package:terminba_mobile/providers/play_request_provider.dart';

class ReservationOverviewScreen extends StatefulWidget {
  final int reservationId;

  const ReservationOverviewScreen({super.key, required this.reservationId});

  @override
  State<ReservationOverviewScreen> createState() => _ReservationOverviewScreenState();
}

class _ReservationOverviewScreenState extends State<ReservationOverviewScreen> {
  bool _isLoading = true;
  bool _isLoadingPlayers = false;
  ReservationResponse? _details;
  FacilityReview? _review;
  List<UserReview>? _userReviews;
  List<PlayRequestResponse>? _acceptedPlayers;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<ReservationProvider>(context, listen: false);
      final details = await provider.getById(widget.reservationId);
      
      FacilityReview? review;
      try {
        final reviewProvider = Provider.of<FacilityReviewProvider>(context, listen: false);
        final reviewResult = await reviewProvider.get(filter: {'reservationId': widget.reservationId});
        if (reviewResult.items != null && reviewResult.items!.isNotEmpty) {
          review = reviewResult.items!.first;
        }
      } catch (e) {
        // ignore review fetch errors
      }

      List<UserReview>? userReviews;
      try {
        final userReviewProvider = Provider.of<UserReviewProvider>(context, listen: false);
        final userReviewResult = await userReviewProvider.get(filter: {
          'reservationId': widget.reservationId,
          'isReviewer': 'true',
        });
        if (userReviewResult.items != null) {
          userReviews = userReviewResult.items;
        }
      } catch (e) {
        // ignore user review fetch errors
      }

      if (mounted) {
        setState(() {
          _details = details;
          _review = review;
          _userReviews = userReviews;
          _isLoading = false;
        });
      }

      if (details!.isUpcoming == false) {
        setState(() => _isLoadingPlayers = true);
        try {
          final playRequestProvider = Provider.of<PlayRequestProvider>(context, listen: false);
          final prResult = await playRequestProvider.get(filter: {
            'ReservationId': widget.reservationId,
            'Status': 'accepted',
          });
          if (mounted) {
            setState(() {
              _acceptedPlayers = prResult.items;
              _isLoadingPlayers = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _acceptedPlayers = [];
              _isLoadingPlayers = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load details: $e')),
        );
      }
    }
  }

  Future<void> _downloadTicket() async {
    try {
      final provider = Provider.of<ReservationProvider>(context, listen: false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket downloaded successfully!')),
        );
        _fetchDetails(); // to update ticketDownloaded status
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download ticket: $e')),
        );
      }
    }
  }

  Future<void> _reserveAgain() async {
    final details = _details;
    if (details == null) return;

    final baseFacility = details.facility;
    if (baseFacility == null) return;

    final sport = details.chosenSport;
    if (sport == null) return;

    setState(() => _isLoading = true);

    Facility? fullFacility;
    try {
      fullFacility = await context.read<FacilityProvider>().getById(baseFacility.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load facility details: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    if (fullFacility == null) return;

    final sportCenter = fullFacility.sportCenter ?? baseFacility.sportCenter;
    final sportCenterName = sportCenter?.username ?? '';
    final sportCenterAddress = sportCenter?.address ?? '';

    if (!mounted) return;

    final notifier = BookingFlowNotifier(
      initialState: BookingFlowState(
        sportCenterId: fullFacility.sportCenterId,
        sportCenterName: sportCenterName,
        sportCenterAddress: sportCenterAddress,
        sport: sport,
        initialDate: DateTime.now(),
        selectedCourt: fullFacility,
        totalPrice: fullFacility.staticPrice?.toDouble() ?? 0.0,
        courts: [fullFacility],
      ),
      facilityProvider: context.read<FacilityProvider>(),
      reservationProvider: context.read<ReservationProvider>(),
      paymentProvider: context.read<PaymentProvider>(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: notifier,
          child: const DateTimeSlotScreen(),
        ),
      ),
    ).then((_) => notifier.dispose());
  }

  void _navigateToWriteReview(Facility facility, {FacilityReview? existingReview}) {
    final sportCenter = facility.sportCenter;
    final sportCenterId = facility.sportCenterId;
    final sportCenterName = sportCenter?.username ?? 'Sport Center';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WriteFacilityReviewScreen(
          sportCenterId: sportCenterId,
          facility: facility,
          reservationId: widget.reservationId,
          existingReview: existingReview,
        ),
      ),
    ).then((_) {
      _fetchDetails(); // Refresh after writing review
    });
  }

  Widget _buildCarousel() {
    final facility = _details?.facility;
    final photoUrls = facility?.photos
            ?.where((p) => p.url?.isNotEmpty ?? false)
            .map((p) => p.url!)
            .toList() ??
        [];

    if (photoUrls.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey.shade100,
        child: const Center(
          child: Icon(Icons.business, size: 80, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: photoUrls.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return Semantics(
                label: '${facility?.name ?? 'Facility'} photo ${index + 1}',
                image: true,
                child: CachedNetworkImage(
                  imageUrl: photoUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => Container(color: Colors.grey.shade100),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              );
            },
          ),
        ),
        if (photoUrls.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photoUrls.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 10 : 6,
                  height: active ? 10 : 6,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white70,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Overview'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _details == null
              ? const Center(child: Text('Could not load details.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _buildCarousel(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _details!.facility?.name ?? '',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_details!.facility?.sportCenter?.address ?? ''}, ${_details!.facility?.sportCenter?.city?.name ?? ''}',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      if (_details!.facility?.sportCenter != null && _details!.isUpcoming)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFD0D7F5)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, color: Color(0xFF5C7AE6), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Cancellation Policy: Free cancellation up to ${_details!.facility!.sportCenter!.cancellationDeadlineHours} hours before the reservation. (30% refund after deadline)',
                                  style: const TextStyle(
                                    color: Color(0xFF334A99),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_details!.facility?.sportCenter != null && _details!.isUpcoming)
                        const SizedBox(height: 24),
                      ReservationTicketCard(details: _details!),
                      const SizedBox(height: 32),
                      if (_details!.isUpcoming)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: _details!.ticketDownloaded ? null : _downloadTicket,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                _details!.ticketDownloaded ? 'Ticket Already Downloaded' : 'Download Ticket',
                                style: const TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CreatePlayerSearchPostScreen(
                                      reservation: _details!,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.people_outline, color: Color(0xFF00C875)),
                              label: const Text(
                                'Find Players',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF00C875),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF00C875), width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (!_details!.isCancelled) ...[
                        if (_isLoadingPlayers)
                          const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                        else if (_acceptedPlayers != null && _acceptedPlayers!.isNotEmpty) ...[
                          Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              title: const Text(
                                'Accepted Players',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Player',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600], fontSize: 13),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          'Review',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600], fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1, thickness: 1),
                                ..._acceptedPlayers!.map((req) {
                                  final requester = req.requester;
                                  final name = requester != null ? '${requester.firstName} ${requester.lastName}' : 'Unknown';
                                  final initials = requester != null ? '${requester.firstName.isNotEmpty ? requester.firstName[0] : ''}${requester.lastName.isNotEmpty ? requester.lastName[0] : ''}'.toUpperCase() : '?';
                                  final existingUserReview = _userReviews?.where((r) => r.reviewedId == requester?.id).firstOrNull;
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: const Color(0xFF00C875).withOpacity(0.15),
                                      child: Text(
                                        initials,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C875), fontSize: 14),
                                      ),
                                    ),
                                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    trailing: IconButton(
                                      icon: Icon(
                                        existingUserReview != null ? Icons.star : Icons.star_outline,
                                        color: const Color(0xFF4CAF50),
                                      ),
                                      tooltip: existingUserReview != null ? 'View Review' : 'Write Review',
                                      onPressed: () {
                                        if (requester != null) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => WriteUserReviewScreen(
                                                reviewedUser: requester,
                                                reservationId: widget.reservationId,
                                                sportName: _details?.chosenSport?.name ?? 'Sport',
                                                existingReview: existingUserReview,
                                              ),
                                            ),
                                          ).then((_) => _fetchDetails());
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        ElevatedButton(
                          onPressed: _reserveAgain,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Reserve Again',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_review != null)
                          OutlinedButton.icon(
                            onPressed: _details!.facility != null
                                ? () => _navigateToWriteReview(_details!.facility!, existingReview: _review)
                                : null,
                            icon: const Icon(Icons.star, color: Color(0xFF4CAF50)),
                            label: const Text(
                              'View your Review',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: _details!.facility != null
                                ? () => _navigateToWriteReview(_details!.facility!)
                                : null,
                            icon: const Icon(Icons.star_outline, color: Color(0xFF4CAF50)),
                            label: const Text(
                              'Leave a Review',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}
