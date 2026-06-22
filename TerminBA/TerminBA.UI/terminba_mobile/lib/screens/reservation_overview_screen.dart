import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/reservation_response.dart';
import 'package:terminba_mobile/providers/reservation_provider.dart';
import 'package:terminba_mobile/widgets/reservation_ticket_card.dart';

class ReservationOverviewScreen extends StatefulWidget {
  final int reservationId;

  const ReservationOverviewScreen({super.key, required this.reservationId});

  @override
  State<ReservationOverviewScreen> createState() => _ReservationOverviewScreenState();
}

class _ReservationOverviewScreenState extends State<ReservationOverviewScreen> {
  bool _isLoading = true;
  ReservationResponse? _details;
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
      if (mounted) {
        setState(() {
          _details = details;
          _isLoading = false;
        });
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
    try {
      final provider = Provider.of<ReservationProvider>(context, listen: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigating to rebook flow (Not fully implemented yet)')),
        );
        // Here we would navigate to the booking flow passing rebookData
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start rebooking: $e')),
        );
      }
    }
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
                      ReservationTicketCard(details: _details!),
                      const SizedBox(height: 32),
                      if (_details!.isUpcoming)
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
                        )
                      else if (!_details!.isCancelled)
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}
