import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerDashboardHeader extends StatelessWidget {
  const OwnerDashboardHeader({
    super.key,
    required this.selectedIndex,
    required this.tabs,
    required this.loadingProfile,
    required this.storeName,
    required this.email,
    required this.photoUrl,
    required this.onTabSelected,
    required this.onEditProfile,
    required this.onLogout,
  });

  final int selectedIndex;
  final List<String> tabs;
  final bool loadingProfile;
  final String storeName;
  final String email;
  final String? photoUrl;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  static const _green = Color(0xFF297B2D);
  static const _background = Color(0xFFF5F2ED);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 170,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 66, 16, 0),
          decoration: const BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: Text(
            'Dashboard Toko',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 124,
          child: OwnerStoreCard(
            loading: loadingProfile,
            storeName: storeName,
            email: email,
            photoUrl: photoUrl,
            onEditProfile: onEditProfile,
            onLogout: onLogout,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 246),
          child: Container(
            color: _background,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final selected = selectedIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == tabs.length - 1 ? 0 : 10,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => onTabSelected(index),
                      child: Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? _green : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _green),
                        ),
                        child: Text(
                          tabs[index],
                          style: GoogleFonts.poppins(
                            color: selected ? Colors.white : _green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OwnerStoreCard extends StatelessWidget {
  const OwnerStoreCard({
    super.key,
    required this.loading,
    required this.storeName,
    required this.email,
    required this.photoUrl,
    required this.onEditProfile,
    required this.onLogout,
  });

  final bool loading;
  final String storeName;
  final String email;
  final String? photoUrl;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  static const _green = Color(0xFF297B2D);
  static const _text = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 62,
              height: 62,
              color: const Color(0xFFE9F3EA),
              child: photoUrl == null
                  ? const Icon(Icons.storefront, color: _green, size: 32)
                  : Image.network(
                      photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return const Icon(
                          Icons.storefront,
                          color: _green,
                          size: 32,
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: loading
                ? const LinearProgressIndicator(color: _green)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: _text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF6D6A66),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onEditProfile,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 38),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                backgroundColor: const Color(0xFFEAF6EC),
                                foregroundColor: _green,
                                side: const BorderSide(color: _green),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.account_circle_outlined,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Edit Profile',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onLogout,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 38),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                backgroundColor: const Color(0xFFFFEFEF),
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.logout, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Keluar',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
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
}
