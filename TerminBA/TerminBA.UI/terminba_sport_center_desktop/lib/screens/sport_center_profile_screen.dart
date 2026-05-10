import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_sport_center_desktop/layouts/master_screen.dart';
import 'package:terminba_sport_center_desktop/model/sport_center.dart';
import 'package:terminba_sport_center_desktop/providers/auth_provider.dart';
import 'package:terminba_sport_center_desktop/providers/sport_center_provider.dart';

class SportCenterProfileScreen extends StatefulWidget {
	const SportCenterProfileScreen({super.key});

	@override
	State<SportCenterProfileScreen> createState() => _SportCenterProfileScreenState();
}

class _SportCenterProfileScreenState extends State<SportCenterProfileScreen> {
	late SportCenterProvider _sportCenterProvider;
	late AuthProvider _authProvider;
	SportCenter? _sportCenter;
	bool _isLoading = true;
	String? _errorMessage;
	bool _initialized = false;

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
		_sportCenterProvider = context.read<SportCenterProvider>();
		_authProvider = context.read<AuthProvider>();
		if (!_initialized) {
			_initialized = true;
			_loadSportCenter();
		}
	}

	Future<void> _loadSportCenter() async {
		setState(() {
			_isLoading = true;
			_errorMessage = null;
		});

		try {
			final int? currentUserId = _authProvider.isLoggedIn
					? await _authProvider.getCurrentUserId()
					: null;

			if (currentUserId == null) {
				throw Exception('Sport center not found for current user.');
			}

			final result = await _sportCenterProvider.getCurrentSportCenter(currentUserId);
			if (!mounted) return;
			setState(() {
				_sportCenter = result;
				_isLoading = false;
			});
		} catch (e) {
			if (!mounted) return;
			setState(() {
				_isLoading = false;
				_errorMessage = 'Unable to load sport center profile.';
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		if (_isLoading) {
			return const MasterScreen(
				title: 'Profile',
				child: Center(child: CircularProgressIndicator()),
			);
		}

		if (_errorMessage != null || _sportCenter == null) {
			return MasterScreen(
				title: 'Profile',
				child: Center(
					child: Text(_errorMessage ?? 'Sport center data not available.'),
				),
			);
		}

		final sportCenter = _sportCenter!;

		return MasterScreen(
			title: 'Profile',
			child: Padding(
				padding: const EdgeInsets.all(20),
				child: LayoutBuilder(
					builder: (context, constraints) {
						final bool stacked = constraints.maxWidth < 1100;

						return SingleChildScrollView(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									_buildHeader(context, stacked, sportCenter),
									const SizedBox(height: 18),
									if (stacked) ...[
										_buildAboutCard(context, sportCenter),
										const SizedBox(height: 16),
										_buildLocationCard(context, sportCenter),
										const SizedBox(height: 16),
										_buildSportsCard(context, sportCenter),
										const SizedBox(height: 16),
										_buildAmenitiesCard(context, sportCenter),
										const SizedBox(height: 16),
										_buildWorkingHoursCard(context, sportCenter),
										const SizedBox(height: 16),
										_buildContactCard(context, sportCenter),
									] else ...[
										Row(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Expanded(
													flex: 7,
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															_buildAboutCard(context, sportCenter),
															const SizedBox(height: 16),
															_buildSportsCard(context, sportCenter),
															const SizedBox(height: 16),
															_buildAmenitiesCard(context, sportCenter),
														],
													),
												),
												const SizedBox(width: 16),
												Expanded(
													flex: 5,
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															_buildLocationCard(context, sportCenter),
															const SizedBox(height: 16),
															_buildWorkingHoursCard(context, sportCenter),
															const SizedBox(height: 16),
															_buildContactCard(context, sportCenter),
														],
													),
												),
											],
										),
									],
							],
						),
						);
					},
				),
			),
		);
	}

	Widget _buildHeader(BuildContext context, bool stacked, SportCenter sportCenter) {
		final TextTheme textTheme = Theme.of(context).textTheme;
		final String cityName = sportCenter.city?.name ?? 'City not set';
		final String address = sportCenter.address.trim().isEmpty
				? 'Address not set'
				: sportCenter.address;
		final String phone = sportCenter.phoneNumber.trim().isEmpty
				? 'Phone not set'
				: sportCenter.phoneNumber;
		final String equipmentLabel = sportCenter.isEquipmentProvided
				? 'Equipment Provided'
				: 'No Equipment';

		final actions = Wrap(
			spacing: 10,
			runSpacing: 10,
			children: [
				ElevatedButton.icon(
					onPressed: () {},
					icon: const Icon(Icons.edit),
					label: const Text('Edit Profile'),
				),
				OutlinedButton.icon(
					onPressed: () {},
					icon: const Icon(Icons.photo_library_outlined),
					label: const Text('Manage Gallery'),
				),
			],
		);

		final info = Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					sportCenter.username,
					style: textTheme.headlineSmall?.copyWith(
						fontWeight: FontWeight.w700,
					),
				),
				const SizedBox(height: 6),
				Text(
					'$cityName • $address',
					style: textTheme.bodyMedium?.copyWith(
						color: Colors.grey.shade700,
					),
				),
				const SizedBox(height: 10),
				Wrap(
					spacing: 8,
					runSpacing: 8,
					children: [
						_pill(
							context,
							icon: Icons.phone,
							label: phone,
							color: Colors.blueGrey.shade600,
						),
						_pill(
							context,
							icon: Icons.handyman_outlined,
							label: equipmentLabel,
							color: Colors.green.shade600,
						),
					],
				),
			],
		);

		return Container(
			width: stacked ? double.infinity : null,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(20),
				color: Colors.white,
				border: Border.all(color: Colors.grey.shade200),
			),
			child: Padding(
				padding: const EdgeInsets.all(20),
				child: stacked
						? Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								info,
								const SizedBox(height: 16),
								actions,
							],
						)
						: Row(
							crossAxisAlignment: CrossAxisAlignment.center,
							children: [
								Expanded(child: info),
								const SizedBox(width: 18),
								actions,
							],
						),
			),
		);
	}

	Widget _buildAboutCard(BuildContext context, SportCenter sportCenter) {
		final String description = sportCenter.description.trim().isEmpty
				? 'No description provided.'
				: sportCenter.description;

		return _sectionCard(
			context,
			title: 'About',
			icon: Icons.info_outline,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						description,
						style: Theme.of(context).textTheme.bodyMedium,
					),
				],
			),
		);
	}

	Widget _buildContactCard(BuildContext context, SportCenter sportCenter) {
		final String phone = sportCenter.phoneNumber.trim().isEmpty
				? 'Not provided'
				: sportCenter.phoneNumber;

		return _sectionCard(
			context,
			title: 'Contact',
			icon: Icons.contact_phone_outlined,
			child: Column(
				children: [
					_infoRow(context, label: 'Username', value: sportCenter.username),
					_infoRow(context, label: 'Phone', value: phone),
					_infoRow(
						context,
						label: 'Equipment',
						value: sportCenter.isEquipmentProvided ? 'Yes' : 'No',
					),
				],
			),
		);
	}

	Widget _buildLocationCard(BuildContext context, SportCenter sportCenter) {
		final String cityName = sportCenter.city?.name ?? 'Not provided';
		final String address = sportCenter.address.trim().isEmpty
				? 'Not provided'
				: sportCenter.address;

		return _sectionCard(
			context,
			title: 'Location',
			icon: Icons.location_on_outlined,
			child: Column(
				children: [
					_infoRow(context, label: 'City', value: cityName),
					_infoRow(context, label: 'Address', value: address),
				],
			),
		);
	}

	Widget _buildWorkingHoursCard(BuildContext context, SportCenter sportCenter) {
		final workingHours = List.of(sportCenter.workingHours)
				..sort((a, b) => a.startDay.index.compareTo(b.startDay.index));

		return _sectionCard(
			context,
			title: 'Working Hours',
			icon: Icons.schedule,
			child: Column(
				children: workingHours.isEmpty
						? const [
							_HoursRow(day: 'No working hours set', time: ''),
						]
						: workingHours
								.map(
										(wh) => _HoursRow(
											day: _formatDayRange(wh.startDay, wh.endDay),
											time: '${wh.openingHours} - ${wh.closeingHours}',
										),
									)
								.toList(),
			),
		);
	}

	String _formatDayRange(dynamic startDay, dynamic endDay) {
		final String start = _dayLabel(startDay);
		final String end = _dayLabel(endDay);
		if (start == end) return start;
		return '$start - $end';
	}

	String _dayLabel(dynamic day) {
		switch (day.toString().split('.').last) {
			case 'monday':
				return 'Mon';
			case 'tuesday':
				return 'Tue';
			case 'wednesday':
				return 'Wed';
			case 'thursday':
				return 'Thu';
			case 'friday':
				return 'Fri';
			case 'saturday':
				return 'Sat';
			case 'sunday':
				return 'Sun';
			default:
				return 'Day';
		}
	}

	Widget _buildSportsCard(BuildContext context, SportCenter sportCenter) {
		final sports = sportCenter.availableSports;

		return _sectionCard(
			context,
			title: 'Sports',
			icon: Icons.sports_soccer,
			badgeText: sports.isEmpty ? null : sports.length.toString(),
			child: sports.isEmpty
					? Text(
						'No sports available.',
						style: Theme.of(context).textTheme.bodyMedium,
					)
					: Wrap(
						spacing: 8,
						runSpacing: 8,
						children: sports
								.map((sport) => Chip(
										label: Text(sport.name ?? 'Sport'),
										backgroundColor: Colors.grey.shade100,
									))
								.toList(),
					),
		);
	}

	Widget _buildAmenitiesCard(BuildContext context, SportCenter sportCenter) {
		final amenities = sportCenter.availableAmenities;

		return _sectionCard(
			context,
			title: 'Amenities',
			icon: Icons.local_activity,
			badgeText: amenities.isEmpty ? null : amenities.length.toString(),
			child: amenities.isEmpty
					? Text(
						'No amenities available.',
						style: Theme.of(context).textTheme.bodyMedium,
					)
					: Wrap(
						spacing: 8,
						runSpacing: 8,
						children: amenities
								.map((amenity) => Chip(
										label: Text(amenity.name),
										backgroundColor: Colors.grey.shade100,
									))
								.toList(),
					),
		);
	}

	Widget _sectionCard(
		BuildContext context, {
		required String title,
		required Widget child,
		IconData? icon,
		String? badgeText,
	}) {
		return Card(
			child: Padding(
				padding: const EdgeInsets.all(18),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							children: [
								if (icon != null) ...[
									Icon(icon, size: 18, color: Colors.grey.shade700),
									const SizedBox(width: 8),
								],
								Expanded(
									child: Text(
										title,
										style: Theme.of(context).textTheme.titleMedium?.copyWith(
												fontWeight: FontWeight.w700,
											),
									),
								),
								if (badgeText != null)
									Container(
										padding: const EdgeInsets.symmetric(
											horizontal: 10,
											vertical: 4,
										),
										decoration: BoxDecoration(
											color: Colors.grey.shade100,
											borderRadius: BorderRadius.circular(12),
										),
										child: Text(
											badgeText,
											style: Theme.of(context).textTheme.bodySmall?.copyWith(
													fontWeight: FontWeight.w600,
											),
										),
									),
							],
						),
						const SizedBox(height: 12),
						child,
					],
				),
			),
		);
	}

	Widget _infoRow(
		BuildContext context, {
		required String label,
		required String value,
	}) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 6),
			child: Row(
				children: [
					SizedBox(
						width: 110,
						child: Text(
							label,
							style: Theme.of(context).textTheme.bodyMedium?.copyWith(
										color: Colors.grey.shade600,
									),
						),
					),
					Expanded(
						child: Text(
							value,
							style: Theme.of(context).textTheme.bodyMedium?.copyWith(
										fontWeight: FontWeight.w600,
									),
						),
					),
				],
			),
		);
	}

	Widget _pill(
		BuildContext context, {
		required IconData icon,
		required String label,
		required Color color,
	}) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
			decoration: BoxDecoration(
				color: Colors.white.withValues(alpha: 90),
				borderRadius: BorderRadius.circular(18),
			),
			child: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					Icon(icon, size: 18, color: color),
					const SizedBox(width: 6),
					Text(
						label,
						style: Theme.of(context).textTheme.bodyMedium?.copyWith(
									fontWeight: FontWeight.w600,
								),
					),
				],
			),
		);
	}

}

class _HoursRow extends StatelessWidget {
	const _HoursRow({required this.day, required this.time});

	final String day;
	final String time;

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 6),
			child: Row(
				children: [
					Expanded(
						child: Text(
							day,
							style: Theme.of(context).textTheme.bodyMedium?.copyWith(
										color: Colors.grey.shade700,
									),
						),
					),
					Text(
						time,
						style: Theme.of(context).textTheme.bodyMedium?.copyWith(
									fontWeight: FontWeight.w600,
								),
					),
				],
			),
		);
	}
}
