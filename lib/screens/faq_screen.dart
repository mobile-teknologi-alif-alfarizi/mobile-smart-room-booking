import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_colors.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'Bagaimana cara melakukan booking ruang?',
      'answer':
          'Untuk melakukan booking ruang, buka halaman "Pemesanan Ruang", pilih tanggal dan waktu yang Anda inginkan, lalu pilih ruang yang tersedia. Setelah itu, klik "Konfirmasi Booking" untuk menyelesaikan pemesanan.',
    },
    {
      'question': 'Berapa lama durasi booking maksimal?',
      'answer':
          'Durasi booking maksimal adalah 4 jam per sesi. Namun, Anda dapat melakukan multiple booking untuk durasi yang lebih panjang dengan memilih time slot yang berbeda.',
    },
    {
      'question': 'Bagaimana jika saya ingin membatalkan booking?',
      'answer':
          'Anda dapat membatalkan booking melalui halaman "Riwayat Booking". Klik pada booking yang ingin dibatalkan dan pilih opsi "Batalkan Booking". Pembatalan dapat dilakukan hingga 1 jam sebelum jadwal booking dimulai.',
    },
    {
      'question': 'Bisakah saya mengubah tanggal dan waktu booking?',
      'answer':
          'Ya, Anda dapat mengubah booking dengan membatalkan booking yang lama dan membuat booking baru. Ubah dapat dilakukan melalui halaman "Riwayat Booking".',
    },
    {
      'question': 'Bagaimana jika terjadi masalah saat melakukan booking?',
      'answer':
          'Jika mengalami masalah, pastikan koneksi internet Anda stabil. Coba refresh halaman atau logout dan login kembali. Jika masalah masih berlanjut, hubungi admin melalui fitur Help & Support.',
    },
    {
      'question': 'Apakah ada batasan jumlah booking per hari?',
      'answer':
          'Tidak ada batasan jumlah booking per hari. Namun, setiap time slot hanya dapat digunakan satu kali per pengguna. Pastikan untuk merencanakan schedule booking Anda dengan baik.',
    },
    {
      'question': 'Bagaimana cara mengatur notifikasi booking?',
      'answer':
          'Anda dapat mengatur notifikasi melalui menu "Pengaturan Notifikasi" di halaman Profil. Di sana Anda dapat mengaktifkan atau menonaktifkan berbagai jenis notifikasi termasuk pengingat booking.',
    },
    {
      'question': 'Akses ruang apa saja yang tersedia di aplikasi ini?',
      'answer':
          'Aplikasi ini menyediakan akses ke berbagai ruang termasuk: Kelas, Ruang Meeting, dan Lab Komputer. Ketersediaan ruang dapat berbeda tergantung jadwal dan lokasi kampus.',
    },
  ];

  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        title: Text(
          'FAQ (Pertanyaan Umum)',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Temukan jawaban untuk pertanyaan umum tentang Ruangin',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isMobile ? 20 : 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _faqs.length,
                itemBuilder: (context, index) {
                  final faq = _faqs[index];
                  final isExpanded = _expandedIndex == index;

                  return Container(
                    margin: EdgeInsets.only(
                      bottom: isMobile ? 10 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isExpanded
                            ? AppColors.primary
                            : AppColors.borderLight,
                        width: isExpanded ? 1.5 : 1,
                      ),
                      boxShadow: isExpanded
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _expandedIndex = isExpanded ? null : index;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 14 : 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    faq['question']!,
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                SizedBox(width: isMobile ? 8 : 12),
                                Icon(
                                  isExpanded
                                      ? Icons.expand_less_rounded
                                      : Icons.expand_more_rounded,
                                  color: AppColors.primary,
                                  size: isMobile ? 20 : 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded) ...[
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.borderLight,
                          ),
                          Padding(
                            padding: EdgeInsets.all(isMobile ? 14 : 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primary.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    faq['answer']!,
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 12,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: isMobile ? 20 : 24),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 14 : 16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: isMobile ? 20 : 24,
                    ),
                    SizedBox(width: isMobile ? 10 : 12),
                    Expanded(
                      child: Text(
                        'Tidak menemukan jawaban? Hubungi admin melalui email atau chat support',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 16 : 20),
            ],
          ),
        ),
      ),
    );
  }
}
