import 'package:flutter/material.dart';

import 'services/user_review_alat_service.dart';
import 'widgets/user_pesanan_widgets.dart';
import 'widgets/user_review_alat_widgets.dart';

class UserReviewAlatPage extends StatefulWidget {
  const UserReviewAlatPage({
    super.key,
    required this.order,
    required this.item,
  });

  final Map<String, dynamic> order;
  final Map<String, dynamic> item;

  @override
  State<UserReviewAlatPage> createState() => _UserReviewAlatPageState();
}

class _UserReviewAlatPageState extends State<UserReviewAlatPage> {
  final _commentController = TextEditingController();
  final _service = UserReviewAlatService();

  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0 || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await _service.submitReview(
        userId: widget.order['user_id'],
        productId: widget.item['product_id'],
        transaksiItemId: widget.item['id_transaksi_item'],
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Review berhasil dikirim')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim review: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _rating > 0 && !_isSubmitting;

    return Scaffold(
      backgroundColor: userPesananBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserReviewHeader(onBack: () => Navigator.pop(context)),
              const SizedBox(height: 28),
              UserReviewProductCard(item: widget.item),
              const SizedBox(height: 28),
              const UserReviewSectionTitle(
                title: 'Rating',
                subtitle: 'Berikan penilaianmu untuk alat ini',
              ),
              const SizedBox(height: 10),
              UserReviewRatingPicker(value: _rating, onChanged: _setRating),
              const SizedBox(height: 30),
              const UserReviewSectionTitle(
                title: 'Komentar',
                subtitle: 'Tulis pengalaman secara jujur dan membantu',
              ),
              const SizedBox(height: 10),
              UserReviewCommentBox(controller: _commentController),
              const SizedBox(height: 34),
              UserReviewPrimaryButton(
                label: _isSubmitting ? 'Mengirim...' : 'Kirim',
                enabled: canSubmit,
                onTap: _submitReview,
              ),
              const SizedBox(height: 12),
              UserReviewSecondaryButton(onTap: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  void _setRating(int value) {
    setState(() => _rating = value);
  }
}
