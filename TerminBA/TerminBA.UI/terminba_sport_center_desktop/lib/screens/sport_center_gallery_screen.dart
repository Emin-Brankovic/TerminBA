import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_sport_center_desktop/helpers/image_validator.dart';
import 'package:terminba_sport_center_desktop/model/sport_center.dart';
import 'package:terminba_sport_center_desktop/model/sport_center_gallery_update_request.dart';
import 'package:terminba_sport_center_desktop/model/sport_center_photo_response.dart';
import 'package:terminba_sport_center_desktop/providers/sport_center_provider.dart';

class SportCenterGalleryScreen extends StatefulWidget {
	final SportCenter sportCenter;

	const SportCenterGalleryScreen({super.key, required this.sportCenter});

	@override
	State<SportCenterGalleryScreen> createState() =>
			_SportCenterGalleryScreenState();
}

class _SportCenterGalleryScreenState extends State<SportCenterGalleryScreen> {
	static const int _maxGalleryPhotos = 12;
	late SportCenterProvider _sportCenterProvider;
	final List<Uint8List> _selectedPhotos = [];
	final Set<int> _removedPhotoIds = {};
	bool _isSaving = false;

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
		_sportCenterProvider = context.read<SportCenterProvider>();
	}

	Future<void> _pickPhotos({bool replace = false}) async {
		final activeExistingCount =
				_existingPhotos.length - _removedPhotoIds.length;
		final remainingSlots = _maxGalleryPhotos -
				(replace ? 0 : (_selectedPhotos.length + activeExistingCount));

		if (remainingSlots <= 0) {
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(content: Text('Gallery is full.')),
				);
			}
			return;
		}

		final result = await FilePicker.platform.pickFiles(
			type: FileType.image,
			allowMultiple: true,
			withData: true,
		);

		if (result == null) {
			return;
		}

		final picked = <Uint8List>[];
		final errors = <String>[];

		for (final file in result.files) {
			if (picked.length >= remainingSlots) {
				errors.add('Gallery limit reached. Max 12 photos allowed.');
				break;
			}

			final validationError = ImageValidator.validatePickedImage(file);
			if (validationError != null) {
				errors.add('${file.name}: $validationError');
				continue;
			}

			if (file.bytes != null) {
				picked.add(file.bytes!);
			}
		}

		if (picked.isEmpty) {
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text(
							errors.isNotEmpty ? errors.first : 'No readable images selected.',
						),
					),
				);
			}
			return;
		}

		if (errors.isNotEmpty && mounted) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text(
						errors.length == 1
								? errors.first
								: '${errors.first} (+${errors.length - 1} more)',
					),
				),
			);
		}

		setState(() {
			if (replace) {
				_selectedPhotos
					..clear()
					..addAll(picked);
				final existing = _existingPhotos;
				if (existing.isNotEmpty) {
					_removedPhotoIds
						..clear()
						..addAll(existing.map((photo) => photo.id));
				}
			} else {
				_selectedPhotos.addAll(picked);
			}
		});
	}

	List<SportCenterPhotoResponse> get _existingPhotos => widget
			.sportCenter.photos
			.where((photo) => (photo.url ?? '').trim().isNotEmpty)
			.toList();

	void _toggleRemovePhoto(SportCenterPhotoResponse photo) {
		setState(() {
			if (_removedPhotoIds.contains(photo.id)) {
				_removedPhotoIds.remove(photo.id);
			} else {
				_removedPhotoIds.add(photo.id);
			}
		});
	}

	void _removePickedPhoto(int index) {
		setState(() {
			_selectedPhotos.removeAt(index);
		});
	}

	Future<void> _saveChanges() async {
		if (_selectedPhotos.isEmpty && _removedPhotoIds.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('No gallery changes to save.')),
			);
			return;
		}

		setState(() => _isSaving = true);

		try {
			final request = SportCenterGalleryUpdateRequest(
				photos: _selectedPhotos.isEmpty
						? null
						: List<Uint8List>.from(_selectedPhotos),
				removedPhotoIds: _removedPhotoIds.isEmpty
						? null
						: _removedPhotoIds.toList(),
			);

			await _sportCenterProvider.updateGallery(request);

			if (!mounted) return;
			Navigator.of(context).pop(true);
		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Failed to update gallery: $e')),
			);
		} finally {
			if (mounted) {
				setState(() => _isSaving = false);
			}
		}
	}

	@override
	Widget build(BuildContext context) {
		final existingPhotos = _existingPhotos;
		final activeExisting = existingPhotos
				.where((photo) => !_removedPhotoIds.contains(photo.id))
				.toList();

		return Scaffold(
			appBar: AppBar(
				leading: const BackButton(),
				 title: const Center(
          child: Text(
            'Manage Gallery',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
			),
			body: Padding(
				padding: const EdgeInsets.all(20),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Card(child: Padding(
							padding: const EdgeInsets.all(16),
							child: _buildHeader(activeExisting.length, _selectedPhotos.length),
						)),
						const SizedBox(height: 16),
						Card(child: Padding(
							padding: const EdgeInsets.all(16),
							child: _buildActionBar(),
						)),
						const SizedBox(height: 16),
						Expanded(
							child: SingleChildScrollView(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Card(child: Padding(
											padding: const EdgeInsets.all(16),
											child: _buildExistingPhotosSection(existingPhotos),
										)),
										const SizedBox(height: 20),
										Card(child: Padding(
											padding: const EdgeInsets.all(16),
											child: _buildPickedPhotosSection(),
										)),
									],
								),
							),
						),
					],
				),
			),
		);
	}

	Widget _buildHeader(int existingCount, int pendingCount) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text('Max ${_maxGalleryPhotos} photos total.'),
				const SizedBox(height: 8),
				Row(
					crossAxisAlignment: CrossAxisAlignment.center,
					children: [
						_counterChip('Existing', existingCount),
						const SizedBox(width: 8),
						_counterChip('New', pendingCount),
					],
				),
			],
		);
	}

	Widget _counterChip(String label, int value) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
			decoration: BoxDecoration(
				color: Colors.grey.shade100,
				borderRadius: BorderRadius.circular(16),
			),
			child: Text(
				'$label: $value',
				style: Theme.of(context).textTheme.bodySmall?.copyWith(
							fontWeight: FontWeight.w600,
						),
			),
		);
	}

	Widget _buildActionBar() {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Wrap(
					spacing: 10,
					runSpacing: 10,
					children: [
						OutlinedButton.icon(
							onPressed: _isSaving ? null : () => _pickPhotos(replace: false),
							icon: const Icon(Icons.photo_library_outlined),
							label: const Text('Add photos'),
						),
						OutlinedButton.icon(
							onPressed: _isSaving ? null : () => _pickPhotos(replace: true),
							icon: const Icon(Icons.collections_outlined),
							label: const Text('Replace gallery'),
						),
						if (_selectedPhotos.isNotEmpty)
							TextButton(
								onPressed: _isSaving
										? null
										: () => setState(() => _selectedPhotos.clear()),
								child: const Text('Clear new photos'),
							),
						const SizedBox(width: 12),
						ElevatedButton.icon(
							onPressed: _isSaving ? null : _saveChanges,
							icon: _isSaving
									? const SizedBox(
											width: 18,
											height: 18,
											child: CircularProgressIndicator(strokeWidth: 2),
										)
								: const Icon(Icons.save),
							label: Text(_isSaving ? 'Saving...' : 'Save changes'),
						),
					],
				),
			],
		);
	}

	Widget _buildExistingPhotosSection(List<SportCenterPhotoResponse> photos) {
		if (photos.isEmpty) {
			return Text(
				'No existing photos yet.',
				style: Theme.of(context).textTheme.bodyMedium,
			);
		}

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					'Existing photos',
					style: Theme.of(context).textTheme.titleMedium?.copyWith(
								fontWeight: FontWeight.w700,
							),
				),
				const SizedBox(height: 12),
				LayoutBuilder(
					builder: (context, constraints) {
						final crossAxisCount = constraints.maxWidth ~/ 220;
						final count = crossAxisCount < 2 ? 2 : crossAxisCount;
						return GridView.builder(
							shrinkWrap: true,
							physics: const NeverScrollableScrollPhysics(),
							gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
								crossAxisCount: count,
								crossAxisSpacing: 12,
								mainAxisSpacing: 12,
								childAspectRatio: 1.2,
							),
							itemCount: photos.length,
							itemBuilder: (context, index) {
								final photo = photos[index];
								final removed = _removedPhotoIds.contains(photo.id);
								return _buildNetworkPhotoCard(photo, removed);
							},
						);
					},
				),
			],
		);
	}

	Widget _buildNetworkPhotoCard(SportCenterPhotoResponse photo, bool removed) {
		return InkWell(
			onTap: _isSaving ? null : () => _toggleRemovePhoto(photo),
			child: Stack(
				children: [
					Container(
						decoration: BoxDecoration(
							borderRadius: BorderRadius.circular(14),
							border: Border.all(color: Colors.grey.shade200),
							color: Colors.grey.shade50,
							image: DecorationImage(
								image: NetworkImage(photo.url ?? ''),
								fit: BoxFit.cover,
							),
						),
					),
					Positioned(
						top: 10,
						right: 10,
						child: Container(
							padding: const EdgeInsets.all(6),
							decoration: BoxDecoration(
								color: removed ? Colors.red.shade600 : Colors.black54,
								borderRadius: BorderRadius.circular(16),
							),
							child: Icon(
								removed ? Icons.undo : Icons.delete_outline,
								color: Colors.white,
								size: 18,
							),
						),
					),
					if (removed)
						Container(
							decoration: BoxDecoration(
								color: Colors.black.withValues(alpha: 120),
								borderRadius: BorderRadius.circular(14),
							),
							child: Center(
								child: Text(
									'Tap to undo',
									style: Theme.of(context).textTheme.bodyMedium?.copyWith(
												color: Colors.white,
												fontWeight: FontWeight.w600,
											),
								),
							),
						),
				],
			),
		);
	}

	Widget _buildPickedPhotosSection() {
		if (_selectedPhotos.isEmpty) {
			return Text(
				'No new photos selected.',
				style: Theme.of(context).textTheme.bodyMedium,
			);
		}

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					'New uploads',
					style: Theme.of(context).textTheme.titleMedium?.copyWith(
								fontWeight: FontWeight.w700,
							),
				),
				const SizedBox(height: 12),
				LayoutBuilder(
					builder: (context, constraints) {
						final crossAxisCount = constraints.maxWidth ~/ 220;
						final count = crossAxisCount < 2 ? 2 : crossAxisCount;
						return GridView.builder(
							shrinkWrap: true,
							physics: const NeverScrollableScrollPhysics(),
							gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
								crossAxisCount: count,
								crossAxisSpacing: 12,
								mainAxisSpacing: 12,
								childAspectRatio: 1.2,
							),
							itemCount: _selectedPhotos.length,
							itemBuilder: (context, index) {
								return _buildPickedPhotoCard(index, _selectedPhotos[index]);
							},
						);
					},
				),
			],
		);
	}

	Widget _buildPickedPhotoCard(int index, Uint8List bytes) {
		return Stack(
			children: [
				Container(
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(14),
						border: Border.all(color: Colors.grey.shade200),
						image: DecorationImage(
							image: MemoryImage(bytes),
							fit: BoxFit.cover,
						),
					),
				),
				Positioned(
					top: 10,
					right: 10,
					child: InkWell(
						onTap: _isSaving ? null : () => _removePickedPhoto(index),
						child: Container(
							padding: const EdgeInsets.all(6),
							decoration: BoxDecoration(
								color: Colors.black54,
								borderRadius: BorderRadius.circular(20),
							),
							child: const Icon(Icons.close, color: Colors.white, size: 18),
						),
					),
				),
			],
		);
	}
}
